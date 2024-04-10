
clear;clc
addpath('C:\Users\patri\Documents\GitHub\MATLAB\Diplomka\funkcie');

M = load("C:\Users\patri\Downloads\a080203.mat");
chi_alfa = 0.05;
pocet_tried_hist = 10;

mmbp_bits = generate_mmbp(M.NN,M.Mx, M.alf,M.bet,M.p);
mmbp_data = sample_generated_data(mmbp_bits, M.NN, M.Mx);

[alfa, beta, p, n] = MMBP_zisti_alfBetP_peakIsMax(mmbp_data, chi_alfa,pocet_tried_hist);

fprintf("alfa je: %.5f\n",alfa);
fprintf("beta je: %.5f\n",beta);
fprintf("p je:    %.5f\n",p);
fprintf("priemer: %.5f\n\n",mean(mmbp_data));

[ET,ET2] = zisti_et_from_bits(M.ab);

% zistenie p, alf, bet
spodna_hranica_p = 1/(1+ET);
spodna_hranica_p_2 = (ET2 + ET) / (2 * (1 + ET)^2);

p_pom = max(spodna_hranica_p,spodna_hranica_p_2) + 0.0001;
for i=1:9999999
    if p_pom > 1
        break
    end

    alfa_pom = (2 * (ET * p_pom + p_pom - 1)^2) / (ET2 * p_pom - 2 * (ET + 1)^2 * p_pom * (1 - p_pom) + ET * p_pom);
    beta_pom = (2 * (ET * p_pom + p_pom - 1))   / (ET2 * p_pom - 2 * (ET + 1)^2 * p_pom * (1 - p_pom) + ET * p_pom);
    %alfa_pom = beta_pom * (ET*p_pom + p_pom - 1);

    pom_mmbp = generate_mmbp(n,M.Mx,alfa_pom,beta_pom,p_pom);
    [chi2_stat] = chi_square_test(pom_mmbp,mmbp_bits,chi_alfa,pocet_tried_hist);

    chi2_statistics(i) = chi2_stat;
    alfy(i) = alfa_pom;
    bety(i) = beta_pom;
    p_pravdepodobnosti(i) = p_pom;

    p_pom = p_pom + 0.0001;
end

chi2_statistics = chi2_statistics(1:i-1);
[~, index] = min(chi2_statistics);
alfa2 = alfy(index);
beta2 = bety(index);
p2 = p_pravdepodobnosti(index);

fprintf("alfa cez ET je: %.5f\n",alfa2);
fprintf("beta cez ET je: %.5f\n",beta2);
fprintf("p cez ET je:    %.5f\n",p2);

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

