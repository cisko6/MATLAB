
clc; clear;

% parametre, čo treba meniť
file_path = "C:\Users\patri\Documents\GitHub\MATLAB\Utoky\Attack_5_v2";
posun_dat = 1000;

[~, folder_name, ~] = fileparts(file_path);
M = load(file_path);

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

% pocitanie alf,bet,chi
for k=2:2999999 %length(data)-posun_dat-shift

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

    % chi kvadrat
    chi_alfa = 0.05;

    %data_pdf = histcounts(data,'Normalization', 'probability');
    %mmrp_pdf = histcounts(mmrp_sampled, length(data_pdf),'Normalization', 'probability');

    data_chi = histcounts(data,50);
    mmrp_chi = histcounts(mmrp_sampled, length(data_chi));

    obs1 = data_chi;
    obs2 = mmrp_chi;

    %%%%%%%%%%%% THIS WORKS %%%%%%%%%%%%%%
    %obs = [obs1; obs2];
    %row_totals = sum(obs, 2);
    %column_totals = sum(obs, 1);
    %grand_total = sum(row_totals);
    
    %expected = row_totals * column_totals / grand_total;
    %chi2_stat = sum(sum((obs - expected).^2 ./ expected));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    obs = [obs1; obs2];

    row_totals = sum(obs, 2);
    column_totals = sum(obs, 1);
    grand_total = sum(row_totals);

    expected = (row_totals * column_totals) / grand_total;
    
    % Find the valid categories where both observed and expected frequencies are non-zero
    % This should be a logical array with the same length as the number of categories
    valid_categories = all(expected > 0) & all(obs > 0);
    
    % Now index only those categories that are valid
    obs_valid = obs(:, valid_categories);
    expected_valid = expected(:, valid_categories);
    
    chi2_stat = sum(((obs_valid - expected_valid).^2) ./ expected_valid, 'all');
    
    % Calculate the degrees of freedom, which should be the number of valid categories - 1
    df = (sum(valid_categories) - 1) * (size(obs, 1) - 1);
    
    % Ensure the degrees of freedom are not negative
    if df > 0
        % Calculate the p-value
        p_value = 1 - chi2cdf(chi2_stat, df);
    else
        p_value = NaN; % The chi-square test is not applicable
    end



    %df = length(obs1) - 1;
    %p_value = 1 - chi2cdf(chi2_stat, df);
    critical_value = chi2inv(1 - chi_alfa, df);

    chi2_stat_array(index) = chi2_stat;
    p_value_array(index) = p_value;
    critical_value_array(index) = critical_value;

    %disp(['Chi-square statistic = ', num2str(chi2_stat)]);
    %disp(['Degrees of freedom = ', num2str(df)]);
    %disp(['P-value = ', num2str(p_value)]);
    %disp(['critical_value = ', num2str(critical_value)]);

    index = index + 1;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

plot(M.a)
title("data")
legend("data");

figure

plot(critical_value_array,'r');
hold on
plot(chi2_stat_array,'b');
legend("critical value","chi2stat");
title("critical value, chi2stat");

figure

chi_alfa_plot(1:length(p_value_array)) = chi_alfa;
plot(chi_alfa_plot,'m');
hold on
plot(p_value_array,'r');
title("alfa, p value");
legend("alfa","p-value");
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

