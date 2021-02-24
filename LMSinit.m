function S = LMSinit(w0,mu,leak)

if nargin < 3
leak = 0;
end

S.coeffs = w0(:);
S.step = mu;
S.leakage = leak;
S.iter = 0;
S.AdaptStart = length(w0);
end

