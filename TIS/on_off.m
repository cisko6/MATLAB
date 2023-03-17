
alfa = 0.5;
beta = 0.5;
stav = 1;
sample_size = 5;
pocet_generovanych = 3000;

one_counter = 0;
zero_counter = 0;

b = 1;

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

for i=1:pocet_generovanych
    pom_sum = sum(data(i*sample_size:(i*sample_size)+sample_size-1));
    sampled_data(i) = pom_sum;
end

plot(sampled_data)
