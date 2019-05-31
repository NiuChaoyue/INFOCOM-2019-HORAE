%{
@Paper: Making Big Money from Small Sensor: Trading Time-Series Data under
        Pufferfish Privacy, in Proc. of INFOCOM, 2019.       
@Author: Chaoyue Niu
@Email: rvincency@gmail.com
@Function: compute profit ratio (not yet - 1) in the pricing of query, by varying
           the variance of noise v, and using the leading strategy.
%}

clear;

% read transition matrix M from file

%Key fixed parameters
%interval * second
interval = 1;
%length of the selected chain
T = 250;
%Lipschitz
ell = 1;

%Key fixed precomputed results

% variance
variance = 10;

% #test
numTest = 100;

for usr = 1:4
	% time records
	preprocessing_time = 0.0;
	privacy_compensation_time_total = 0.0;
	pricing_time_total = 0.0;
    %read usr i's data
    transMFilename = sprintf('../Preprocess/pa_transM2_interval_%d_usr_%d',interval,usr);
    M = csvread(transMFilename);
    
    %read i's fixed markov quilt sequence (T = 250)  
    markovquiltFilename = sprintf('usr_%d_fixed_markov_quilt',usr);
    fixed_markov_quilt = csvread(markovquiltFilename);
    
    %precomputed intermediate results
    tic;
    [full_downstream, full_upstream1, full_upstream2] = exactRatioMultiGenerate(M, T);
    preprocessing_time = preprocessing_time + toc;
    for test_i = 1:numTest
        %Type 1 Privacy Compensation: Linear
    	tic;
        [compensation_bound1] = privacy_compensation_period(full_downstream, full_upstream1, full_upstream2, T, variance, ell);
        privacy_compensation_time_total = privacy_compensation_time_total + toc;

        %Corresponding price
        tic;
        [pricing_bound] = online_pricing_period(full_downstream, full_upstream1, full_upstream2, T, variance, ell, fixed_markov_quilt);
        pricing_time_total = pricing_time_total + toc;
    end
    fprintf('Data owner %d and Total Query Number %d\n', usr, numTest);
    fprintf('Preprocess time: %f seconds\n', preprocessing_time);
    fprintf('Total time of privacy compensation: %f seconds\n', privacy_compensation_time_total);
    fprintf('Total time of pricing: %f seconds\n', pricing_time_total);
    fprintf('-------------------------------------------------\n');
end