
clear;clc
tic;
addpath('C:\Users\patri\Documents\GitHub\MATLAB\Diplomka\funkcie');


M = load('C:\Users\patri\Documents\GitHub\MATLAB\Utoky\Attack_2_d010.mat');
cely_tok = M.a;
compute_window = 1000;
predict_window = 1000;
pocet_tried_hist = 10;
chi_alfa = 0.05;
sigma_nasobok = 3;
simulacia = "MMRP";
typ_statistiky = "chi";
typ_peaku = "max";
average_multiplier = 0;


data_cw = cely_tok(1:compute_window);

[alfa, beta, n] = MMRP_zisti_alfBet_peakIsMax(data_cw);
gen_data = generate_mmrp(n,length(data_cw),alfa,beta);
gen_prve_cw = sample_generated_data(gen_data, n);

[chi2_stat_array, dolne_hranice, horne_hranice, index_H] = vytvor_autonomny_tunel(cely_tok,gen_prve_cw, compute_window,predict_window,typ_statistiky,chi_alfa,pocet_tried_hist,sigma_nasobok);


%[chi2_stat_array, dolne_hranice, horne_hranice, index_H] = vytvor_autonomny_tunel(data,compute_window,predict_window, simulacia,typ_statistiky,typ_peaku,average_multiplier,chi_alfa,pocet_tried_hist,sigma_nasobok);

figure
chi2_stat_array = chi2_stat_array(1:find(chi2_stat_array, 1, 'last'));
dolne_hranice = dolne_hranice(1:find(dolne_hranice, 1, 'last'));
horne_hranice = horne_hranice(1:find(horne_hranice, 1, 'last'));


N = length(chi2_stat_array);
t =  linspace(compute_window,N+compute_window-1,N);
t2 = linspace(compute_window+predict_window+1,N+compute_window-1,index_H);
t3 = linspace(0,N+compute_window-1,N+compute_window);
plot(t3,0,t,chi2_stat_array,'b',t2,dolne_hranice,'r',t2,horne_hranice,'r')
title("Autonomne riesenie");


elapsedTime = toc;
fprintf('\nElapsed time is %.6f seconds.\n', elapsedTime);
