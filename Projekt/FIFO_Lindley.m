clear
clc

load('C:\Users\patri\OneDrive\Documents\GitHub\MATLAB\Utoky\Attack_3_d010.mat')

Nt=a;
dlzkaPcapu = length(Nt);
t = linspace(1,dlzkaPcapu,dlzkaPcapu);

compute_window = 1000;
shift = 100;
d = 100;
Plost = 1*10^-100;

Y = log(Plost)/(-d);


% Initialize the buffer
q(1) = 0;

j = 1;
last_in_queue = 0;
q = zeros(1,5000);
for i=1:dlzkaPcapu-compute_window
    if mod(i,shift) ~= 0 % prejdu do vnutra vsetky okrem 100 200 300..
        if i ~= 1 % ak i je 1, tak sa vypocita velkost buffra
            continue
        end
    end
    % tu prejde iba v čase shiftu
    data  = Nt(i:compute_window-1+i);

    %vypocet pravdepodobnosti Pk
    hist_counts = histcounts(data);
    pdf = hist_counts/sum(hist_counts);
    dlzkaPdf = length(pdf);
    for k=1:dlzkaPdf
        if pdf(k)==0
            pdf(k) = 10^(-20);
        end
    end
    
    % vypocet thety
    theta = 0;
    
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
    if i == 1
        pointer = compute_window;%0; zakomentovane preto aby boli grafy pod sebou
    else
        pointer = pointer + shift;
    end
    
    j = 0;
    for t = (compute_window-shift):compute_window
        
        q(pointer+j+2) = (min(max(q(pointer+j+1) + data(t) - c, 0), velkost_buffra));

        % zahodene pakety
        je_viac = max(q(pointer+j+1) + data(t) - c, 0);
        if je_viac > velkost_buffra
            zahodene(pointer+j+1) = (max(q(pointer+j+1) + data(t) - c, 0) - velkost_buffra);
        end
        j = j + 1;
    end
end

%Vypisy
subcislo = 3;

subplot(subcislo,1,1);
plot(Nt);
title("data");

subplot(subcislo,1,2);
plot(q);
title("queue");
xlim([0 dlzkaPcapu]);

subplot(subcislo,1,3);
plot(zahodene);
title("zahodene pakety");
xlim([0 dlzkaPcapu]);


zz = rand(1);