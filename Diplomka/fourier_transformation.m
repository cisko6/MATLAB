
clc; clear;

% Parameters
n = 10;
p = 0.5;
N = 1000;
a = binornd(n, p, 1, N);

% Fourier transform
c = fft(a) / N;
ca = abs(c);
ca(1) = 0;

smooth_range = length(a) * 0.025; %length(a)/40 je 25;
c(smooth_range+2:end-smooth_range) = 0;

y = ifft(c) * N;

subplot(3,1,1);
plot(a);
title('Original Signal + Vysledny signal');
xlabel('Time');
ylabel('Amplitude');
hold on
plot(y,'LineWidth',1)

subplot(3,1,2);
plot(ca);
title('Amplitude spectrum');
xlabel('Frequency');
ylabel('Amplitude');

subplot(3,1,3);
plot(abs(y-a));
title('Rozdiel');
xlabel('Time');
ylabel('Amplitude');
