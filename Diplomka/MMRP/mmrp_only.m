
clear;clc;

% vstup pocty paketov
file_path = "C:\Users\patri\Documents\GitHub\MATLAB\Utoky\Attack_5_v2";
from = 1;
to = 20000;
posun_dat = 100;
plot_nasobok_alf_bet = 150;
average_multiplier = 2;

M = load(file_path);
[~, folder_name, ~] = fileparts(file_path);
dlzka_celych_dat = length(M.a);

data = M.a;
data = data(from:to);

% zistenie alfa beta
[alfa, beta, n] = zisti_alf_bet(data,average_multiplier);

%generovanie a samplovanie mmrp
mmrp_data = generate_mmrp(n*length(data),length(data),alfa,beta);
mmrp_sampled = sample_generated_data(mmrp_data, ceil(n*length(data)), ceil(n));







% rovnaká Y os pre histogramy
maxValue = max(max(histcounts(data, 'Normalization', 'probability')), ...
           max(histcounts(mmrp_sampled, 'Normalization', 'probability')));
if maxValue <= 0.1
    maxValue = maxValue + 0.01;
elseif maxValue > 0.1 && maxValue < 0.5
    maxValue = maxValue + 0.05;
else
    maxValue = maxValue + 0.2;
end

% pocitanie alfa beta v klzavom okne
for i=1:dlzka_celych_dat-posun_dat-1
    data_pom = M.a;
    data_pom = data_pom(i:i+posun_dat);
    
    lambda_avg = mean(data_pom);
    n = max(data_pom);
    peak_count = numel(find(data_pom==n));
    ppeak = peak_count/length(data_pom);

    alfa(i+posun_dat) = 1 - (ppeak * n/lambda_avg)^(1/(n-1));
    beta(i+posun_dat) = (lambda_avg * alfa(i+posun_dat)) / (n - lambda_avg);
    alfa_plus_beta(i+posun_dat) = alfa(i+posun_dat) + beta(i+posun_dat);
end



% upravit Y axis pre plot
alf_bet_y_axis = max(max(alfa), max(beta));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

subplot(4,1,1)
plot(data)
title(sprintf('Data od %d do %d z %s', from, to, folder_name));
xlabel("Čas")
ylabel("Počet paketov")

subplot(4,1,2)
plot(mmrp_sampled)
title("MMRP");
xlabel("Čas")
ylabel("Počet paketov")

subplot(4,1,3)
hist_data = histogram(data, 'Normalization', 'probability');
title("Histogram dát")
ylabel("Pravd.")
xlabel("Triedy")
ylim([0 maxValue])

subplot(4,1,4)
hist_mmrp = histogram(mmrp_sampled, 'Normalization', 'probability','NumBins',hist_data.NumBins, 'BinEdges',hist_data.BinEdges);
title("Histogram MMRP")
ylabel("Pravd.")
xlabel("Triedy")
ylim([0 maxValue])

% upravit X axis pre hist
maxValue = max(max(hist_mmrp.BinEdges),max(hist_data.BinEdges));

xlim(hist_mmrp.Parent, [0 maxValue])
xlim(hist_data.Parent, [0 maxValue])

figure

subplot(5,1,1)
plot(M.a)
legend("data")
xlabel("Čas")
ylabel("Počet paketov");
title("data")
xlim([0 dlzka_celych_dat])

subplot(5,1,2)
plot(M.a)
hold on
plot(alfa*plot_nasobok_alf_bet)
hold on
plot(beta*plot_nasobok_alf_bet)
hold on
plot(alfa_plus_beta*plot_nasobok_alf_bet)
legend("data","alfa","beta","sucet alfa + beta")
xlabel("Čas")
ylabel("Počet paketov");
title("data s klzavou alfou, betou a ich suctom, velkost cw="+posun_dat)
xlim([0 dlzka_celych_dat])

subplot(5,1,3)
plot(alfa)
title("alfa")
legend("alfa")
ylim([0 alf_bet_y_axis])
xlabel("Čas")
ylabel("Pravd.");
xlim([0 dlzka_celych_dat])

subplot(5,1,4)
plot(beta)
title("beta")
legend("beta")
ylim([0 alf_bet_y_axis])
xlabel("Čas")
ylabel("Pravd.");
xlim([0 dlzka_celych_dat])

subplot(5,1,5)
plot(alfa_plus_beta)
title("sucet alfa + beta")
legend("sucet alfa + beta")
xlabel("Čas")
ylabel("Súčet pravdepodobností");
xlim([0 dlzka_celych_dat])

figure

plot(data)

figure

plot()

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [alfa, beta, n] = zisti_alf_bet(data, average_multiplier)
    % mean, max, ppeak
    lambda_avg = mean(data);

    max_data = max(data);
    n = round(average_multiplier * lambda_avg);
    if n > max_data
        n = max_data;
    end

    peak_count = numel(find(data==n));
    if peak_count == 0
        peak_count = 1;
    end

    ppeak = peak_count/length(data);

    %alfa beta
    alfa = 1 - (ppeak * n/lambda_avg)^(1/(n-1));
    beta = (lambda_avg * alfa) / (n - lambda_avg);
end

%{
% ppeak je nastaveny na max
function [alfa, beta, n] = zisti_alf_bet(data)
    % mean, max, ppeak
    lambda_avg = mean(data);
    n = max(data);
    peak_count = numel(find(data==n));
    ppeak = peak_count/length(data);
    
    %alfa beta
    alfa = 1 - (ppeak * n/lambda_avg)^(1/(n-1));
    beta = (lambda_avg * alfa) / (n - lambda_avg);
end
%}

function [mmrp_data] = generate_mmrp(pocet_bitov,dlzka_dat, alfa,beta)
    mmrp_data = zeros(1,ceil(dlzka_dat));

    stav = 1;
    for i=1:pocet_bitov
        if stav == 1
            mmrp_data(i) = 1;
    
            pravd = 1.*rand();
            if pravd >= (1 - alfa)
                stav = 0;
            end
        else
            mmrp_data(i) = 0;
    
            pravd = 1.*rand();
            if pravd >= (1-beta)
                stav = 1;
            end
        end
    end
end

function [result_data] = sample_generated_data(data, pocet_bitov, sample_size)
    result_data = zeros(1,pocet_bitov);
    
    pom_sum = sum(data(1:sample_size));
    result_data(1) = pom_sum;
    
    for i=1:(pocet_bitov/sample_size)-1
        pom_sum = sum(data((i*sample_size)+1:(i*sample_size)+sample_size));
        result_data(i+1) = pom_sum;
    end
    lastNonZeroIndex = find(result_data, 1, 'last');
    result_data = result_data(1:lastNonZeroIndex);
end