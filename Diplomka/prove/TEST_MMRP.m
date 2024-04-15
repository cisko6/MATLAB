
clear;clc
addpath('C:\Users\patri\Documents\GitHub\MATLAB\Diplomka\funkcie');

N = 20;
pocet_generovanych = 10000;
alfa = 0.3;
beta = 0.4;

fprintf("Pôvodné hodnoty:\n");
fprintf("alfa: %.5f\n",alfa);
fprintf("beta: %.5f\n\n",beta);

mmrp_bits = generate_mmrp(N,pocet_generovanych,alfa, beta);
mmrp_data = sample_generated_data(mmrp_bits, N);
[alfa2, beta2, N] = MMRP_zisti_alfBet_peakIsMax(mmrp_data);

fprintf("Vypočítané z intenzít:\n");
fprintf("alfa cez intenzity: %.5f\n",alfa2);
fprintf("beta cez intenzity: %.5f\n\n",beta2);

[ET,ET2] = zisti_et_from_bits(mmrp_bits);
beta3 = 2*ET/(ET2 + ET);
alfa3 = beta3 * ET;

fprintf("Vypočítané z medzier:\n");
fprintf("alfa: %.5f\n",alfa3);
fprintf("beta: %.5f\n\n",beta3);
