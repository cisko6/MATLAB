clear
clc

pocet_generovanych = 10000;
lambda = 50;
compute_window = 40;
shift = 20;
d = 0.1;
Plost = 0.2;

%generovanie poisson
for i=1:pocet_generovanych
    r = 1.*rand();
    x(i) = (-log(1-r))/lambda;
end
T = cumsum(x);

%vzorkovanie
count = 1;
data = zeros(1,pocet_generovanych);
data(count) = data(count) + 1;

for i=2:pocet_generovanych
    if floor(T(i)) > floor(T(i-1))
        count = count + 1;
        data(count) = data(count) + 1;
        continue
    end
    data(count) = data(count) + 1;
end

dlzka_dat = count;

% Inicializácia buffra
q = zeros(1,dlzka_dat);
zahodene = zeros(1,dlzka_dat);

%i==1
data_cw = data(1:compute_window);
[c,velkost_buffra] = vypocitaj_poisson_kapacitu(lambda,Plost,d);
kapacita(compute_window) = c;

klzavy_priemer = zeros(1,dlzka_dat);
for i=compute_window+1:dlzka_dat-1

    if mod(i,shift) ~= 0 % prejdu do vnutra vsetky okrem nasobkov shiftu..
        [q,zahodene] = vloz_do_buffra(data,q,zahodene,i,c,velkost_buffra);
        klzavy_priemer(i) = mean(data(i-compute_window:i));
        kapacita(i) = c;
        continue
    end

    %nastavenie c,velkosti buffra a hodenie do buffru
    data_cw  = data(i-compute_window:i);
    klzavy_priemer(i) = mean(data_cw);
    kapacita(i) = c;

    [c,velkost_buffra] = vypocitaj_poisson_kapacitu(lambda,Plost,d);
    [q,zahodene] = vloz_do_buffra(data,q,zahodene,i,c,velkost_buffra);
end




mean_zahodene = mean(zahodene);
mean_data = mean(data(1:count));

%Vypisy
subcislo = 3;
subplot(subcislo,1,1);
plot(data);
hold on
plot(klzavy_priemer);
hold on
plot(kapacita);
title("data,"+"d="+d+", Plost="+Plost);
xlim([0 dlzka_dat]);

subplot(subcislo,1,2);
plot(q);
title("queue, c = "+c+", velkost buffra = "+velkost_buffra);
xlim([0 dlzka_dat]);

subplot(subcislo,1,3);
plot(zahodene);
title("zahodene pakety");
xlim([0 dlzka_dat]);

fprintf("mean_data: %f\n",mean_data);
zz = rand(1);


function [c,velkost_buffra] = vypocitaj_poisson_kapacitu(lambda,Plost,d)
    % vypocet thety
    %theta = log(log(Plost)/(-d * lambda));
    theta = log(1-log(Plost)/(d*lambda));

    % nastavenie kapacity
    c = (lambda*((exp(theta))-1))/theta;
    velkost_buffra = d*c;
end


function [q,zahodene] = vloz_do_buffra(Nt,q,zahodene,i,c,velkost_buffra)

        %vkladanie po 1 do buffra
        q(i+1) = min(max(q(i) + Nt(i+1) - c, 0), velkost_buffra);

        % zahodene pakety
        je_viac = max(q(i) + Nt(i+1) - c, 0);
        if je_viac > velkost_buffra
            zahodene(i+1) = je_viac - velkost_buffra;
        end
end



