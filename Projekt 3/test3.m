clc
clear

data1 = [8 29 70 117 212 304 319 279 257 227 154 112 70 28 22 7 4 2 1];
data2 = [11 45 69 95 159 203 228 221 218 242 214 161 136 93 62 35 15 13 1];

data1 = [5	58	262	633	1252	2039	2774	3121	3028	2667	2233	1609	1101	669	392	206	88	44	28	9	4];
data2 = [94	315	600	1051	1511	1884	2320	2479	2494	2295	1981	1634	1282	914	608	398	201	91	45	20	4];

%data1 = [1 2 2 3 3 4];
%data2 = [2 2 2 3 4 4];

% Calculate the total observations for each dataset
total1 = sum(data1);
total2 = sum(data2);

% Calculate the proportions for each category
proportions1 = histcounts(data1, 1:max(data1)+1) / total1;
proportions2 = histcounts(data2, 1:max(data2)+1) / total2;

% Calculate the expected frequencies for each dataset
expected1 = total1 * proportions1;
expected2 = total2 * proportions2;

% Add a small constant to avoid division by zero
epsilon = 0.01;
expected1 = expected1 + epsilon;
expected2 = expected2 + epsilon;

% Calculate the chi-square statistic
chi2statistic = sum((histcounts(data1, 1:max(data1)+1) - expected1).^2 ./ expected1) + ...
                sum((histcounts(data2, 1:max(data2)+1) - expected2).^2 ./ expected2);

% Number of categories in each dataset
num_categories1 = numel(unique(data1));
num_categories2 = numel(unique(data2));

% Calculate the degrees of freedom
df = (num_categories1 - 1) + (num_categories2 - 1);

% Set Significance Level
alpha = 0.05;

% Look up Critical Value from Chi-Square Distribution Table
critical_value = chi2inv(1 - alpha, df);

% Compare with Calculated Chi-Square Statistic
if chi2statistic > critical_value
    fprintf('Reject the null hypothesis.\n chi2statistic: %f \n critical_value: %f', chi2statistic, critical_value);
else
    fprintf('Fail to reject the null hypothesis.\n chi2statistic: %f \n critical_value: %f', chi2statistic, critical_value);
end




