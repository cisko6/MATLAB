clear
clc

%parametre na menienie
% where_to_store, attacks_folder, posun_dat

where_to_store = "C:\Users\patri\Documents\GitHub\MATLAB\Diplomka\MMRP\MMRP automated";
attacks_folder = "C:\Users\patri\Documents\GitHub\MATLAB\Utoky\";

for p=1:9
    if p == 1
        file_path = fullfile(attacks_folder, "Attack_1.mat");
        from = 1;
        to = 10000;
    elseif p == 2
        file_path = fullfile(attacks_folder, "Attack_2_d010.mat");
        from = 1;
        to = 7500;
    elseif p == 3
        file_path = fullfile(attacks_folder, "Attack_3_d010.mat");
        from = 1;
        to = 5000;
    elseif p == 4
        file_path = fullfile(attacks_folder, "Attack_4_d0001.mat");
        from = 1;
        to = 3000;
    elseif p == 5
        file_path = fullfile(attacks_folder, "Attack_5_v1.mat");
        from = 1;
        to = 20000;
    elseif p == 6
        file_path = fullfile(attacks_folder, "Attack_5_v2.mat");
        from = 1;
        to = 22500;
    elseif p == 7
        file_path = fullfile(attacks_folder, "Attack_6.mat");
        from = 1;
        to = 7000;
    elseif p == 8
        file_path = fullfile(attacks_folder, "Attack_7.mat");
        from = 1;
        to = 8000;
    elseif p == 9
        file_path = fullfile(attacks_folder, "Attack_8.mat");
        from = 1;
        to = 5000;
    end



    for l=1:3
        if l == 1
            % hodnota tejto premennej vytvara foldre
            average_multiplier = 1.5;
        elseif l == 2
            average_multiplier = 2;
        elseif l == 3
            average_multiplier = 2.5;
        end
    
        [~, folder_name, ~] = fileparts(file_path);
        full_folder_name = folder_name + "\" + num2str(average_multiplier) + " average_multiplier";
        folder_path = fullfile(where_to_store, full_folder_name);
        
        if ~exist(folder_path, 'dir')
            mkdir(folder_path);
        end
        
        M = load(file_path);
        data = M.a(from:to);

        % zistenie alfa beta
        [alfa, beta, n] = zisti_alf_bet(data,average_multiplier);

        %generovanie a samplovanie mmrp
        mmrp_data = generate_mmrp(n*length(data),length(data),alfa,beta);
        mmrp_sampled = sample_generated_data(mmrp_data, ceil(n*length(data)), ceil(n));
        
        lastNonZeroIndex = find(mmrp_sampled, 1, 'last');
        mmrp_sampled = mmrp_sampled(1:lastNonZeroIndex);








        % upravit Y axis pre plot
        y_for_plot = max(max(data), max(mmrp_sampled));

        fig = figure;
        subplot(4,1,1)
        plot(data)
        xlim([0, length(data)])
        ylim([0, y_for_plot])
        xlabel("Čas")
        ylabel("Počet paketov");
        title(sprintf('Data od %d do %d z %s', from, to, folder_name));
    
        subplot(4,1,2)
        plot(mmrp_sampled)
        xlim([0, length(mmrp_sampled)])
        ylim([0, y_for_plot])
        xlabel("Čas")
        ylabel("Počet paketov");
        title("MMRP");
    
        subplot(4,1,3)
        hist_data = histogram(data, 'Normalization', 'probability');
        ylabel("Pravd.")
        xlabel("Triedy")
        title("Histogram dát")
    
        subplot(4,1,4)
        hist_mmrp = histogram(mmrp_sampled, 'Normalization', 'probability','NumBins',hist_data.NumBins, 'BinEdges',hist_data.BinEdges);
        ylabel("Pravd.")
        xlabel("Triedy")
        title("Histogram MMRP")


        % rovnaká Y os pre histogramy
        y_for_hist = max([hist_data.Values, hist_mmrp.Values]);
        if y_for_hist <= 0.1
            y_for_hist = y_for_hist + 0.01;
        elseif y_for_hist > 0.1 && y_for_hist < 0.5
            y_for_hist = y_for_hist + 0.05;
        else
            y_for_hist = y_for_hist + 0.2;
        end
        ylim(hist_data.Parent, [0 y_for_hist])
        ylim(hist_mmrp.Parent, [0 y_for_hist])

        % save data
        saveas(fig,fullfile(folder_path,sprintf('Vzorka_od_%d_do_%d.fig',from,to)));
        saveas(fig,fullfile(folder_path,sprintf('Vzorka_od_%d_do_%d.png',from,to)));

        clearvars -except M file_path folder_path where_to_store attacks_folder folder_name peak_multiplier from to;
        close all;
    end

    % save cely utok
    figall = figure;
    plot(M.a);
    title(sprintf('Utok - %s', folder_name));
    cely_tok_path = fullfile(where_to_store, folder_name);
    if ~exist(sprintf("%s/Cely_utok.png",cely_tok_path), 'file')
        saveas(figall,fullfile(cely_tok_path,"Cely_utok.png"));
        saveas(figall,fullfile(cely_tok_path,"Cely_utok.fig"));
    end
    close all;
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [alfa, beta, n] = zisti_alf_bet(data, average_multiplier)
    % mean, max, ppeak
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
