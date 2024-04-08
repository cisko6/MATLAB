
clc; clear;
tic;
addpath('C:\Users\patri\Documents\GitHub\MATLAB\Diplomka\funkcie');

% vstup kumulovane medzery

%M = importdata("C:\Users\patri\Desktop\diplomka\Zaznamy\Ďalšie záznamy\TIS cele zaznamy\Cele zaznamy\TIS medzery\kumulovane medzery\0104.txt");

M = importdata("C:\Users\patri\Desktop\diplomka\Zaznamy\Finalisti - skopirovane z ostatnych\Kumulovane medzery\Utok2\Utok2Cely.txt");

%M = importdata("C:\Users\patri\Desktop\diplomka\Zaznamy\Finalisti - skopirovane z ostatnych\Kumulovane medzery\fri-01-20141113.Time\fri-01-20141113.Time.txt");
data = M(1:10485);
slot_window = 0.01;
chi_alfa = 0.05;
pocet_tried_hist = 10;

%%%%%%%%%%%%%% Zistenie ET, ET2 %%%%%%%%%%%%%%

N = length(data);
ti = diff(data);
ti2 = ti.^2;
ET = sum(ti)/N;
ET2 = sum(ti2)/(N - 1);

chi2_statistics = zeros(1,9999); alfy = zeros(1,9999); bety = zeros(1,9999); p_pravdepodobnosti = zeros(1,9999);


% samplovanie kumul medzier
sampled_data = cumulatedSpaces_to_casy(data, slot_window);
n = ceil(max(sampled_data));

% zistenie p
spodna_hranica_p = 1/(1+ET);
spodna_hranica_p_2 = (ET2 + ET) / (2 * (1 + ET)^2);
p_pom = max(spodna_hranica_p,spodna_hranica_p_2) + 0.001;
for i=1:99999999
    if p_pom > 1
        break
    end

    alfa_pom = (2 * (ET * p_pom + p_pom - 1)^2) / (ET2 * p_pom - 2 * (ET + 1)^2 * p_pom * (1 - p_pom) + ET * p_pom);
    beta_pom = (2 * (ET * p_pom + p_pom - 1))   / (ET2 * p_pom - 2 * (ET + 1)^2 * p_pom * (1 - p_pom) + ET * p_pom);

    % generovanie a samplovanie MMBP
    pom_mmbp = generate_mmbp(n,length(sampled_data),alfa_pom,beta_pom,p_pom);
    pom_samped_mmbp = sample_generated_data(pom_mmbp, n, length(sampled_data));
    

    % zistenie chi statistiky
    [chi2_stat] = chi_square_test(pom_samped_mmbp,sampled_data,chi_alfa,pocet_tried_hist);

    chi2_statistics(i) = chi2_stat;
    alfy(i) = alfa_pom;
    bety(i) = beta_pom;
    p_pravdepodobnosti(i) = p_pom;

    p_pom = p_pom + 0.001;
end

chi2_statistics = chi2_statistics(1:i-1);
[~, index] = min(chi2_statistics); %%%%%%%% MIN MAX
alfa = alfy(index);
beta = bety(index);
p = p_pravdepodobnosti(index);

fprintf('ET=%.15f\n', ET);
fprintf('ET2=%.15f\n', ET2);
fprintf('MMBP alfa=%.15f\n', alfa);
fprintf('MMBP beta=%.15f\n', beta);
fprintf('MMBP p=%.15f\n', p);

final_mmbp = generate_mmbp(n,length(sampled_data),alfa,beta,p);
final_samped_mmbp = sample_generated_data(final_mmbp, n, length(sampled_data));

plot(final_samped_mmbp)
title("final_samped_mmbp")
figure
plot(sampled_data)
title("sampled_data")
figure
histogram(final_samped_mmbp,'Normalization', 'probability');
title("Hist final_samped_mmbp")
figure
histogram(sampled_data,'Normalization', 'probability');
title("Hist sampled_data")



elapsedTime = toc;
fprintf('Elapsed time is %.6f seconds.\n', elapsedTime);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
