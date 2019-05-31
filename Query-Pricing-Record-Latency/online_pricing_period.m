function [pricing_bound_direct] = online_pricing_period(downstream, upstream1, upstream2, T, variance, ell, fixed_markov_quilt)

pricing_bound_direct = zeros(1, T);

% Considering privacy comepnsation under empty X_M
tmp0 = ell / sqrt(variance / 2);

for i = 1:T

    %For online latency, i.e., computing price directly
    
    price_phi_direct = 0;
    for j = 1:size(downstream, 2)
        pp0 = 1;
        pp1 = 1;
        if fixed_markov_quilt(2, i) <= T - i
            pp0 = downstream(fixed_markov_quilt(2, i), j);
        end 
        if fixed_markov_quilt(1, i) <= i - 1
            pp1 = upstream1(fixed_markov_quilt(1, i), j) * upstream2(i, j);
        end
        price_phi_direct = max(price_phi_direct, pp0 * pp1);
    end
    price_phi_direct = log(price_phi_direct);
    pp2 = i;
    pp3 = T - i + 1;
    if fixed_markov_quilt(1, i) <= i - 1
        pp2 = fixed_markov_quilt(1, i);
    end 
    if fixed_markov_quilt(2, i) <= T - i
        pp3 = fixed_markov_quilt(2, i);
    end
    price_xi0_direct = (pp2 + pp3 - 1) * tmp0;
    pricing_bound_direct(i) = price_xi0_direct + price_phi_direct;
end