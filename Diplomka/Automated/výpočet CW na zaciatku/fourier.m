clear
clc

% do furierky v tomto stave ide len zaciatocny tok, potom sa porovnava s tym co prichadza

%parametre na menienie
% where_to_store, attacks_folder, posun_dat

where_to_store = "C:\Users\patri\Documents\GitHub\MATLAB\Diplomka\Automated\výpočet CW na zaciatku";
attacks_folder = "C:\Users\patri\Documents\GitHub\MATLAB\Utoky\";
shift = 1;
chi_alfa = 0.05;
pocet_tried_hist = 10;
percent_to_keep_fft = 0.2;

for p=1:9
    if p == 1
        file_path = fullfile(attacks_folder, "Attack_1.mat");
    elseif p == 2
        file_path = fullfile(attacks_folder, "Attack_2_d010.mat");
    elseif p == 3
        file_path = fullfile(attacks_folder, "Attack_3_d010.mat");
    elseif p == 4
        file_path = fullfile(attacks_folder, "Attack_4_d0001.mat");
    elseif p == 5
        file_path = fullfile(attacks_folder, "Attack_5_v1.mat");
    elseif p == 6
        file_path = fullfile(attacks_folder, "Attack_5_v2.mat");
    elseif p == 7
        file_path = fullfile(attacks_folder, "Attack_6.mat");
    elseif p == 8
        file_path = fullfile(attacks_folder, "Attack_7.mat");
    elseif p == 9
        file_path = fullfile(attacks_folder, "Attack_8.mat");
    end


    for l=1:3
        if l == 1
            posun_dat = 1000;
        elseif l == 2
            posun_dat = 1500;
        elseif l == 3
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


        data2 = M.a;
        data = data2(1:posun_dat);
        index = 1;

        % fourier
        [fourier_data, ca]=fourier_transform(data, percent_to_keep_fft);
        fourier_data(fourier_data < 0) = 0;

        figure4 = figure;
        plot(data);
        title("Originaly signal + Vysledny signal, ponechanych "+percent_to_keep_fft*100+"%");
        xlabel('Čas');
        ylabel('Počet paketov');
        hold on
        plot(fourier_data,'LineWidth',1)

        saveas(figure4,fullfile(folder_path,"Fourier_smoothing.fig"));
        saveas(figure4,fullfile(folder_path,"Fourier_smoothing.png"));
    
        % alfa, beta
        lambda_avg = mean(fourier_data);
        n = max(fourier_data);
        peak_count = numel(find(fourier_data==n));
        ppeak = peak_count/length(fourier_data);
        alfa = 1 - (ppeak * n/lambda_avg)^(1/(n-1));
        beta = (lambda_avg * alfa) / (n - lambda_avg);
        
        %generovanie a samplovanie mmrp
        gen_data = generate_mmrp(n*length(fourier_data),length(fourier_data),alfa,beta);
        gen_sampled = sample_generated_data(gen_data, ceil(n*length(fourier_data)), ceil(n));
        
        % vymazanie nul na konci z dát
        lastNonZeroIndex = find(gen_sampled, 1, 'last');
        gen_sampled = gen_sampled(1:lastNonZeroIndex);

        % pocitanie alf,bet,chi
        for k=2:2999999 %length(data)-posun_dat-shift
        
            if ~mod(k,shift) == 0
                continue
            end
        
            from = k + shift;
            to = from + posun_dat;
            try
                data = data2(from:to);
            catch
                break
            end
        
            % chi kvadrat
            data_chi = histcounts(data,pocet_tried_hist);
            mmrp_chi = histcounts(gen_sampled, length(data_chi));
    
            [chi2_stat, p_value, critical_value] = chi_square_test(data_chi,mmrp_chi,chi_alfa);
        
            chi2_stat_array(index) = chi2_stat;
            p_value_array(index) = p_value;
            critical_value_array(index) = critical_value;
        
            index = index + 1;
        end
    
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
        saveas(figure1,fullfile(folder_path,sprintf('DATA, posun_dat=%d, chi_alfa=%.2f, pocet_tried_hist=%d, shift=%d.fig',posun_dat,chi_alfa,pocet_tried_hist, shift)));
        saveas(figure1,fullfile(folder_path,sprintf('DATA, posun_dat=%d, chi_alfa=%.2f, pocet_tried_hist=%d, shift=%d.png',posun_dat,chi_alfa,pocet_tried_hist, shift)));
    
        saveas(figure2,fullfile(folder_path,sprintf('CHI2STAT_CRITICVALUE, posun_dat=%d, chi_alfa=%.2f, pocet_tried_hist=%d, shift=%d.fig',posun_dat,chi_alfa,pocet_tried_hist, shift)));
        saveas(figure2,fullfile(folder_path,sprintf('CHI2STAT_CRITICVALUE, posun_dat=%d, chi_alfa=%.2f, pocet_tried_hist=%d, shift=%d.png',posun_dat,chi_alfa,pocet_tried_hist, shift)));
    
        saveas(figure3,fullfile(folder_path,sprintf('PVALUE_CHIALFA, posun_dat=%d, chi_alfa=%.2f, pocet_tried_hist=%d, shift=%d.fig',posun_dat,chi_alfa,pocet_tried_hist, shift)));
        saveas(figure3,fullfile(folder_path,sprintf('PVALUE_CHIALFA, posun_dat=%d, chi_alfa=%.2f, pocet_tried_hist=%d, shift=%d.png',posun_dat,chi_alfa,pocet_tried_hist, shift)));
    
        clearvars -except M file_path folder_path where_to_store attacks_folder folder_name posun_dat shift pocet_tried_hist chi_alfa percent_to_keep_fft;    
        close all;
    end
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

