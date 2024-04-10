
clear;clc
tic;
addpath('C:\Users\patri\Documents\GitHub\MATLAB\Diplomka\funkcie');

% nižšie v kode treba nastavit compute_window a sigma_nasobok
where_to_store = "C:\Users\patri\Documents\GitHub\MATLAB\Diplomka\Automated\avg, ppeak";
attacks_folder_mat = "C:\Users\patri\Documents\GitHub\MATLAB\Utoky\";
shift = 1;
chi_alfa = 0.05;
pocet_tried_hist = 20;
simulacia = "MMBP"; % MMRP, MMBP
use_fourier = "yes"; % yes, default=no
keep_frequencies = 3;
slot_window = 0.01;
predict_window = 1000;

for j=1:8
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
    end
    
        %{
    elseif j == 2
        % kumul medzery txt
        file_path = "C:\Users\patri\Desktop\diplomka\Zaznamy\Finalisti - skopirovane z ostatnych\Kumulovane medzery\ISCX 1\ISCX 1.txt";
    elseif j == 3
        % kumul medzery csv
        file_path = "C:\Users\patri\Desktop\diplomka\Zaznamy\Finalisti - skopirovane z ostatnych\Kumulovane medzery\fri-01-20141113.Time\fri-01-20141113.Time.csv";
    elseif j == 4
        % pcap
        file_path = "C:\Users\patri\Desktop\diplomka\Zaznamy\Finalisti - skopirovane z ostatnych\Pcapy bez protokolov\A1\Moloch-180418-10-04-anonymized.pcap";
    elseif j == 5
        % csv pcap
        file_path = "C:\Users\patri\Desktop\diplomka\Zaznamy\záznamy\Pcapy s protokolmi\TIS - po kuskoch\0207_3051.csv";
    elseif j == 6
        % nekumul medzery txt
        file_path = "C:\Users\patri\Desktop\diplomka\Zaznamy\záznamy\nekumulovane medzery\ver_data\Ver_data.txt";
    end
        %}

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


    for l=2:4
        if l == 1
            compute_window = 500;
        elseif l == 2
            compute_window = 1000;
        elseif l == 3
            compute_window = 1500;
        elseif l == 4
            compute_window = 2000;
        end
    
        full_folder_name = folder_name + "\" + num2str(compute_window) + " cw";
        folder_path = fullfile(where_to_store, full_folder_name);
        
        if ~exist(folder_path, 'dir')
            mkdir(folder_path);
        end
        


        % save cely utok
        figall = figure('Visible', 'off');
        plot(cely_tok);
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

            average_folder_path = folder_path + "\" + num2str(average_multiplier) + " average_multiplier";
            if ~exist(average_folder_path, 'dir')
                mkdir(average_folder_path);
            end

            % zaciatok
            data = cely_tok(1:compute_window);
    
            if use_fourier == "yes"
                [data, fft_frequency] = fourier_smooth(data, keep_frequencies);
            end

            if simulacia == "MMRP"
                [alfa, beta, n] = MMRP_zisti_alfBet_peakIsChanged(data, average_multiplier);
                gen_data = generate_mmrp(n,length(data),alfa,beta);
            elseif simulacia == "MMBP"
                [alfa, beta, p, n] = MMBP_zisti_alfBetP_peakIsChanged(data, chi_alfa,average_multiplier,pocet_tried_hist);
                gen_data = generate_mmbp(n,length(data),alfa,beta,p);
            end

            gen_sampled = sample_generated_data(gen_data, n);


            % divergencia klzavo
            [diverg_array] = pouzi_diverg(cely_tok, gen_sampled, compute_window, shift, use_fourier, keep_frequencies);


            %%% diverg
            figure1 = figure('Visible', 'off');
            t = linspace(1,length(cely_tok),length(cely_tok));
            t2 = linspace(compute_window,length(cely_tok), length(cely_tok)-compute_window);
            plot(t,cely_tok,t2,diverg_array);
            grid on
            title("Kullback Leibler Divergencia")
            legend("Data","DKL");
            xlabel("Čas")
            ylabel("Počet paketov");
    
            % save diverg
            saveas(figure1,fullfile(average_folder_path,sprintf('DIVERG, compute_window=%d, shift=%d.fig',compute_window, shift)));
            saveas(figure1,fullfile(average_folder_path,sprintf('DIVERG, compute_window=%d, shift=%d.png',compute_window, shift)));
            close(figure1)

            clearvars -except M slot_window predict_window compute_window sigma_nasobok cely_tok file_path folder_path where_to_store attacks_folder_mat folder_name posun_dat shift pocet_tried_hist chi_alfa simulacia use_fourier keep_frequencies;    
            close all;
        end
    end
end



elapsedTime = toc;
fprintf('\nElapsed time is %.6f seconds.\n', elapsedTime);
