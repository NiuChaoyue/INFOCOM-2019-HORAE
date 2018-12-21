%{
@Paper: Making Big Money from Small Sensor: Trading Time-Series Data under
        Pufferfish Privacy, in Proc. of INFOCOM, 2019.       
@Author: Chaoyue Niu
@Email: rvincency@gmail.com
@Function: preprocess ARAS dataset, and generate Markov chains.
%}

clear;

%read data
fullchains = ones(86400 * 30,4);
for house = 1:2
    for day = 1:30
        tmpfilename = sprintf('./House_%d/DAY_%d.txt',house,day);
        tmpdata = load(tmpfilename);
        %Resident 1 in house
        fullchains((day - 1) * 86400 + 1:day * 86400, 2 * house - 1) = tmpdata(:,21);
        %Resident 2 in house
        fullchains((day - 1) * 86400 + 1:day * 86400, 2 * house) = tmpdata(:,22);
    end
end

%some key parameters
%interval * second
interval = 10000;
%number of states 
num_states = 27;

for usr = 1:4
    chain = fullchains(:,usr);
    T = length(chain);
    %calculate transition matrix
    recordStates = zeros(num_states,num_states);
    transM = zeros(num_states,num_states);
        
    for t = 1 : T - interval
        cur = chain(t);
        nex = chain(t + interval);
        recordStates(cur, nex) = recordStates(cur, nex) + 1;
    end
    
    for t = 1 : num_states
        if sum(recordStates(t,:)) ~= 0
            for nex = 1 : num_states
                transM(t, nex) = recordStates(t, nex)/(sum(recordStates(t,:)));
            end
        end
    end
       
    %save 30 days chain (with interval start at 1), and corresponding matrix
    chainFilename = sprintf('pa_chain_interval_%d_usr_%d',interval,usr);
    dlmwrite(chainFilename,chain(1:interval:T),'newline','pc');
        
    transMFilename = sprintf('pa_transM_interval_%d_usr_%d',interval,usr);
    dlmwrite(transMFilename,transM,'newline','pc');
    
    %delete all zero row and column
    transM2 = transM;
    if all(all(transM2 == 0, 2) == all(transM2 == 0, 1)') == 1
        %delete zero row
        transM2(all(transM2 == 0, 2),:) = [];
        %delete zero column
        transM2(:,all(transM2 == 0, 1)) = [];
    end
    
    transM2Filename = sprintf('pa_transM2_interval_%d_usr_%d',interval,usr);
    dlmwrite(transM2Filename,transM2,'newline','pc');
end