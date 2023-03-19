clear
clc

load('C:\Users\patri\OneDrive\Documents\GitHub\MATLAB\Utoky\Attack_3_d010.mat')

Nt=a;
dlzkaPcapu = length(Nt);
t = linspace(1,dlzkaPcapu,dlzkaPcapu);

compute_window = 100;
shift = 5;
d = 100;
Plost = 1*10^-100;

Y = log(Plost)/(-d);


% Initialize the buffer
q(1) = 0;
pom_zahodene = 0;

for i=1:dlzkaPcapu-compute_window
    
    data  = Nt(i:compute_window-1+i);
    
    if mod(i,shift) ~= 0 % prejdu do vnutra vsetky okrem 100 200 300..
        if i ~= 1 % ak i je 1, tak sa vypocita velkost buffra
            % Simulacia buffra
            for t = 1:compute_window
                q(t+1) = (min(max(q(t) + data(t) - c, 0), velkost_buffra));

                % zahodene pakety
                je_viac = max(q(t) + data(t) - c, 0);
                if je_viac > velkost_buffra
                    pom_zahodene(t) = (max(q(t) + data(t) - c, 0) - velkost_buffra);
                end
            end
            zahodene(i+compute_window) = sum(pom_zahodene);
            continue
        end
    end
    
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
            pom(k) = (exp(theta*k))*pdf(k);
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
    for t = 1:compute_window
        q(t+1) = (min(max(q(t) + data(t) - c, 0), velkost_buffra));

        % zahodene pakety
        je_viac = max(q(t) + data(t) - c, 0);
        if je_viac > velkost_buffra
            pom_zahodene(t) = (max(q(t) + data(t) - c, 0) - velkost_buffra);
        end
    end
    zahodene(i+compute_window) = sum(pom_zahodene);
end

%Vypisy
subcislo = 2;

subplot(subcislo,1,1);
plot(Nt);
title("data");
%{
subplot(subcislo,1,2);
plot(q);
title("queue");
xlim([0 dlzkaPcapu]);
%}
subplot(subcislo,1,2);
plot(zahodene);
title("zahodene pakety");
xlim([0 dlzkaPcapu]);


zz = rand(1);
