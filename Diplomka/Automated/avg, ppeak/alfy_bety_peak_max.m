
clear
clc
addpath('C:\Users\patri\Documents\GitHub\MATLAB\Diplomka\funkcie');
%parametre na menienie
% where_to_store, attacks_folder, posun_dat

where_to_store = "C:\Users\patri\Documents\GitHub\MATLAB\Diplomka\Automated\avg, ppeak";
attacks_folder_mat = "C:\Users\patri\Documents\GitHub\MATLAB\Utoky\";
simulacia = "MMRP"; % MMRP, MMBP
chi_alfa = 0.05;
pocet_tried_hist = 20;

for j=2:2
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

    cely_tok_path = fullfile(where_to_store, attack_name);

    for l=1:3
        if l == 1
            compute_window = 1000;
        elseif l == 2
            compute_window = 1500;
        elseif l == 3
            compute_window = 2000;
        end

        full_folder_name = attack_name + "\" + num2str(compute_window) + "cw";
        folder_path = fullfile(where_to_store, full_folder_name);
        
        if ~exist(folder_path, 'dir')
            mkdir(folder_path);
        end

       
        priemer = zeros(1,length(cely_tok)-compute_window);
        alfy = zeros(1,length(cely_tok)-compute_window);
        bety = zeros(1,length(cely_tok)-compute_window);
        
        for k=1:999999 % počet posunov

            from = k;
            to = from + compute_window;
        
            try
                data = cely_tok(from:to);
            catch 
                break
            end

            if simulacia == "MMRP"
                [alfa, beta, n] = MMRP_zisti_alfBet_peakIsMax(data);
            elseif simulacia == "MMBP"
                [alfa, beta, p, n] = MMBP_zisti_alfBetP_peakIsMax(data, chi_alfa,pocet_tried_hist);
            end

            priemer(k) = mean(data);

            alfy(k) = alfa;
            bety(k) = beta;
        
            clearvars -except M priemer chi_alfa pocet_tried_hist attacks_folder_mat cely_tok_path cely_tok attack_name alfy bety compute_window simulacia file_path folder_path where_to_store attacks_folder posun_dat folder_name;
            close all;
        end

        nasobitel = 10000;
        if attack_name == "Attack_2_d010"
            nasobitel = 100000;
        end
        if attack_name == "Attack_3_d010"
            nasobitel = 10000000;
        end

        if attack_name == "Attack_5_v1"
            nasobitel = 100;
        end

        if attack_name == "Attack_5_v2" || attack_name == "Attack_6" || attack_name == "Attack_8"
            nasobitel = 1000;
        end

        if attack_name == "Attack_6" 
            nasobitel = 5000;
        end

        if attack_name == "Attack_1-ISCX 1" 
            nasobitel = 750;
        end

        alfy = alfy .* nasobitel;
        bety = bety .* nasobitel;
        

        % save alf bet
        fig = figure;
        t = linspace(0,length(cely_tok),length(cely_tok));
        t2 = linspace(compute_window,length(cely_tok),length(alfy));
        plot(t,cely_tok,'b', t2,alfy,'r',t2,bety,'m');
        %plot(t3,alfy,'r',t3,bety,'b',0,0.00001);
        grid on
        title(sprintf("alfa a beta, cw=%d",compute_window));
        legend("data","alfa","beta")
        xlabel("Čas");
        ylabel("Počet paketov");
        saveas(fig,fullfile(cely_tok_path,sprintf("alfa_beta_cw=%d.png",compute_window)));

        fig2= figure;
        t = linspace(0,length(cely_tok),length(cely_tok));
        t2 = linspace(compute_window,length(cely_tok),length(alfy));
        plot(t2,alfy,'r',t2,bety,'m',t,0)
        title("alfa a beta")
        grid on
        legend("alfa","beta")
        xlabel("Čas");
        ylabel("Hodnota");
        saveas(fig2,fullfile(cely_tok_path,sprintf("alfaa_betaa_cw=%d.png",compute_window)));

        fig3 = figure;
        alfbet_sucet = alfy + bety;
        t = linspace(0,length(cely_tok),length(cely_tok));
        t2 = linspace(compute_window,length(cely_tok),length(alfbet_sucet));
        plot(t2,alfbet_sucet,'m',t,0)
        title("sucet alf a bet");
        legend("sucet alf a bet");
        xlabel("Čas");
        ylabel("Hodnota súčtu");
        grid on
        saveas(fig3,fullfile(cely_tok_path,sprintf("sucetAlfBet_cw=%d.png",compute_window)));
    end
        %}
        %save cely tok
        figall = figure;
        t = linspace(0,length(cely_tok),length(cely_tok));
        t2 = linspace(compute_window,length(cely_tok),length(priemer));
        plot(t,cely_tok,'b');
        hold on
        plot(t2,priemer,'r','LineWidth', 2);
        title(sprintf('Utok - %s', attack_name));
        xlabel("Čas");
        ylabel("Počet paketov");
        if ~exist(sprintf("%s/Cely_utok.png",cely_tok_path), 'file')
            saveas(figall,fullfile(cely_tok_path,"Cely_utok.png"));
            %saveas(figall,fullfile(cely_tok_path,"Cely_utok.fig"));
        end
        close(figall)
end

