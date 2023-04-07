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
Plost = 0.1;%1*10^-100;
lambda = 50;

Y = log(Plost)/(-d);

% Inicializácia buffra
q = zeros(1,dlzkaPcapu-compute_window);
zahodene = zeros(1,dlzkaPcapu-compute_window);

for i=1:dlzkaPcapu-compute_window

    if i == 1 % ak i je 1, tak sa vypocita velkost buffra
        data_cw  = Nt(i:compute_window);
        vysl = vypocitaj_kapacitu(lambda,Plost,d);
        c = vysl(1);theta = vysl(2);
        velkost_buffra = d*c;
        continue  
    end

    if mod(i,shift) ~= 0 % prejdu do vnutra vsetky okrem 100 200 300..

        %vkladanie po 1 do buffra
        q(i+compute_window) = min(max(q(i+compute_window-1) + Nt(i+compute_window) - c, 0), velkost_buffra);

        % zahodene pakety
        je_viac = max(q(i+compute_window-1) + Nt(i+compute_window) - c, 0);
        if je_viac > velkost_buffra
            zahodene(i+compute_window) = je_viac - velkost_buffra;
        end
        continue
    end

    %PREJDU SEM LEN 100 200 300
    %PREPOCITA SA KAPACITA
    %hodi sa jeden prvok do buffra

    data_cw  = Nt(i:i+compute_window);
    
    %nastavenie kapacity a velkosti buffra
    vysl = vypocitaj_kapacitu(lambda,Plost,d);
    c = vysl(1);theta = vysl(2);
    velkost_buffra = d*c;
    
    %hodenie jedneho prvku do buffru
    q(i+compute_window) = min(max(q(i+compute_window-1) + Nt(i+compute_window) - c, 0), velkost_buffra);
    % zahodene pakety
    je_viac = max(q(i+compute_window-1) + Nt(i+compute_window) - c, 0);
    if je_viac > velkost_buffra
        zahodene(i+compute_window) = je_viac - velkost_buffra;
    end
end

mean_zahodene = mean(zahodene);
mean_Nt = mean(Nt);

%Vypisy
subcislo = 3;
subplot(subcislo,1,1);
plot(Nt);
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



function vysl = vypocitaj_kapacitu(lambda,Plost,d)
    % vypocet thety
    theta = log(log(Plost)/(-d * lambda));

    % nastavenie kapacity
    c = (lambda*((exp(theta))-1))/theta;
    vysl = [c,theta];
end





