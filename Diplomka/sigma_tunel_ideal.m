
clear;clc
tic;
addpath('C:\Users\patri\Documents\GitHub\MATLAB\Diplomka\funkcie');


M = load('C:\Users\patri\Documents\GitHub\MATLAB\Utoky\Attack_3_d010.mat');
data = M.a;
compute_window = 1000;
predict_window = 1000;
pocet_tried_hist = 10;
chi_alfa = 0.05;
sigma_nasobok = 3;


data_mmrp = data(1:compute_window);
[alfa, beta, n] = MMRP_zisti_alfBet_peakIsMax(data_mmrp);
gen_data = generate_mmrp(n,length(data_mmrp),alfa,beta);
gen_sampled = sample_generated_data(gen_data, n, length(data_mmrp));

% počítanie chi štatistiky
chi2_stat_array = zeros(1,length(data)-predict_window);
for u=1:9999999

    from = u + compute_window;
    to = from + compute_window - 1;
    try
        cast_dat = data(from:to);
    catch
        break
    end

    [chi2_stat] = chi_square_test(cast_dat,gen_sampled,chi_alfa,pocet_tried_hist);
    chi2_stat_array(u) = chi2_stat;
end
chi2_stat_array = chi2_stat_array(1:find(chi2_stat_array, 1, 'last'));

[dH_ideal, hH_ideal, N] = vytvor_tunel(chi2_stat_array,sigma_nasobok,predict_window);


figure
t = linspace(compute_window,N+predict_window+compute_window-1,N);
t2 = linspace(compute_window+predict_window+1,N+predict_window+compute_window-1,N-predict_window);
t3 = linspace(0,N+compute_window-1,N+compute_window);
plot(t3,0,t,chi2_stat_array,'b',t2,dH_ideal,'r',t2,hH_ideal,'r')
title("Ideal");



elapsedTime = toc;
fprintf('\nElapsed time is %.6f seconds.\n', elapsedTime);
