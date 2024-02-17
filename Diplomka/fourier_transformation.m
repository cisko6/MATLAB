
% Parameters
n = 10;
p = 0.5;
N = 1000;

% Generate binomial random numbers
a = binornd(n, p, 1, N);

% Fourier transform
c = fft(a) / N;
ca = abs(c);
ca(1) = 0;

y = ifft(c) * N;

subplot(3,1,1);
plot(a);
title('Originalny signal');
xlabel('Cas');
ylabel('Amplituda');

subplot(3,1,2);
plot(ca);
title('Fourierova Transformacia');
xlabel('Frekvencia');
ylabel('Amplituda');

subplot(3,1,3);
plot(y);
title('Vyhladeny signal');
xlabel('Cas');
ylabel('Amplituda');
