
clc;clear

pocet_tried_hist = 36;
compute_window = 1000;
chi_alfa = 0.05;

data1 = [1 20 30 20 10 50];
data2 = [10 1 30 40 10 20];


[chi2_stat, p_value, critical_value, df] = chi_square_test2(data1,data2,chi_alfa);
fprintf("chi štatistika: %f\n",chi2_stat);
fprintf("p_value: %f\n",p_value);
fprintf("critical_value: %f\n",critical_value);
fprintf("df: %f\n",df);



function [chi2_stat, p_value, critical_value, df] = chi_square_test2(obs1,obs2,chi_alfa)
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