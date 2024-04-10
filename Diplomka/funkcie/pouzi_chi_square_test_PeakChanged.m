

function [chi2_stat_array, p_value_array, critical_value_array] = pouzi_chi_square_test_PeakChanged(cely_tok, gen_sampled, compute_window, shift, pocet_tried_hist, chi_alfa, use_fourier, keep_frequencies,simul_folder_path)

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

        [chi2_stat, p_value, critical_value] = chi_square_test(data,gen_sampled,chi_alfa, pocet_tried_hist);
    
        chi2_stat_array(k-1) = chi2_stat;
        p_value_array(k-1) = p_value;
        critical_value_array(k-1) = critical_value;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        if k == 2
            figure16 = figure('Visible', 'off');
            h = histogram(gen_sampled,pocet_tried_hist);
            title(sprintf('Hist generated od %d do %d',1,compute_window));
            xlabel("Triedy")
            ylabel("Počet paketov");
    
            saveas(figure16,fullfile(simul_folder_path,sprintf('lHist generated od %d do %d.fig',1,compute_window)));
            saveas(figure16,fullfile(simul_folder_path,sprintf('lHist generated od %d do %d.png',1,compute_window)));
        end

        % už len save histogramov
         if k == 2 || k == 3
            figure15 = figure('Visible', 'off');
            h = histogram(data,pocet_tried_hist);
            title(sprintf('Hist data od %d do %d.fig',from,to));
            xlabel("Triedy")
            ylabel("Počet paketov");

            saveas(figure15,fullfile(simul_folder_path,sprintf('lHist data od %d do %d.fig',from,to)));
            saveas(figure15,fullfile(simul_folder_path,sprintf('lHist data od %d do %d.png',from,to)));
        end
    end
end
