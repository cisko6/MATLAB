clc
clear

%load("C:\Users\patri\Documents\GitHub\MATLAB\Utoky\Attack_5_v1.mat"); % attack 5 - prvých 19k je stacionarnych
%data = a(1:15000);
load("C:\Users\patri\Documents\GitHub\MATLAB\Utoky\Attack_5_v2.mat"); % (1-20000)
%load("C:\Users\patri\Documents\GitHub\MATLAB\Utoky\Attack_1.mat"); % 450 830
begin_flow = 1;
end_flow = 20000;
data = a(begin_flow:end_flow);


% zistenie Ppeak
maxValue = max(data);
count_max_value = sum(data == maxValue);
Ppeak = count_max_value/length(data);

% zistenie lambda_avg
lambda_avg = mean(data);

% vzorce clanok, n=lambda_max
alfa = 1 - (Ppeak * maxValue/lambda_avg)^(1/(maxValue-1));
beta = (lambda_avg * alfa) / (maxValue - lambda_avg);

%%%%%%%%%%%%%%%%%%%%%%%%%%% ON OFF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sample_size = maxValue;
pocet_generovanych = (end_flow - begin_flow) * sample_size;%400000;
stav = 1;


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
sampled_data = zeros(1,ceil(pocet_generovanych/sample_size));

pom_sum = sum(generated_data(1:sample_size));
sampled_data(1) = pom_sum;

for i=1:(pocet_generovanych/sample_size)-1
    pom_sum = sum(generated_data((i*sample_size)+1:(i*sample_size)+sample_size));
    sampled_data(i+1) = pom_sum;
end

% vypocitanie kapacity
c_mmrp = mmrp_calc_c(alfa,beta,sample_size);

d = 100;
Plost = 0.1;
Y = (log(Plost))/(-d);

c_ipflow = ipflow_calc_c(data,Y);

% VYPISY
subplot(3,1,1);
cla
plot(data, 'b');
hold on;
plot(length(data) + (1:length(sampled_data)), sampled_data,'r');
legend('flow','generated data')
title("\color{blue}flow \color{black}/ \color{red}generated data");

subplot(3,1,2);
hist_data = histogram(data);
disp(hist_data.NumBins)
xxx = hist_data.Values;
title("\color{blue}histogram flow");

subplot(3,1,3);
hist_generated = histogram(sampled_data,'NumBins',hist_data.NumBins);
yyy = hist_generated.Values;
title("\color{red}histogram generated data");

function [c] = mmrp_calc_c(alfa,beta,sample_size)
    pi1 = beta / (alfa+beta);
    c = sample_size * pi1;
end

function [c] = ipflow_calc_c(data_cw,Y)
    max_number = max(data_cw);
    for k=0:max_number
        n = 0;
        n = numel(find(data_cw==k));
        pdf(k+1) = n/length(data_cw);
    end
    sumpdf = sum(pdf);
    dlzkaPdf = length(pdf);

    % vypocet thety
    theta = 0.001;
    
    while true
        for k=1:dlzkaPdf
            pom(k) = (exp(theta*(k-1)))*pdf(k);
        end
        lambda_theta = log(sum(pom));
        if lambda_theta >= Y
            break
        end
        theta = theta + 0.001;
    end

    c = lambda_theta/theta;
end
