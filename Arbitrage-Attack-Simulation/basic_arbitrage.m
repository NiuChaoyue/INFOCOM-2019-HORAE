%{
@Paper: Making Big Money from Small Sensor: Trading Time-Series Data under
        Pufferfish Privacy, in Proc. of INFOCOM, 2019.       
@Author: Chaoyue Niu
@Email: rvincency@gmail.com
@Function: simulate arbitrage attack in the basic pricing functions.
%}

clear;
%some expermental parameters 
v = 10;
m = 100;
simNum = 200;

%some fixed system parameters
%ell, interval 
ell = 1;
interval = 1;

%length of selected chain 
T = 100;

%whether apply tanh function
boundflag = 0;

%record simulation results (percentage)
resPercentage = zeros(101,4);

for usr = 4:4
    %read usr i's data
    transMFilename = sprintf('../Preprocess/pa_transM2_interval_%d_usr_%d',interval,usr);
    M = csvread(transMFilename);
    
    %precomputed intermediate results
    [downstream, upstream1, upstream2] = exactRatioMultiGenerate(M, T);
    
    for sim = 1:simNum
        %vl \in (v, (m^2 - m + 1) * v)
        vecVl = v + (m^2 - m) * v .* rand(m, 1);
        tmp = (m^2 * v) / sum(vecVl);
        vecVl = vecVl .* tmp;
        
        %price for v and attack cost for vl
        price = basic_pricing(downstream, upstream1, upstream2, T, v, ell, boundflag);
        attackCost = 0.0;
        for l = 1:m
            attackCost = attackCost + basic_pricing(downstream, upstream1, upstream2, T, vecVl(l), ell, boundflag);
        end
        
        %ratio between attack cost and original price
        ratio = attackCost/price;
        if ratio < 1
            resPercentage(101,usr) = resPercentage(101, usr) + 1/simNum;
        else
            resPercentage(floor(ratio),usr) = resPercentage(floor(ratio),usr) + 1/simNum;
        end
        
        disp(sim);
    end   
end