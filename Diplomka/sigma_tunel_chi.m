
clear

% čo je okno?

M = load('C:\Users\patri\Documents\GitHub\MATLAB\Utoky\Attack_1.mat');
data = M.a;
N  = length(data);  
okno = 0; 
posun_dat = 1000;
shift = 1;
pocet_tried_hist = 10;
chi_alfa = 0.05;


[alfa, beta, n] = MMRP_zisti_alfBet_peakIsMax(data);
gen_data = generate_mmrp(n*length(data),length(data),alfa,beta);
gen_sampled = sample_generated_data(gen_data, n, length(data));

[chi2_stat_array, p_value_array, critical_value_array] = pouzi_chi_square_test(data, gen_sampled, posun_dat, shift, pocet_tried_hist, chi_alfa);



%%%

plot(data);
xlim([0 length(data)])
ylim([0 n])
title(sprintf('Data od %d do %d',1,posun_dat));
legend("Data");
xlabel("Čas")
ylabel("Počet paketov");











for i=0:N-okno-posun_dat-1
    if mod(i,10000)==0
       i;
    end
    mH(i+1) =     mean(data(1+i:posun_dat+i));
    sH(i+1) = sqrt(cov(data(1+i:posun_dat+i)));
end
k = 3; % nasobok sigmi
dH = mH - k*sH;
hH = mH + k*sH;

xx  = linspace(1,N,N);
mxx = linspace(posun_dat,N,N-okno-posun_dat);
plot(xx,data,mxx,dH,'r',mxx,hH,'r',0,1)

%Hpred=data(rozsah+1:N);
%dHpred = [ dH(1) dH(1:N-okno-rozsah-1)];
%hHpred = [ hH(1) hH(1:N-okno-rozsah-1)];
%mx2 = linspace(rozsah,N,N-okno-rozsah);
%plot(mx2,Hpred-hHpred)




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
    
    if df > 0
        p_value = 1 - chi2cdf(chi2_stat, df);
    else
        p_value = NaN; % The chi-square test is not applicable
    end

    critical_value = chi2inv(1 - chi_alfa, df);
end

function [chi2_stat_array, p_value_array, critical_value_array] = pouzi_chi_square_test(cely_tok, gen_sampled, posun_dat, shift, pocet_tried_hist, chi_alfa)

    for k=2:9999999
    
        if ~mod(k,shift) == 0
            continue
        end
    
        from = k + shift;
        to = from + posun_dat;
        try
            data = cely_tok(from:to);
        catch
            break
        end
    
        % chi kvadrat
        data_chi = histcounts(data,pocet_tried_hist);
        mmrp_chi = histcounts(gen_sampled, length(data_chi));

        [chi2_stat, p_value, critical_value] = chi_square_test(data_chi,mmrp_chi,chi_alfa);
    
        chi2_stat_array(k-1) = chi2_stat;
        p_value_array(k-1) = p_value;
        critical_value_array(k-1) = critical_value;
    end

end
