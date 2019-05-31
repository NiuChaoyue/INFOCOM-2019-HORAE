%{
@Paper: Making Big Money from Small Sensor: Trading Time-Series Data under
        Pufferfish Privacy, in Proc. of INFOCOM, 2019.       
@Author: Chaoyue Niu
@Email: rvincency@gmail.com
@Function: compute unbounded/bounded and valid privacy compensation.
%}

clear;

% read transition matrix M from file

%some key parameters
%interval * second
interval = 1;
%index of user
usr = 4;

chainFilename = sprintf('../Preprocess/pa_chain_interval_%d_usr_%d',interval,usr);        
%remove zero rows and columns
transMFilename = sprintf('../Preprocess/pa_transM2_interval_%d_usr_%d',interval,usr);

fullchain = csvread(chainFilename);
%length of the selected chain
T = 720;

M = csvread(transMFilename);

% Compute privacy loss for all timestamps t
ell = 1;
variance = 10;
[full_downstream, full_upstream1, full_upstream2] = exactRatioMultiGenerate(M, T);
[compensation_bound1, compensation_bound1_ab, phi] = privacy_compensation_t(full_downstream, full_upstream1, full_upstream2, T, variance, ell);


total_privacy_compensation = 10.0 * T;

% Type 1 Privacy Compensation: Linear
total_privacy_loss1 = sum(compensation_bound1);
percent_privacy_compensation1 = zeros(40, 1);
for t = 1:T
    tmp_pc1 = compensation_bound1(t) / total_privacy_loss1 * total_privacy_compensation;
    % 1: 1, 2: 1.5, 3: 2 ...  2k - 1
    index = floor(tmp_pc1 * 2.0 - 1.0);
    index = min(index, 40);
    percent_privacy_compensation1(index) = percent_privacy_compensation1(index) + 1 / T;
end

% Type 2 Privacy Compensation: tanh
parad = 1/max(compensation_bound1);
compensation_bound2 = tanh(parad .* compensation_bound1);
total_privacy_loss2 = sum(compensation_bound2);
percent_privacy_compensation2 = zeros(40, 1);
for t = 1:T
    tmp_pc2 = compensation_bound2(t) / total_privacy_loss2 * total_privacy_compensation;
    % 1: 1, 2: 1.5, 3: 2 ...  2k - 1
    index = floor(tmp_pc2 * 2.0 - 1.0);
    index = min(index, 40);
    percent_privacy_compensation2(index) = percent_privacy_compensation2(index) + 1 / T;
end