function [price] = advanced_pricing(two_fixed_parts, variance, boundflag)
paramd = 0.01;
if boundflag == 0
    price = sum(two_fixed_parts(1,:)./sqrt(variance/2)) + sum(two_fixed_parts(2,:));
else
    tmp_price = two_fixed_parts(1,:)./sqrt(variance/2) + two_fixed_parts(2,:);
    price = sum(tanh(tmp_price .* paramd));
end