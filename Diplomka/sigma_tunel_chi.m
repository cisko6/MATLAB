
clear;clc

% čo je okno?

M = load('C:\Users\patri\Documents\GitHub\MATLAB\Utoky\Attack_5_v1.mat');
data = M.a;
compute_window = 1000;
predict_window = 1000;
pocet_tried_hist = 10;
chi_alfa = 0.05;
tunel_sigma = 3;



data_mmrp = data(1:compute_window);
[alfa, beta, n] = MMRP_zisti_alfBet_peakIsMax(data_mmrp);
gen_data = generate_mmrp(n*length(data_mmrp),length(data_mmrp),alfa,beta);
gen_sampled = sample_generated_data(gen_data, n, length(data_mmrp));





%%%%% TEST

for u=1:9999999

    from = u + compute_window;
    to = from + compute_window - 1;
    try
        cast_dat = data(from:to);
    catch
        break
    end

    % chi kvadrat
    data_chi = histcounts(cast_dat,pocet_tried_hist);
    gen_chi = histcounts(gen_sampled, length(data_chi));
    [chi2_stat] = chi_square_test(data_chi,gen_chi,chi_alfa);

    chi2_stat_array(u) = chi2_stat;
end



NN = length(chi2_stat_array);
for i=0:NN-predict_window-1
    mH(i+1) =     mean(chi2_stat_array(1+i:predict_window+i));
    sH(i+1) = sqrt(cov(chi2_stat_array(1+i:predict_window+i)));
end
k = tunel_sigma;
dH_ideal = mH - k*sH;
hH_ideal = mH + k*sH;

t  = linspace(1,NN,NN);
%t2 = linspace(compute_window+predict_window,NN,NN-predict_window);
t2 = linspace(1,NN,NN-compute_window);
plot(t,chi2_stat_array,t2,dH_ideal,'r',t2,hH_ideal,'r')
title("Ideal");

%%%%%





%%%%%%%%%%%%%%%
N = length(data);
chi2_stat_array = zeros(1,N);
dolne_hranice = zeros(1,N);
horne_hranice = zeros(1,N);

% vypocitanie prvych chi
for u=1:compute_window+1

    from = u;
    to = from + compute_window - 1;
    cast_dat = data(from:to);


    % chi kvadrat
    data_chi = histcounts(cast_dat,pocet_tried_hist);
    gen_chi = histcounts(gen_sampled, length(data_chi));

    [chi2_stat] = chi_square_test(data_chi,gen_chi,chi_alfa);
    chi2_stat_array(u) = chi2_stat;
end

% inicializovanie počiatočného tunelu
index_H = 0;
%[dH,hH] = vypocitaj_hodnotu_hranice_tunelu(chi2_stat_array,predict_window,tunel_sigma);
%dolne_hranice(index_H) = dH;
%horne_hranice(index_H) = hH;
% prechadzanie compute window klzavo
for u=1:9999999

    from = u + compute_window; % + predict window
    to = from + compute_window - 1;
    try
        cast_dat = data(from:to);
    catch
        fprintf("try catch\n")
        break
    end

    % chi kvadrat
    data_chi = histcounts(cast_dat,pocet_tried_hist);
    gen_chi = histcounts(gen_sampled, length(data_chi));
    [chi2_stat] = chi_square_test(data_chi,gen_chi,chi_alfa);

    chi2_stat_array(u+predict_window+1) = chi2_stat;

    [dH,hH] = vypocitaj_hranice_tunelu(chi2_stat_array(u+2:u+predict_window+1),predict_window,tunel_sigma);
    index_H = index_H + 1;
    dolne_hranice(index_H) = dH;
    horne_hranice(index_H) = hH;

    if chi2_stat > horne_hranice(index_H)
        fprintf("Horna hranica prekrocena na %d\n",u)
        %break
        %[~,hH] = vypocitaj_hodnotu_hranice_tunelu(chi2_stat_array(u:u+predict_window),predict_window,tunel_sigma+1);
        %if chi2_stat > hH
         %   fprintf("Horna hranica prekrocena na %d\n",u)
        %    break
        %end
    end

    if chi2_stat < dolne_hranice(index_H)
        fprintf("Dolna hranica prekrocena na %d\n",u)
        %break
        %[dH,~] = vypocitaj_hodnotu_hranice_tunelu(chi2_stat_array(u:u+predict_window),predict_window,tunel_sigma+1);
        %if chi2_stat < dH
        %    fprintf("Dolna hranica prekrocena na %d\n",u)
        %    break
        %end
    end
    %[dH,hH] = vypocitaj_hodnotu_hranice_tunelu(chi2_stat_array(u:u+predict_window),predict_window,tunel_sigma);
    %index_H = index_H + 1;
    %dolne_hranice(index_H) = dH;
    %horne_hranice(index_H) = hH;
