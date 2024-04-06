
clear;clc

%parametre na menienie
% where_to_store, attacks_folder, posun_dat

where_to_store = "C:\Users\patri\Documents\GitHub\MATLAB\Diplomka\Automated\výpočet CW na zaciatku";
attacks_folder = "C:\Users\patri\Documents\GitHub\MATLAB\Utoky\";
shift = 1;
chi_alfa = 0.05;
pocet_tried_hist = 10;
simulacia = "MMRP"; % MMRP, MMBP
use_fourier = "yes"; % yes, default=no
keep_frequencies = 3;

for j=1:9
    if j == 1
        file_path = fullfile(attacks_folder, "Attack_1.mat");
    elseif j == 2
        file_path = fullfile(attacks_folder, "Attack_2_d010.mat");
    elseif j == 3
        file_path = fullfile(attacks_folder, "Attack_3_d010.mat");
    elseif j == 4
        file_path = fullfile(attacks_folder, "Attack_4_d0001.mat");
    elseif j == 5
        file_path = fullfile(attacks_folder, "Attack_5_v1.mat");
    elseif j == 6
        file_path = fullfile(attacks_folder, "Attack_5_v2.mat");
    elseif j == 7
        file_path = fullfile(attacks_folder, "Attack_6.mat");
    elseif j == 8
        file_path = fullfile(attacks_folder, "Attack_7.mat");
    elseif j == 9
        file_path = fullfile(attacks_folder, "Attack_8.mat");
    end


    for l=1:4
        if l == 1
            posun_dat = 500;
        elseif l == 2
            posun_dat = 1000;
        elseif l == 3
            posun_dat = 1500;
        elseif l == 4
            posun_dat = 2000;
        end
    
        [~, folder_name, ~] = fileparts(file_path);
        full_folder_name = folder_name + "\" + num2str(posun_dat) + " cw";
        folder_path = fullfile(where_to_store, full_folder_name);
        
        if ~exist(folder_path, 'dir')
            mkdir(folder_path);
        end
        

        M = load(file_path);
        % save cely utok
        figall = figure;
        plot(M.a);
        title(sprintf('Utok - %s', folder_name));
        cely_tok_path = fullfile(where_to_store, folder_name);
        if ~exist(sprintf("%s/Cely_utok.png",cely_tok_path), 'file')
            saveas(figall,fullfile(cely_tok_path,"Cely_utok.png"));
            saveas(figall,fullfile(cely_tok_path,"Cely_utok.fig"));
        end
        close(figall)


        for o=1:5 % average_multiplier
            if o == 1
                % hodnota tejto premennej vytvara foldre
                average_multiplier = 2;
            elseif o == 2
                average_multiplier = 2.5;
            elseif o == 3
                average_multiplier = 3;
            elseif o == 4
                average_multiplier = 3.5;
            elseif o == 5
                average_multiplier = 4;
            end

            average_folder_path = folder_path + "\" + num2str(average_multiplier) + " average_multiplier";
            if ~exist(average_folder_path, 'dir')
                mkdir(average_folder_path);
            end

            cely_tok = M.a;
            data = cely_tok(1:posun_dat);
    
            if use_fourier == "yes"
                [data, fft_frequency] = fourier_smooth(data, keep_frequencies);
            end

            if simulacia == "MMRP"
                [alfa, beta, n] = MMRP_zisti_alfBet_peakIsChanged(data, average_multiplier);
                gen_data = generate_mmrp(n*length(data),length(data),alfa,beta);
            elseif simulacia == "MMBP"
                [alfa, beta, p, n] = MMBP_zisti_alfBetP_peakIsChanged(data, chi_alfa,average_multiplier);
                gen_data = generate_mmbp(n,length(data),alfa,beta,p);
            end

            gen_sampled = sample_generated_data(gen_data, n, length(data));

            % chi square test klzavo
            [chi2_stat_array, p_value_array, critical_value_array] = pouzi_chi_square_test(cely_tok, gen_sampled, posun_dat, shift, pocet_tried_hist, chi_alfa);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % save simulaciu
            simul_folder_name = folder_name + "\pociatocna_simulacia\"+ num2str(posun_dat) + " cw\" + num2str(average_multiplier) + " average_multiplier";
            simul_folder_path = fullfile(where_to_store, simul_folder_name);
            if ~exist(simul_folder_path, 'dir')
                mkdir(simul_folder_path);
            end
    
            if use_fourier == "yes"
                figure14 = figure;
                plot(cely_tok(1:posun_dat));
                hold on
                plot(fft_frequency);
                xlim([0 length(cely_tok(1:posun_dat))])
                ylim([0 n])
                title(sprintf('Data pred FFT od %d do %d',1,posun_dat));
                legend("Data");
                xlabel("Čas")
                ylabel("Počet paketov");
                saveas(figure14,fullfile(simul_folder_path,sprintf('Data pred FFT od %d do %d.fig', 1,posun_dat)));
                saveas(figure14,fullfile(simul_folder_path,sprintf('Data pred FFT od %d do %d.png', 1,posun_dat)));
            end
    
            figure10 = figure;
            plot(data);
            xlim([0 length(data)])
            ylim([0 n])
            if use_fourier == "yes"
                title(sprintf('Data po FFT od %d do %d',1,posun_dat));
            else
                title(sprintf('Data od %d do %d',1,posun_dat));
            end
            legend("Data");
            xlabel("Čas")
            ylabel("Počet paketov");
            if use_fourier == "yes"
                saveas(figure10,fullfile(simul_folder_path,sprintf('Data po FFT od %d do %d.fig', 1,posun_dat)));
                saveas(figure10,fullfile(simul_folder_path,sprintf('Data po FFT od %d do %d.png', 1,posun_dat)));
            else
                saveas(figure10,fullfile(simul_folder_path,sprintf('Data od %d do %d.fig', 1,posun_dat)));
                saveas(figure10,fullfile(simul_folder_path,sprintf('Data od %d do %d.png', 1,posun_dat)));
            end
    
            figure11 = figure;
            plot(gen_sampled);
            xlim([0 length(gen_sampled)])
            ylim([0 n])
            title(sprintf('%s od %d do %d', simulacia,1,posun_dat));
            legend(sprintf('%s', simulacia));
            xlabel("Čas")
            ylabel("Počet paketov");
            saveas(figure11,fullfile(simul_folder_path,sprintf('e%s od %d do %d.fig', simulacia,1,posun_dat)));
            saveas(figure11,fullfile(simul_folder_path,sprintf('e%s od %d do %d.png', simulacia,1,posun_dat)));
    
            % y pre histogramy
            ylim_hist = max( ...
                        max(histcounts(data, 'Normalization', 'probability')), ...
                        max(histcounts(gen_sampled, 'Normalization', 'probability')));
            
            if ylim_hist <= 0.1
                ylim_hist = ylim_hist + 0.01;
            elseif ylim_hist > 0.1 && ylim_hist < 0.5
                ylim_hist = ylim_hist + 0.05;
            else
                ylim_hist = ylim_hist + 0.2;
            end
    
            figure12 = figure;
            aa = histogram(data,'Normalization', 'probability');
            ylim([0 ylim_hist])
            title(sprintf('Hist data od %d do %d',1,posun_dat));
            xlabel("Triedy")
            ylabel("P");
    
            figure13 = figure;
            bb = histogram(gen_sampled,'Normalization', 'probability','NumBins',aa.NumBins);
            ylim([0 ylim_hist])
            title(sprintf('Hist %s od %d do %d', simulacia,1,posun_dat));
            xlabel("Triedy")
            ylabel("P");
            
            % nastavenie X os pre histogramy
            xlim_hist = max(max(aa.BinEdges),max(bb.BinEdges));
            xlim(aa.Parent, [0 xlim_hist])
            xlim(bb.Parent, [0 xlim_hist])
    
            saveas(figure12,fullfile(simul_folder_path,sprintf('Hist data od %d do %d.fig', 1,posun_dat)));
            saveas(figure12,fullfile(simul_folder_path,sprintf('Hist data od %d do %d.png', 1,posun_dat)));
    
            saveas(figure13,fullfile(simul_folder_path,sprintf('Hist %s od %d do %d.fig', simulacia,1,posun_dat)));
            saveas(figure13,fullfile(simul_folder_path,sprintf('Hist %s od %d do %d.png', simulacia,1,posun_dat)));

            %%%
            figure1 = figure;
            plot(M.a)
            title("data")
            legend("data");
            xlabel("Čas")
            ylabel("Počet paketov");

            figure2 = figure;
            x = posun_dat:(posun_dat + length(critical_value_array) - 1);
            plot(x,critical_value_array,'r');
            hold on
            plot(x,chi2_stat_array,'b');
            xlabel("Čas")
            ylabel("Hodnoty");
            xlim([0 length(M.a)])
            legend("critical value","chi2stat");
            title("critical value, chi2stat");
            
            figure3 = figure;
            chi_alfa_plot(1:length(p_value_array)) = chi_alfa;
            x = posun_dat:(posun_dat + length(chi_alfa_plot) - 1);
            plot(x,chi_alfa_plot,'m');
            hold on
            startIdx = 1;
            for i = 2:length(p_value_array)
                if (i == length(p_value_array)) || (p_value_array(i) == 0 && p_value_array(i+1) ~= 0) || (p_value_array(i) ~= 0 && p_value_array(i+1) == 0)
                    endIdx = i;
                    color = 'g';
                    if p_value_array(startIdx) == 0
                        color = 'r';
                    end
                    plot(x(startIdx:endIdx), p_value_array(startIdx:endIdx), color, 'LineWidth', 2);
                    startIdx = i+1;
                end
            end
            xlabel("Čas")
            ylabel("Hodnoty");
            xlim([0 length(M.a)])
            title("alfa, p-value, if p-value is 0 then it is red");
            legend("alfa","p-value");
        
            % save data
            saveas(figure1,fullfile(average_folder_path,sprintf('DATA, posun_dat=%d, chi_alfa=%.2f, pocet_tried_hist=%d, shift=%d.fig',posun_dat,chi_alfa,pocet_tried_hist, shift)));
            saveas(figure1,fullfile(average_folder_path,sprintf('DATA, posun_dat=%d, chi_alfa=%.2f, pocet_tried_hist=%d, shift=%d.png',posun_dat,chi_alfa,pocet_tried_hist, shift)));
        
            saveas(figure2,fullfile(average_folder_path,sprintf('CHI2STAT_CRITICVALUE, posun_dat=%d, chi_alfa=%.2f, pocet_tried_hist=%d, shift=%d.fig',posun_dat,chi_alfa,pocet_tried_hist, shift)));
            saveas(figure2,fullfile(average_folder_path,sprintf('CHI2STAT_CRITICVALUE, posun_dat=%d, chi_alfa=%.2f, pocet_tried_hist=%d, shift=%d.png',posun_dat,chi_alfa,pocet_tried_hist, shift)));
        
            saveas(figure3,fullfile(average_folder_path,sprintf('PVALUE_CHIALFA, posun_dat=%d, chi_alfa=%.2f, pocet_tried_hist=%d, shift=%d.fig',posun_dat,chi_alfa,pocet_tried_hist, shift)));
            saveas(figure3,fullfile(average_folder_path,sprintf('PVALUE_CHIALFA, posun_dat=%d, chi_alfa=%.2f, pocet_tried_hist=%d, shift=%d.png',posun_dat,chi_alfa,pocet_tried_hist, shift)));
        
            clearvars -except M file_path folder_path where_to_store attacks_folder folder_name posun_dat shift pocet_tried_hist chi_alfa simulacia use_fourier keep_frequencies;    
            close all;
        end
    end
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [fourier_data, y_final] = fourier_smooth(data, keep_frequencies)
    
    N = length(data);
    t = linspace(1,N,N);

    % fft
    c = fft(data)./N;
    c(1)=0;
    ca = abs(c);
    
    % zisti najvacsie indexy
    c_pom = c(1:length(c)/2);
    biggest_indexes = zeros(1, keep_frequencies);
    for i = 1:keep_frequencies
        [~, index] = max(c_pom);
        biggest_indexes(i) = index;
        c_pom(index) = 0;
    end
    
    % ponechaj iba par frekvencii
    y_pom = 0;
    for i = 1:keep_frequencies
        y_final = y_pom + 2*real(c(biggest_indexes(i)))*cos((biggest_indexes(i)-1)*t*2*pi/N)-2*imag(c(biggest_indexes(i)))*sin((biggest_indexes(i)-1)*t*2*pi/N)+c(1);
        y_pom = y_final;
    end
    
    fourier_data = data-y_final;
    fourier_data(fourier_data < 0) = 0;
    fourier_data = round(fourier_data);

    y_final = y_final+mean(data);
