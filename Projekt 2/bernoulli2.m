clear
clc

pravd_prepocitania = 0.5;
compute_window = 40;

d = 0.1;
Plost = 0.05;
nasobok = 1.2;
pravd_na_1 = 0.6;

min_th = 0.8;
pravd_min_th = 0.7;
typ_zahodenia = "linear";
%typ_zahodenia = "logaritmus";
%typ_zahodenia = "exponential";

max_hodnota_1 = 10;
max_hodnota_2 = 20;
pocet_generovanych_1 = 1000;
pocet_generovanych_2 = 1000;


Y = (log(Plost))/(-d);
pocet_generovanych = pocet_generovanych_1 + pocet_generovanych_2;
%generuj bernoulli
data = zeros(1,pocet_generovanych+1);
data(1:pocet_generovanych_1) = binornd(max_hodnota_1,pravd_na_1,1,pocet_generovanych_1);
data(pocet_generovanych_1+1:pocet_generovanych) = binornd(max_hodnota_2,pravd_na_1,1,pocet_generovanych_2);

% Inicializácia buffra
q = zeros(1,pocet_generovanych);
zahodene = zeros(1,pocet_generovanych);

%i==1
data_cw = data(1:compute_window);
[c,n] = vypocitaj_bernoulli_kapacitu(Y,d,pravd_na_1,max_hodnota_1,nasobok);
kapacita(compute_window) = c;
velkost_buffra(compute_window) = n;
klzavy_priemer = zeros(1,pocet_generovanych);

for i=compute_window+1:pocet_generovanych-1
    pom = n * pravd_prepocitania;
    if q(i) < pom
        [q,zahodene] = vloz_do_buffra(data,q,zahodene,i,c,n,min_th,pravd_min_th,typ_zahodenia);
        klzavy_priemer(i) = mean(data(i-compute_window:i));
        kapacita(i) = c;
        velkost_buffra(i) = n;
        continue
    end

    %nastavenie c,velkosti buffra a hodenie do buffru
    data_cw  = data(i-compute_window:i);
    
    if i <= pocet_generovanych_1
        [c,n] = vypocitaj_bernoulli_kapacitu(Y,d,pravd_na_1,max_hodnota_1,nasobok);
    else
        [c,n] = vypocitaj_bernoulli_kapacitu(Y,d,pravd_na_1,max_hodnota_2,nasobok);
    end

    [q,zahodene] = vloz_do_buffra(data,q,zahodene,i,c,n,min_th,pravd_min_th,typ_zahodenia);

    klzavy_priemer(i) = mean(data_cw);
    kapacita(i) = c;
    velkost_buffra(i) = n;
end


%Vypisy
subcislo = 3;
subplot(subcislo,1,1);
plot(data);
hold on
plot(klzavy_priemer);
hold on
plot(kapacita);
title("\color{blue}Bernoulli\color{black}, pravdNa1 = "+pravd_na_1+ ", d = "+d+"s, c = "+nasobok+" * λavg");
xlabel("Čas");
ylabel("Počet paketov");
legend('Bernoulli','klzavý priemer','kapacita','Location','northwest');
xlim([0 pocet_generovanych]);

subplot(subcislo,1,2);
plot(q);
hold on
plot(velkost_buffra);
title("\color{blue}Buffer");
xlabel("Čas");
ylabel("Počet paketov");
legend('Buffer','veľkost buffra','Location','northwest')
xlim([0 pocet_generovanych]);

subplot(subcislo,1,3);
plot(zahodene);
title("\color{blue}Zahodené pakety\color{black}, počet = "+sum(zahodene));
xlabel("Čas");
ylabel("Počet paketov");
xlim([0 pocet_generovanych]);



fprintf("zahodene - "+typ_zahodenia+": %f\n",sum(zahodene));
fprintf("kapacita -  %f\n",mean(kapacita));
fprintf("velkost_buffra -  %f\n",mean(velkost_buffra));


function [q,zahodene] = vloz_do_buffra(data,q,zahodene,i,c,n,min_th,pravd_min_th,typ_zahodenia)
        
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
                    zahodene(i+1) = zahodene(i+1) + 1;
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

    if buffer > max_96 && buffer < n
        if typ_zahodenia == "linear"
            pravd_min_th = 0.9; 
        end
        if typ_zahodenia == "logaritmus"
            pravd_min_th = 0.98;
        end
        if typ_zahodenia == "exponential"
            pravd_min_th = 0.98; 
        end
    end

    if buffer >= n
        pravd_min_th = 1; % 100% pravd zahodenia
    end
end

function [c,n] = vypocitaj_bernoulli_kapacitu(Y,d,pravd_na_1,max_hodnota,nasobok)

c = max_hodnota* pravd_na_1 * nasobok;
n = d*c;

% % vypocet thety
%  theta = log((exp(Y/max_hodnota) - 1 + pravd_na_1)/pravd_na_1);
% 
% % nastavenie kapacity a n
%  c = 1/theta * log(1 - pravd_na_1 + pravd_na_1*exp(theta));
%  n = d*c;
%  c = c * 10;
end