end

%%%%%%%%%%%%%%%%%%%%


figure
plot(data);
xlim([0 N])
title("Data");
legend("Data");
xlabel("Čas")
ylabel("Počet paketov");

figure
chi2_stat_array = chi2_stat_array(1:find(chi2_stat_array, 1, 'last'));
dolne_hranice = dolne_hranice(1:find(dolne_hranice, 1, 'last'));
horne_hranice = horne_hranice(1:find(horne_hranice, 1, 'last'));


N = length(chi2_stat_array);
t  = linspace(1,N,N);
%t2 = linspace(compute_window+predict_window,compute_window+predict_window+index_H,index_H);
%t2 = linspace(compute_window+1,compute_window+predict_window+index_H,index_H);
t2 = linspace(1,compute_window + index_H,index_H); 
plot(t,chi2_stat_array,t2,dolne_hranice,'r',t2,horne_hranice,'r')
title("Autonomne riesenie");



%t = linspace(compute_window,compute_window+length(chi2_stat_array),length(chi2_stat_array));
%t2 = linspace(compute_window+predict_window,compute_window+predict_window+index_H,compute_window+predict_window-index_H);
%plot(t,chi2_stat_array,t2,dolna_hranice,'r',t2,horne_hranice,'r')


%Hpred=data(rozsah+1:N);
%dHpred = [ dH(1) dH(1:N-rozsah-1)];
%hHpred = [ hH(1) hH(1:N-rozsah-1)];
%mx2 = linspace(rozsah,N,N-rozsah);
%plot(mx2,Hpred-hHpred)








%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [dH,hH] = vypocitaj_hranice_tunelu(data,predict_window,k)
    mH =     mean(data(1:predict_window));
    sH = sqrt(cov(data(1:predict_window)));

    dH = mH - k*sH;
    hH = mH + k*sH;
end

function [alfa, beta, n] = MMRP_zisti_alfBet_peakIsMax(data)
    % zistenie n, lambda_avg, ppeak
    n = ceil(max(data));
    if n == 0
        n = 1;
    end
    % mean, max, ppeak
    lambda_avg = mean(data);
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


function [sampled_data] = sample_generated_data(data, n, dlzka_dat)
    n = round(n);
    pocet_bitov = ceil(n*dlzka_dat);
    sampled_data = zeros(1,pocet_bitov);
    
    pom_sum = sum(data(1:n));
    sampled_data(1) = pom_sum;

    for i=1:(pocet_bitov/n)-1
        try
            pom_sum = sum(data((i*n)+1:(i*n)+n));
        catch
            break
        end
        sampled_data(i+1) = pom_sum;
    end
    sampled_data = sampled_data(1:dlzka_dat);
end


function [chi2_stat, p_value, critical_value, df] = chi_square_test(obs1,obs2,chi_alfa)

    obs = [obs1; obs2];

    row_totals = sum(obs, 2);
    column_totals = sum(obs, 1);
    grand_total = sum(row_totals);

    expected = (row_totals * column_totals) / grand_total;

    valid_categories = all(expected > 0) & all(obs > 0);

    obs_valid = obs(:, valid_categories);
    expected_valid = expected(:, valid_categories);
    
    chi2_stat = sum(((obs_valid - expected_valid).^2) ./ expected_valid, 'all');
    
    df = (sum(valid_categories) - 1) * (size(obs, 1) - 1);

    critical_value = chi2inv(1 - chi_alfa, df);

    p_value = 1 - chi2cdf(chi2_stat, df);
end


