function [compensation_bound1, pricing_bound] = privacy_compensation_period(downstream, upstream1, upstream2, T, variance, ell, fixed_markov_quilt)

compensation_bound1 =  zeros(1, T);
pricing_bound = zeros(1, T);
pricing_bound_direct = zeros(1, T);

% Considering privacy comepnsation under empty X_M
tmp0 = ell / sqrt(variance / 2);
xi_empty = tmp0 * T;

disp(xi_empty)

for i = 1:T
    %markov quilt set
    as = 1:i-1; % a as row
    bs = [1:T-i]'; % b as col
    
    %max-influence: \phi_Theta(X_M|X_i) grid search
    phi = zeros(length(bs)+1, length(as)+1);
    for j = 1:size(downstream, 2)
        phi = max(phi, [downstream(bs, j); 1] * [upstream1(as, j)*upstream2(i, j); 1]');
    end
    phi = log(phi);
    
    % \ell \times card(X_C)/sqrt(v/2)
    xi0 = (repmat([as, i], length(bs)+1, 1) + repmat([bs; T-i+1], 1, length(as)+1) - 1) .* tmp0;
    
    xi = xi0 + phi; 
    
    % Considering empty X_M
    [compensation_bound1(i), best_idx] = min(xi(:));
    compensation_bound1(i) = min(compensation_bound1(i), xi_empty);
    
    %For pricing use
    pricing_bound(i) = xi(fixed_markov_quilt(2, i), fixed_markov_quilt(1, i));
    
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
    if pricing_bound(i) ~= pricing_bound_direct(i)
        disp('Oh no!')
    end
end