
clear
clc

%parametre na menienie
% where_to_store, attacks_folder, posun_dat

where_to_store = "C:\Users\patri\Documents\GitHub\MATLAB\Diplomka\Automated\avg, ppeak";
attacks_folder_mat = "C:\Users\patri\Documents\GitHub\MATLAB\Utoky\";
simulacia = "MMRP"; % MMRP, MMBP


for i=1:8
    if i == 1
        file_path = fullfile(attacks_folder_mat, "Attack_2_d010.mat");
    elseif i == 2
        file_path = fullfile(attacks_folder_mat, "Attack_3_d010.mat");
    elseif i == 3
        file_path = fullfile(attacks_folder_mat, "Attack_4_d0001.mat");
    elseif i == 4
        file_path = fullfile(attacks_folder_mat, "Attack_5_v1.mat");
    elseif i == 5
        file_path = fullfile(attacks_folder_mat, "Attack_5_v2.mat");
    elseif i == 6
        file_path = fullfile(attacks_folder_mat, "Attack_6.mat");
    elseif i == 7
        file_path = fullfile(attacks_folder_mat, "Attack_7.mat");
    elseif i == 8
        file_path = fullfile(attacks_folder_mat, "Attack_8.mat");
    end


    for l=1:3
        if l == 1
            compute_window = 1000;
        elseif l == 2
            compute_window = 1500;
        elseif l == 3
            compute_window = 2000;
        end
    
        [~, folder_name, ~] = fileparts(file_path);
        full_folder_name = folder_name + "\" + num2str(compute_window) + "cw";
        folder_path = fullfile(where_to_store, full_folder_name);
        
        if ~exist(folder_path, 'dir')
            mkdir(folder_path);
        end
        
        M = load(file_path);
        cely_tok = M.a;
        
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
        

        for o=1:3
            if o == 1
                average_multiplier = 2;
            elseif o == 2
                average_multiplier = 3;
            elseif o == 3
                average_multiplier = 4;
            elseif o == 4
                average_multiplier = 2.5;
            elseif o == 5
                average_multiplier = 3.5;
            end

            for k=1:999999 % počet posunov
            
                data = M.a;
            
                from = (k-1)*compute_window + 1;
                to = from + compute_window;
                
                if from > length(data)
                    break
                end
            
                try
                    data = data(from:to);
                catch 
                    to = to - (to-length(data));
                    data = data(from : to);
                end
                
                if simulacia == "MMRP"
                    [alfa, beta, n] = MMRP_zisti_alfBet_peakIsChanged(data, average_multiplier);
                elseif simulacia == "MMBP"
                    [alfa, beta, p, n] = MMBP_zisti_alfBetP_peakIsMax(data_cw, chi_alfa,pocet_tried_hist);
                end
    
                alfy(k) = alfa;
                bety(k) = beta;
            
                clearvars -except M average_multiplier attacks_folder_mat average_folder_path cely_tok_path cely_tok alfy bety compute_window simulacia file_path folder_path where_to_store attacks_folder posun_dat folder_name;
                close all;
            end
    
    
            % save alf bet
            fig = figure;
            t = linspace(1,length(cely_tok),length(cely_tok));
            t2 = linspace(compute_window,length(cely_tok),length(alfy));
            plot(t2,alfy,'r',t2,bety,'b',0,0.00001);
            grid on
            title(sprintf("alfa a beta, cw=%d, %dx avg",compute_window,average_multiplier));
            legend("alfa","beta")
    
            % save data
            saveas(fig,fullfile(cely_tok_path,sprintf("alfa_beta_cw=%d, %dx avg.fig",compute_window,average_multiplier)));
            saveas(fig,fullfile(cely_tok_path,sprintf("alfa_beta_cw=%d, %dx avg.png",compute_window,average_multiplier)));

        end
    end
end

