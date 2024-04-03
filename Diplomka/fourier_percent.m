
%clc; clear;

% Parameters
n = 10;
p = 0.5;
N = 1000;
a = binornd(n, p, 1, N);

percent_to_keep_fft = 0.1;

[fourier_output, ca]=fourier_transform(a, percent_to_keep_fft);

subplot(3,1,1);
plot(a);
title('Original Signal + Vysledny signal');
xlabel('Time');
ylabel('Amplitude');
hold on
plot(fourier_output,'LineWidth',1)

subplot(3,1,2);
plot(ca);
title('Amplitude spectrum');
xlabel('Frequency');
ylabel('Amplitude');

subplot(3,1,3);
plot(abs(fourier_output-a));
title('Rozdiel');
xlabel('Time');
ylabel('Amplitude');


function [fourier_output, ca, c] = fourier_transform(data, percent_to_keep_fft)
    N = length(data);
    
    c = fft(data) / N;
    ca = abs(c);
    ca(1) = 0;
    
    smooth_range = round(length(c) * percent_to_keep_fft / 2);
    smooth_range = max(smooth_range, 1);
    
    c(smooth_range+2:end-smooth_range) = 0;
    
    fourier_output = ifft(c) * N;
end
