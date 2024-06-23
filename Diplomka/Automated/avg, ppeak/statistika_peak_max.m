
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
typ_statistiky = "chi"; % chi,dkl
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


    for l=1:3
        if l == 1
            compute_window = 1000;
        elseif l == 2
            compute_window = 1500;
        elseif l == 3
            compute_window = 2000;
        end
 
        full_folder_name = folder_name + "\" + num2str(compute_window) + " cw";
        folder_path = fullfile(where_to_store, full_folder_name);
        if ~exist(folder_path, 'dir')
            mkdir(folder_path);
        end

        % zaciatok
        data = cely_tok(1:compute_window);

        if use_fourier == "yes"
            [fft_data, fft_frequency] = fourier_smooth(data, keep_frequencies);
            data = fft_data;
        end

        if simulacia == "MMRP"
            [alfa, beta, n] = MMRP_zisti_alfBet_peakIsMax(data);
            gen_data = generate_mmrp(n,length(data),alfa,beta);
        elseif simulacia == "MMBP"
            [alfa, beta, p, n] = MMBP_zisti_alfBetP_peakIsMax(data, chi_alfa,pocet_tried_hist);
            gen_data = generate_mmbp(n,length(data),alfa,beta,p);
        end

        gen_sampled = sample_generated_data(gen_data, n);

        if typ_statistiky == "dkl"
            % divergencia klzavo
            [statistika_array] = pouzi_diverg(cely_tok, gen_sampled, compute_window, shift, use_fourier, keep_frequencies,pocet_tried_hist);
        elseif typ_statistiky == "chi"
            % chi klzavo
            [statistika_array] = pouzi_chi_square_test(cely_tok, gen_sampled, compute_window, shift, pocet_tried_hist, chi_alfa, use_fourier, keep_frequencies);
            % [statistika_array, p_value_array, critical_value_array] = pouzi_chi_square_test(cely_tok, gen_sampled, compute_window, shift, pocet_tried_hist, chi_alfa, use_fourier, keep_frequencies);
        end

        % save cely utok
        figall = figure('Visible', 'off');
        plot(cely_tok);
        xlabel("Čas")
        ylabel("Počet paketov")
        grid on
        title(sprintf('Utok - %s', folder_name));
        cely_tok_path = fullfile(where_to_store, folder_name);
        if ~exist(sprintf("%s/Cely_utok.png",cely_tok_path), 'file')
            saveas(figall,fullfile(cely_tok_path,"Cely_utok.png"));
            saveas(figall,fullfile(cely_tok_path,"Cely_utok.fig"));
        end
        close(figall)

        %%% diverg, chi
        figure1 = figure('Visible', 'off');
        t = linspace(1,length(cely_tok),length(cely_tok));
        t2 = linspace(compute_window,length(cely_tok), length(cely_tok)-compute_window);
        plot(t,cely_tok,t2,statistika_array,'r');
        grid on
        if typ_statistiky == "dkl"
            title("Kullback Leibler Divergencia")
            legend("Data","DKL");
        elseif typ_statistiky == "chi"
            title("Chi-kvadrát štatistika")
            legend("Data","Chi-štatistika");
        end
        xlabel("Čas")
        ylabel("Počet paketov");

        % save diverg, chi
        if typ_statistiky == "dkl"
            saveas(figure1,fullfile(folder_path,sprintf('DIVERG, compute_window=%d, shift=%d.fig',compute_window, shift)));
            saveas(figure1,fullfile(folder_path,sprintf('DIVERG, compute_window=%d, shift=%d.png',compute_window, shift)));
            close(figure1)
        elseif typ_statistiky == "chi"
            saveas(figure1,fullfile(folder_path,sprintf('CHI-STATISTICS, compute_window=%d, chi_alfa=%.2f, pocet_tried_hist=%d, shift=%d.png',compute_window,chi_alfa,pocet_tried_hist, shift)));
            saveas(figure1,fullfile(folder_path,sprintf('CHI-STATISTICS, compute_window=%d, chi_alfa=%.2f, pocet_tried_hist=%d, shift=%d.fig',compute_window,chi_alfa,pocet_tried_hist, shift)));
            close(figure1)
        end

        clearvars -except M slot_window predict_window file_path sigma_nasobok folder_path where_to_store attacks_folder_mat folder_name compute_window shift pocet_tried_hist chi_alfa simulacia use_fourier keep_frequencies cely_tok typ_statistiky;    
        close all;
    end
end


elapsedTime = toc;
fprintf('\nElapsed time is %.6f seconds.\n', elapsedTime);
