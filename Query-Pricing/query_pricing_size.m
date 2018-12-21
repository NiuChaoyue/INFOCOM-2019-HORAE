%{
@Paper: Making Big Money from Small Sensor: Trading Time-Series Data under
        Pufferfish Privacy, in Proc. of INFOCOM, 2019.       
@Author: Chaoyue Niu
@Email: rvincency@gmail.com
@Function: compute profit ratio (not yet - 1) in the pricing of query, by varying 
           the size of queried states T, and using the randomized strategy.
%}

clear;

% read transition matrix M from file

%Key fixed parameters
%interval * second
interval = 1;
%Lipschitz
ell = 1;
%variances
variance = 10;

% set of the sizes of queried states 
lens = [100,100];

% set of profit ratios
profit_ratio_1 = zeros(length(lens),4);
profit_ratio_2 = zeros(length(lens),4);

for usr = 1:1
    %read usr i's data
    transMFilename = sprintf('../Preprocess/pa_transM2_interval_%d_usr_%d',interval,usr);
    M = csvread(transMFilename);
    
    for i = 1:length(lens)
        T = lens(i);
        
        %precomputed intermediate results
        [full_downstream, full_upstream1, full_upstream2] = exactRatioMultiGenerate(M, T);
        %use all (1, 1) Markov quilt
        [compensation_bound1, pricing_bound] = privacy_compensation_size(full_downstream, full_upstream1, full_upstream2, T, variance, ell);
       
        % Profit Ratio Under Type 1 Privacy Compensation: Linear
        total_privacy_compensation1 = sum(compensation_bound1);
        price1 = sum(pricing_bound);
        profit_ratio_1(i, usr) = price1/total_privacy_compensation1;

        % Profit Ratio Under Type 2 Privacy Compensation: tanh
        parad = min(1/max(compensation_bound1), 1/max(pricing_bound));
        tmp_pc = tanh(parad .* compensation_bound1);
        total_privacy_compensation2 = sum(tmp_pc);

        tmp_qp = tanh(parad .* pricing_bound);
        price2 = sum(tmp_qp);
        profit_ratio_2(i, usr) = price2/total_privacy_compensation2;
    end 
end