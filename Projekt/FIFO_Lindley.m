clear
clc
load("C:\Users\patri\Documents\GitHub\MATLAB\Utoky\Attack_2_d010.mat");%ntbk

%load('Attack_3_d010.mat');
%load('C:\Users\patri\OneDrive\Documents\GitHub\MATLAB\Utoky\Attack_3_d010.mat')

Nt=a;
dlzkaPcapu = length(Nt);
t = linspace(1,dlzkaPcapu,dlzkaPcapu);

compute_window = 1000;
shift = 100;
d = 100;
Plost = 0.1;%%1*10^-100;

Y = log(Plost)/(-d);


% Initialize the buffer
q(1) = 0;

j = 1;
last_in_queue = 0;
q = zeros(1,dlzkaPcapu-compute_window);
for i=1:dlzkaPcapu-compute_window
    if mod(i,shift) ~= 0 % prejdu do vnutra vsetky okrem 100 200 300..
        if i ~= 1 % ak i je 1, tak sa vypocita velkost buffra
            continue
        end
    end
    % tu prejde iba v čase shiftu
    data  = Nt(i:compute_window-1+i);
    
    theta_data = Nt(i:i+shift);
    %vypocet pravdepodobnosti Pk
    hist_counts = histcounts(theta_data);
    pdf = hist_counts/sum(hist_counts);
    dlzkaPdf = length(pdf);
    for k=1:dlzkaPdf
        if pdf(k)==0
            pdf(k) = 10^(-20);
        end
    end
    
    % vypocet thety
    theta = 0.01;
    
    while true

        for k=1:dlzkaPdf
            pom(k) = (exp(theta*(k-1)))*pdf(k);
        end

        lambda_theta = log(sum(pom));

        if lambda_theta >= Y
            break
        end

        theta = theta + 0.0001;
    end

    % nastavenie kapacity a velkosti buffra
    c = lambda_theta/theta;
    velkost_buffra = d*c;

    % Simulacia buffra
    for t = 1:shift
        if i==1
            q(i+t+shift) = (min(max(q(i+t-1) + theta_data(t) - c, 0), velkost_buffra));
        else
            q(i+t+1+shift) = (min(max(q(i+t) + theta_data(t) - c, 0), velkost_buffra));
        end

        % zahodene pakety
        je_viac = max(q(i+t) + theta_data(t) - c, 0);
        if je_viac > velkost_buffra
            zahodene(i+t+shift) = je_viac - velkost_buffra;
        end
        klzavyPriemer(i+t+shift) = mean(theta_data);
    end
    %
    

end
mean_zahodene = mean(zahodene);
mean_Nt = mean(Nt);
%Vypisy
subcislo = 3;

subplot(subcislo,1,1);
plot(Nt);
title("data");
hold on 
plot(klzavyPriemer);
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