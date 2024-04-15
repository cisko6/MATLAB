
clear;clc
addpath('C:\Users\patri\Documents\GitHub\MATLAB\Diplomka\funkcie');

%M = load("C:\Users\patri\Downloads\a080203.mat");
N = 20;
dlzka_dat = 10000;
alfa = 0.2;
beta = 0.3;
p = 0.8;
chi_alfa = 0.05;
pocet_tried_hist = 10;
pocet_generovanych = dlzka_dat * N;

fprintf("Pôvodné hodnoty:\n");
fprintf("alfa: %.5f\n",alfa);
fprintf("beta: %.5f\n",beta);
fprintf("p:    %.5f\n\n",p);

mmbp_bits = generate_mmbp(N,dlzka_dat, alfa,beta,p);
mmbp_data = sample_generated_data(mmbp_bits, N);

[alfa2, beta2, p2, n] = MMBP_zisti_alfBetP_peakIsMax(mmbp_data, chi_alfa,pocet_tried_hist);

fprintf("Vypočítané z intenzít:\n");
fprintf("alfa cez intenzity: %.5f\n",alfa2);
fprintf("beta cez intenzity: %.5f\n",beta2);
fprintf("p cez intenzity:    %.5f\n\n",p2);

[ET,ET2] = zisti_et_from_bits(mmbp_bits);
[alfa3,beta3,p3] = MMBP_zisti_alfBetP_z_medzier(mmbp_bits,ET,ET2,dlzka_dat,N,chi_alfa,pocet_tried_hist);

fprintf("Vypočítané z medzier:\n");
fprintf("alfa: %.5f\n",alfa3);
fprintf("beta: %.5f\n",beta3);
fprintf("p:    %.5f\n",p3);

% pocet_tried_hist = 3 hups
% PRVY OUTPUT
%alfa je: 0.21273
%beta je: 0.30198
%p je:    0.81794
%priemer: 9.59774

% DRUHY OUTPUT
%alfa cez ET je: 0.22886
%beta cez ET je: 0.30190
%p cez ET je:    0.84247

