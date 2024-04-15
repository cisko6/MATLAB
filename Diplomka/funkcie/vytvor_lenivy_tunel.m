

function [statistika_array, dolne_hranice, horne_hranice, index_H] = vytvor_lenivy_tunel(cely_tok,gen_prve_cw, compute_window,predict_window,typ_statistiky,chi_alfa,pocet_tried_hist,sigma_nasobok)
    N = length(cely_tok);
    statistika_array = zeros(1,N);
    dolne_hranice = zeros(1,N);
    horne_hranice = zeros(1,N);
    % vypocitanie prvych chi od 1 do 1000 a prvu hranicu tunelu
    for u=1:compute_window
        from = u;
        to = from + predict_window - 1;
        cast_dat = cely_tok(from:to);
        if typ_statistiky == "chi"
            [vysl] = chi_square_test(cast_dat,gen_prve_cw,chi_alfa,pocet_tried_hist);
        elseif typ_statistiky == "dkl"
            [vysl] = divergencia(cast_dat,gen_prve_cw);
        end
        statistika_array(u) = vysl;
    end
    
    
    
    [dH,hH] = vytvor_hranice_tunelu(statistika_array(1:compute_window),sigma_nasobok);
    index_H = 1;
    dolne_hranice(index_H) = dH;
    horne_hranice(index_H) = hH;
    
    
    % prechadzanie compute window klzavo
    for u=1:9999999
        from = u + compute_window;
        to = from + predict_window - 1;
        try
            cast_dat = cely_tok(from:to);
        catch
            %fprintf("try catch - u=%d\n",u)
            break
        end

        if typ_statistiky == "chi"
            [vysl] = chi_square_test(cast_dat,gen_prve_cw,chi_alfa,pocet_tried_hist);
        elseif typ_statistiky == "dkl"
            [vysl] = divergencia(cast_dat,gen_prve_cw);
        end
    
        statistika_array(u+predict_window) = vysl;
    
        %if vysl > horne_hranice(index_H)
            %fprintf("Horna hranica prekrocena na %d\n",u+compute_window)


            %break
            %[~,hH] = vypocitaj_hodnotu_hranice_tunelu(chi2_stat_array(u:u+predict_window),predict_window,tunel_sigma+1);
            %if chi2_stat > hH
             %   fprintf("Horna hranica prekrocena na %d\n",u)
            %    break
            %end
        %end
    
        %if vysl < dolne_hranice(index_H)
            %fprintf("Dolna hranica prekrocena na %d\n",u+compute_window)


            %break
            %[dH,~] = vypocitaj_hodnotu_hranice_tunelu(chi2_stat_array(u:u+predict_window),predict_window,tunel_sigma+1);
            %if chi2_stat < dH
            %    fprintf("Dolna hranica prekrocena na %d\n",u)
            %    break
            %end
        %end
        [dH,hH] = vytvor_hranice_tunelu(statistika_array(u+1:u+predict_window),sigma_nasobok);
        index_H = index_H + 1;
        dolne_hranice(index_H) = dH;
        horne_hranice(index_H) = hH;
    end
        statistika_array = statistika_array(1:find(statistika_array, 1, 'last'));
        dolne_hranice = dolne_hranice(1:find(dolne_hranice, 1, 'last'));
        horne_hranice = horne_hranice(1:find(horne_hranice, 1, 'last'));
end

