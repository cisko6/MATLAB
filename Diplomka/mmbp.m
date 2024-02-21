
clc
clear

alfa = 0.1;
beta = 0.3;
p = 0.8;
sample_size = 8; % n

pocet_generovanych = 10000;
stav = 1;

counter_one = 0;
counter_zero = 0;
% generovanie sekvencie bitov
for i=1:pocet_generovanych
    if stav == 1
        pravd_p = 1.*rand();
        if pravd_p <= p     % mmbp parameter pravdepodobnosti na 1
            mmbp_data(i) = 1;
            counter_one = counter_one + 1;
        else
            mmbp_data(i) = 0;
            counter_zero = counter_zero + 1;
        end

        % či sa mení stav
        pravd = 1.*rand();
        if pravd >= (1 - alfa)
            stav = 0;
        end
    else
        mmbp_data(i) = 0;
        counter_zero = counter_zero + 1;

        % či sa mení stav
        pravd = 1.*rand();
        if pravd >= (1-beta)
            stav = 1;
        end
    end
end

% samplovanie dat
sampled_mmbp_data = zeros(1,ceil(pocet_generovanych/sample_size));

pom_sum = sum(mmbp_data(1:sample_size));
sampled_mmbp_data(1) = pom_sum;

for i=1:(pocet_generovanych/sample_size)-1
    pom_sum = sum(mmbp_data((i*sample_size)+1:(i*sample_size)+sample_size));
    sampled_mmbp_data(i+1) = pom_sum;
end

%%%%%%%%%%%%%%%%%%%%%%%% ZISTENIE ALFA BETA P %%%%%%%%%%%%%%%%%%%%%%%%%%%%

lambda_avg = mean(sampled_mmbp_data);

% zistenie ppeak
max_number = max(sampled_mmbp_data);
peak = numel(find(sampled_mmbp_data==max_number));
ppeak = peak/length(sampled_mmbp_data);

p_2 = 0.8;
sample_size = 8; % n

alfa_2 = 1 - (((sample_size * ppeak) / lambda_avg)^(1 / (sample_size - 1))) * 1 / p_2;
beta_2 = (lambda_avg * alfa_2) / ((sample_size * p_2) - lambda_avg);

%%%%%%%%%%%%%%%%%%%%%%%% ET ET2 %%%%%%%%%%%%%%%%%%%%%%%%

%et = ((alfa_2 + beta_2)/(beta_2 * p_2)) - 1;
%et2 = % netusim čo je q

lastNonZeroIndex = find(sampled_mmbp_data, 1, 'last');
sampled_mmbp_data = sampled_mmbp_data(1:lastNonZeroIndex);

et = sampled_mmbp_data(lastNonZeroIndex) / lastNonZeroIndex;

ti = diff(sampled_mmbp_data);
ti2 = ti.^2;
n = max(sampled_mmbp_data);
et2 = (1/(n - 1)) * sum(ti2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%% OUTPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf("lambda avg: %f  idealne ma byt 4,8\n", mean(sampled_mmbp_data))
fprintf("ppeak: %f       idealne ma byt 0,06\n",ppeak)
plot(sampled_mmbp_data)
xlim([1 length(sampled_mmbp_data) ])