end

function [alfa, beta, n] = MMRP_zisti_alfBet_peakIsChanged(data, average_multiplier)

    lambda_avg = mean(data);
    max_data = max(data);
    n = round(average_multiplier * lambda_avg);
    if n > max_data
        n = max_data;
    end

    peak_count = numel(find(data==n));
    if peak_count == 0
        peak_count = 1;
    end

    ppeak = peak_count/length(data);

    %alfa beta
    alfa = 1 - (ppeak * n/lambda_avg)^(1/(n-1));
    beta = (lambda_avg * alfa) / (n - lambda_avg);
end

function [alfa, beta, p, n] = MMBP_zisti_alfBetP_peakIsChanged(data, chi_alfa, average_multiplier)
    % zistenie n, lambda_avg, ppeak
    lambda_avg = mean(data);

    n = round(average_multiplier * lambda_avg);
    max_data = max(data);
    if n > max_data
        n = max_data;
    end
    
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
            %if i == 1
            %    p_pom = 0.900; %%%%% ??
            %    continue
            %end
            break
        end
    
        alfa_pom = 1 - ((n * ppeak / lambda_avg)^(1 / (n - 1))) * 1 / p_pom;
        beta_pom = (lambda_avg * alfa_pom) / ((n * p_pom) - lambda_avg);
    
        % generovanie a samplovanie dat
        pom_mmbp = generate_mmbp(n,length(data),alfa_pom,beta_pom,p_pom);
        pom_samped_mmbp = sample_generated_data(pom_mmbp, n, length(data));
        % zistenie chi statistiky
        [chi2_stat] = chi_square_test(pom_samped_mmbp,data,chi_alfa);
    
        chi2_statistics(i) = chi2_stat;
        alfy(i) = alfa_pom;
        bety(i) = beta_pom;
        p_pravdepodobnosti(i) = p_pom;
    
        p_pom = p_pom + 0.001;
    end
    chi2_statistics = chi2_statistics(1:i-1);
    [~, index] = max(chi2_statistics);
    alfa = alfy(index);
    beta = bety(index);
    p = p_pravdepodobnosti(index);