function [result_data] = sample_generated_data(data, pocet_bitov, sample_size)
    result_data = zeros(1,pocet_bitov);
    
    pom_sum = sum(data(1:sample_size));
    result_data(1) = pom_sum;
    
    for i=1:(pocet_bitov/sample_size)-1
        pom_sum = sum(data((i*sample_size)+1:(i*sample_size)+sample_size));
        result_data(i+1) = pom_sum;
    end
end

function [chi2_stat, p_value, critical_value, df] = chi_square_test(obs1,obs2,chi_alfa)

    obs = [obs1; obs2];

    row_totals = sum(obs, 2);
    column_totals = sum(obs, 1);
    grand_total = sum(row_totals);

    expected = (row_totals * column_totals) / grand_total;
    
    % Find the valid categories where both observed and expected frequencies are non-zero
    % This should be a logical array with the same length as the number of categories
    valid_categories = all(expected > 0) & all(obs > 0);
    
    % Now index only those categories that are valid
    obs_valid = obs(:, valid_categories);
    expected_valid = expected(:, valid_categories);
    
    chi2_stat = sum(((obs_valid - expected_valid).^2) ./ expected_valid, 'all');
    
    % Calculate the degrees of freedom, which should be the number of valid categories - 1
    df = (sum(valid_categories) - 1) * (size(obs, 1) - 1);
    
    % Ensure the degrees of freedom are not negative
    if df > 0
        % Calculate the p-value
        p_value = 1 - chi2cdf(chi2_stat, df);
    else
        p_value = NaN; % The chi-square test is not applicable
    end



    %df = length(obs1) - 1;
    %p_value = 1 - chi2cdf(chi2_stat, df);
    critical_value = chi2inv(1 - chi_alfa, df);
end

function [fourier_output, ca, c] = fourier_transform(data, percent_to_keep_fft)
    N = length(data);
    
    c = fft(data) / N;
    ca = abs(c);
    ca(1) = 0;
    
    smooth_range = round(length(c) * percent_to_keep_fft / 2);
    smooth_range = max(smooth_range, 1);
    
    c(smooth_range+2:end-smooth_range) = 0;
    
    fourier_output = ifft(c) * N;
end
