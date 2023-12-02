clc
clear



% Define the data arrays
data1 = [1 2 2 3 3 4];
data2 = [2 2 2 3 4 4];

%data1 = 1:50;
%data2 = data1 + randi([-50, 50], size(data1));

alpha = 0.05;

% Combine the data into a contingency table
data = [data1; data2];

% Calculate expected frequencies
expectedFrequencies = mean(data, 2);

% Compute chi-square statistic
chi2Statistic = sum((data - expectedFrequencies).^2 ./ expectedFrequencies);

% Calculate degrees of freedom
degreesOfFreedom = (size(data, 1) - 1) * (size(data, 2) - 1);

% Calculate p-value
pValue = chi2cdf(chi2Statistic, degreesOfFreedom);

% vytvorenie hranice úspechu
if mod(length(data1),2) ~= 0
    hranica = ceil(length(data1) / 2); % ak vyjde 3,5 tak bude 4
else
    hranica = length(data1) / 2;
end

% spočítanie pocet mensich než alpha
pocet_mensich = 0;
for number = pValue
    if number < alpha
        fprintf('p-value = %f GUCCI\n', number);
        pocet_mensich = pocet_mensich + 1;
    else
        fprintf('p-value = %f ZLE\n', number);
    end
end

% print výsledku
if hranica > pocet_mensich
    fprintf("NIE SU PODOBNE, počet_menších = %d z %d, hranica=%d", pocet_mensich,length(data1),hranica);
else
    fprintf("SU PODOBNE, počet_menších = %d z %d, hranica=%d", pocet_mensich,length(data1),hranica);
end