end

function [mmrp_data] = generate_mmrp(pocet_bitov,dlzka_dat, alfa,beta)
    mmrp_data = zeros(1,ceil(dlzka_dat));

    stav = 1;
    for i=1:pocet_bitov
        if stav == 1
            mmrp_data(i) = 1;
    
            pravd = 1.*rand();
            if pravd >= (1 - alfa)
                stav = 0;
            end
        else
            mmrp_data(i) = 0;
    
            pravd = 1.*rand();
            if pravd >= (1-beta)
                stav = 1;
            end
        end
    end
end

function [mmbp_data] = generate_mmbp(n,dlzka_dat, alfa,beta,p)
    
    pocet_bitov = n * dlzka_dat;
    mmbp_data = zeros(1,ceil(dlzka_dat));
    stav = 1;

    counter_one = 0;
    counter_zero = 0;
    % generovanie sekvencie bitov
    for i=1:pocet_bitov
        if stav == 1
            pravd_p = 1.*rand();
            if pravd_p <= p     % mmbp parameter pravdepodobnosti na 1
                mmbp_data(i) = 1;
                counter_one = counter_one + 1;
            else
                mmbp_data(i) = 0;
                counter_zero = counter_zero + 1;
            end
    
            % či sa mení stav
            pravd = 1.*rand();
            if pravd >= (1 - alfa)
                stav = 0;
            end
        else
            mmbp_data(i) = 0;
            counter_zero = counter_zero + 1;
    
            % či sa mení stav
            pravd = 1.*rand();
            if pravd >= (1-beta)
                stav = 1;
            end
        end
    end
