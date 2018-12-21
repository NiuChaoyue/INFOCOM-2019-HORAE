%% Compute Two Fixed Parts of Pricing Function in Physical Activity Monitoring
% Input:
%   c:          original chain
%   M:          transition matrix

clear;

%some fixed key parameters
%interval * second
interval = 1;
%length of the selected chain
T = 1000;
variance = 10;
ell = 1;

for usr = 1:4
    % read transition matrix M from file
    %remove zero rows and columns
    transMFilename = sprintf('../Preprocess/pa_transM2_interval_%d_usr_%d',interval,usr);
    M = csvread(transMFilename);

    % Compute two fixed parts for all timestamps t
    [downstream, upstream1, upstream2] = exactRatioMultiGenerate(M, T);
    [two_fixed_parts] = privacy_compensation_fixed(downstream, upstream1, upstream2, T, variance, ell);
    
    twoPartsFilename = sprintf('T_%d_usr_%d_two_fixed_parts', T, usr);
    dlmwrite(twoPartsFilename,two_fixed_parts,'newline','pc');
end