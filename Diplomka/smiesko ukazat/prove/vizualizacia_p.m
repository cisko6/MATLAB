
clear;clc
addpath('C:\Users\patri\Documents\GitHub\MATLAB\Diplomka\funkcie');

chi_alfa = 0.05;
pocet_tried_hist = 10;

%M = load("C:\Users\patri\Downloads\a080203.mat");
%M.Mx = 10000;
%mmbp_bits = generate_mmbp(M.NN,M.Mx, M.alf,M.bet,M.p);
%mmbp_data = sample_generated_data(mmbp_bits, M.NN, M.Mx);

alfa = 0.8;
beta = 0.3;
p = 0.5;
N = 8;
pocet_generovanych = 100000;

mmbp_bits = generate_mmbp(N,pocet_generovanych,alfa,beta,p);
mmbp_data = sample_generated_data(mmbp_bits, N, pocet_generovanych);

figure
plot(mmbp_data)
title("mmbp_data");

[ET,ET2] = zisti_et_from_bits(mmbp_bits);

chi2_statistics = zeros(1,pocet_generovanych);
alfy = zeros(1,pocet_generovanych);
bety = zeros(1,pocet_generovanych);
p_pravdepodobnosti = zeros(1,pocet_generovanych);
p_pom = 0.001;
for i=1:9999999
    if p_pom > 1
        break
    end

    alfa_pom = (2 * (ET * p_pom + p_pom - 1)^2) / (ET2 * p_pom - 2 * (ET + 1)^2 * p_pom * (1 - p_pom) + ET * p_pom);
    beta_pom = (2 * (ET * p_pom + p_pom - 1))   / (ET2 * p_pom - 2 * (ET + 1)^2 * p_pom * (1 - p_pom) + ET * p_pom);
    %alfa_pom = beta_pom * (ET*p_pom + p_pom - 1);

    if alfa_pom < 0 || beta_pom < 0 || alfa_pom > 1 || beta_pom > 1
        chi2_statistics(i) = 100;
        p_pom = p_pom + 0.005;
        continue
    end

    pom_mmbp = generate_mmbp(N,pocet_generovanych,alfa_pom,beta_pom,p_pom);
    pom_sampled_mmbp = sample_generated_data(pom_mmbp, N, pocet_generovanych);
    [chi2_stat] = chi_square_test(mmbp_data,pom_sampled_mmbp,chi_alfa,pocet_tried_hist);
    chi2_statistics(i) = chi2_stat;
    alfy(i) = alfa_pom;
    bety(i) = beta_pom;
    p_pravdepodobnosti(i) = p_pom;

    if chi2_statistics(i) > 100
        chi2_statistics(i) = 100;
    end

    p_pom = p_pom + 0.005;
end

chi2_statistics = chi2_statistics(1:i-1);
[~, index] = min(chi2_statistics);
alfa2 = alfy(index);
beta2 = bety(index);
p2 = p_pravdepodobnosti(index);

fprintf("alfa cez ET je: %.5f\n",alfa2);
fprintf("beta cez ET je: %.5f\n",beta2);
fprintf("p cez ET je:    %.5f\n",p2);

figure
plot(chi2_statistics)
title("chi2_statistics");