end

function [sampled_data] = sample_generated_data(data, n, dlzka_dat)
    n = round(n);
    pocet_bitov = ceil(n*dlzka_dat);
    sampled_data = zeros(1,pocet_bitov);
    
    pom_sum = sum(data(1:n));
    sampled_data(1) = pom_sum;

    for i=1:(pocet_bitov/n)-1
        try
            pom_sum = sum(data((i*n)+1:(i*n)+n));
        catch
            break
        end
        sampled_data(i+1) = pom_sum;
    end
    sampled_data = sampled_data(1:dlzka_dat);
end

function [chi2_stat, p_value, critical_value, df] = chi_square_test(obs1,obs2,chi_alfa)

    obs = [obs1; obs2];

    row_totals = sum(obs, 2);
    column_totals = sum(obs, 1);
    grand_total = sum(row_totals);

    expected = (row_totals * column_totals) / grand_total;

    valid_categories = all(expected > 0) & all(obs > 0);

    obs_valid = obs(:, valid_categories);
    expected_valid = expected(:, valid_categories);
    
    chi2_stat = sum(((obs_valid - expected_valid).^2) ./ expected_valid, 'all');
    
    df = (sum(valid_categories) - 1) * (size(obs, 1) - 1);
    
    if df > 0
        p_value = 1 - chi2cdf(chi2_stat, df);
    else
        p_value = NaN; % The chi-square test is not applicable
    end

    critical_value = chi2inv(1 - chi_alfa, df);
