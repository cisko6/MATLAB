clc
clear
% Example data
data1 = [1 2 2 3 3 4];
data2 = [2 2 2 3 4 4];


% Define the unique values in data1 and data2
unique_data1 = unique(data1);
unique_data2 = unique(data2);

% Initialize the contingency table with zeros
contingency_table = zeros(numel(unique_data1), numel(unique_data2));

% Fill in the contingency table by accumulating values from data1
for i = 1:numel(data1)
    row_index = find(unique_data1 == data1(i));
    col_index = find(unique_data2 == data2(i));
    contingency_table(row_index, col_index) = contingency_table(row_index, col_index) + data1(i);
end

% Display the contingency table
disp('Contingency Table:');
disp(contingency_table);

% zistit sucty riadkov a stlpcov a celkovy sucet
sumRows = sum(contingency_table, 2);
sumRows1D = sumRows(:)';

sumColumns = sum(contingency_table, 1);
sumAll = sum(contingency_table(:));

% vypocítať ideal table
for i=1:length(contingency_table)
    for j=1:length(contingency_table)-1
        ideal_table(i,j) = sumRows(i) * sumColumns(j) / sumAll;
    end
end

% Display the expected table
disp('Expected Table:');
disp(ideal_table);

% zmenit z 2D na 1D
ideal_table1D = ideal_table(:);
contingency_table_1D = contingency_table(:);

expected_values = ideal_table(:);
observed_values = contingency_table(:);





% Calculate the chi-square statistic
chi2stat = sum((observed_values - expected_values).^2 ./ expected_values);

% Degrees of freedom
df = numel(observed_values) - 1;

% Calculate the p-value using the chi2cdf function
p_value = 1 - chi2cdf(chi2stat, df);

% Display results
disp(['Chi-square test statistic: ' num2str(chi2stat)]);
disp(['Degrees of freedom: ' num2str(df)]);
disp(['P-value: ' num2str(p_value)]);

% Check for significance
alpha = 0.05;
if p_value < alpha 
    disp('Reject the null hypothesis: The observed values are not significantly different from the expected values.');
else
    disp('Fail to reject the null hypothesis: The observed values are significantly different from the expected values.');
end



%{ 

% Calculate the chi-square statistic
chiSquareStat = sum((contingency_table_1D - ideal_table1D).^2 ./ ideal_table1D);

% Degrees of freedom (assuming one variable)
df = numel(contingency_table_1D) - 1;

% Calculate the p-value using the chi2cdf function
pValue = 1 - chi2cdf(chiSquareStat, df);

% Display the results
fprintf('Chi-square test result:\n');
fprintf('   H0: The observed data follows the expected distribution.\n');
fprintf('   H1: There is a significant difference between observed and expected data.\n\n');

fprintf('Chi-square statistic: %f\n', chiSquareStat);
fprintf('P-value: %f\n', pValue);

% Check the significance level (commonly 0.05)
alpha = 0.05;
if pValue < alpha
    fprintf('Reject the null hypothesis (H0) at %.2f significance level.\n', alpha);
else
    fprintf('Fail to reject the null hypothesis (H0) at %.2f significance level.\n', alpha);
end

%}










