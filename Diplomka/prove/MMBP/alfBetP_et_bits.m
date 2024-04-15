
clc
clear

chi_alfa = 0.05;
pocet_tried_hist = 10;

alfa = 0.1;
beta = 0.3;
p = 0.8;
n = 8;
pocet_generovanych = 10000;

% generovanie dát
mmbp_bits = generate_mmbp(n,pocet_generovanych,alfa,beta,p);

% zistenie ET, ET2 z bitov
[ET,ET2] = zisti_et_from_bits(mmbp_bits);

% zistenie p
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

    % generovanie MMBP
    pom_mmbp = generate_mmbp(n,pocet_generovanych,alfa_pom,beta_pom,p_pom);

    % zistenie chi statistiky
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

fprintf('ET=%.15f\n', ET);
fprintf('ET2=%.15f\n\n', ET2);
fprintf('MMBP alfa ma byt: %.3f, je: %.3f\n',alfa, alfa2);
fprintf('MMBP beta ma byt: %.3f, je: %.3f\n',beta, beta2);
fprintf('MMBP p ma byt:    %.3f, je: %.3f\n',p, p2);

