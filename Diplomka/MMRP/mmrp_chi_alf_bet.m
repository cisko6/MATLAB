clear
clc

% parametre, čo treba meniť
file_path = "C:\Users\patri\Documents\GitHub\MATLAB\Utoky\Attack_5_v2.mat";
posun_dat = 1000;

[~, folder_name, ~] = fileparts(file_path);
M = load(file_path);

for k=1:1%99999

    data = M.a;

    from = (k-1)*posun_dat + 1;
    to = from + (posun_dat-1);
    
    if from > length(data)
        break
    end

    try
        data = data(from:to);
    catch 
        to = to - (to-length(data)); % Keď "to" je väčšie ako length(data)
        data = data(from : to);
    end

    % mean, max, ppeak
    lambda_avg = mean(data);
    n = max(data);
    
    peak_count = numel(find(data==n));
    ppeak = peak_count/length(data);
    
    %alfa beta
    alfa = 1 - (ppeak * n/lambda_avg)^(1/(n-1));
    beta = (lambda_avg * alfa) / (n - lambda_avg);
    
    %generovanie a samplovanie mmrp
    mmrp_data = generate_mmrp(n*length(data),length(data),alfa,beta);
    mmrp_sampled = sample_generated_data(mmrp_data, ceil(n*length(data)), ceil(n));
    
    
    
    % vymazanie nul na konci z dát pre plot
    lastNonZeroIndex = find(mmrp_sampled, 1, 'last');
    mmrp_sampled = mmrp_sampled(1:lastNonZeroIndex);
    
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

    fig = figure;
    subplot(4,1,1)
    plot(data)
    title(sprintf('Data od %d do %d z %s', from, to, folder_name));

    subplot(4,1,2)
    plot(mmrp_sampled)
    title("MMRP");

    subplot(4,1,3)
    hist_data = histogram(data, 'Normalization', 'probability');
    title("Histogram dát")
    ylim([0 maxValue])

    subplot(4,1,4)
    hist_mmrp = histogram(mmrp_sampled, 'Normalization', 'probability','NumBins',hist_data.NumBins);
    title("Histogram MMRP")
    ylim([0 maxValue])


    % chi2kvadrat
    chi2value = chisquaretest(hist_data.Values,hist_mmrp.Values);
    fprintf("Chi2value: %f\n",chi2value)
    figure(1)
    subplot(4,1,4)
    title("Histogram MMRP - chi2test:" + chi2value)
end
%%%%%%%%%%%%%%%%%%%%%%%%% CHI ALF BET PLOT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clearvars -except M posun_dat;
close all;

shift = 1;
data2 = M.a;
index = posun_dat+1;

%%% počítanie mmrp len raz
data = data2(1:posun_dat);

% mean, max, ppeak
lambda_avg = mean(data);
n = max(data);

peak_count = numel(find(data==n));
ppeak = peak_count/length(data);


alfa = 1 - (ppeak * n/lambda_avg)^(1/(n-1));
beta = (lambda_avg * alfa) / (n - lambda_avg);

%generovanie a samplovanie mmrp
mmrp_data = generate_mmrp(n*length(data),length(data),alfa,beta);
mmrp_sampled = sample_generated_data(mmrp_data, ceil(n*length(data)), ceil(n));

% vymazanie nul na konci z dát
lastNonZeroIndex = find(mmrp_sampled, 1, 'last');
mmrp_sampled = mmrp_sampled(1:lastNonZeroIndex);

%%%

for k=2:999999 %length(data)-posun_dat-shift

    if ~mod(k,shift) == 0
        continue
    end

    from = k + shift;
    to = from + posun_dat;
    try
        data = data2(from:to);
    catch
        break
    end
    
    % mean, max, ppeak
    lambda_avg = mean(data);
    n = max(data);
    
    peak_count = numel(find(data==n));
    ppeak = peak_count/length(data);

    %alfa beta
    alfa = 1 - (ppeak * n/lambda_avg)^(1/(n-1));
    beta = (lambda_avg * alfa) / (n - lambda_avg);

    % chi kvadrat
    values1 = histcounts(data,'Normalization', 'probability');
    values2 = histcounts(mmrp_sampled, length(values1),'Normalization', 'probability');

    chi2value(index) = chisquaretest(values1,values2);
    alfa_plot(index) = alfa;
    beta_plot(index) = beta;
    index = index + 1;
end

subplot(4,1,1)
plot(data2)
title("tok, posun="+shift+" dat v bloku="+posun_dat)
subplot(4,1,2)
plot(alfa_plot)
title("alfa")
subplot(4,1,3)
plot(beta_plot)
title("beta")
subplot(4,1,4)
plot(chi2value)
title("chi kvadrat")

figure

chi2value2 = chi2value(posun_dat+1:length(chi2value));
plot(data2);
hold on
t = linspace(1, length(data2), length(data2));
a = max(data2);
tcw1 = linspace(posun_dat,length(data2),length(data2)-posun_dat-2);
plot(t,a,tcw1,posun_dat*chi2value2/2,'r');% *10
title("Chi2");
legend("Data","Chi2*500");
xlabel("čas(s)")
ylabel("Počet paketov")

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function chi2_stat = chisquaretest(expected, observed)
    pseudo_count = 1;
    chi2_stat = sum((observed - expected).^2 ./ (expected + pseudo_count));
end


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
end
