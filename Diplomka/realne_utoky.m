
%csv
%M = readtable("C:\Users\patri\Desktop\diplomka\Real Utoky\CICIDS 1.csv");
%data = reshape(M.Var1,1,height(M));

%txt
%M = load("C:\Users\patri\Desktop\diplomka\Real Utoky\Utok1Cely.txt"); % utok 1
%M = load("C:\Users\patri\Desktop\diplomka\Real Utoky\Utok2Cely.txt"); % utok 2
%M = load("C:\Users\patri\Desktop\diplomka\Real Utoky\Utok3Cely.txt"); % utok 3
%M = load("C:\Users\patri\Desktop\diplomka\Real Utoky\Utok_5_CICIDS.txt"); % utok 5
data = reshape(M,1,height(M));

slot_window = 1; % U1=1; U2=1;0.5; U3 = 0.01

pocet_bitov = 2100000; % U1 stacionar
data = data(1:pocet_bitov);


sampled_data = sample_data(data, pocet_bitov, slot_window);

% vymazanie nul na konci z dát
lastNonZeroIndex = find(sampled_data, 1, 'last');
sampled_data = sampled_data(1:lastNonZeroIndex);

%%%%%%%%%%%%%% Zistenie alfa, beta, p %%%%%%%%%%%%%%
lambda_avg = mean(sampled_data);

% zistenie ppeak
n = max(sampled_data);
peak_count = numel(find(sampled_data==n));
ppeak = peak_count/length(sampled_data);

p = 0.8; % ako zistit p

alfa = 1 - (((n * ppeak) / lambda_avg)^(1 / (n - 1))) * 1 / p;
beta = (lambda_avg * alfa) / ((n * p) - lambda_avg);

%%%%%%%%%%%%%% Zistenie ET, ET2 %%%%%%%%%%%%%%
et = sampled_data(lastNonZeroIndex) / lastNonZeroIndex;

ti = diff(data);
ti2 = ti.^2;
et2 = (1/(n - 1)) * sum(ti2);

%%%%%%%%%%%%%%%%%%%%%%%%% SIMULACIA MMRP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mmrp_data = generate_mmrp(pocet_bitov,dlzka_dat, alfa, beta);
sampled_mmrp = sample_generated_data(mmrp_data, pocet_bitov, n);

% vymazanie nul na konci z dát
lastNonZeroIndex_mmrp = find(sampled_mmrp, 1, 'last');
sampled_mmrp = sampled_mmrp(1:lastNonZeroIndex_mmrp);

subplot(2,1,1)
plot(sampled_mmrp);
xlim([1 lastNonZeroIndex_mmrp])
subplot(2,1,2)
histogram(sampled_mmrp, 'Normalization', 'probability');

figure;

subplot(2,1,1)
plot(sampled_data)
xlim([1 lastNonZeroIndex])
subplot(2,1,2)
histogram(sampled_data, 'Normalization', 'probability');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [sampled_data] = sample_data(data, dlzka_dat, slot_window)

    sampled_index = 1;
    sampled_data = zeros(1,ceil(length(data)/10)); %toto plati pre 1 sw -> zeros(1,ceil(max(data)) + 1); % +1 lebo môžu dáta končiť celým číslom
    pom_slot_window = slot_window;

    for i=1:dlzka_dat
        if data(i) < pom_slot_window
            sampled_data(sampled_index) = sampled_data(sampled_index) + 1;
        else
            if data(i) >= (sampled_index + slot_window) % ošetrenie ak timeslot mal 0 prírastkov -> index sa musí posunúť
                while true
                    if data(i) >= (sampled_index + slot_window)
                        sampled_index = sampled_index + slot_window;
                    else
                        break
                    end
                end
            end
            sampled_index = sampled_index + 1;
            sampled_data(sampled_index) = sampled_data(sampled_index) + 1;
            pom_slot_window = pom_slot_window + slot_window;
        end
    end

end

%

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

%

function chisquaretest(flow_data, mmrp_data)
    vysl = 0;
    for i=1:length(flow_data)

        if flow_data(i) == 0
            flow_data(i) = 0.00001;
        end

        vysl = vysl + ( ( (mmrp_data(i) - flow_data(i))^2 ) / flow_data(i) );
    end
end
