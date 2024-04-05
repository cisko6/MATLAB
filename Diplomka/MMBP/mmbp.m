
clc
clear

chi_alfa = 0.05;

alfa = 0.1;
beta = 0.3;
p = 0.8;
n = 8;


data = (1:1250);
% generovanie a samplovanie idealnych
mmbp_data = generate_mmbp(n,length(data),alfa,beta,p);
sampled_mmbp = sample_generated_data(mmbp_data, n, length(data));


% zistenie alfa, beta, p
[alfa_2, beta_2, p_2] = MMBP_zisti_alfBetP_peakIsMax(sampled_mmbp, chi_alfa);
% generovanie a samplovanie dat
gen_data = generate_mmbp(n,length(sampled_mmbp),alfa_2,beta_2,p_2);
gen_sampled = sample_generated_data(gen_data, n, length(sampled_mmbp));


%%%%%%%%%%%%%%%%%%%%%%%% ET ET2 %%%%%%%%%%%%%%%%%%%%%%%%

%et = ((alfa_2 + beta_2)/(beta_2 * p_2)) - 1;
%et2 = % netusim čo je q
%{
lastNonZeroIndex = find(sampled_mmbp_data, 1, 'last');
sampled_mmbp_data = sampled_mmbp_data(1:lastNonZeroIndex);

et = sampled_mmbp_data(lastNonZeroIndex) / lastNonZeroIndex; % ked sa na tento vzorec divam po case tak toto "sampled_mmbp_data(lastNonZeroIndex)" je zle lebo nemam kumulativne casy

ti = diff(sampled_mmbp_data);
ti2 = ti.^2;
n = max(sampled_mmbp_data);
et2 = (1/(n - 1)) * sum(ti2);
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%% OUTPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%fprintf("lambda avg: %f  idealne ma byt 4,8\n", mean(sampled_mmbp))
%fprintf("ppeak: %f       idealne ma byt 0,06\n",ppeak)
plot(sampled_mmbp)
title("sampled_mmbp_data")
xlim([1 length(sampled_mmbp) ])

figure

plot(gen_sampled)
title("result_sampled_mmbp")
xlim([1 length(gen_sampled) ])





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [chi2_stat_array, p_value_array, critical_value_array] = pouzi_chi_square_test(cely_tok, gen_sampled, posun_dat, shift, pocet_tried_hist, chi_alfa)

    for k=2:9999999
    
        if ~mod(k,shift) == 0
            continue
        end
    
        from = k + shift;
        to = from + posun_dat;
        try
            data = cely_tok(from:to);
        catch
            break
        end
    
        % chi kvadrat
        data_chi = histcounts(data,pocet_tried_hist);
        mmrp_chi = histcounts(gen_sampled, length(data_chi));

        [chi2_stat, p_value, critical_value] = chi_square_test(data_chi,mmrp_chi,chi_alfa);
    
        chi2_stat_array(k-1) = chi2_stat;
        p_value_array(k-1) = p_value;
        critical_value_array(k-1) = critical_value;
    end

end

function [alfa, beta, p, n] = MMBP_zisti_alfBetP_peakIsMax(sampled_mmbp, chi_alfa)
    % zistenie n, lambda_avg, ppeak
    n = ceil(max(sampled_mmbp));
    lambda_avg = mean(sampled_mmbp);
    peak = numel(find(sampled_mmbp==n));
    if peak == 0
        peak = 1;
    end
    ppeak = peak/length(sampled_mmbp);
    
    spodna_hranica_p = (ppeak*n/lambda_avg)^(1/(n-1));
    p_pom = spodna_hranica_p + 0.001;
    for i=1:99999
    
        if p_pom > 1
            break
        end
    
        alfa_pom = 1 - ((n * ppeak / lambda_avg)^(1 / (n - 1))) * 1 / p_pom;
        beta_pom = (lambda_avg * alfa_pom) / ((n * p_pom) - lambda_avg);
    
        % generovanie a samplovanie dat
        pom_mmbp = generate_mmbp(n,length(sampled_mmbp),alfa_pom,beta_pom,p_pom);
        pom_samped_mmbp = sample_generated_data(pom_mmbp, n, length(sampled_mmbp));
        % zistenie chi statistiky
        [chi2_stat] = chi_square_test(pom_samped_mmbp,sampled_mmbp,chi_alfa);
    
        chi2_statistics(i) = chi2_stat;
        alfy(i) = alfa_pom;
        bety(i) = beta_pom;
        p_pravdepodobnosti(i) = p_pom;
    
        p_pom = p_pom + 0.001;
    end
    
    [~, index] = max(chi2_statistics);
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
%{
function [alfa, beta, p] = MMBP_zisti_alfBetP_peakIsMax(sampled_mmbp, chi_alfa)
    % zistenie n, lambda_avg, ppeak
    n = ceil(max(sampled_mmbp));
    if n == 0
        n = 1;
    end
    lambda_avg = mean(sampled_mmbp);
    peak = numel(find(sampled_mmbp==n));
    ppeak = peak/length(sampled_mmbp);
    
    spodna_hranica_p = (ppeak*n/lambda_avg)^(1/(n-1));
    p_pom = spodna_hranica_p;
    for i=1:99999
    
        if p_pom > 1
            break
        end
    
        alfa_pom = 1 - ((n * ppeak / lambda_avg)^(1 / (n - 1))) * 1 / p_pom;
        beta_pom = (lambda_avg * alfa_pom) / ((n * p_pom) - lambda_avg);
    
        % generovanie a samplovanie dat
        pom_mmbp = generate_mmbp(n,length(sampled_mmbp),alfa_pom,beta_pom,p_pom);
        pom_samped_mmbp = sample_generated_data(pom_mmbp, n, length(sampled_mmbp));
        % zistenie chi statistiky
        [chi2_stat] = chi_square_test(pom_samped_mmbp,sampled_mmbp,chi_alfa);
    
        chi2_statistics(i) = chi2_stat;
        alfy(i) = alfa_pom;
        bety(i) = beta_pom;
        p_pravdepodobnosti(i) = p_pom;
    
        p_pom = p_pom + 0.001;
    end
    
    [~, index] = max(chi2_statistics);
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
%}
