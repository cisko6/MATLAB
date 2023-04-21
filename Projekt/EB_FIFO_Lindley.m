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

Y = (log(Plost))/(-d);


% Inicializácia buffra
q = zeros(1,dlzkaPcapu);
zahodene = zeros(1,dlzkaPcapu);
kapacita = zeros(1,dlzkaPcapu);

%i==1
data_cw = Nt(1:compute_window);
[c,velkost_buffra] = vypocitaj_kapacitu(data_cw,Y,d);
kapacita(1) = c;
klzavy_priemer = zeros(1,dlzkaPcapu);

for i=compute_window+1:dlzkaPcapu-1

    if mod(i,shift) ~= 0 % prejdu do vnutra vsetky okrem nasobkov shiftu..
        [q,zahodene] = vloz_do_buffra(Nt,q,zahodene,i,c,velkost_buffra);
        kapacita(i) = c;
        klzavy_priemer(i) = mean(Nt(i-compute_window:i));
        continue
    end
    %nastavenie c,velkosti buffra a hodenie do buffru
    data_cw  = Nt(i-compute_window:i);

    klzavy_priemer(i) = mean(data_cw);


    [c,velkost_buffra] = vypocitaj_kapacitu(data_cw,Y,d);
    [q,zahodene] = vloz_do_buffra(Nt,q,zahodene,i,c,velkost_buffra);
    kapacita(i) = c;
end

mean_zahodene = mean(zahodene);
mean_Nt = mean(Nt);

%Vypisy
subcislo = 3;
subplot(subcislo,1,1);
plot(Nt);
hold on 
plot(klzavy_priemer,'red');
hold on 
plot(kapacita,'black');
title("Compute window = "+compute_window);
legend("tok","priemer","kapacita");
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






function [c,velkost_buffra] = vypocitaj_kapacitu(data_cw,Y,d)
    %vypocet pravdepodobnosti Pk
   
    %hist_counts = histcounts(data_cw);
    %pdf = hist_counts/sum(hist_counts);
    %dlzkaPdf = length(pdf);

    max_number = max(data_cw);
    for k=0:max_number
        n = 0;
        n = numel(find(data_cw==k));
        pdf(k+1) = n/length(data_cw);
    end
    sumpdf = sum(pdf);
    dlzkaPdf = length(pdf);

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
    % nastavenie kapacity a n
    c = lambda_theta/theta;
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


