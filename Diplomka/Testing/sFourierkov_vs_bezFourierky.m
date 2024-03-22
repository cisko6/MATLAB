
%clc;clear

% vstup pcap

folder_path = "C:\Users\patri\Desktop\diplomka\TIS\Po vybranych kuskoch\0207_3051.csv";
slot_window = 0.1;
percent_to_keep_fft = 0.2;

%M = readtable(folder_path);
[~, folder_name, ~] = fileparts(folder_path);

dlzka_csv = height(M)-1;
data_casy = M.Var6;
minuty = data_casy.Minute;
sekundy = data_casy.Second;

% vytvorenie nekumulovanych medzier
medzery = create_spaces_from_pcap(dlzka_csv, sekundy, minuty);

% nekumulovane na kumulovane medzery
cumulated_spaces = cumulate_spaces(medzery);

% samplovanie kumulovanych medzier
data_casy = cumulatedSpaces_to_casy(cumulated_spaces, slot_window);
data_casy = data_casy(1:2300);

% generate mmrp without fourier
[alfa, beta, n] = zisti_alf_bet(data_casy);
mmrp_data = generate_mmrp(n*length(data_casy),length(data_casy),alfa,beta);
mmrp_sampled = sample_generated_data(mmrp_data, ceil(n*length(data_casy)), ceil(n));

% use fourier on data
fourier_output = fourier_transform(data_casy, percent_to_keep_fft);
%fourier_output = abs(fourier_output-data_casy);

% generate mmrp with fourier
[alfa, beta, n] = zisti_alf_bet(fourier_output);
mmrp_data_fourier = generate_mmrp(n*length(fourier_output),length(fourier_output),alfa,beta);
mmrp_sampled_fourier = sample_generated_data(mmrp_data_fourier, ceil(n*length(fourier_output)), ceil(n));

%%%%%%%%%% PLOT 

% pre data
ylim_data = max(max(data_casy),max(mmrp_sampled));
ylim_data = max(ylim_data,max(mmrp_sampled_fourier));

% pre histogramy
ylim_hist = max( ...
            max(histcounts(data_casy, 'Normalization', 'probability')), ...
            max(histcounts(mmrp_sampled, 'Normalization', 'probability')));
ylim_hist = max(ylim_hist, max(histcounts(mmrp_sampled_fourier, 'Normalization', 'probability')));

if ylim_hist <= 0.1
    ylim_hist = ylim_hist + 0.01;
elseif ylim_hist > 0.1 && ylim_hist < 0.5
    ylim_hist = ylim_hist + 0.05;
else
    ylim_hist = ylim_hist + 0.2;
end

subplot(3,1,1)
plot(data_casy)
hold on
plot(fourier_output,'LineWidth', 2)
lastNonZeroIndex = find(data_casy, 1, 'last');
xlim([0 lastNonZeroIndex])
ylim([0 ylim_data])
title("Data")

subplot(3,1,2)
plot(mmrp_sampled)
lastNonZeroIndex = find(mmrp_sampled, 1, 'last');
xlim([0 lastNonZeroIndex])
ylim([0 ylim_data])
title("MMRP pred fourierom")

subplot(3,1,3)
plot(mmrp_sampled_fourier)
lastNonZeroIndex = find(mmrp_sampled_fourier, 1, 'last');
xlim([0 lastNonZeroIndex])
ylim([0 ylim_data])
title("MMRP po fourierovi - ponechanych "+percent_to_keep_fft*100+"%")

figure

subplot(3,1,1)
aa = histogram(data_casy,'Normalization', 'probability');
ylim([0 ylim_hist])
title("Data")

subplot(3,1,2)
bb = histogram(mmrp_sampled,'Normalization', 'probability');
ylim([0 ylim_hist])
title("MMRP pred fourierom")

subplot(3,1,3)
cc = histogram(mmrp_sampled_fourier,'Normalization', 'probability');
ylim([0 ylim_hist])
title("MMRP po fourierovi - ponechanych "+percent_to_keep_fft*100+"%")

% nastavenie X os pre histogramy
xlim_hist = max(max(aa.BinEdges),max(bb.BinEdges));
xlim_hist = max(xlim_hist,max(cc.BinEdges));

xlim(aa.Parent, [0 xlim_hist])
xlim(bb.Parent, [0 xlim_hist])
xlim(cc.Parent, [0 xlim_hist])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [alfa, beta, n] = zisti_alf_bet(data)
    % mean, max, ppeak
    lambda_avg = mean(data);
    n = max(data);
    peak_count = numel(find(data==n));
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
    lastNonZeroIndex = find(result_data, 1, 'last');
    result_data = result_data(1:lastNonZeroIndex);
end

function [fourier_output, ca, c] = fourier_transform(data, percent_to_keep_fft)
    N = length(data);
    
    c = fft(data) / N;
    ca = abs(c);
    ca(1) = 0;
    
    smooth_range = round(length(c) * percent_to_keep_fft / 2);
    smooth_range = max(smooth_range, 1);
    
    c(smooth_range+2:end-smooth_range) = 0;
    
    fourier_output = ifft(c) * N;
end

function sampled_data = cumulatedSpaces_to_casy(data, samplingRate)

    maxTime = max(data);
    numBins = ceil(maxTime / samplingRate) + 1;
    
    sampled_data = zeros(1, numBins);
    
    for i = 1:length(data)
        binIndex = floor(data(i) / samplingRate) + 1;
        
        sampled_data(binIndex) = sampled_data(binIndex) + 1;
    end
end

function [cumulated_spaces] = cumulate_spaces(data)
    cumulated_spaces = zeros(1,ceil(length(data)));
    cumulated_spaces(1) = data(1);
    for i=2:length(data)
        cumulated_spaces(i) = cumulated_spaces(i-1) + data(i);
    end
end

function medzery = create_spaces_from_pcap(dlzka_csv, sekundy, minuty)
    medzery = zeros(1,dlzka_csv);
    for i=1:dlzka_csv-1
    
        medzery(i) = sekundy(i+1) - sekundy(i);
    
        if minuty(i) ~= minuty(i+1)
            medzery(i) = medzery(i) + 60;
        end
    
        if medzery(i) < 0
            medzery(i) = 0.0001;
        end
    end
end
