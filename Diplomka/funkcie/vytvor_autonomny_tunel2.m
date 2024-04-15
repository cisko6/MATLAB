
function [statistika_array, dolne_hranice, horne_hranice, index_H] = vytvor_autonomny_tunel2(cely_tok, compute_window,predict_window,typ_peaku,typ_statistiky,simulacia,chi_alfa,pocet_tried_hist,sigma_nasobok,average_multiplier,fileID,use_fourier,keep_frequencies)

    % generate prvu 1000
    data_prve_cw = cely_tok(1:compute_window);
    gen_cw = generate_universal(data_prve_cw,simulacia,typ_peaku,chi_alfa,pocet_tried_hist,average_multiplier);

    N = length(cely_tok);
    statistika_array = zeros(1,N);
    dolne_hranice = zeros(1,N);
    horne_hranice = zeros(1,N);
    % vypocitanie prvych chi od 1 do 1000 a prvu hranicu tunelu
    for u=1:compute_window
        from = u;
        to = from + predict_window - 1;

        cast_dat = cely_tok(from:to);
        if use_fourier == "yes"
            [fft_data] = fourier_smooth(cast_dat, keep_frequencies);
            cast_dat = fft_data;
        end
        
        if typ_statistiky == "chi"
            [vysl] = chi_square_test(cast_dat,gen_cw,chi_alfa,pocet_tried_hist);
        elseif typ_statistiky == "dkl"
            [vysl] = divergencia(cast_dat,gen_cw,pocet_tried_hist);
        end
        statistika_array(u) = vysl;
    end
    
    
    
    [dH,hH] = vytvor_hranice_tunelu(statistika_array(1:compute_window),sigma_nasobok);
    index_H = 1;
    dolne_hranice(index_H) = dH;
    horne_hranice(index_H) = hH;
    lastAdded = -1;

    % prechadzanie compute window klzavo
    for u=1:9999999
        from = u + compute_window;
        to = from + predict_window;% - 1;
        try
            cast_dat = cely_tok(from:to);
            if use_fourier == "yes"
                [fft_data] = fourier_smooth(cast_dat, keep_frequencies);
                cast_dat = fft_data;
            end
        catch
            %fprintf("try catch - u=%d\n",u)
            break
        end

        if typ_statistiky == "chi"
            [vysl] = chi_square_test(cast_dat,gen_cw,chi_alfa,pocet_tried_hist);
        elseif typ_statistiky == "dkl"
            [vysl] = divergencia(cast_dat,gen_cw,pocet_tried_hist);
        end
        statistika_array(u+predict_window) = vysl;


        if vysl > horne_hranice(index_H) || vysl < dolne_hranice(index_H)
            gen_cw = generate_universal(cast_dat,simulacia,typ_peaku,chi_alfa,pocet_tried_hist,average_multiplier);
            
            if typ_statistiky == "chi"
                [vysl] = chi_square_test(cast_dat,gen_cw,chi_alfa,pocet_tried_hist);
            elseif typ_statistiky == "dkl"
                [vysl] = divergencia(cast_dat,gen_cw,pocet_tried_hist);
            end
            statistika_array(u+predict_window) = vysl;

            if vysl > horne_hranice(index_H) || vysl < dolne_hranice(index_H)
                if lastAdded ~= (index_H-1)
                    fprintf(fileID, 'Utok nastal: %d\n', index_H+predict_window+compute_window);
                end
                lastAdded = index_H;
                %break
            end
        end


        [dH,hH] = vytvor_hranice_tunelu(statistika_array(u+1:u+predict_window),sigma_nasobok);
        index_H = index_H + 1;
        dolne_hranice(index_H) = dH;
        horne_hranice(index_H) = hH;
    end
    
    dolne_hranice = dolne_hranice(1:find(dolne_hranice, 1, 'last'));
    horne_hranice = horne_hranice(1:find(horne_hranice, 1, 'last'));
    statistika_array = statistika_array(1:length(horne_hranice)+predict_window-1); %%%% MOZNO - 1 PREC
    fprintf(fileID,'\n\n');
end