end

function [chi2_stat_array, p_value_array, critical_value_array] = pouzi_chi_square_test(cely_tok, gen_sampled, posun_dat, shift, pocet_tried_hist, chi_alfa, use_fourier, keep_frequencies,simul_folder_path)

    for k=2:9999999
    
        if ~mod(k,shift) == 0
            continue
        end
    
        from = k + shift - 1;
        to = from + posun_dat - 1;
        try
            data = cely_tok(from:to);
        catch
            break
        end
    
        if use_fourier == "yes"
            data = fourier_smooth(data, keep_frequencies);
        end

        % chi kvadrat
        data_chi = histcounts(data,pocet_tried_hist);
        gen_chi = histcounts(gen_sampled, length(data_chi));

        [chi2_stat, p_value, critical_value] = chi_square_test(data_chi,gen_chi,chi_alfa);
    
        chi2_stat_array(k-1) = chi2_stat;
        p_value_array(k-1) = p_value;
        critical_value_array(k-1) = critical_value;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        if k == 2
            figure16 = figure('Visible', 'off');
            histogram(gen_sampled,NumBins=pocet_tried_hist);
            title(sprintf('Hist generated od %d do %d',1,posun_dat));
            xlabel("Triedy")
            ylabel("Počet paketov");
    
            saveas(figure16,fullfile(simul_folder_path,sprintf('Hist generated od %d do %d.fig',1,posun_dat)));
            saveas(figure16,fullfile(simul_folder_path,sprintf('Hist generated od %d do %d.png',1,posun_dat)));
        end

        % už len save histogramov
        if k == 2 || k == 3
            figure15 = figure('Visible', 'off');
            histogram(data,NumBins=pocet_tried_hist);
            title(sprintf('Hist data od %d do %d.fig',from,to));
            xlabel("Triedy")
            ylabel("Počet paketov");

            saveas(figure15,fullfile(simul_folder_path,sprintf('Hist data od %d do %d.fig',from,to)));
            saveas(figure15,fullfile(simul_folder_path,sprintf('Hist data od %d do %d.png',from,to)));
        end
    end
end

%{
% in case ze by nefungovalo to co som pridal

function [chi2_stat_array, p_value_array, critical_value_array] = pouzi_chi_square_test(cely_tok, gen_sampled, posun_dat, shift, pocet_tried_hist, chi_alfa, use_fourier, keep_frequencies)

    for k=2:9999999
    
        if ~mod(k,shift) == 0
            continue
        end
    
        from = k + shift;
        to = from + posun_dat - 1;
        try
            data = cely_tok(from:to);
        catch
            break
        end
    
        if use_fourier == "yes"
            data = fourier_smooth(data, keep_frequencies);
        end

        % chi kvadrat
        data_chi = histcounts(data,pocet_tried_hist);
        mmrp_chi = histcounts(gen_sampled, length(data_chi));

        [chi2_stat, p_value, critical_value] = chi_square_test(data_chi,mmrp_chi,chi_alfa);
    
        chi2_stat_array(k-1) = chi2_stat;
        p_value_array(k-1) = p_value;
        critical_value_array(k-1) = critical_value;
    end
end
%}