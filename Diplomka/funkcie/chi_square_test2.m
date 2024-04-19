
function [chi2_stat, p, critical_value] = chi_square_test2(obs1, obs2, pocet_tried_hist,chi_alfa)
    obs1_counts = histcounts(obs1, pocet_tried_hist);
    obs2_counts = histcounts(obs2, length(obs1_counts));


    valid_indices = (obs1_counts > 0) & (obs2_counts > 0);
    obs1_counts = obs1_counts(valid_indices);
    obs2_counts = obs2_counts(valid_indices);


    if ~isempty(obs1_counts) && ~isempty(obs2_counts)

        [~, p, st] = chi2gof(obs1_counts, 'Expected', obs1_counts .* obs2_counts);
        chi2_stat = st.chi2stat;
    else
        chi2_stat = NaN;
    end

    critical_value = chi2inv(1-chi_alfa, st.df);
end