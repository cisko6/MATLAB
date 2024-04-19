
clear;clc

addpath('C:\Users\patri\Documents\GitHub\MATLAB\Diplomka\funkcie');

%M = load("C:\Users\patri\Downloads\Z1_d_100000.mat");
%slot_window = 100000;
M = load("C:\Users\patri\Downloads\Z2_d_10000.mat");
vsetky_medzery = M.T;
vsetky_medzery = vsetky_medzery';

slot_window = 10000;
compute_window = 1000;

vsetky_medzery = M.T;
vsetky_medzery = vsetky_medzery';

%vzorkovanie inak - mozno lepsie
%edges = 0:slot_window:max(vsetky_medzery)+slot_window;
%[sampled_data, ~] = histcounts(vsetky_medzery, edges);

sampled_data = cumulatedSpaces_to_casy(vsetky_medzery, slot_window);
casy_cw = sampled_data(1:compute_window);

figure
plot(casy_cw);
xlim([0 length(casy_cw)])
title("Cez casy");

%%%%%%%%%%%%%%%%%%%
index = find(vsetky_medzery < slot_window*compute_window, 1, 'last');
medzery = vsetky_medzery(1:index);
medzery_cw = cumulatedSpaces_to_casy(medzery, slot_window);


figure
plot(medzery_cw);
xlim([0 length(medzery_cw)])
title("Cez medzery");


N = length(medzery);
ti = diff(medzery);
ti2 = ti.^2;
ET = sum(ti)/N;
ET2 = sum(ti2)/(N - 1);


fprintf("ET=%f\n",ET);
fprintf("ET2=%f\n\n",ET2);

beta = (2*ET)/(ET2+ET);
alfa = beta * ET;

fprintf("alfa=%f\n",alfa);
fprintf("beta=%f\n",beta);
fprintf("ET vypocet cez alfa beta=%f\n",alfa/beta);
fprintf("ET2 vypocet cez alfa beta=%f\n\n",(alfa/(beta)^2)*(2 - beta));

[mmrp_data] = generate_mmrp(max(casy_cw),length(medzery_cw), alfa,beta);
[sampled_mmrp] = sample_generated_data(mmrp_data, max(casy_cw));

figure
plot(sampled_mmrp);
xlim([0 length(sampled_mmrp)])
title("sampled_mmrp");




