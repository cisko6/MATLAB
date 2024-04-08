
clc; clear;

% vstup kumulovane medzery

%M = importdata("C:\Users\patri\Desktop\diplomka\Zaznamy\Ďalšie záznamy\TIS cele zaznamy\Cele zaznamy\TIS medzery\kumulovane medzery\0104.txt");

M = importdata("C:\Users\patri\Desktop\diplomka\Zaznamy\Finalisti - skopirovane z ostatnych\Kumulovane medzery\Utok2\Utok2Cely.txt");
data = M;
slot_window = 0.01;
chi_alfa = 0.05;
pocet_tried_hist = 10;















%%%%%%%%%%%%%% Zistenie ET, ET2 %%%%%%%%%%%%%%
N = length(data);
ET = data(N)/N;
ti = diff(data);
ti2 = ti.^2;
ET2 = sum(ti2)/(N - 1);

chi2_statistics = zeros(1,9999); alfy = zeros(1,9999); bety = zeros(1,9999); p_pravdepodobnosti = zeros(1,9999);


% samplovanie kumul medzier
pom_data = cumulatedSpaces_to_casy(data, slot_window);
n = ceil(max(pom_data));

spodna_hranica_p = 1/(1+ET);
p_pom = spodna_hranica_p + 0.001;
for i=1:99999

    if p_pom > 1
        %if i == 1
        %    p_pom = 0.900; %%%%% ??
        %    continue
        %end
        break
    end

    alfa_pom = (2 * (ET * p_pom + p_pom - 1)^2) / (ET2 * p_pom - 2 * (ET + 1)^2 * p_pom * (1 - p_pom) + ET * p_pom);
    beta_pom = (2 * (ET * p_pom + p_pom - 1)) / (ET2 * p_pom - 2 * (ET + 1)^2 * p_pom * (1 - p_pom) + ET * p_pom);


    % generovanie a samplovanie MMBP
    pom_mmbp = generate_mmbp(n,length(pom_data),alfa_pom,beta_pom,p_pom);
    pom_samped_mmbp = sample_generated_data(pom_mmbp, n, length(pom_data));
    

    % zistenie chi statistiky
    data_chi = histcounts(pom_data,pocet_tried_hist);
    gen_chi = histcounts(pom_samped_mmbp, length(data_chi));
    [chi2_stat] = chi_square_test(gen_chi,data_chi,chi_alfa);

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



%MMBP_alfa = (2 * (ET * p + p - 1)^2) / (ET2 * p - 2 * (ET + 1)^2 * p * (1 - p) + ET * p);
%MMBP_beta = (2 * (ET * p + p - 1)) / (ET2 * p - 2 * (ET + 1)^2 * p * (1 - p) + ET * p);

fprintf('ET=%.15f\n', ET);
fprintf('ET2=%.15f\n', ET2);
fprintf('MMBP alfa=%.15f\n', alfa);
fprintf('MMBP beta=%.15f\n', beta);
fprintf('MMBP p=%.15f\n', p);




%figure
%data = cumulatedSpaces_to_casy(data, slot_window);
%plot(data);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

function sampled_data = cumulatedSpaces_to_casy(kumul_medzery, slot_window)

    maxTime = max(kumul_medzery);
    numBins = ceil(maxTime / slot_window) + 1;
    
    sampled_data = zeros(1, numBins);
    
    for i = 1:length(kumul_medzery)
        binIndex = floor(kumul_medzery(i) / slot_window) + 1;
        
        sampled_data(binIndex) = sampled_data(binIndex) + 1;
    end
end






