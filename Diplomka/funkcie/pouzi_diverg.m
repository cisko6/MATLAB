
function [diverg_array] = pouzi_diverg(cely_tok, gen_sampled, compute_window, shift, use_fourier, keep_frequencies)
    diverg_multiplier = max(gen_sampled) * 2;
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

        diverg_array(k-1) = divergencia(data,gen_sampled) * diverg_multiplier;
    end
end
