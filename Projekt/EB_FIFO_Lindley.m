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

Y = log(Plost)/(-d);

% Inicializácia buffra
q = zeros(1,dlzkaPcapu-compute_window);
zahodene = zeros(1,dlzkaPcapu-compute_window);

%klzavyPriemer(i+compute_window) = mean(data_cw);

for i=1:dlzkaPcapu-compute_window

    if i == 1 % ak i je 1, tak sa vypocita velkost buffra
        data_cw  = Nt(i:compute_window);
        vysl = vypocitaj_kapacitu(data_cw,Y);
        c = vysl(1); theta = vysl(2); lambda_theta = vysl(3);
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
    vysl = vypocitaj_kapacitu(data_cw,Y);
    c = vysl(1); theta = vysl(2); lambda_theta = vysl(3);
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
%hold on 
%plot(klzavyPriemer);
xlim([0 dlzkaPcapu]);
hold off
subplot(subcislo,1,2);
plot(q);
title("queue");
xlim([0 dlzkaPcapu]);
subplot(subcislo,1,3);
plot(zahodene);
title("zahodene pakety");
xlim([0 dlzkaPcapu]);
zz = rand(1);



function vysl = vypocitaj_kapacitu(data_cw,Y)
    %vypocet pravdepodobnosti Pk
   
    hist_counts = histcounts(data_cw);
    pdf = hist_counts/sum(hist_counts);
    dlzkaPdf = length(pdf);

    %max_number_y = max(data_cw);
    %for k=0:max_number_y
    %    n = 0;
    %    n = numel(find(data_cw==k));
    %    pdf(k+1) = n;
    %end
    

    % vypocet thety
    theta = 0.001;
    
    while true
        for k=1:dlzkaPdf
            pom(k) = (exp(theta*(k-1)))*pdf(k);
        end
        lambda_theta = log(sum(pom));
        if lambda_theta >= Y
            break
        end
        theta = theta + 0.001;
    end
    % nastavenie kapacity
    c = lambda_theta/theta;
    vysl = [c,theta,lambda_theta];
end





