
clc

% fastICA path
addpath('C:\Program Files\MATLAB\Moje addons\fastICA')

% Step 1: Load the data
load('C:\Users\patri\Documents\GitHub\MATLAB\Utoky\Attack_5_v2.mat');

% Step 2: Extract the relevant traffic data array
% Assuming 'a' is your traffic data array
traffic_data = a;

% Step 3: Apply FastICA to the data
% Note: You might need to transpose the data depending on how fastICA expects it
[icasig, A, W] = fastica(traffic_data');

% Step 4: Analyze the independent components (ICs)
% This part is more exploratory and will require you to look at the ICs and
% determine which ones represent the DDoS traffic. You can plot the ICs or
% use other statistical methods to examine them.

% Example: Plot the first independent component
plot(icasig(1, :));
title('Independent Component - Possibly DDoS Traffic');
xlabel('Samples');
ylabel('Signal Strength');

% Repeat the plotting for other components or use other analysis techniques
% to identify the DDoS traffic.

% Step 5: Further analysis as required
% Depending on your findings, you may need to do additional processing or
% filtering based on the characteristics of the DDoS traffic.
