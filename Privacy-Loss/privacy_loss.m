%{
@Paper: Making Big Money from Small Sensor: Trading Time-Series Data under
        Pufferfish Privacy, in Proc. of INFOCOM, 2019.       
@Author: Chaoyue Niu
@Email: rvincency@gmail.com
@Function: compute the upper bound of privacy loss 
%}

clear;


%some fixed parameters
T = 720;
ell = 1;
variance = 10;

%other parameters choices
%intervals * second
intervals = [1, 60, 3600];

%outputs
means = zeros(length(intervals), 4);
stds = zeros(length(intervals), 4);

for usr = 1:4
    for inter = 1 : length(intervals)
        interval = intervals(inter);
        % read transition matrix M from file (remove zero rows and columns)
        transMFilename = sprintf('../Preprocess/pa_transM2_interval_%d_usr_%d',interval,usr);
        M = csvread(transMFilename);

        % Compute privacy loss for all timestamps t
        [downstream, upstream1, upstream2] = exactRatioMultiGenerate(M, T);
        [loss_bound, loss_bound_ab, phi] = privacy_loss_t(downstream, upstream1, upstream2, T, variance, ell);

        %mean and standard deviation 
        means(inter, usr) = mean(loss_bound);
        stds(inter, usr) = std(loss_bound);
    end
end