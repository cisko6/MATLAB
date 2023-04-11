clear
clc
%load("C:\Users\patri\Documents\GitHub\MATLAB\Utoky\Attack_3_d010.mat");%ntbk
%load('Attack_3_d010.mat');
load('C:\Users\patri\OneDrive\Documents\GitHub\MATLAB\Utoky\Attack_3_d010.mat')
Nt=a;
dlzkaPcapu = length(Nt);

compute_window = 1000;
shift = 100;
d = 100;
Plost = 0.1;
lambda = 50;


% Inicializácia buffra
q = zeros(1,dlzkaPcapu);
zahodene = zeros(1,dlzkaPcapu);

%i==1
data_cw = Nt(1:compute_window);
[c,velkost_buffra] = vypocitaj_poisson_kapacitu(lambda,Plost,d);

klzavy_priemer = zeros(1,dlzkaPcapu);
for i=compute_window+1:dlzkaPcapu-1

    if mod(i,shift) ~= 0 % prejdu do vnutra vsetky okrem nasobkov shiftu..
        [q,zahodene] = vloz_do_buffra(Nt,q,zahodene,i,c,velkost_buffra);
        klzavy_priemer(i) = mean(Nt(i-compute_window:i));
        continue
    end

    %nastavenie c,velkosti buffra a hodenie do buffru
    data_cw  = Nt(i-compute_window:i);
    klzavy_priemer(i) = mean(data_cw);

    [c,velkost_buffra] = vypocitaj_poisson_kapacitu(lambda,Plost,d);
    [q,zahodene] = vloz_do_buffra(Nt,q,zahodene,i,c,velkost_buffra);
end

mean_zahodene = mean(zahodene);
mean_Nt = mean(Nt);

%Vypisy
subcislo = 3;
subplot(subcislo,1,1);
plot(Nt);
hold on
plot(klzavy_priemer);
title("data");
xlim([0 dlzkaPcapu]);

subplot(subcislo,1,2);
plot(q);
title("queue, c = "+c+", velkost buffra = "+velkost_buffra);
xlim([0 dlzkaPcapu]);

subplot(subcislo,1,3);
plot(zahodene);
title("zahodene pakety");
xlim([0 dlzkaPcapu]);
zz = rand(1);


function [c,velkost_buffra] = vypocitaj_poisson_kapacitu(lambda,Plost,d)
    % vypocet thety
    theta = log(log(Plost)/(-d * lambda));

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



