clc
clear

%load("C:\Users\patri\Documents\GitHub\MATLAB\Utoky\Attack_5_v1.mat"); % attack 5 - prvých 19k je stacionarnych
%data = a(1:15000);
load("C:\Users\patri\Documents\GitHub\MATLAB\Utoky\Attack_5_v2.mat");
data = a(1:20000);

% zistenie Ppeak
maxValue = max(data);
count_max_value = sum(data == maxValue);
Ppeak = count_max_value/length(data) * 100;

% zistenie lambda_avg
lambda_avg = mean(data);


%plot(data)

% vzorce TIS 
alfa = 1 - (Ppeak * maxValue/lambda_avg)^(1 / (maxValue-1));
beta = lambda_avg*alfa / (maxValue - lambda_avg); 

% vzorce clanok
%alfa = 1 - (Ppeak * 1/lambda_avg);
%beta = (lambda_avg * alfa) / (1 - lambda_avg);

%%%%%%%%%%%%%%%%%%%%%%%%%%% ON OFF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pocet_generovanych = 500000;
stav = 1;

sample_size = maxValue;

for i=1:pocet_generovanych
    if stav == 1
        generated_data(i) = 1;

        pravd = 1.*rand();
        if pravd >= (1 - alfa)
            stav = 0;
        end
    else
        generated_data(i) = 0;

        pravd = 1.*rand();
        if pravd >= (1-beta)
            stav = 1;
        end
    end
end

% samplovanie dat
sampled_data = zeros(1,pocet_generovanych/sample_size);

pom_sum = sum(generated_data(1:sample_size));
sampled_data(1) = pom_sum;

for i=1:(pocet_generovanych/sample_size)-1
    pom_sum = sum(generated_data((i*sample_size)+1:(i*sample_size)+sample_size));
    sampled_data(i+1) = pom_sum;
end



plot(data);
hold on;
%plot(length(data) + (1:length(sampled_data)), sampled_data);
plot(length(data) + 1:length(data) + length(sampled_data), sampled_data);









