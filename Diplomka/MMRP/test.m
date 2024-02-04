clc
clear

file_path = "C:\Users\patri\Documents\GitHub\MATLAB\Utoky\Attack_1.mat";
M = load(file_path);
data = M.a;



data2 = data(1:1000);
mmrp_sampled = data(201:1200);

values1 = histcounts(data2,'Normalization', 'probability');
values2 = histcounts(mmrp_sampled,length(values1),'Normalization', 'probability');
disp(values1)
disp(values2)
fprintf("\n\n\n")
%[values3] = hist(data2,15,'Normalization', 'probability');
%[values4] = hist(mmrp_sampled, length(values3),'Normalization', 'probability');

chi2value = chisquaretest(values1,values2);
%chi2value2 = chisquaretest(values3,values4);

%fprintf("%f\n",chi2value)
%fprintf("%f\n",chi2value2)

subplot(2,1,1)
hist_data = histogram(data2, 'Normalization', 'probability');
disp(hist_data.Values)
subplot(2,1,2)
hist_mmrp = histogram(mmrp_sampled, 'Normalization', 'probability','NumBins',hist_data.NumBins);
disp(hist_mmrp.Values)

chi2value3 = chisquaretest(hist_data.Values, hist_mmrp.Values);

disp(length(hist_data.Values))
disp(length(hist_mmrp.Values))
fprintf("chi2value1: %f\n",chi2value)
%fprintf("%f\n",chi2value2)
fprintf("chi2value2: %f\n",chi2value3)

figure
subplot(4,1,1)
plot(values1)
subplot(4,1,2)
plot(values2)
subplot(4,1,3)
plot(hist_data.Values)
subplot(4,1,4)
plot(hist_mmrp.Values)

function chi2_stat = chisquaretest(expected, observed)
    pseudo_count = 1;
    chi2_stat = sum((observed - expected).^2 ./ (expected + pseudo_count));
end