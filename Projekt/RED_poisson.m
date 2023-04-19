clear
clc

pocet_generovanych = 10000;
compute_window = 40;
shift = 40;

nasobok_lambdy = 1.1;
lambda_1 = 50;
lambda_2 = 70;
lambda_3 = 90;
d = 0.05;
Plost = 0.1;

min_th = 0.7;
pravd_min_th = 0.7;

%generuj poisson
data = zeros(1,pocet_generovanych*3);
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
c = nasobok_lambdy*lambda_1;
n = d*c;

klzavy_priemer = zeros(1,dlzka_dat);
for i=compute_window+1:dlzka_dat-1

    if mod(i,shift) ~= 0 % prejdu do vnutra vsetky okrem nasobkov shiftu..
        [q,zahodene,zahodene_RED] = vloz_do_buffra(data,q,zahodene,i,c,n,zahodene_RED,min_th,pravd_min_th);
        klzavy_priemer(i) = mean(data(i-compute_window:i));
        continue
    end

    %nastavenie c,velkosti buffra a hodenie do buffru
    data_cw  = data(i-compute_window:i);
    klzavy_priemer(i) = mean(data_cw);

    c = nasobok_lambdy*lambda_1;
    n = d*c;
    [q,zahodene,zahodene_RED] = vloz_do_buffra(data,q,zahodene,i,c,n,zahodene_RED,min_th,pravd_min_th);
end




mean_zahodene = mean(zahodene);
%mean_data = mean(data(1:count));

%Vypisy
subcislo = 4;
subplot(subcislo,1,1);
plot(data);
hold on
plot(klzavy_priemer);
title("data");
xlim([0 dlzka_dat]);

subplot(subcislo,1,2);
plot(q);
title("queue, c = "+c+", velkost buffra = "+n);
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
                    zahodene(i+1) = zahodene(i+1) + 1;
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

