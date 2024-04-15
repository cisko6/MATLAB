
clear;clc
addpath('C:\Users\patri\Documents\GitHub\MATLAB\Diplomka\funkcie');

alfa = 0.2;
beta = 0.3;
p = 0.8;
dlzka_dat = 1000000;
N = 20;
chi_alfa = 0.05;
pocet_tried_hist = 20;

mmbp_bits_ideal = generate_mmbp(N,dlzka_dat, alfa,beta,p);
mmbp_data_ideal = sample_generated_data(mmbp_bits_ideal, N, dlzka_dat);

[alfa_2, beta_2, p_2, N_2] = MMBP_zisti_alfBetP_peakIsMax(mmbp_data_ideal, chi_alfa, pocet_tried_hist);

mmbp_bits = generate_mmbp(N_2,dlzka_dat, alfa_2,beta_2,p_2);
mmbp_data = sample_generated_data(mmbp_bits, N_2, dlzka_dat);

fprintf("alfa ma byt %.1f, je: %.5f\n",alfa,alfa_2);
fprintf("beta ma byt %.1f, je: %.5f",beta,beta_2);
fprintf("p ma byt    %.1f, je: %.5f",p,p_2);

% OUTPUT pri 1000000 dlzka dat - trvalo to mega dlho
%alfa ma byt 0.2, je: 0.19823
%beta ma byt 0.3, je: 0.30037
%p ma byt    0.8, je: 0.79707



