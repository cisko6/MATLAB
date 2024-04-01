
clc
clear

alfa = 0.95;
beta = 0.95;
p = 0.8;
sample_size = 10; % n

pocet_generovanych = 2000;
stav = 1;

counter_one = 0;
counter_zero = 0;
% generovanie sekvencie bitov
for i=1:pocet_generovanych
    if stav == 1
        pravd_p = 1.*rand();
        if pravd_p <= p     % mmbp parameter pravdepodobnosti na 1
            mmbp_data(i) = 1;
            counter_one = counter_one + 1;
        else
            mmbp_data(i) = 0;
            counter_zero = counter_zero + 1;
        end

        % či sa mení stav
        pravd = 1.*rand();
        if pravd >= (1 - alfa)
            stav = 0;
        end
    else
        mmbp_data(i) = 0;
        counter_zero = counter_zero + 1;

        % či sa mení stav
        pravd = 1.*rand();
        if pravd >= (1-beta)
            stav = 1;
        end
    end
end

% samplovanie dat
sampled_mmbp_data = zeros(1,ceil(pocet_generovanych/sample_size));

pom_sum = sum(mmbp_data(1:sample_size));
sampled_mmbp_data(1) = pom_sum;

for i=1:(pocet_generovanych/sample_size)-1
    pom_sum = sum(mmbp_data((i*sample_size)+1:(i*sample_size)+sample_size));
    sampled_mmbp_data(i+1) = pom_sum;
end


fig1 = plot(mmbp_data);
title("MMBP pre " + pocet_generovanych + " bitov, α = "+alfa+", β = "+beta+", p = "+ p);
xlabel('Počet bitov');
ylabel('1/0');
grid on
%saveas(fig1,sprintf('MMBP_alf=%.2f, bet=%.2f, p=%.1f.fig',alfa,beta, p));
%saveas(fig1,sprintf('MMBP_alf=%.2f, bet=%.2f, p=%.1f.png',alfa,beta, p));

figure

fig2 = plot(sampled_mmbp_data);
ylim([0 sample_size])
title("Navzorkované dáta na "+sample_size+" ts, α = "+alfa+" a β = "+beta+", p = "+ p);
xlabel('Počet navzorkovaných dát');
ylabel('Počet jednotiek vo vzorkách');
grid on
%saveas(fig2,sprintf('MMBP_sampled_alf=%.2f, bet=%.2f, p=%.1f.fig',alfa,beta, p));
%saveas(fig2,sprintf('MMBP_sampled_alf=%.2f, bet=%.2f, p=%.1f.png',alfa,beta, p));






