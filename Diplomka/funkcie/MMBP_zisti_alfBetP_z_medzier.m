
function [alfa,beta,p] = MMBP_zisti_alfBetP_z_medzier(original_bits,ET,ET2,dlzka_dat,N,chi_alfa,pocet_tried_hist)
    pocet_generovanych = N * dlzka_dat;

    spodna_hranica_p = 1/(1+ET);
    spodna_hranica_p_2 = (ET2 + ET) / (2 * (1 + ET)^2);
    
    p_pom = max(spodna_hranica_p,spodna_hranica_p_2) + 0.001;
    for i=1:9999999
        if p_pom > 1
            break
        end
    
        alfa_pom = (2 * (ET * p_pom + p_pom - 1)^2) / (ET2 * p_pom - 2 * (ET + 1)^2 * p_pom * (1 - p_pom) + ET * p_pom);
        beta_pom = (2 * (ET * p_pom + p_pom - 1))   / (ET2 * p_pom - 2 * (ET + 1)^2 * p_pom * (1 - p_pom) + ET * p_pom);
    
        pom_mmbp = generate_mmbp(N,pocet_generovanych,alfa_pom,beta_pom,p_pom);
        [chi2_stat] = chi_square_test(pom_mmbp,original_bits,chi_alfa,pocet_tried_hist);
    
        chi2_statistics(i) = chi2_stat;
        alfy(i) = alfa_pom;
        bety(i) = beta_pom;
        p_pravdepodobnosti(i) = p_pom;
    
        p_pom = p_pom + 0.001;
    end
    
    chi2_statistics = chi2_statistics(1:i-1);
    [~, index] = min(chi2_statistics);
    alfa = alfy(index);
    beta = bety(index);
    p = p_pravdepodobnosti(index);
end

