
clear;clc
tic;
addpath('C:\Users\patri\Documents\GitHub\MATLAB\Diplomka\funkcie');

% nižšie v kode treba nastavit compute_window a sigma_nasobok
where_to_store = "C:\Users\patri\Documents\GitHub\MATLAB\Diplomka\Automated\avg, ppeak";
attacks_folder_mat = "C:\Users\patri\Documents\GitHub\MATLAB\Utoky\";
shift = 1;
chi_alfa = 0.05;
pocet_tried_hist = 20;
simulacia = "MMRP"; % MMRP, MMBP
use_fourier = "no"; % yes, default=no
typ_statistiky = "chi";
keep_frequencies = 3;
slot_window = 0.01;
predict_window = 1000;

for j=1:1
    if j == 1
        file_path = fullfile(attacks_folder_mat, "Attack_2_d010.mat");
    elseif j == 2
        %file_path = "C:\Users\patri\Desktop\mat subory\Attack_2_d005.mat";
        file_path = fullfile(attacks_folder_mat, "Attack_3_d010.mat");
    elseif j == 3
        file_path = fullfile(attacks_folder_mat, "Attack_4_d0001.mat");
    elseif j == 4
        file_path = fullfile(attacks_folder_mat, "Attack_5_v1.mat");
    elseif j == 5
        file_path = fullfile(attacks_folder_mat, "Attack_5_v2.mat");
    elseif j == 6
        file_path = fullfile(attacks_folder_mat, "Attack_6.mat");
    elseif j == 7
        file_path = fullfile(attacks_folder_mat, "Attack_7.mat");
    elseif j == 8
        file_path = fullfile(attacks_folder_mat, "Attack_8.mat");
    end
    
    [~, folder_name, extension] = fileparts(file_path);

    if extension == ".txt"
        M = importdata(file_path);
        suKumulovane = true;
        for i=1:min(length(M)-1, 50)
            if M(i) >= M(i+1)
                suKumulovane = false;
                break;
            end
        end
        if suKumulovane == true
            cely_tok = cumulatedSpaces_to_casy(M,slot_window);
        else
            cely_tok = medzery_to_casy(M, slot_window);
        end
    elseif extension == ".csv"
        M = readtable(file_path);
        variableExists = ismember('Var2', M.Properties.VariableNames);
        if variableExists
            data_casy = M.Var6;
            cely_tok = sample_csvPcap(data_casy, slot_window);
        else
            M = table2array(M);
            cely_tok = cumulatedSpaces_to_casy(M,slot_window);
        end
    elseif extension == ".mat"
        M = load(file_path);
        cely_tok = M.a;
    elseif extension == ".pcap"
        pcapAll = pcapReader(file_path);
        pcap = pcapAll.readAll;
        cely_tok = sample_pcap(pcap, slot_window);
    end



    for l=1:3
        if l == 1
            compute_window = 1000;
        elseif l == 2
            compute_window = 1500;
        elseif l == 3
            compute_window = 2000;
        end

        tunel_folder_name = folder_name + "\" + num2str(compute_window) + " cw\Tunel\";
        tunel_folder_path = fullfile(where_to_store, tunel_folder_name);
        if ~exist(tunel_folder_path, 'dir')
            mkdir(tunel_folder_path);
        end

        % zaciatok
        data_cw = cely_tok(1:compute_window);

        if use_fourier == "yes"
            [fft_data, fft_frequency] = fourier_smooth(data_cw, keep_frequencies);
            data_cw = fft_data;
        end

        if simulacia == "MMRP"
            [alfa, beta, n] = MMRP_zisti_alfBet_peakIsMax(data_cw);
            gen_data = generate_mmrp(n,length(data_cw),alfa,beta);
        elseif simulacia == "MMBP"
            [alfa, beta, p, n] = MMBP_zisti_alfBetP_peakIsMax(data_cw, chi_alfa,pocet_tried_hist);
            gen_data = generate_mmbp(n,length(data_cw),alfa,beta,p);
        end

        gen_prve_cw = sample_generated_data(gen_data, n);

        %%%% TUNEL %%%%
        for r=1:1
            if r == 1
                sigma_nasobok = 2;
            elseif r == 2
                sigma_nasobok = 3;
            elseif r == 3
                sigma_nasobok = 4;
            elseif r == 4
                sigma_nasobok = 5;
            end

            [chi2stat_array, dolne_hranice, horne_hranice, index_H] = vytvor_autonomny_tunel(cely_tok,gen_prve_cw, compute_window,predict_window,typ_statistiky,chi_alfa,pocet_tried_hist,sigma_nasobok);

            figtunel = figure('Visible', 'off');
            N = length(chi2stat_array);
            t =  linspace(compute_window,N+compute_window-1,N);
            t2 = linspace(compute_window+predict_window+1,N+compute_window-1,index_H);
            t3 = linspace(0,N+compute_window-1,N+compute_window);
            plot(t3,0,t,chi2stat_array,'b',t2,dolne_hranice,'r',t2,horne_hranice,'r')
            title(sprintf("Tunel, sigma=%d",sigma_nasobok));
            saveas(figtunel,fullfile(tunel_folder_name,sprintf('TUNEL, sigma=%d ,compute_window=%d, predict_window=%d.fig',sigma_nasobok,compute_window,predict_window)));
            saveas(figtunel,fullfile(tunel_folder_name,sprintf('TUNEL, sigma=%d , compute_window=%d, predict_window=%d.png',sigma_nasobok,compute_window,predict_window)));
            close(figtunel)

        end
   

        % save cely utok
        figall = figure('Visible', 'off');
        plot(cely_tok);
        grid on
        title(sprintf('Utok - %s', folder_name));
        cely_tok_path = fullfile(where_to_store, folder_name);
        if ~exist(sprintf("%s/Cely_utok.png",cely_tok_path), 'file')
            saveas(figall,fullfile(cely_tok_path,"Cely_utok.png"));
            saveas(figall,fullfile(cely_tok_path,"Cely_utok.fig"));
        end
        close(figall)
        


        clearvars -except M slot_window predict_window file_path sigma_nasobok folder_path where_to_store attacks_folder_mat folder_name compute_window typ_statistiky shift pocet_tried_hist chi_alfa simulacia use_fourier keep_frequencies cely_tok;    
        close all;
    end
end


elapsedTime = toc;
fprintf('\nElapsed time is %.6f seconds.\n', elapsedTime);