function [price] = basic_pricing(downstream, upstream1, upstream2, T, variance, ell, boundflag)
%for bounded tanh function
paramd = 0.01;

[compensation_bound1] = privacy_compensation_t(downstream, upstream1, upstream2, T, variance, ell);

% bounded pricing function 
if boundflag == 0
    price = sum(compensation_bound1);
else
    tmp_pc = tanh(paramd .* compensation_bound1);
    price = sum(tmp_pc);
end
