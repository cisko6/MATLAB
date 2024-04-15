
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
    
    p_value = 1 - chi2cdf(chi2_stat, df);

    critical_value = chi2inv(1 - chi_alfa, df);
end
