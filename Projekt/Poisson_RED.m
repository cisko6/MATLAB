clear

pocet_generovanych = 10000;
compute_window = 40;
shift = 20;

lambda_1 = 50;
lambda_2 = 100;
lambda_3 = 200;
d = 0.1;
Plost = 0.1;

pravd_prepocitania = 0.5;
min_th = 0.7;
pravd_min_th = 0.7;
typ_zahodenia = "linear";
%typ_zahodenia = "logaritmus";
%typ_zahodenia = "exponential";


%generuj poisson
data = zeros(1,pocet_generovanych);
dlzka_dat = 1;

[data, dlzka_dat] = generuj_poisson(data,pocet_generovanych,lambda_1,dlzka_dat,0);
dlzka_1 = dlzka_dat;
[data, dlzka_dat] = generuj_poisson(data,pocet_generovanych,lambda_2,dlzka_dat,1);
dlzka_2 = dlzka_dat - dlzka_1;
[data, dlzka_dat] = generuj_poisson(data,pocet_generovanych,lambda_3,dlzka_dat,1);
dlzka_3 = dlzka_dat - dlzka_2 - dlzka_1;

% Inicializácia buffra
q = zeros(1,dlzka_dat);
zahodene = zeros(1,dlzka_dat);
zahodene_RED = zeros(1,dlzka_dat);
%i==1
data_cw = data(1:compute_window);
[c,n] = vypocitaj_poisson_kapacitu(lambda_1,Plost,d);
kapacita(compute_window) = c;
velkost_buffra(compute_window) = n;
klzavy_priemer = zeros(1,dlzka_dat);

for i=compute_window+1:dlzka_dat-1

    pom = n * pravd_prepocitania;
    if q(i) < pom
        [q,zahodene,zahodene_RED] = vloz_do_buffra(data,q,zahodene,i,c,n,zahodene_RED,min_th,pravd_min_th,typ_zahodenia);
        klzavy_priemer(i) = mean(data(i-compute_window:i));
        kapacita(i) = c;
        velkost_buffra(i) = n;
        continue
    end

    %nastavenie c,velkosti buffra a hodenie do buffru
    data_cw  = data(i-compute_window:i);

    if i < dlzka_1
        lambda = lambda_1;
    elseif i > dlzka_1 && i < (dlzka_1 + dlzka_2)
        lambda = lambda_2;
    elseif i > (dlzka_1 + dlzka_2)
        lambda = lambda_3;
    end

    [c,n] = vypocitaj_poisson_kapacitu(lambda,Plost,d);
    [q,zahodene,zahodene_RED] = vloz_do_buffra(data,q,zahodene,i,c,n,zahodene_RED,min_th,pravd_min_th,typ_zahodenia);

    klzavy_priemer(i) = mean(data_cw);
    kapacita(i) = c;
    velkost_buffra(i) = n;
end




mean_zahodene = mean(zahodene);
%mean_data = mean(data(1:count));

% zmena_toku = zeros(1,dlzka_dat);
% zmena_toku(dlzka_1) = lambda_3 + 50;
% zmena_toku(dlzka_1+dlzka_2) = lambda_3+50;


%Vypisy
subcislo = 4;
subplot(subcislo,1,1);
plot(data);
hold on
plot(klzavy_priemer);
hold on
plot(kapacita);
% hold on
% plot(zmena_toku);
title("data,"+"d="+d+", Plost="+Plost);
legend('tok','klzavy priemer','kapacita','Location','northwest');
xlim([0 dlzka_dat-1]);

subplot(subcislo,1,2);
plot(q);
hold on
plot(velkost_buffra);
title("queue");
legend('queue','velkost buffra','Location','northwest')
xlim([0 dlzka_dat]);

subplot(subcislo,1,3);
plot(zahodene);
title("zahodene pakety");
xlim([0 dlzka_dat]);

subplot(subcislo,1,4);
plot(zahodene_RED);
title("zahodene pakety_RED");
xlim([0 dlzka_dat]);

%fprintf("mean_data: %f\n",mean_data);
zz = rand(1);
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

function [data,dlzka_dat] = generuj_poisson(data, pocet_generovanych, lambda, dlzka_dat, was_here)

    %generovanie poisson
    for i=1:pocet_generovanych
        r = 1.*rand();
        x(i) = (-log(1-r))/lambda;
    end
    T = cumsum(x);


    %vzorkovanie
    if was_here==1
        count = dlzka_dat + 1;
        data(count) = data(count) + 1;
    else
        count = dlzka_dat;
        data(count) = data(count) + 1;
    end

    for i=2:pocet_generovanych
        if floor(T(i)) > floor(T(i-1))
            count = count + 1;
            data(count) = data(count) + 1;
            continue
        end
        data(count) = data(count) + 1;
    end

    dlzka_dat = count;

end

function [c,n] = vypocitaj_poisson_kapacitu(lambda,Plost,d)
    % vypocet thety
    %theta = log(log(Plost)/(-d * lambda));
    theta = log(1-log(Plost)/(d*lambda));

    % nastavenie kapacity
    c = (lambda*((exp(theta))-1))/theta;
    n = d*c;
end
