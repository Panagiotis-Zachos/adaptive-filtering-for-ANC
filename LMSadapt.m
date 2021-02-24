function [yn,en,S] = LMSadapt(un,dn,S)

M = length(S.coeffs);
mu = S.step;
leak = S.leakage;
AdaptStart = S.AdaptStart;
w = S.coeffs;

u = zeros(M,1);
ITER = length(un);
yn = zeros(1,ITER);
en = zeros(1,ITER);

for n = 1:ITER
    u = [un(n); u(1:end-1)];
    yn(n) = w'*u;
    en(n) = dn(n) - yn(n);
    if n >= AdaptStart
        w = (1-mu*leak)*w + (mu*en(n))*u;
        S.iter = S.iter + 1;
    end
end

S.coeffs = w;
end

