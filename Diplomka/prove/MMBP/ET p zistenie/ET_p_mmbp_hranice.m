
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
dlzka_dat = 20000;%2000000;
alfa = 0.2;
beta = 0.4;
p = 0.2;
[mmbp_bits] = generate_mmbp(N,dlzka_dat, alfa,beta,p);
[ET,ET2] = zisti_et_from_bits(mmbp_bits);
[sampled_data] = sample_generated_data(mmbp_bits, N);


ET = ET/N;
ET2=ET2/(N^2);


lambda_avg = mean(sampled_data);
peak = numel(find(sampled_data==N));
if peak == 0
    peak = 1;
end
ppeak = peak/length(sampled_data);


% matlab numericku vypocet
f = @(p) ((2*(ET*p+p-1)^2) / (ET2*p-2*(ET + 1)^2 *p*(1 - p) + ET * p)) - 1 + ( (1/p)*((N * ppeak) / lambda_avg)^(1/(N-1)) );
options = optimset('Display', 'iter', 'TolFun', 1e-6);
initialGuess = 0.5;
[z_p_solution] = fsolve(f, initialGuess, options);


lava_strana = zeros(1,dlzka_dat);
prava_strana = zeros(1,dlzka_dat);
pravd_p = zeros(1,dlzka_dat);

% spodne hranice
spodna_hranica_1 = (ppeak*N/lambda_avg)^(1/(N-1));
spodna_hranica_2 = 1/(1+ET);
spodna_hranica = max(spodna_hranica_1,spodna_hranica_2);

p_pom = spodna_hranica + 0.001;

for i=1:9999999
    if p_pom > 1
        break
    end

    lava_strana(i) = (2 * (ET * p_pom + p_pom - 1)^2) / (ET2 * p_pom - 2 * (ET + 1)^2 * p_pom * (1 - p_pom) + ET * p_pom);
    prava_strana(i) = 1 - (1/p_pom) * (ppeak*N/lambda_avg)^(1/(N-1));

    pravd_p(i) = p_pom;
    alfy(i) = 1 - ((N * ppeak / lambda_avg)^(1 / (N - 1))) * 1 / p_pom;
    bety(i) = (lambda_avg * alfy(i)) / ((N * p_pom) - lambda_avg);

    p_pom = p_pom + 0.001;
end

lava_strana = lava_strana(1:find(lava_strana, 1, 'last'));
prava_strana = prava_strana(1:find(prava_strana, 1, 'last'));
pravd_p = pravd_p(1:find(pravd_p, 1, 'last'));



if lava_strana(1) > prava_strana(1)
    lava_vacsia = true;
else
    lava_vacsia = false;
end

% cakanie na prekrizenie
for i=1 : length(prava_strana)
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


figure
lava_strana = lava_strana(index_final:length(pravd_p));
prava_strana = prava_strana(index_final:length(pravd_p));

%t = linspace(spodna_hranica,1,length(lava_strana));
t = linspace(spodna_hranica, 1, length(pravd_p));
%plot(t,prava_strana,t,lava_strana)
plot(lava_strana); hold on; plot(prava_strana)
title("Priebeh pravej a ľavej strany")
xlabel("p")
ylabel("P")
legend("pravá strana","lavá strana")

p_final = pravd_p(index_final);
alfa_final = alfy(index_final);
beta_final = bety(index_final);
%{
figure
plot(t,alfy,t,bety)
title("Priebeh alfa a beta")
xlabel("p")
ylabel("P")
legend("alfa","beta")
%}



fprintf("alfa = %.3f\n",alfa_final);
fprintf("beta = %.3f\n",beta_final);
fprintf("p_pom = %.3f\n",p_final);



