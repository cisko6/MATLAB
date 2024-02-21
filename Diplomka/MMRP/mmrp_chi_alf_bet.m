clear
clc

% parametre, čo treba meniť
file_path = "C:\Users\patri\Documents\GitHub\MATLAB\Utoky\Attack_5_v2";
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
index = 1; %posun_dat+1;

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

for k=2:2%999999 %length(data)-posun_dat-shift

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

    alfa_plot(index) = alfa;
    beta_plot(index) = beta;

    % chi kvadrat
    %data_pdf = histcounts(data,'Normalization', 'probability');
    %mmrp_pdf = histcounts(mmrp_sampled, length(data_pdf),'Normalization', 'probability');

    data_chi = histcounts(data,5);
    mmrp_chi = histcounts(mmrp_sampled, length(data_chi));

    chi2_stat(index) = chisquaretest(mmrp_chi,data_chi);
    df = length(data_chi) - 1;
    chi_alfa = 0.05;
    critical_value(index) = chi2inv(1 - chi_alfa, df);
    p_value(index) = 1 - chi2cdf(chi2_stat(index), df);


    %{
    % P-VALUE
    data_chi = histcounts(data);
    mmrp_chi = histcounts(mmrp_sampled, length(data_pdf));
    for l=1:length(mmrp_chi)
        if mmrp_chi(l) == 0
            mmrp_chi(l) = 10^(-6);
        end
        if data_chi(l) == 0
            data_chi(l) = 10^(-6);
        end
    end
    

    %diverg(index) = kl_diverg(data_chi,mmrp_chi); % dkl

    chi2value(index) = chisquaretest(data_chi,mmrp_chi); % chi statistic
    df = length(data_chi) - 1; % stupen volnosti
    chi_alfa = 0.05; % alfa
    critical_value(index) = chi2inv(1 - chi_alfa, df); % critical value
    p_value(index) = 1 - chi2cdf(chi2value(index), df); % p-value

    %[h(index), p(index)] = chi2gof(data_chi, 'Expected', mmrp_chi);
    %}
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
plot(chi2_stat)
title("chi kvadrat")


figure

%plot(data2);
%hold on
plot(critical_value,'r');
hold on
plot(chi2_stat,'b');
legend("critical value","chivalue");
title("critical value - chivalue");

figure

chi_alfa_plot(1:length(p_value)) = chi_alfa;
plot(chi_alfa_plot,'m');
hold on
plot(p_value,'r');
title("alfa - p value");
legend("alfa","p-value");

%figure

%plot(h)
%title("Ak je 0 tak prešiel testom (1 = reject null hypothesis)");
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function chi2_stat = chisquaretest(expected, observed)
    %pseudo_count = 1;
    chi2_stat = sum((observed - expected).^2 ./ (expected)); % (expected + pseudo_count)
end

function diverg = kl_diverg(P,Q)
    for k=1:length(Q)
        if Q(k)==0
           Q(k) = 10^(-20);
        end
    end

    pom = -sum(P.*log(P/Q));
    diverg = max(0,pom);
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
