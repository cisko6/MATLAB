clear
clc

% parametre, čo treba meniť
%file_path = "C:\Users\patri\Documents\GitHub\MATLAB\Utoky\Attack_1.mat";
%file_path = "C:\Users\patri\Documents\GitHub\MATLAB\Utoky\Attack_2_d010.mat";
%file_path = "C:\Users\patri\Documents\GitHub\MATLAB\Utoky\Attack_3_d010.mat";
%file_path = "C:\Users\patri\Documents\GitHub\MATLAB\Utoky\Attack_4_d0001.mat";
%file_path = "C:\Users\patri\Documents\GitHub\MATLAB\Utoky\Attack_5_v1.mat";
%file_path = "C:\Users\patri\Documents\GitHub\MATLAB\Utoky\Attack_5_v2.mat";
%file_path = "C:\Users\patri\Documents\GitHub\MATLAB\Utoky\Attack_6.mat";
%file_path = "C:\Users\patri\Documents\GitHub\MATLAB\Utoky\Attack_7.mat";
file_path = "C:\Users\patri\Documents\GitHub\MATLAB\Utoky\Attack_8.mat";

posun_dat = 1500;



[~, folder_name, ~] = fileparts(file_path);
full_folder_name = folder_name + "\" + num2str(posun_dat);
folder_path = fullfile("C:\Users\patri\Documents\GitHub\MATLAB\Diplomka", full_folder_name);

if ~exist(folder_path, 'dir')
    %mkdir(folder_path);
end

M = load(file_path);

% save cely utok
figall = figure;
plot(M.a);
title(sprintf('Utok - %s', folder_name));
cely_tok_path = fullfile("C:\Users\patri\Documents\GitHub\MATLAB\Diplomka", folder_name);
if ~exist(sprintf("%s/Cely_utok.png",cely_tok_path), 'file')
    %saveas(figall,fullfile(cely_tok_path,"Cely_utok.png"));
    %saveas(figall,fullfile(cely_tok_path,"Cely_utok.fig"));
end
close(figall)

for k=1:1 % počet posunov

    data = M.a;

    from = (k-1)*posun_dat + 1;
    to = from + (posun_dat-1);
    
    if from > length(data)
        break;
    end

    try
        data = data(from:to);
    catch 
        to = to - (to-length(data)); % Keď "to" je väčšie ako length(data)
        data = data(from : to);
    end

    % mean, max, ppeak
    lambda_avg = mean(data);
    n = max(data);
    
    peak_count = numel(find(data==n));
    ppeak = peak_count/length(data);
    
    %alfa beta
    alfa = 1 - (ppeak * n/lambda_avg)^(1/(n-1));
    beta = (lambda_avg * alfa) / (n - lambda_avg);
    
    %generovanie a samplovanie mmrp
    mmrp_data = generate_mmrp(n*length(data),length(data),alfa,beta);
    mmrp_sampled = sample_generated_data(mmrp_data, ceil(n*length(data)), ceil(n));
    
    
    
    % vymazanie nul na konci z dát pre plot
    lastNonZeroIndex = find(mmrp_sampled, 1, 'last');
    mmrp_sampled = mmrp_sampled(1:lastNonZeroIndex);
    
    % rovnaká Y os pre histogramy
    maxValue = max(max(histcounts(data, 'Normalization', 'probability')), ...
               max(histcounts(mmrp_sampled, 'Normalization', 'probability')));
    if maxValue <= 0.1
        maxValue = maxValue + 0.01;
    elseif maxValue > 0.1 && maxValue < 0.5
        maxValue = maxValue + 0.05;
    else
        maxValue = maxValue + 0.2;
    end

    fig = figure;
    subplot(4,1,1)
    plot(data)
    title(sprintf('Data od %d do %d z %s', from, to, folder_name));

    subplot(4,1,2)
    plot(mmrp_sampled)
    title("MMRP");

    subplot(4,1,3)
    hist_data = histogram(data, 'Normalization', 'probability');
    title("Histogram dát")
    ylim([0 maxValue])

    subplot(4,1,4)
    hist_mmrp = histogram(mmrp_sampled, 'Normalization', 'probability','NumBins',hist_data.NumBins);
    title("Histogram MMRP")
    ylim([0 maxValue])


    % chi2kvadrat
    chi2value = chisquaretest(hist_data.Values,hist_mmrp.Values);
    fprintf("Chi2value: %f\n",chi2value)
    figure(1)
    subplot(4,1,4)
    title("Histogram MMRP - chi2test:" + chi2value)


    % save data
    %saveas(fig,fullfile(folder_path,sprintf('Vzorka_od_%d_do_%d.fig',from,to)));
    %saveas(fig,fullfile(folder_path,sprintf('Vzorka_od_%d_do_%d.png',from,to)));

    clearvars -except M file_path folder_path posun_dat folder_name;
    %close all;

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function chi2_stat = chisquaretest(expected, observed)
    pseudo_count = 1;
    chi2_stat = sum((observed - expected).^2 ./ (expected + pseudo_count));
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
