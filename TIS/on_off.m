clear
clc

% Parametre
alfa = 0.95;
beta = 0.95;
sample_size = 6;
pocet_generovanych = 6000;
stav = 1;
avg_lambda = 1;

counter_one = 0;
counter_zero = 0;

% generovanie sekvencie bitov
for i=1:pocet_generovanych%pocet_generovanych*sample_size
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

% simulacia lidleyho buffru
pi1 = beta/(alfa + beta);
avg_intenzita = pi1 * sample_size;

c = avg_lambda * avg_intenzita; % kapacita
T = pocet_generovanych/sample_size; % čas

% Inicializacia buffra
q = zeros(1, T+1);
q(1) = 0;

% Simulacia buffra
for t=1:T
    q(t+1) = max(q(t) + sampled_data(t) - c, 0);
end

% Overenie ON/OFF generátora
xd = counter_one/pocet_generovanych;
fprintf("KONTROLA GENERATORA\n");
fprintf("N1/pocet generovanych = π1\n");
fprintf("         %d = %d\n",xd,pi1);

% Výstupy
subplot(4,1,1)
plot(data);
title("ON/OFF Generátor pre " + pocet_generovanych + " bitov, kde sample size = "+sample_size+", α = "+alfa+" a β = "+beta);
xlabel('Počet bitov');
ylabel('1/0');

subplot(4,1,2)
plot(sampled_data)
title("Navzorkované dáta");
xlabel('Počet navzorkovaných dát');
ylabel('Počet jednotiek vo vzorkách');

subplot(4,1,3)
plot(q);
xlim([0 pocet_generovanych/sample_size]);
title("Lindley buffer simulácia, kde c = "+c);
xlabel('Čas');
ylabel('Počet paketov v queue');

subplot(4,1,4)
histogram(q, 'Normalization', 'probability');
title('Histogram Lindleyho buffra');
xlabel('Počet paketov v queue');
ylabel('Pravdepodobnosti');
