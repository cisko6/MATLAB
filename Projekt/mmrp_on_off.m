clear

% Parametre ON OFF
alfa = 0.1;
beta = 0.1;
sample_size = 10;
pocet_generovanych = 2000;
stav = 1;

% Parametre 
compute_window = 5;
Plost = 0.05;
d = 0.1;

pravd_prepocitania = 0.5;
min_th = 0.8;
pravd_min_th = 0.7;
typ_zahodenia = "linear";
%typ_zahodenia = "logaritmus";
%typ_zahodenia = "exponential";

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

sample_length = length(sampled_data);

% Inicializácia buffra
q = zeros(1,sample_length);
zahodene = zeros(1,sample_length);
zahodene_RED = zeros(1,sample_length);
%i==1
data_cw = sampled_data(1:compute_window);
[c,n] = vypocitaj_markovovu_kapacitu(Plost,d,alfa,beta,sample_size);
kapacita(compute_window) = c;
velkost_buffra(compute_window) = n;
klzavy_priemer = zeros(1,sample_length);

for i=compute_window+1:sample_length-1

    pom = n * pravd_prepocitania;
    if q(i) > pom
        [q,zahodene,zahodene_RED] = vloz_do_buffra(sampled_data,q,zahodene,i,c,n,zahodene_RED,min_th,pravd_min_th,typ_zahodenia);
        klzavy_priemer(i) = mean(sampled_data(i-compute_window:i));
        kapacita(i) = c;
        velkost_buffra(i) = n;
        continue
    end

    %nastavenie c,velkosti buffra a hodenie do buffru
    data_cw = sampled_data(i-compute_window:i);

    [c,n] = vypocitaj_markovovu_kapacitu(Plost,d,alfa,beta,sample_size);
    [q,zahodene,zahodene_RED] = vloz_do_buffra(sampled_data,q,zahodene,i,c,n,zahodene_RED,min_th,pravd_min_th,typ_zahodenia);

    klzavy_priemer(i) = mean(data_cw);
    kapacita(i) = c;
    velkost_buffra(i) = n;
end

%Vypisy
subcislo = 4;
subplot(subcislo,1,1);
plot(sampled_data);
hold on
plot(klzavy_priemer);
hold on
plot(kapacita);
title("d="+d+", Plost="+Plost);
legend('tok','klzavy priemer','kapacita','Location','northwest');
xlim([0 sample_length-1]);

subplot(subcislo,1,2);
plot(q);
hold on
plot(velkost_buffra);
title("queue");
legend('queue','velkost buffra','Location','northwest')
xlim([0 sample_length]);

subplot(subcislo,1,3);
plot(zahodene);
title("zahodene pakety");
xlim([0 sample_length]);

subplot(subcislo,1,4);
plot(zahodene_RED);
title("zahodene pakety RED");
xlim([0 sample_length]);


fprintf("zahodene RED - "+typ_zahodenia+": %f\n",sum(zahodene_RED));

function [q,zahodene,zahodene_RED] = vloz_do_buffra(data,q,zahodene,i,c,n,zahodene_RED,min_th,pravd_min_th,typ_zahodenia)
        
        %RED - skontrolovat kapacitu
        min_th_number =  min_th * n;
        if q(i) > min_th_number % dnu pojde ked buffer > 80%

            for j=1:data(i+1)-c
                pom_pravd_min_th = pravd_min_th;
                [pom_pravd_min_th] = zisti_pravd_zahodenia_linear(q(i),pom_pravd_min_th,typ_zahodenia,n);

                r = 1.*rand();
                if r >= pom_pravd_min_th
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

function [pravd_min_th] = zisti_pravd_zahodenia_linear(buffer,pravd_min_th,typ_zahodenia,n)

    max_84 = 0.84 * n;
    max_88 = 0.88 * n;
    max_92 = 0.92 * n;
    max_96 = 0.96 * n;

    if buffer <= max_84
        pravd_min_th = 0.70;% 70% pravd zahodenia
    end

    if buffer > max_84 && buffer <= max_88
        if typ_zahodenia == "linear"
            pravd_min_th = 0.75; 
        end
        if typ_zahodenia == "logaritmus"
            pravd_min_th = 0.85;
        end
        if typ_zahodenia == "exponential"
            pravd_min_th = 0.75; 
        end
    end

    if buffer > max_88 && buffer <= max_92
        if typ_zahodenia == "linear"
            pravd_min_th = 0.80; 
        end
        if typ_zahodenia == "logaritmus"
            pravd_min_th = 0.9;
        end
        if typ_zahodenia == "exponential"
            pravd_min_th = 0.9; 
        end
    end

    if buffer > max_92 && buffer <= max_96
        if typ_zahodenia == "linear"
            pravd_min_th = 0.85; 
        end
        if typ_zahodenia == "logaritmus"
            pravd_min_th = 0.95;
        end
        if typ_zahodenia == "exponential"
            pravd_min_th = 0.95; 
        end
    end

    if buffer > max_96
        pravd_min_th = 1; % 100% pravd zahodenia
    end
end

function [c,n] = vypocitaj_markovovu_kapacitu(Plost,d,alfa,beta,sample_size)
    %c = log(Plost)/( d*log( ((Plost^(-1/d))*(1-alfa)-1+alfa+beta) -d*log(Plost^(-1/d)) -d*log((Plost^(-1/d)) -1+beta)));
    pi1 = beta / (alfa+beta);
    c = sample_size * pi1;
    n = d*c;
end
