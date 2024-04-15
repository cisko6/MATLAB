
function gen_sampled = generate_universal(data,simulacia,typ_peaku,chi_alfa,pocet_tried_hist,average_multiplier)
    if simulacia == "MMRP"
        if typ_peaku == "max"
            [alfa, beta, n] = MMRP_zisti_alfBet_peakIsMax(data);
        elseif typ_peaku == "changed"
            [alfa, beta, n] = MMRP_zisti_alfBet_peakIsChanged(data, average_multiplier);
        end
        gen_bits = generate_mmrp(n,length(data),alfa,beta);
        gen_sampled = sample_generated_data(gen_bits, n);

    elseif simulacia == "MMBP"
        if typ_peaku == "max"
            [alfa, beta, p, n] = MMBP_zisti_alfBetP_peakIsMax(data, chi_alfa,pocet_tried_hist);
        elseif typ_peaku == "changed"
            [alfa, beta, p, n] = MMBP_zisti_alfBetP_peakIsChanged(data, chi_alfa, average_multiplier,pocet_tried_hist);
        end
        gen_bits = generate_mmbp(n,length(data), alfa,beta,p);
        gen_sampled = sample_generated_data(gen_bits, n);
    end
end
