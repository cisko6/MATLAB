clc
clear

pocet_generovanych = 5000;
sample_size = 8; % n

%%%%%%%%%%%%%%%%%%%%%%%%%% BERNOULLI %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

p = 0.5;

bernoulli_data = binornd(1, p, 1, pocet_generovanych);

% samplovanie dat
sampled_ber_data = zeros(1,ceil(pocet_generovanych/sample_size));

pom_sum = sum(bernoulli_data(1:sample_size));
sampled_ber_data(1) = pom_sum;

for i=1:(pocet_generovanych/sample_size)-1
    pom_sum = sum(bernoulli_data((i*sample_size)+1:(i*sample_size)+sample_size));
    sampled_ber_data(i+1) = pom_sum;
end

%%%%%%%%%%%%%%%%%%%%%%%%%% MMRP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Parametre ON OFF
alfa = 0.1;
beta = 0.1;
stav = 1;


counter_one = 0;
counter_zero = 0;
% generovanie sekvencie bitov
for i=1:pocet_generovanych
    if stav == 1
        mmrp_data(i) = 1;
        counter_one = counter_one + 1;

        pravd = 1.*rand();
        if pravd >= (1 - alfa)
            stav = 0;
        end
    else
        mmrp_data(i) = 0;
        counter_zero = counter_zero + 1;

        pravd = 1.*rand();
        if pravd >= (1-beta)
            stav = 1;
        end
    end
end

% samplovanie dat
sampled_mmrp_data = zeros(1,ceil(pocet_generovanych/sample_size));

pom_sum = sum(mmrp_data(1:sample_size));
sampled_mmrp_data(1) = pom_sum;

for i=1:(pocet_generovanych/sample_size)-1
    pom_sum = sum(mmrp_data((i*sample_size)+1:(i*sample_size)+sample_size));
    sampled_mmrp_data(i+1) = pom_sum;
end

%%%%%%%%%%%%%%%%%%%%%%%%%% ICA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% fastICA path
addpath('C:\Program Files\MATLAB\Moje addons\fastICA')

% mixovanie signálov
mixed = [sampled_ber_data; sampled_mmrp_data];

% použitie ICA
[S_est, A_est, W] = fastica(mixed);

%{
% mixovanie signálov
mixed = [bernoulli_data; mmrp_data];

% použitie ICA
[S_est, A_est, W] = fastica(mixed);
%}
%%%%%%%%%%%%%%%%%%%%%%%%%% PLOT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

subplot(3,1,1);
plot(sampled_ber_data);
hold on
plot(sampled_mmrp_data);
xlim([1 length(sampled_mmrp_data) ])
title('Original Signals');
legend('bernoulli data', 'mmrp data');

subplot(3,1,2);
plot(mixed');
xlim([1 length(sampled_mmrp_data) ])
title('Mixed Signals');

subplot(3,1,3);
plot(S_est')
xlim([1 length(sampled_mmrp_data) ])
title('Separated Signals by ICA');
legend('Separated 1', 'Separated 2');

%{ 
subplot(3,1,1);
plot(bernoulli_data,'r');
hold on
plot(mmrp_data,'b');
title('Original Signals');
legend('bernoulli data', 'mmrp data');

subplot(3,1,2);
plot(mixed');
title('Mixed Signals');

subplot(3,1,3);
plot(S_est')
title('Separated Signals by ICA');
legend('Separated 1', 'Separated 2');
%}








