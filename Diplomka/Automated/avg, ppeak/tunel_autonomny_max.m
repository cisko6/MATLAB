
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
use_fourier = "yes"; % yes, default=no
typ_statistiky = "dkl"; % chi,dkl
keep_frequencies = 3;
slot_window = 0.01;
predict_window = 1000;
typ_peaku = "max"; % max only here
average_multiplier = 0;

for j=9:12
    if j == 1
        file_path = fullfile(attacks_folder_mat, "Attack_2_d010.mat");
    elseif j == 2
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
    elseif j == 9
        file_path = "C:\Users\patri\Desktop\diplomka\Zaznamy\Finalisti - skopirovane z ostatnych\FINALE\Attack_1-ISCX\Attack_1-ISCX 1.txt";
        %file_path = "C:\Users\patri\Desktop\diplomka\Zaznamy\Finalisti - skopirovane z ostatnych\FINALE\A1\A1_medzery.txt";
        slot_window = 0.01;
    elseif j == 10
        file_path = "C:\Users\patri\Desktop\diplomka\Zaznamy\Finalisti - skopirovane z ostatnych\FINALE\0207_3051.csv";
        slot_window = 0.01;
    elseif j == 11
        file_path = "C:\Users\patri\Desktop\diplomka\Zaznamy\Finalisti - skopirovane z ostatnych\FINALE\0504b_1316.csv";
        slot_window = 0.01;
    elseif j == 12
        file_path = "C:\Users\patri\Desktop\diplomka\Zaznamy\Finalisti - skopirovane z ostatnych\FINALE\0605b_10582.csv";
        slot_window = 0.01;
    end

    [~, attack_name, extension] = fileparts(file_path);

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
            cely_tok = sample_csvPcap(M, slot_window);
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


    filename_with_extension = sprintf('%s.txt', attack_name);
    fileID = fopen(filename_with_extension, 'a');
    
    for l=1:2
        if l == 1
            compute_window = 1000;
        elseif l == 2
            compute_window = 1500;
        elseif l == 3
            compute_window = 2000;
        end
    
        fprintf(fileID, '\n\nCOMPUTE WINDOOW = %d\n\n\n\n', compute_window);

        tunel_folder_name = attack_name + "\" + num2str(compute_window) + " cw\";
        tunel_folder_path = fullfile(where_to_store, tunel_folder_name);
        if ~exist(tunel_folder_path, 'dir')
            mkdir(tunel_folder_path);
        end

        % zaciatok
        data_cw = cely_tok(1:compute_window);
        N = length(cely_tok);

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
        for r=2:3
            if r == 1
                sigma_nasobok = 2;
            elseif r == 2
                sigma_nasobok = 3;
            elseif r == 3
                sigma_nasobok = 4;
            elseif r == 4
                sigma_nasobok = 5;
            end

            fprintf(fileID, 'Sigma_nasobok = %d\n\n', sigma_nasobok);

            [statistika_array, dolne_hranice, horne_hranice, index_H] = vytvor_autonomny_tunel2(cely_tok, compute_window,predict_window,typ_peaku,typ_statistiky,simulacia,chi_alfa,pocet_tried_hist,sigma_nasobok,average_multiplier,fileID,use_fourier,keep_frequencies);

            %[statistika_array, dolne_hranice, horne_hranice, index_H] = vytvor_autonomny_tunel1(cely_tok, compute_window,predict_window,typ_peaku,typ_statistiky,simulacia,chi_alfa,pocet_tried_hist,sigma_nasobok,average_multiplier,fileID,use_fourier,keep_frequencies);
    

            figtunel = figure;
            NN = length(statistika_array);
            t =  linspace(compute_window,NN+compute_window,NN);
            t2 = linspace(compute_window+predict_window,compute_window+predict_window+index_H-1,index_H);
            %t =  linspace(compute_window,N+compute_window-1,N);
            %t2 = linspace(compute_window+predict_window+1,N+compute_window-1,index_H);
            %t3 = linspace(0,N,N);
            %plot(t3,N,t,statistika_array,'b',t2,dolne_hranice,'r',t2,horne_hranice,'r')
            plot(t,statistika_array,'b',t2,dolne_hranice,'r',t2,horne_hranice,'r')
            ylim([(min(dolne_hranice)-mean(statistika_array)) (max(max(statistika_array),max(horne_hranice))+mean(statistika_array))]);
            xlim([0 N]);
            xlabel("Čas")
            ylabel(sprintf("Hodnoty %s",typ_statistiky));
            if typ_statistiky == "chi"
                title(sprintf("Tunel CHI, sigma=%d",sigma_nasobok));
            elseif typ_statistiky == "dkl"
                title(sprintf("Tunel DKL, sigma=%d",sigma_nasobok));
            end
            saveas(figtunel,fullfile(tunel_folder_name,sprintf('TUNEL, sigma=%d ,compute_window=%d, predict_window=%d.fig',sigma_nasobok,compute_window,predict_window)));
            saveas(figtunel,fullfile(tunel_folder_name,sprintf('TUNEL, sigma=%d , compute_window=%d, predict_window=%d.png',sigma_nasobok,compute_window,predict_window)));
            close(figtunel)

        end
        

        % save cely utok
        figall = figure;
        plot(cely_tok);
        xlim([0 N]);
        grid on
        title(sprintf('Utok - %s', attack_name));
        xlabel("Čas")
        ylabel("Počet paketov")
        cely_tok_path = fullfile(where_to_store, attack_name);
        if ~exist(sprintf("%s/Cely_utok.png",cely_tok_path), 'file')
            saveas(figall,fullfile(cely_tok_path,"Cely_utok.png"));
            saveas(figall,fullfile(cely_tok_path,"Cely_utok.fig"));
        end
        close(figall)
        


        clearvars -except M slot_window predict_window file_path sigma_nasobok average_multiplier typ_peaku folder_path where_to_store attacks_folder_mat folder_name compute_window typ_statistiky shift pocet_tried_hist chi_alfa simulacia use_fourier keep_frequencies cely_tok attack_name fileID;    
        close all;
    end
    fclose(fileID);
end


elapsedTime = toc;
fprintf('\nElapsed time is %.6f seconds.\n', elapsedTime);