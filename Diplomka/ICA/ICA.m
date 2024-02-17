% Independent Component Analysis (ICA) in MATLAB

clc
clear

% fastICA path
addpath('C:\Program Files\MATLAB\Moje addons\fastICA')

% Step 1: Create two signals
Fs = 1000;                % Sampling Frequency
t = 0:1/Fs:1-1/Fs;        % Time Vector

% Create two sample signals
S1 = sin(2*pi*10*t);      % Sinusoidal signal
S2 = sign(sin(2*pi*15*t));% Square wave signal

% Step 2: Mix the signals
A = [0.6 0.4; 0.4 0.6];  % Mixing matrix
X = A * [S1; S2];         % Mixed signals

% Step 3: ICA to separate the signals
[S_est, A_est, W] = fastica(X);

% Plotting the results
subplot(3,1,1);
plot(t, S1, t, S2);
title('Original Signals');
legend('Signal 1', 'Signal 2');

subplot(3,1,2);
plot(t, X);
title('Mixed Signals');
legend('Mixed 1', 'Mixed 2');

subplot(3,1,3);
plot(t, S_est);
title('Separated Signals by ICA');
legend('Separated 1', 'Separated 2');





