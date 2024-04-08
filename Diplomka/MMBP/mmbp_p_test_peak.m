
clc
clear

chi_alfa = 0.05;
pocet_tried_hist = 10;

alfa = 0.1;
beta = 0.3;
p = 0.8;
n = 8; % n

pocet_generovanych = 10000;
stav = 1;


for i=1:1
    data = (1:125000);
    % generovanie dát
    mmbp_data = generate_mmbp(n,length(data),alfa,beta,p);
    % samplovanie dat
    sampled_mmbp_data = sample_generated_data(mmbp_data, n, length(data));
    % zisti alf,bet,p
    [alfa, beta, p, n] = MMBP_zisti_alfBetP_peakIsMax(sampled_mmbp_data, chi_alfa,pocet_tried_hist);
    
    vysledne_p_max(i) = p;
end

disp(mean(vysledne_p_max))






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [alfa, beta, p, n] = MMBP_zisti_alfBetP_peakIsMax(data, chi_alfa,pocet_tried_hist)

    n = ceil(max(data));
    lambda_avg = mean(data);


    peak = numel(find(data==n));
    if peak == 0
        peak = 1;
    end
    ppeak = peak/length(data);
    

    chi2_statistics = zeros(1,9999); alfy = zeros(1,9999); bety = zeros(1,9999); p_pravdepodobnosti = zeros(1,9999);

    spodna_hranica_p = (ppeak*n/lambda_avg)^(1/(n-1));
    p_pom = spodna_hranica_p + 0.001;
    for i=1:99999
    
        if p_pom > 1
            break
        end
    
        alfa_pom = 1 - ((n * ppeak / lambda_avg)^(1 / (n - 1))) * 1 / p_pom;
        beta_pom = (lambda_avg * alfa_pom) / ((n * p_pom) - lambda_avg);
    
        % generovanie a samplovanie dat
        pom_mmbp = generate_mmbp(n,length(data),alfa_pom,beta_pom,p_pom);
        pom_samped_mmbp = sample_generated_data(pom_mmbp, n, length(data));

        % zistenie chi statistiky
        [chi2_stat] = chi_square_test(pom_samped_mmbp,data,chi_alfa,pocet_tried_hist);
    
        chi2_statistics(i) = chi2_stat;
        alfy(i) = alfa_pom;
        bety(i) = beta_pom;
        p_pravdepodobnosti(i) = p_pom;
    
        p_pom = p_pom + 0.001;
    end
    chi2_statistics = chi2_statistics(1:i-1);
    [~, index] = min(chi2_statistics); %%%%%%%% MIN MAX
    alfa = alfy(index);
    beta = bety(index);
    p = p_pravdepodobnosti(index);
end

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
    n = round(n);
    pocet_bitov = ceil(n*dlzka_dat);
    sampled_data = zeros(1,pocet_bitov);
    
    pom_sum = sum(data(1:n));
    sampled_data(1) = pom_sum;

    for i=1:(pocet_bitov/n)-1
        try
            pom_sum = sum(data((i*n)+1:(i*n)+n));
        catch
            break
        end
        sampled_data(i+1) = pom_sum;
    end
    sampled_data = sampled_data(1:dlzka_dat);
end

function [chi2_stat, p_value, critical_value, df] = chi_square_test(obs1,obs2,chi_alfa,pocet_tried_hist)

    % chi kvadrat
    obs1_counts = histcounts(obs1,pocet_tried_hist);
    obs2_counts = histcounts(obs2, length(obs1_counts));

    obs = [obs1_counts; obs2_counts];

    row_totals = sum(obs, 2);
    column_totals = sum(obs, 1);
    grand_total = sum(row_totals);

    expected = (row_totals * column_totals) / grand_total;

    valid_categories = all(expected > 0) & all(obs > 0);

    obs_valid = obs(:, valid_categories);
    expected_valid = expected(:, valid_categories);
    
    chi2_stat = sum(((obs_valid - expected_valid).^2) ./ expected_valid, 'all');
    
    df = (sum(valid_categories) - 1) * (size(obs, 1) - 1);
    
    if df > 0
        p_value = 1 - chi2cdf(chi2_stat, df);
    else
        p_value = NaN; % The chi-square test is not applicable
    end

    critical_value = chi2inv(1 - chi_alfa, df);
end
