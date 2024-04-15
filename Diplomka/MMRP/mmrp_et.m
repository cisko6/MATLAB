
%clc; clear;
tic;
addpath('C:\Users\patri\Documents\GitHub\MATLAB\Diplomka\funkcie');


% vstup kumulovane medzery

%M = importdata("C:\Users\patri\Desktop\diplomka\Zaznamy\Ďalšie záznamy\TIS cele zaznamy\Cele zaznamy\TIS medzery\kumulovane medzery\0104.txt");

%M = importdata("C:\Users\patri\Desktop\diplomka\Zaznamy\Finalisti - skopirovane z ostatnych\Kumulovane medzery\Utok2\Utok2Cely.txt");

M = importdata("C:\Users\patri\Desktop\diplomka\Zaznamy\Finalisti - skopirovane z ostatnych\Kumulovane medzery\fri-01-20141113.Time\fri-01-20141113.Time.txt");
data = M(1:10485);
slot_window = 0.01;
chi_alfa = 0.05;
pocet_tried_hist = 10;

%%%%%%%%%%%%%% Zistenie ET, ET2 %%%%%%%%%%%%%%

N = length(data);
ti = diff(data);
ti2 = ti.^2;
ET = sum(ti)/N;
ET2 = sum(ti2)/(N - 1);

beta = 2*ET/(ET2 + ET);
alfa = beta * ET;

fprintf('ET=%.15f\n', ET);
fprintf('ET2=%.15f\n', ET2);
fprintf('MMRP alfa: %.3f\n',alfa);
fprintf('MMRP beta: %.3f\n',beta);

% samplovanie kumul medzier
sampled_data = cumulatedSpaces_to_casy(data, slot_window);
n = ceil(max(sampled_data));


final_mmrp = generate_mmrp(n,length(sampled_data), alfa,beta);
final_samped_mmrp = sample_generated_data(final_mmrp, n, length(sampled_data));




fprintf('ET=%.15f\n', ET);
fprintf('ET2=%.15f\n', ET2);
fprintf('MMBP alfa=%.15f\n', alfa);
fprintf('MMBP beta=%.15f\n', beta);

plot(final_samped_mmrp)
title("final_samped_mmrp")
figure
plot(sampled_data)
title("sampled_data")
figure
histogram(final_samped_mmrp,'Normalization', 'probability');
title("Hist final_samped_mmrp")
figure
histogram(sampled_data,'Normalization', 'probability');
title("Hist sampled_data")



elapsedTime = toc;
fprintf('\nElapsed time is %.6f seconds.\n', elapsedTime);






