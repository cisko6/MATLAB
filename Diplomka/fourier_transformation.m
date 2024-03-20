
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

smooth_range = 100;
c(smooth_range+2:end-smooth_range) = 0;

y = ifft(c) * N;

subplot(3,1,1);
plot(a);
title('Original Signal');
xlabel('Time');
ylabel('Amplitude');

subplot(3,1,2);
plot(ca);
title('Amplitude spectrum');
xlabel('Frequency');
ylabel('Amplitude');

subplot(3,1,3);
plot(y);
title('Smoothed Signal');
xlabel('Time');
ylabel('Amplitude');
