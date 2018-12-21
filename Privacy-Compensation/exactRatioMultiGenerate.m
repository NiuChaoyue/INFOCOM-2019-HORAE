function [downstream, upstream1, upstream2] = exactRatioMultiGenerate(M, T, c0, c1)
% downstream: length T-1 vector. downstream(b): max_{x_{i+b}} P(x_{i+b} | X_i = 0)/P(x_{i+b} | X_i = 1) (this is the same for all i)
% upstream_1: length T-1 vector. upstream_1(a): max_{x_{i-a}} P(X_i = 0 | x_{i-a})/P(X_i = 1 | x_{i-a}) (this is the same for all i)
% upstream_2: length T vector.   upstream_2(i): P(X_i=1)/P(X_i=0) (different for different i)

nState = size(M, 1);

Mpower = zeros(nState, nState, T-1); Mpower(:,:,1) = M;
for i = 2:T-1
    Mpower(:,:,i) = M*Mpower(:,:,i-1);
end

% % downstream
% downstream = [permute(max(Mpower(1,:,:)./Mpower(2,:,:), [], 2), [3, 1, 2]), ...
%     permute(min(Mpower(1,:,:)./Mpower(2,:,:), [], 2), [3, 1, 2])];
% 
% % downstream is nState*nState*(T-1)
% downstream = ones(nState, nState, T-1);
% for s = 1:nState
%     for t = s+1:nState
%         tmp = Mpower(s,:,:)./Mpower(t,:,:);
%         downstream(s, t, :) = max(tmp, [], 2);
%         downstream(t, s, :) = 1./min(tmp, [], 2);
%     end
% end

% downstream is (T-1)*nState^2
downstream = ones(T-1, nState^2);
for s = 1:nState
    for t = s+1:nState
        tmp = Mpower(s,:,:)./Mpower(t,:,:);
        downstream(:, (s-1)*nState+t) = permute(max(tmp, [], 2), [3,1,2]);
        downstream(:, (t-1)*nState+s) = 1./permute(min(tmp, [], 2), [3,1,2]);
    end
end

% % upstream
% upstream1 = [permute(max(Mpower(:,1,:)./Mpower(:,2,:), [], 1), [3, 1, 2]), ...
%     permute(min(Mpower(:,1,:)./Mpower(:,2,:), [], 1), [3, 1, 2])];

% upstream is (T-1)*nState^2
upstream1 = ones(T-1, nState^2); upstream2 = upstream1;
for s = 1:nState
    upstream1(:, (s-1)*nState+s) = ones(T-1, 1);
    for t = s+1:nState
        tmp = Mpower(:,s,:)./Mpower(:,t,:);
        upstream1(:, (s-1)*nState+t) = permute(max(tmp, [], 1), [3,1,2]);
        upstream1(:, (t-1)*nState+s) = 1./permute(min(tmp, [], 1), [3,1,2]);
        
        upstream2(:, (s-1)*nState+t) = upstream1(:, (t-1)*nState+s);
        upstream2(:, (t-1)*nState+s) = upstream1(:, (s-1)*nState+t);
    end
end

if nargin == 4 % given fixed c0, c1
    upstream2 = repmat(c1./c0, 1, 2);
elseif nargin == 2 % take max c0, c1
    %     upstream2 = [1./upstream1(:,2), 1./upstream1(:,1)];
    upstream2 = [nan(1,nState^2); upstream2];
else
    error('exactRatioBinaryGenerate input formate error')
end

