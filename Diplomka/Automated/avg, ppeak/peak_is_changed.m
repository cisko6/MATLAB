
clear;clc
tic;
addpath('C:\Users\patri\Documents\GitHub\MATLAB\Diplomka\funkcie');

% nižšie v kode treba nastavit compute_window a sigma_nasobok
where_to_store = "C:\Users\patri\Documents\GitHub\MATLAB\Diplomka\Automated\avg, ppeak";
attacks_folder_mat = "C:\Users\patri\Documents\GitHub\MATLAB\Utoky\";
shift = 1;
chi_alfa = 0.05;
pocet_tried_hist = 10;
simulacia = "MMRP"; % MMRP, MMBP
use_fourier = "no"; % yes, default=no
keep_frequencies = 3;
slot_window = 0.01;
predict_window = 1000;

for j=1:1
    if j == 1
        file_path = "C:\Users\patri\Desktop\mat subory\Attack_2_d005.mat";
        %file_path = fullfile(attacks_folder_mat, "Attack_1.mat");
    elseif j == 2
        file_path = fullfile(attacks_folder_mat, "Attack_2_d010.mat");
    elseif j == 3
        file_path = fullfile(attacks_folder_mat, "Attack_3_d010.mat");
    elseif j == 4
        file_path = fullfile(attacks_folder_mat, "Attack_4_d0001.mat");
    elseif j == 5
        file_path = fullfile(attacks_folder_mat, "Attack_5_v1.mat");
    elseif j == 6
        file_path = fullfile(attacks_folder_mat, "Attack_5_v2.mat");
    elseif j == 7
        file_path = fullfile(attacks_folder_mat, "Attack_6.mat");
    elseif j == 8
        file_path = fullfile(attacks_folder_mat, "Attack_7.mat");
    elseif j == 9
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


    for l=1:2
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


        for o=3:5
            if o == 1
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

            % zaciatok
            data = cely_tok(1:compute_window);
    
            if use_fourier == "yes"
                [data, fft_frequency] = fourier_smooth(data, keep_frequencies);
            end

            if simulacia == "MMRP"
                [alfa, beta, n] = MMRP_zisti_alfBet_peakIsChanged(data, average_multiplier);
                gen_data = generate_mmrp(n,length(data),alfa,beta);
            elseif simulacia == "MMBP"
                [alfa, beta, p, n] = MMBP_zisti_alfBetP_peakIsChanged(data, chi_alfa,average_multiplier);
                gen_data = generate_mmbp(n,length(data),alfa,beta,p);
            end

            gen_sampled = sample_generated_data(gen_data, n, length(data));


            simul_folder_name = folder_name + "\pociatocna_simulacia\"+ num2str(compute_window) + " cw\" + num2str(average_multiplier) + " average_multiplier";
            simul_folder_path = fullfile(where_to_store, simul_folder_name);
            if ~exist(simul_folder_path, 'dir')
                mkdir(simul_folder_path);
            end

            % chi square test klzavo
            [chi2_stat_array, p_value_array, critical_value_array] = pouzi_chi_square_test_PeakChanged(cely_tok, gen_sampled, compute_window, shift, pocet_tried_hist, chi_alfa, use_fourier, keep_frequencies,simul_folder_path);

            %%%% TUNEL %%%%
            for r=1:4
                if r == 1
                    sigma_nasobok = 2;
                elseif r == 2
                    sigma_nasobok = 3;
                elseif r == 3
                    sigma_nasobok = 4;
                elseif r == 4
                    sigma_nasobok = 5;
                end
    
                [dH, hH, Ntunel] = vytvor_tunel(chi2_stat_array,sigma_nasobok,predict_window);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                % save tunel
                tunel_folder_name = folder_name + "\" + num2str(compute_window) + " cw\tunel\"+ num2str(sigma_nasobok)+" sigma nasobok";
                tunel_folder_path = fullfile(where_to_store, tunel_folder_name);
                if ~exist(tunel_folder_path, 'dir')
                    mkdir(tunel_folder_path);
                end
    
                figtunel = figure('Visible', 'off');
                t = linspace(compute_window,Ntunel+predict_window+compute_window-1,Ntunel);
                t2 = linspace(compute_window+predict_window+1,Ntunel+predict_window+compute_window-1,Ntunel-predict_window);
                t3 = linspace(0,Ntunel+compute_window-1,Ntunel+compute_window);
                plot(t3,0,t,chi2_stat_array,'b',t2,dH,'r',t2,hH,'r')
                title(sprintf("Tunel, sigma=%d",sigma_nasobok));
        
                saveas(figtunel,fullfile(tunel_folder_name,sprintf('TUNEL, compute_window=%d, predict_window=%d.fig',compute_window,predict_window)));
                saveas(figtunel,fullfile(tunel_folder_name,sprintf('TUNEL, compute_window=%d, predict_window=%d.png',compute_window,predict_window)));
                close(figtunel)
            end

            % save simulaciu
            simul_folder_name = folder_name + "\pociatocna_simulacia\"+ num2str(compute_window) + " cw\" + num2str(average_multiplier) + " average_multiplier";
            simul_folder_path = fullfile(where_to_store, simul_folder_name);
            if ~exist(simul_folder_path, 'dir')
                mkdir(simul_folder_path);
            end
    
            if use_fourier == "yes"
                figure14 = figure('Visible', 'off');
                plot(cely_tok(1:compute_window));
                hold on
                plot(fft_frequency);
                xlim([0 length(cely_tok(1:compute_window))])
                ylim([0 n])
                title(sprintf('Data pred FFT od %d do %d',1,compute_window));
                legend("Data");
                xlabel("Čas")
                ylabel("Počet paketov");
                saveas(figure14,fullfile(simul_folder_path,sprintf('Data pred FFT od %d do %d.fig', 1,compute_window)));
                saveas(figure14,fullfile(simul_folder_path,sprintf('Data pred FFT od %d do %d.png', 1,compute_window)));
            end
    
            figure10 = figure('Visible', 'off');
            plot(data);
            xlim([0 length(data)])
            ylim([0 n])
            if use_fourier == "yes"
                title(sprintf('Data po FFT od %d do %d',1,compute_window));
            else
                title(sprintf('Data od %d do %d',1,compute_window));
            end
            legend("Data");
            xlabel("Čas")
            ylabel("Počet paketov");
            if use_fourier == "yes"
                saveas(figure10,fullfile(simul_folder_path,sprintf('Data po FFT od %d do %d.fig', 1,compute_window)));
                saveas(figure10,fullfile(simul_folder_path,sprintf('Data po FFT od %d do %d.png', 1,compute_window)));
            else
                saveas(figure10,fullfile(simul_folder_path,sprintf('Data od %d do %d.fig', 1,compute_window)));
                saveas(figure10,fullfile(simul_folder_path,sprintf('Data od %d do %d.png', 1,compute_window)));
            end
    
            figure11 = figure('Visible', 'off');
            plot(gen_sampled);
            xlim([0 length(gen_sampled)])
            ylim([0 n])
            title(sprintf('%s od %d do %d', simulacia,1,compute_window));
            legend(sprintf('%s', simulacia));
            xlabel("Čas")
            ylabel("Počet paketov");
            saveas(figure11,fullfile(simul_folder_path,sprintf('e%s od %d do %d.fig', simulacia,1,compute_window)));
            saveas(figure11,fullfile(simul_folder_path,sprintf('e%s od %d do %d.png', simulacia,1,compute_window)));
    
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
    
            figure12 = figure('Visible', 'off');
            aa = histogram(data,'Normalization', 'probability');
            ylim([0 ylim_hist])
            title(sprintf('Hist data od %d do %d',1,compute_window));
            xlabel("Triedy")
            ylabel("P");
    
            figure13 = figure('Visible', 'off');
            bb = histogram(gen_sampled,'Normalization', 'probability','NumBins',aa.NumBins);
            ylim([0 ylim_hist])
            title(sprintf('Hist %s od %d do %d', simulacia,1,compute_window));
            xlabel("Triedy")
            ylabel("P");
            
            % nastavenie X os pre histogramy
            xlim_hist = max(max(aa.BinEdges),max(bb.BinEdges));
            xlim(aa.Parent, [0 xlim_hist])
            xlim(bb.Parent, [0 xlim_hist])
    
            saveas(figure12,fullfile(simul_folder_path,sprintf('Hist data od %d do %d.fig', 1,compute_window)));
            saveas(figure12,fullfile(simul_folder_path,sprintf('Hist data od %d do %d.png', 1,compute_window)));
    
            saveas(figure13,fullfile(simul_folder_path,sprintf('Hist %s od %d do %d.fig', simulacia,1,compute_window)));
            saveas(figure13,fullfile(simul_folder_path,sprintf('Hist %s od %d do %d.png', simulacia,1,compute_window)));

            %%%
            figure1 = figure('Visible', 'off');
            plot(cely_tok)
            title("data")
            legend("data");
            xlabel("Čas")
            ylabel("Počet paketov");

            figure2 = figure('Visible', 'off');
            x = compute_window:(compute_window + length(critical_value_array) - 1);
            plot(x,critical_value_array,'r');
            hold on
            plot(x,chi2_stat_array,'b');
            xlabel("Čas")
            ylabel("Hodnoty");
            xlim([0 length(cely_tok)])
            legend("critical value","chi2stat");
            title("critical value, chi2stat");
            
            figure3 = figure('Visible', 'off');
            chi_alfa_plot(1:length(p_value_array)) = chi_alfa;
            x = compute_window:(compute_window + length(chi_alfa_plot) - 1);
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
            xlim([0 length(cely_tok)])
            title("alfa, p-value, if p-value is 0 then it is red");
            legend("alfa","p-value");
        
            % save data
            saveas(figure1,fullfile(average_folder_path,sprintf('DATA, posun_dat=%d, chi_alfa=%.2f, pocet_tried_hist=%d, shift=%d.fig',compute_window,chi_alfa,pocet_tried_hist, shift)));
            saveas(figure1,fullfile(average_folder_path,sprintf('DATA, posun_dat=%d, chi_alfa=%.2f, pocet_tried_hist=%d, shift=%d.png',compute_window,chi_alfa,pocet_tried_hist, shift)));
        
            saveas(figure2,fullfile(average_folder_path,sprintf('CHI2STAT_CRITICVALUE, posun_dat=%d, chi_alfa=%.2f, pocet_tried_hist=%d, shift=%d.fig',compute_window,chi_alfa,pocet_tried_hist, shift)));
            saveas(figure2,fullfile(average_folder_path,sprintf('CHI2STAT_CRITICVALUE, posun_dat=%d, chi_alfa=%.2f, pocet_tried_hist=%d, shift=%d.png',compute_window,chi_alfa,pocet_tried_hist, shift)));
        
            saveas(figure3,fullfile(average_folder_path,sprintf('PVALUE_CHIALFA, posun_dat=%d, chi_alfa=%.2f, pocet_tried_hist=%d, shift=%d.fig',compute_window,chi_alfa,pocet_tried_hist, shift)));
            saveas(figure3,fullfile(average_folder_path,sprintf('PVALUE_CHIALFA, posun_dat=%d, chi_alfa=%.2f, pocet_tried_hist=%d, shift=%d.png',compute_window,chi_alfa,pocet_tried_hist, shift)));
        
            clearvars -except M slot_window predict_window compute_window sigma_nasobok cely_tok file_path folder_path where_to_store attacks_folder_mat folder_name posun_dat shift pocet_tried_hist chi_alfa simulacia use_fourier keep_frequencies;    
            close all;
        end
    end
end



elapsedTime = toc;
fprintf('\nElapsed time is %.6f seconds.\n', elapsedTime);
