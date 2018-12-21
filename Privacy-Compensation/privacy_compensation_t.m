function [compensation_bound1, compensation_bound1_ab, phi] = privacy_compensation_t(downstream, upstream1, upstream2, T, variance, ell)

compensation_bound1 =  zeros(1, T);
compensation_bound1_ab =  zeros(2, T);

% Considering privacy compensation under empty X_M
tmp0 = ell / sqrt(variance / 2);
xi_empty = tmp0 * T;

%disp(xi_empty)

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
    
    [compensation_bound1(i), best_idx] = min(xi(:));
    [compensation_bound1_ab(2, i), compensation_bound1_ab(1, i)] = ind2sub(size(xi), best_idx);
    
    % Considering empty X_M
    compensation_bound1(i) = min(compensation_bound1(i), xi_empty);
end