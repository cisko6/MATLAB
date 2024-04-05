
clc
clear

chi_alfa = 0.05;

alfa = 0.1;
beta = 0.3;
p = 0.8;
n = 8; % n

pocet_generovanych = 10000;
stav = 1;


for k=1:10
    data = (1:1250);
    % generovanie dát
    mmbp_data = generate_mmbp(n,length(data),alfa,beta,p);
    % samplovanie dat
    sampled_mmbp_data = sample_generated_data(mmbp_data, n, length(data));
    
    % zistenie n, lambda_avg, ppeak
    n = max(sampled_mmbp_data);
    lambda_avg = mean(sampled_mmbp_data);
    peak = numel(find(sampled_mmbp_data==n));
    ppeak = peak/length(sampled_mmbp_data);
    
    spodna_hranica_p = (ppeak*n/lambda_avg)^(1/(n-1));
    p_pom = spodna_hranica_p;
    for i=1:99999
    
        if p_pom > 1
            break
        end
    
    
        alfa_2 = 1 - ((n * ppeak / lambda_avg)^(1 / (n - 1))) * 1 / p_pom;
        beta_2 = (lambda_avg * alfa_2) / ((n * p_pom) - lambda_avg);
    
        % generovanie dát
        pom_mmbp = generate_mmbp(n,length(sampled_mmbp_data),alfa_2,beta_2,p_pom);
        % samplovanie dat
        pom_samped_mmbp = sample_generated_data(pom_mmbp, n, length(data));
    
        % zistenie chi statistiky
        [chi2_stat] = chi_square_test(pom_samped_mmbp,sampled_mmbp_data,chi_alfa);
    
        chi2_statistics(i) = chi2_stat;
        alfy(i) = alfa_2;
        bety(i) = beta_2;
        p_pravdepodobnosti(i) = p_pom;
    
        p_pom = p_pom + 0.001;
    end
    
    [~, index] = max(chi2_statistics);
    vysledne_p_max(k) = p_pravdepodobnosti(index);

    [~, index2] = min(chi2_statistics);
    vysledne_p_min(k) = p_pravdepodobnosti(index2);
end

disp(mean(vysledne_p_max))
disp(mean(vysledne_p_min))






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [mmbp_data] = generate_mmbp(n,dlzka_dat, alfa,beta,p)
    
    pocet_bitov = n * dlzka_dat;
    mmbp_data = zeros(1,ceil(dlzka_dat));
    stav = 1;

    counter_one = 0;
    counter_zero = 0;
    % generovanie sekvencie bitov
    for i=1:pocet_bitov
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
end


function [sampled_data] = sample_generated_data(data, n, dlzka_dat)

    pocet_bitov = ceil(n*dlzka_dat);
    sampled_data = zeros(1,pocet_bitov);
    
    pom_sum = sum(data(1:n));
    sampled_data(1) = pom_sum;

    for i=1:(pocet_bitov/n)-1
        pom_sum = sum(data((i*n)+1:(i*n)+n));
        sampled_data(i+1) = pom_sum;
    end
    sampled_data = sampled_data(1:dlzka_dat);
end


function [chi2_stat, p_value, critical_value, df] = chi_square_test(obs1,obs2,chi_alfa)

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

end
