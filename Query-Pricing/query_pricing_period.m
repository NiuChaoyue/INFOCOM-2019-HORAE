%{
@Paper: Making Big Money from Small Sensor: Trading Time-Series Data under
        Pufferfish Privacy, in Proc. of INFOCOM, 2019.       
@Author: Chaoyue Niu
@Email: rvincency@gmail.com
@Function: compute profit ratio (not yet - 1) in the pricing of query, by varying 
           the sampling period, and using the leading strategy.
%}

clear;

% read transition matrix M from file

%some key parameters
%interval * second
interval = 10000;
%index of user
usr = 2;

chainFilename = sprintf('../Preprocess/pa_chain_interval_%d_usr_%d',interval,usr);        
%remove zero rows and columns
transMFilename = sprintf('../Preprocess/pa_transM2_interval_%d_usr_%d',interval,usr);

fullchain = csvread(chainFilename);
%length of the selected chain
T = 250;

M = csvread(transMFilename);

%read fixed markov quilt sequence (T = 250)
markovquiltFilename = sprintf('usr_%d_fixed_markov_quilt',usr);
fixed_markov_quilt = csvread(markovquiltFilename);

% Compute privacy loss for all timestamps t
ell = 1;
variance = 10;
[full_downstream, full_upstream1, full_upstream2] = exactRatioMultiGenerate(M, T);
[compensation_bound1, pricing_bound] = privacy_compensation_period(full_downstream, full_upstream1, full_upstream2, T, variance, ell, fixed_markov_quilt);


% Profit Ratio Under Type 1 Privacy Compensation: Linear
total_privacy_compensation1 = sum(compensation_bound1);
price1 = sum(pricing_bound);
profit_ratio_1 = price1/total_privacy_compensation1;


% Profit Ratio Under Type 2 Privacy Compensation: tanh
parad = min(1/max(compensation_bound1), 1/max(pricing_bound));
tmp_pc = tanh(parad .* compensation_bound1);
total_privacy_compensation2 = sum(tmp_pc);

tmp_qp = tanh(parad .* pricing_bound);
price2 = sum(tmp_qp);
profit_ratio_2 = price2/total_privacy_compensation2;