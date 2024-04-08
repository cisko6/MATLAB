
clc
clear

chi_alfa = 0.05;
pocet_tried_hist = 10;

alfa = 0.1;
beta = 0.3;
p = 0.8;
n = 8;
pocet_generovanych = 10000;

% generovanie dát
mmbp_bits = generate_mmbp(n,pocet_generovanych,alfa,beta,p);

% zistenie ET, ET2 z bitov
[ET,ET2] = zisti_et_et2(mmbp_bits);

% zistenie p
spodna_hranica_p = 1/(1+ET);
spodna_hranica_p_2 = (ET2 + ET) / (2 * (1 + ET)^2);

p_pom = max(spodna_hranica_p,spodna_hranica_p_2) + 0.0001;
for i=1:9999999
    if p_pom > 1
        break
    end

    alfa_pom = (2 * (ET * p_pom + p_pom - 1)^2) / (ET2 * p_pom - 2 * (ET + 1)^2 * p_pom * (1 - p_pom) + ET * p_pom);
    beta_pom = (2 * (ET * p_pom + p_pom - 1))   / (ET2 * p_pom - 2 * (ET + 1)^2 * p_pom * (1 - p_pom) + ET * p_pom);
    %alfa_pom = beta_pom * (ET*p_pom + p_pom - 1);

    % generovanie MMBP
    pom_mmbp = generate_mmbp(n,pocet_generovanych,alfa_pom,beta_pom,p_pom);

    % zistenie chi statistiky
    [chi2_stat] = chi_square_test(pom_mmbp,mmbp_bits,chi_alfa,pocet_tried_hist);

    chi2_statistics(i) = chi2_stat;
    alfy(i) = alfa_pom;
    bety(i) = beta_pom;
    p_pravdepodobnosti(i) = p_pom;

    p_pom = p_pom + 0.0001;
end

chi2_statistics = chi2_statistics(1:i-1);
[~, index] = min(chi2_statistics);
alfa2 = alfy(index);
beta2 = bety(index);
p2 = p_pravdepodobnosti(index);

fprintf('ET=%.15f\n', ET);
fprintf('ET2=%.15f\n\n', ET2);
fprintf('MMBP alfa ma byt: %.3f, je: %.3f\n',alfa, alfa2);
fprintf('MMBP beta ma byt: %.3f, je: %.3f\n',beta, beta2);
fprintf('MMBP p ma byt:    %.3f, je: %.3f\n',p, p2);







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ET,ET2] = zisti_et_et2(mmrp_bits)
    pocetnosti = zisti_pocetnosti(mmrp_bits);
    N = sum(pocetnosti);
    ET = 0;
    ET2 = 0;
    for i=1:length(pocetnosti)
        ET = ET + ( (i-1) * pocetnosti(i)/N );
        ET2 = ET2 + ( ((i-1)^2) * pocetnosti(i)/N );
    end
end

function vysl = zisti_pocetnosti(data)
    % zistenie početnost núl 0 00 000
    zeroLengths = [];
    zeroCount = 0;
    for i = 1:length(data)
        if data(i) == 0
            zeroCount = zeroCount + 1;
        else
            if zeroCount > 0
                zeroLengths = [zeroLengths, zeroCount];
                zeroCount = 0;
            end
        end
    end
    
    if zeroCount > 0
        zeroLengths = [zeroLengths, zeroCount];
    end
    
    vysl = zeros(1, max(zeroLengths)+1);
    for i = 1:length(zeroLengths)
        vysl(zeroLengths(i)+1) = vysl(zeroLengths(i)+1) + 1;
    end
    
    % zistenie početnosť jednotiek 11
    count = 0;
    for i = 1:length(data)-1
        if data(i) == 1 && data(i+1) == 1
            count = count + 1;
        end
    end
    vysl(1) = count;
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
    mmbp_data = mmbp_data(1:find(mmbp_data, 1, 'last'));
end

function [chi2_stat, p_value, critical_value, df] = chi_square_test(obs1,obs2,chi_alfa,pocet_tried_hist)

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