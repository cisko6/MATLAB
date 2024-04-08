
clear;clc
tic;
addpath('C:\Users\patri\Documents\GitHub\MATLAB\Diplomka\funkcie');


M = load('C:\Users\patri\Documents\GitHub\MATLAB\Utoky\Attack_3_d010.mat');
data = M.a;
compute_window = 1000;
predict_window = 1000;
pocet_tried_hist = 10;
chi_alfa = 0.05;
sigma_nasobok = 3;

% pre prvu 1000
data_mmrp = data(1:compute_window);
[alfa, beta, n] = MMRP_zisti_alfBet_peakIsMax(data_mmrp);
gen_bits = generate_mmrp(n,length(data_mmrp),alfa,beta);
gen_sampled = sample_generated_data(gen_bits, n, length(data_mmrp));


N = length(data);
chi2_stat_array = zeros(1,N);
dolne_hranice = zeros(1,N);
horne_hranice = zeros(1,N);
% vypocitanie prvych chi od 1 do 1000 a prvu hranicu tunelu
for u=1:compute_window

    from = u;
    to = from + predict_window - 1;
    cast_dat = data(from:to);

    [chi2_stat] = chi_square_test(gen_sampled,cast_dat,chi_alfa,pocet_tried_hist);
    chi2_stat_array(u) = chi2_stat;
end


[dH,hH] = vypocitaj_hranice_tunelu(chi2_stat_array(1:compute_window),predict_window,sigma_nasobok);
index_H = 1;
dolne_hranice(index_H) = dH;
horne_hranice(index_H) = hH;


% prechadzanie compute window klzavo
for u=1:9999999

    from = u + compute_window;
    to = from + predict_window - 1;
    try
        cast_dat = data(from:to);
    catch
        fprintf("try catch - u=%d\n",u)
        break
    end

    % chi kvadrat
    [chi2_stat] = chi_square_test(cast_dat,gen_sampled,chi_alfa,pocet_tried_hist);

    chi2_stat_array(u+predict_window) = chi2_stat;

    if chi2_stat > horne_hranice(index_H)
        fprintf("Horna hranica prekrocena na %d\n",u+compute_window)
        %break
        %[~,hH] = vypocitaj_hodnotu_hranice_tunelu(chi2_stat_array(u:u+predict_window),predict_window,tunel_sigma+1);
        %if chi2_stat > hH
         %   fprintf("Horna hranica prekrocena na %d\n",u)
        %    break
        %end
    end

    if chi2_stat < dolne_hranice(index_H)
        fprintf("Dolna hranica prekrocena na %d\n",u+compute_window)
        %break
        %[dH,~] = vypocitaj_hodnotu_hranice_tunelu(chi2_stat_array(u:u+predict_window),predict_window,tunel_sigma+1);
        %if chi2_stat < dH
        %    fprintf("Dolna hranica prekrocena na %d\n",u)
        %    break
        %end
    end
    [dH,hH] = vypocitaj_hranice_tunelu(chi2_stat_array(u+1:u+predict_window),predict_window,sigma_nasobok);
    index_H = index_H + 1;
    dolne_hranice(index_H) = dH;
    horne_hranice(index_H) = hH;
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
t =  linspace(compute_window,N+compute_window-1,N);
t2 = linspace(compute_window+predict_window+1,N+compute_window-1,index_H);
t3 = linspace(0,N+compute_window-1,N+compute_window);
plot(t3,0,t,chi2_stat_array,'b',t2,dolne_hranice,'r',t2,horne_hranice,'r')
title("Autonomne riesenie");




elapsedTime = toc;
fprintf('\nElapsed time is %.6f seconds.\n', elapsedTime);