
M = load("C:\Users\patri\Downloads\T.mat");
%M = load("C:\Users\patri\Downloads\T2.mat");
data = M.T;

N = length(data);
ti = diff(data);
ti2 = ti.^2;
ET = sum(ti)/N;
ET2 = sum(ti2)/(N - 1);

% na T.mat ET bolo dobre, a na T2 alfa beta boli zle hodnoty, ktore boli udajne dobre

beta = (2*ET)/(ET2 + ET);
alfa = beta * ET;

fprintf('ET=%.15f\n', ET);
fprintf('ET2=%.15f\n', ET2);
fprintf('MMRP alfa: %.3f\n',alfa);
fprintf('MMRP beta: %.3f\n',beta);


