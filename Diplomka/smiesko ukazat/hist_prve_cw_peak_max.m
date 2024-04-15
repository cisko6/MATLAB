
clear;clc
tic;
addpath('C:\Users\patri\Documents\GitHub\MATLAB\Diplomka\funkcie');

% nižšie v kode treba nastavit compute_window a sigma_nasobok
where_to_store = "C:\Users\patri\Documents\GitHub\MATLAB\Diplomka\smiesko ukazat";
attacks_folder_mat = "C:\Users\patri\Documents\GitHub\MATLAB\Utoky\";
shift = 1;
chi_alfa = 0.05;
pocet_tried_hist = 20;
simulacia = "MMRP"; % MMRP, MMBP
use_fourier = "no"; % yes, default=no
keep_frequencies = 3;
slot_window = 0.01;
predict_window = 1000;

for j=1:1
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

    [~, folder_name, extension] = fileparts(file_path);

    if extension == ".mat"
        M = load(file_path);
        cely_tok = M.a;
    end


    for l=1:4
        if l == 1
            compute_window = 1000;
        elseif l == 2
            compute_window = 500;
        elseif l == 3
            compute_window = 1500;
        elseif l == 4
            compute_window = 2000;
        end
        
        simul_folder_name = folder_name + "\pociatocna_simulacia\"+ num2str(compute_window) + " cw";
        simul_folder_path = fullfile(where_to_store, simul_folder_name);
        if ~exist(simul_folder_path, 'dir')
            mkdir(simul_folder_path);
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


        % CHILL SO FAR
        
        
        

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % save cely utok
        figall = figure('Visible', 'off');
        plot(cely_tok);
        title(sprintf('Utok - %s', folder_name));
        grid on
        cely_tok_path = fullfile(where_to_store, folder_name);
        if ~exist(sprintf("%s/Cely_utok.png",cely_tok_path), 'file')
            saveas(figall,fullfile(cely_tok_path,"Cely_utok.png"));
            saveas(figall,fullfile(cely_tok_path,"Cely_utok.fig"));
        end
        close(figall)
        
        % save simulaciu
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
            grid on
            saveas(figure14,fullfile(simul_folder_path,sprintf('Data pred FFT od %d do %d.fig', 1,compute_window)));
            saveas(figure14,fullfile(simul_folder_path,sprintf('Data pred FFT od %d do %d.png', 1,compute_window)));
        end

        figure10 = figure;
        plot(data);
        grid on
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

        figure11 = figure;
        plot(gen_sampled);
        xlim([0 length(gen_sampled)])
        ylim([0 n])
        grid on
        title(sprintf('%s od %d do %d', simulacia,1,compute_window));
        legend(sprintf('%s', simulacia));
        xlabel("Čas")
        ylabel("Počet paketov");
        saveas(figure11,fullfile(simul_folder_path,sprintf('e%s od %d do %d.fig', simulacia,1,compute_window)));
        saveas(figure11,fullfile(simul_folder_path,sprintf('e%s od %d do %d.png', simulacia,1,compute_window)));
        close(figure11)


        figure12 = figure;
        h1 = histcounts(data,pocet_tried_hist);
        h2 = histcounts(gen_sampled,pocet_tried_hist);
        plot(h1,'*-')
        hold on
        plot(h2,'*-')
        grid on
        if use_fourier == "yes"
            title('FFT PEAK MAX');
        else
            title('PEAK MAX');
        end
        xlabel("Triedy")
        ylabel("Počet paketov");
        legend("data",sprintf("%s",simulacia))

        saveas(figure12,fullfile(simul_folder_path,sprintf('p_Hist data od %d do %d.fig', 1,compute_window)));
        saveas(figure12,fullfile(simul_folder_path,sprintf('p_Hist data od %d do %d.png', 1,compute_window)));
        close(figure12)














        %%%
 

        clearvars -except M slot_window predict_window file_path sigma_nasobok folder_path where_to_store attacks_folder_mat folder_name compute_window shift pocet_tried_hist chi_alfa simulacia use_fourier keep_frequencies cely_tok;    
        close all;
    end
end


elapsedTime = toc;
fprintf('\nElapsed time is %.6f seconds.\n', elapsedTime);