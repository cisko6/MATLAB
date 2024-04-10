clear
clc

% Parametre
alfa = 0.95;
beta = 0.95;
sample_size = 10;
pocet_generovanych = 2000;
stav = 1;
avg_lambda = 1.2;

counter_one = 0;
counter_zero = 0;

% generovanie sekvencie bitov
for i=1:pocet_generovanych
    if stav == 1
        data(i) = 1;
        counter_one = counter_one + 1;

        pravd = 1.*rand();
        if pravd >= (1 - alfa)
            stav = 0;
        end
    else
        data(i) = 0;
        counter_zero = counter_zero + 1;

        pravd = 1.*rand();
        if pravd >= (1-beta)
            stav = 1;
        end
    end
end

% samplovanie dat
sampled_data = zeros(1,pocet_generovanych/sample_size);

pom_sum = sum(data(1:sample_size));
sampled_data(1) = pom_sum;

for i=1:(pocet_generovanych/sample_size)-1
    pom_sum = sum(data((i*sample_size)+1:(i*sample_size)+sample_size));
    sampled_data(i+1) = pom_sum;
end


% Overenie ON/OFF generátora
pi1 = beta/(alfa + beta);
xd = counter_one/pocet_generovanych;
fprintf("KONTROLA GENERATORA\n");
fprintf("N1/pocet generovanych = π1\n");
fprintf("         %d = %d\n",xd,pi1);



% Výstupy
fig1 = plot(data);
title("MMRP pre " + pocet_generovanych + " bitov, α = "+alfa+" a β = "+beta);
xlabel('Počet bitov');
ylabel('1/0');
grid on
%saveas(fig1,sprintf('MMRP_alf=%.2f, bet=%.2f.fig',alfa,beta));
%saveas(fig1,sprintf('MMRP_alf=%.2f, bet=%.2f.png',alfa,beta));

figure

fig2 = plot(sampled_data);
title("Navzorkované dáta na "+sample_size+" ts, α = "+alfa+" a β = "+beta);
xlabel('Počet navzorkovaných dát');
ylabel('Počet jednotiek vo vzorkách');
grid on
ylim([0 10])
%saveas(fig2,sprintf('MMRP_sampled_alf=%.2f, bet=%.2f.fig',alfa,beta));
%saveas(fig2,sprintf('MMRP_sampled_alf=%.2f, bet=%.2f.png',alfa,beta));
