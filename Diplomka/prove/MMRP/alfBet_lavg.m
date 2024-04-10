
clear;clc
addpath('C:\Users\patri\Documents\GitHub\MATLAB\Diplomka\funkcie');

alfa = 0.2;
beta = 0.3;
dlzka_dat = 1000000;
N = 20;

mmrp_bits_ideal = generate_mmrp(N,dlzka_dat, alfa,beta);
mmrp_data_ideal = sample_generated_data(mmrp_bits_ideal, N, dlzka_dat);

[alfa_2, beta_2, N_2] = MMRP_zisti_alfBet_peakIsMax(mmrp_data_ideal);

mmrp_bits = generate_mmrp(N_2,dlzka_dat, alfa_2,beta_2);
mmrp_data = sample_generated_data(mmrp_bits, N_2, dlzka_dat);

fprintf("alfa ma byt %.1f, je: %.5f\n",alfa,alfa_2);
fprintf("beta ma byt %.1f, je: %.5f",beta,beta_2);


