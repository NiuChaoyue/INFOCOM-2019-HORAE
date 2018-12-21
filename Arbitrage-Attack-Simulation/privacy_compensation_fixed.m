function [two_fixed_parts] = privacy_compensation_fixed(downstream, upstream1, upstream2, T, variance, ell)

two_fixed_parts =  zeros(2, T);

% Considering privacy comepnsation under empty X_M
tmp0 = ell / sqrt(variance / 2);
xi_empty = tmp0 * T;

disp(xi_empty);

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
    
    [privacy_loss_bound, best_idx] = min(xi(:));
    if privacy_loss_bound > xi_empty
        privacy_loss_bound = xi_empty;
        two_fixed_parts(1, i) = ell * T;
        two_fixed_parts(2, i) = 0;
    else
        [index1, index2] = ind2sub(size(xi), best_idx);
        two_fixed_parts(1, i) = xi0(index1, index2) * sqrt(variance/2);
        two_fixed_parts(2, i) = phi(index1, index2);
    end
    
    %check whether this parts are correctly computed
    gap = two_fixed_parts(1, i) / sqrt(variance/2) + two_fixed_parts(2, i) - privacy_loss_bound;
    if gap ~= 0
        disp(gap);
    end
end