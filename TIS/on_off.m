
alfa = 0.95;
beta = 0.95;
stav = 1;
sample_size = 5;
pocet_generovanych = 100;

one_counter = 0;
zero_counter = 0;

b = 1;

%generovanie sekvencie bitov
for i=1:pocet_generovanych
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

%samplovanie dat
clear('sampled_data');
pom_sum = sum(data(1:sample_size));
sampled_data(1) = pom_sum;

for i=1:(pocet_generovanych/sample_size)-1 % -1 lebo prvykrat mam vysie
    pom_sum = sum(data((i*sample_size)+1:(i*sample_size)+sample_size));
    sampled_data(i+1) = pom_sum;
end

plot(sampled_data)
