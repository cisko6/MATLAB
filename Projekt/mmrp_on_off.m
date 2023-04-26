clear
clc

% Parametre ON OFF
alfa = 0.95;
beta = 0.95;
sample_size = 10;
pocet_generovanych = 2000;
stav = 1;

% Parametre 
compute_window = 40;
Plost = 0.05;
d = 10;

pravd_prepocitania = 0.5;
min_th = 0.8;
pravd_min_th = 0.7;


counter_one = 0;
counter_zero = 0;

% generovanie sekvencie bitov
for i=1:pocet_generovanych
    if stav == 1
        data(i) = 1;
        counter_one = counter_one + 1;

        pravd = 1.*rand();
        if pravd >= (1 - alfa)
            stav = 0;
        end
    else
        data(i) = 0;
        counter_zero = counter_zero + 1;

        pravd = 1.*rand();
        if pravd >= (1-beta)
            stav = 1;
        end
    end
end

% samplovanie dat
sampled_data = zeros(1,pocet_generovanych/sample_size);

pom_sum = sum(data(1:sample_size));
sampled_data(1) = pom_sum;

for i=1:(pocet_generovanych/sample_size)-1
    pom_sum = sum(data((i*sample_size)+1:(i*sample_size)+sample_size));
    sampled_data(i+1) = pom_sum;
end

% Inicializácia buffra
q = zeros(1,pocet_generovanych);
zahodene = zeros(1,pocet_generovanych);
zahodene_RED = zeros(1,pocet_generovanych);
%i==1
data_cw = data(1:compute_window);
[c,n] = vypocitaj_markovovu_kapacitu(Plost,d,alfa,beta);
kapacita(compute_window) = c;
velkost_buffra(compute_window) = n;
klzavy_priemer = zeros(1,pocet_generovanych);

for i=compute_window+1:pocet_generovanych-1

    pom = n * pravd_prepocitania;
    if q(i) > pom
        [q,zahodene,zahodene_RED] = vloz_do_buffra(data,q,zahodene,i,c,n,zahodene_RED,min_th,pravd_min_th);
        klzavy_priemer(i) = mean(data(i-compute_window:i));
        kapacita(i) = c;
        velkost_buffra(i) = n;
        continue
    end

    %nastavenie c,velkosti buffra a hodenie do buffru
    data_cw  = data(i-compute_window:i);

    [c,n] = vypocitaj_markovovu_kapacitu(Plost,d,alfa,beta);
    [q,zahodene,zahodene_RED] = vloz_do_buffra(data,q,zahodene,i,c,n,zahodene_RED,min_th,pravd_min_th);

    klzavy_priemer(i) = mean(data_cw);
    kapacita(i) = c;
    velkost_buffra(i) = n;
end

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

function [c,n] = vypocitaj_markovovu_kapacitu(Plost,d,alfa,beta)
    c = log(Plost)/( d*log( ((Plost^(-1/d))*(1-alfa)-1+alfa+beta) -d*log(Plost^(-1/d)) -d*log((Plost^(-1/d)) -1+beta)));
    n = d*c;
end

function [q,zahodene,zahodene_RED] = vloz_do_buffra(data,q,zahodene,i,c,n,zahodene_RED,min_th,pravd_min_th)
        
        %RED - skontrolovat kapacitu
        min_th_number =  min_th * n;
        if q(i) > min_th_number

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
                    %zahodene(i+1) = zahodene(i+1) + 1;
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
