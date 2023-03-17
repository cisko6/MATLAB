clear('data');
clear('sampled_data');

alfa = 0.95;
beta = 0.95;
stav = 1;
sample_size = 4;
pocet_generovanych = 5000;

one_counter = 0;
zero_counter = 0;

b = 1;

% generovanie sekvencie bitov
for i=1:pocet_generovanych*sample_size
    if stav == 1
        data(i) = 1;
        one_counter = one_counter + 1;

        pravd = b.*rand();
        if pravd >= (1 - alfa)
            stav = 0;
        end
    else
        data(i) = 0;
        zero_counter = zero_counter + 1;

        pravd = b.*rand();
        if pravd >= (1-beta)
            stav = 1;
        end
    end
end

% samplovanie dat;
sampled_data = zeros(1,pocet_generovanych/sample_size);

pom_sum = sum(data(1:sample_size));
sampled_data(1) = pom_sum;

for i=1:pocet_generovanych-1 % -1 lebo prvykrat mam vysie
    pom_sum = sum(data((i*sample_size)+1:(i*sample_size)+sample_size));
    sampled_data(i+1) = pom_sum;
end







% simulacia lidleyho buffru
c = 2; % kapacita
T = pocet_generovanych; % čas
priemerPrichodov = 1;

%a = exprnd(priemerPrichodov, [1, T]); % prichadzajuce pakety

% Inicializacia buffra
q = zeros(1, T+1);
q(1) = 0;

% Simulacia buffra
for t = 1:T
    %q(t+1) = max(q(t) + a(t) - c, 0);
end



plot(sampled_data)
