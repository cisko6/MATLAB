


% HRANICE LEPSIE


clc;clear
close("all")
%{
M = load("C:\Users\patri\Downloads\p_alf_bet_070205.mat");
data = M.ab;
dlzka_dat = length(data);
N = 10;

[ET,ET2] = zisti_et_from_bits(data);

[sampled_data] = sample_generated_data(data, N);
%}

N = 10;
dlzka_dat = 1000;
alfa = 0.2;
beta = 0.3;
p = 0.8;
[mmbp_bits] = generate_mmbp(N,dlzka_dat, alfa,beta,p);
[ET,ET2] = zisti_et_from_bits(mmbp_bits);
[sampled_data] = sample_generated_data(mmbp_bits, N);



%%%% PRACA UZ S NASAMPLOVANYMI DATAMI
lambda_avg = mean(sampled_data);
peak = numel(find(sampled_data==N));
if peak == 0
    peak = 1;
end
ppeak = peak/length(sampled_data);

lava_strana = zeros(1,dlzka_dat);
prava_strana = zeros(1,dlzka_dat);
pravd_p = zeros(1,dlzka_dat);
p_pom = 0.01;
for i=1:9999999
    if p_pom > 1
        break
    end

    lava_strana(i) = (2 * (ET * p_pom + p_pom - 1)^2) / (ET2 * p_pom - 2 * (ET + 1)^2 * p_pom * (1 - p_pom) + ET * p_pom);
    
    prava_strana(i) = 1 - (1/p_pom) * (ppeak*N/lambda_avg)^(1/(N-1));

    pravd_p(i) = p_pom;
    alfy(i) = 1 - ((N * ppeak / lambda_avg)^(1 / (N - 1))) * 1 / p_pom;
    bety(i) = (lambda_avg * alfy(i)) / ((N * p_pom) - lambda_avg);

    p_pom = p_pom + 0.01;
end

lava_strana = lava_strana(1:find(lava_strana, 1, 'last'));
prava_strana = prava_strana(1:find(prava_strana, 1, 'last'));
pravd_p = pravd_p(1:find(pravd_p, 1, 'last'));



% zistenie p
prava_strana(prava_strana < 0) = 0;
lava_strana(lava_strana < 0) = 0;

prava_strana(prava_strana > 1) = 1;
lava_strana(lava_strana > 1) = 1;

index_prava = find(prava_strana, 1, 'first');
index_lava = find(lava_strana, 1, 'first');
idx_more_than_zero = max(index_prava,index_lava);

% zistenie ktora strana je vacsia
if lava_strana(idx_more_than_zero) > prava_strana(idx_more_than_zero)
    lava_vacsia = true;
else
    lava_vacsia = false;
end


% cakanie na prekrizenie
for i=idx_more_than_zero : length(prava_strana)
    if lava_vacsia == true
        if lava_strana(i) < prava_strana(i)
            index_final = i;
            break
        end
    else
        if prava_strana(i) < lava_strana(i)
            index_final = i;
            break
        end
    end
end

p_final = pravd_p(index_final);
alfa_final = alfy(index_final);
beta_final = pravd_p(index_final);

figure
plot(prava_strana)
hold on
plot(lava_strana)
ylim([0 1])
title("lava/prava strana")
legend("prava_strana","lava_strana")

figure
plot(alfy)
hold on
plot(bety)
ylim([0 1])
title("alfy/bety")
legend("alfy","bety")


fprintf("p_pom = %.2f\n",p_final);
fprintf("alfa = %.2f\n",alfa_final);
fprintf("beta = %.2f\n",beta_final);

%{
%%%%%%%%%%%%%%%%%%%%%%%%%%%

if lava_strana(1) > prava_strana(1)
    lava_vacsia = true;
else
    lava_vacsia = false;
end

for i=2:length(pravd_p)
    if lava_vacsia == true
        if lava_strana(i) < prava_strana(i)
            index = i;
            break
        end
    else
        if prava_strana(i) < lava_strana(i)
            index = i;
            break
        end
    end
end

fprintf("p_pom = %.2f\n\n",pravd_p(index));

%%%%%%%%%%%%%%%%%%%%%%%%%%%

lava_strana = lava_strana(index:find(lava_strana, 1, 'last'));
prava_strana = prava_strana(index:find(prava_strana, 1, 'last'));
pravd_p = pravd_p(index:find(pravd_p, 1, 'last'));

if lava_strana(1) > prava_strana(1)
    lava_vacsia = true;
else
    lava_vacsia = false;
end

for i=2:length(pravd_p)
    if lava_vacsia == true
        if lava_strana(i) <= prava_strana(i)
            index2 = i;
            break
        end
    else
        if prava_strana(i) <= lava_strana(i)
            index2 = i;
            break
        end
    end
end

fprintf("index = %.2f\n",index2);
fprintf("index_cely = %.2f\n",index2+index);
fprintf("p_pom = %.2f\n",pravd_p(index2));
fprintf("prava_strana = %.2f\n",prava_strana(index2));
fprintf("lava_strana = %.2f\n",lava_strana(index2));
%}





