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