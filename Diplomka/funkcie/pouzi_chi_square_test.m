

function [chi2_stat_array, p_value_array, critical_value_array] = pouzi_chi_square_test(cely_tok, gen_sampled, compute_window, shift, pocet_tried_hist, chi_alfa, use_fourier, keep_frequencies)

    for k=2:9999999
    
        if ~mod(k,shift) == 0
            continue
        end
    
        from = k + shift - 1;
        to = from + compute_window - 1;
        try
            data = cely_tok(from:to);
        catch
            break
        end
    
        if use_fourier == "yes"
            data = fourier_smooth(data, keep_frequencies);
        end

        %[chi2_stat, p_value, critical_value] = chi_square_test(data,gen_sampled,chi_alfa, pocet_tried_hist);
        [chi2_stat, p_value, critical_value] = chi_square_test2(data, gen_sampled, pocet_tried_hist,chi_alfa);

        chi2_stat_array(k-1) = chi2_stat;
        p_value_array(k-1) = p_value;
        critical_value_array(k-1) = critical_value;
    end
end
