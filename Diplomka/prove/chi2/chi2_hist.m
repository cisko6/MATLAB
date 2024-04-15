
clear;clc
addpath('C:\Users\patri\Documents\GitHub\MATLAB\Diplomka\funkcie');

pocet_tried_hist = 36;
compute_window = 1000;
chi_alfa = 0.05;

file_path = "C:\Users\patri\Desktop\mat subory\Attack_2_d005.mat";
M = load(file_path);
cely_tok = M.a;
data = cely_tok(1:compute_window);
%{
figure
plot(data)
figure
histogram(data,pocet_tried_hist);
[h] = hist(data,pocet_tried_hist);
%}

[alfa, beta, n] = MMRP_zisti_alfBet_peakIsMax(data);
gen_data = generate_mmrp(n,length(data),alfa,beta);
gen_sampled = sample_generated_data(gen_data, n);


% y pre histogramy
ylim_hist = max( ...
            max(histcounts(data, 'Normalization', 'probability')), ...
            max(histcounts(gen_sampled, 'Normalization', 'probability')));

if ylim_hist <= 0.1
    ylim_hist = ylim_hist + 0.01;
elseif ylim_hist > 0.1 && ylim_hist < 0.5
    ylim_hist = ylim_hist + 0.05;
else
    ylim_hist = ylim_hist + 0.2;
end

figure
aa = histogram(data,'NumBins',pocet_tried_hist);
[data_h] = hist(data,pocet_tried_hist);
title("data");


figure
bb = histogram(gen_sampled,'NumBins',pocet_tried_hist);
[gen_h] = hist(gen_sampled,pocet_tried_hist);
title("gen_sampled");


[chi2_stat] = chi_square_test(data,gen_sampled,chi_alfa,pocet_tried_hist);
fprintf("chi štatistika: %f\n",chi2_stat);






