
clear;clc
addpath('C:\Users\patri\Documents\GitHub\MATLAB\Diplomka\funkcie');

M = load("C:\Users\patri\Downloads\a100203.mat");

mmrp_bits = generate_mmrp(M.NN,M.Mx, M.alf,M.bet);
mmrp_data = sample_generated_data(mmrp_bits, M.NN, 1000000);

[alfa, beta, n] = MMRP_zisti_alfBet_peakIsMax(mmrp_data);

fprintf("alfa je: %.5f\n",alfa);
fprintf("beta je: %.5f\n",beta);
fprintf("priemer: %.5f\n\n",mean(mmrp_data));

[ET,ET2] = zisti_et_from_bits(M.ab);
beta2 = 2*ET/(ET2 + ET);
alfa2 = beta2 * ET;

fprintf("alfa cez ET je: %.5f\n",alfa2);
fprintf("beta cez ET je: %.5f\n",beta2);
