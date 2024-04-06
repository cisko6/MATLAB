
clear;clc

keep_frequencies = 3;
load("C:\Users\patri\Desktop\mat subory\Attack_2_d005.mat")

N = 1000;
a = a(1:N);
t = linspace(1,N,N);

[fourier_data, ca] = fourier_smooth(a, keep_frequencies);

figure
plot(t,a,t,ca)
title("t,a")

figure
plot(t,fourier_data)
title("t,y")



function [fourier_data, y_final] = fourier_smooth(data, keep_frequencies)
    
    N = length(data);
    t = linspace(1,N,N);

    % fft
    c =fft(data)./N;
    c(1)=0;
    ca = abs(c);
    
    % zisti najvacsie indexy
    c_pom = c(1:length(c)/2);
    biggest_indexes = zeros(1, keep_frequencies);
    for i = 1:keep_frequencies
        [~, index] = max(c_pom);
        biggest_indexes(i) = index;
        c_pom(index) = 0;
    end
    
    % ponechaj iba par frekvencii
    y_pom = 0;
    for i = 1:keep_frequencies
        y_final = y_pom + 2*real(c(biggest_indexes(i)))*cos((biggest_indexes(i)-1)*t*2*pi/N)-2*imag(c(biggest_indexes(i)))*sin((biggest_indexes(i)-1)*t*2*pi/N)+c(1);
        y_pom = y_final;
    end
    
    fourier_data = data-y_final;
    y_final = y_final+mean(data);
end




