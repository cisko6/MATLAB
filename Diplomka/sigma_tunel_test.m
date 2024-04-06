
clear

% čo je okno?

M = load('C:\Users\patri\Documents\GitHub\MATLAB\Utoky\Attack_5_v1.mat');
data = M.a;
compute_window = 1000;
predict_window = 1000;
pocet_tried_hist = 10;
chi_alfa = 0.05;
tunel_sigma = 50;


[alfa, beta, n] = MMRP_zisti_alfBet_peakIsMax(data);
gen_data = generate_mmrp(n*length(data),length(data),alfa,beta);
gen_sampled = sample_generated_data(gen_data, n, length(data));

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

N = length(chi2_stat_array);

k = tunel_sigma; % nasobok sigmi
for i=1:N-predict_window
    [dH,hH] = vypocitaj_hranice_tunelu(chi2_stat_array(i:predict_window+i),predict_window,k);
    dH_final(i) = dH;
    hH_final(i) = hH;
end

plot(chi2_stat_array)

figure

plot(data);
xlim([0 N])
title("Data");
legend("Data");
xlabel("Čas")
ylabel("Počet paketov");

figure

t  = linspace(1,N,N);
t2 = linspace(compute_window+predict_window,N,N-predict_window);
plot(t,chi2_stat_array,t2,dH_final,'r',t2,hH_final,'r')
title("Ideal");


%Hpred=data(predict_window+1:N);
%dHpred = [ dH(1) dH(1:N-predict_window-1)];
%hHpred = [ hH(1) hH(1:N-predict_window-1)];
%mx2 = linspace(tunnel_window,N,N-okno-tunnel_window);
%plot(mx2,Hpred-hHpred)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

