clear
clc

pravd_prepocitania = 0.5;
compute_window = 40;

d = 10;
Plost = 0.05;

min_th = 0.8;
pravd_min_th = 0.7;

max_hodnota_1 = 10;
max_hodnota_2 = 20;
pocet_generovanych_1 = 1000;
pocet_generovanych_2 = 1000;

pravd_na_1 = 0.95;


Y = (log(Plost))/(-d);
pocet_generovanych = pocet_generovanych_1 + pocet_generovanych_2;
%generuj bernoulli
data = zeros(1,pocet_generovanych+1);
data(1:pocet_generovanych_1) = binornd(max_hodnota_1,pravd_na_1,1,pocet_generovanych_1);
data(pocet_generovanych_1+1:pocet_generovanych) = binornd(max_hodnota_2,pravd_na_1,1,pocet_generovanych_2);

% Inicializácia buffra
q = zeros(1,pocet_generovanych);
zahodene = zeros(1,pocet_generovanych);
zahodene_RED = zeros(1,pocet_generovanych);
%i==1
data_cw = data(1:compute_window);
[c,n] = vypocitaj_bernoulli_kapacitu(Y,d,pravd_na_1,max_hodnota_1);
kapacita(compute_window) = c;
velkost_buffra(compute_window) = n;
klzavy_priemer = zeros(1,pocet_generovanych);

for i=compute_window+1:pocet_generovanych-1
    pom = n * pravd_prepocitania;
    if q(i) < pom
        [q,zahodene,zahodene_RED] = vloz_do_buffra(data,q,zahodene,i,c,n,zahodene_RED,min_th,pravd_min_th);
        klzavy_priemer(i) = mean(data(i-compute_window:i));
        kapacita(i) = c;
        velkost_buffra(i) = n;
        continue
    end

    %nastavenie c,velkosti buffra a hodenie do buffru
    data_cw  = data(i-compute_window:i);
    
    if i <= pocet_generovanych_1
        [c,n] = vypocitaj_bernoulli_kapacitu(Y,d,pravd_na_1,max_hodnota_1);
    else
        [c,n] = vypocitaj_bernoulli_kapacitu(Y,d,pravd_na_1,max_hodnota_2);
    end

    [q,zahodene,zahodene_RED] = vloz_do_buffra(data,q,zahodene,i,c,n,zahodene_RED,min_th,pravd_min_th);

    klzavy_priemer(i) = mean(data_cw);
    kapacita(i) = c;
    velkost_buffra(i) = n;
end




mean_zahodene = mean(zahodene);
%mean_data = mean(data(1:count));


%Vypisy
subcislo = 4;
subplot(subcislo,1,1);
plot(data);
hold on
plot(klzavy_priemer);
hold on
plot(kapacita);
title("pravd na 1="+pravd_na_1+", d="+d+", Plost="+Plost);
legend('tok','klzavy priemer','kapacita','Location','northwest');
xlim([0 pocet_generovanych-1]);

subplot(subcislo,1,2);
plot(q);
hold on
plot(velkost_buffra);
title("queue");
legend('queue','velkost buffra','Location','northwest')
xlim([0 pocet_generovanych]);

subplot(subcislo,1,3);
plot(zahodene);
title("zahodene pakety");
xlim([0 pocet_generovanych]);

subplot(subcislo,1,4);
plot(zahodene_RED);
title("zahodene pakety RED");
xlim([0 pocet_generovanych]);

%fprintf("mean_data: %f\n",mean_data);
zz = rand(1);


function [q,zahodene,zahodene_RED] = vloz_do_buffra(data,q,zahodene,i,c,n,zahodene_RED,min_th,pravd_min_th)
        
        %RED - skontrolovat kapacitu
        min_th_number =  min_th * n;
        if q(i) > min_th_number % dnu pojde ked q(i) > 80%

            for j=1:data(i+1)-c
                r = 1.*rand();
                if r >= pravd_min_th
                    %vlozi
                    q(i+1) = min(q(i+1) + 1, n);
                    je_viac = q(i+1) + 1;
                    if je_viac > n
                        zahodene(i+1) = zahodene(i+1) + 1;
                    end
                else
                    %zahodi
                    zahodene_RED(i+1) = zahodene_RED(i+1) + 1;
                end
            end
        else
            %vkladanie po 1 do buffra
            q(i+1) = min(max(q(i) + data(i+1) - c, 0), n);

            % zahodene pakety
            je_viac = max(q(i) + data(i+1) - c, 0);
            if je_viac > n
                zahodene(i+1) = je_viac - n;
            end
        end
end

function [c,n] = vypocitaj_bernoulli_kapacitu(Y,d,pravd_na_1,max_hodnota)

c = (max_hodnota/2) * 1;
n = d*c;

% % vypocet thety
% theta = log((exp(Y/max_hodnota) - 1 + pravd_na_1)/pravd_na_1);
% 
% % nastavenie kapacity a n
% c = 1/theta * log(1 - pravd_na_1 + pravd_na_1*exp(theta));
% n = d*c;
% c = c * 10;
end


