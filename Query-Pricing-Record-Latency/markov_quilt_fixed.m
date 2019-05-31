%% Compute Privacy Compensation on Physical Activity Monitoring
% leading strategy
% Input:
%   c:          original chain
%   M:          transition matrix

clear;

% read transition matrix M from file

%some key parameters
%interval * second
interval = 1;
%Lipschitz parameter
ell = 1;
%variance of noise
variance = 10;
%length of the selected chain
T = 250;


for usr = 1:4
	chainFilename = sprintf('../Preprocess/pa_chain_interval_%d_usr_%d',interval,usr);        
	%remove zero rows and columns
	transMFilename = sprintf('../Preprocess/pa_transM2_interval_%d_usr_%d',interval,usr);

	fullchain = csvread(chainFilename);

	M = csvread(transMFilename);

	% Compute privacy loss for all timestamps t
	
	[full_downstream, full_upstream1, full_upstream2] = exactRatioMultiGenerate(M, T);
	[compensation_bound1, compensation_bound1_ab, phi] = privacy_compensation_fixed(full_downstream, full_upstream1, full_upstream2, T, variance, ell);

	markovquiltFilename = sprintf('usr_%d_fixed_markov_quilt',usr);
	dlmwrite(markovquiltFilename,compensation_bound1_ab,'newline','pc');
end