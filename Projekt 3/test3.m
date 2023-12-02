clc
clear

% Define the data arrays
data1 = [1 2 2 3 3 4];
data2 = [2 2 2 3 4 4];

passedCount = 0;

for i = 1:6
    % Combine the data into a contingency table
    data = [data1(randperm(size(data1, 1))), data2(randperm(size(data2, 1)))];

    % Calculate expected frequencies
    expectedFrequencies = mean(data, 2);

    % Compute chi-square statistic
    chi2Statistic = sum((data - expectedFrequencies).^2 ./ expectedFrequencies);

    % Calculate degrees of freedom
    degreesOfFreedom = (size(data, 1) - 1) * (size(data, 2) - 1);

    % Calculate p-value
    pValue = chi2cdf(chi2Statistic, degreesOfFreedom);

    % Count the number of times the p-value is less than 0.05
    if pValue <= 0.05
        passedCount = passedCount + 1;
    end
    fprintf('p-value = %f \n', pValue);
end


% Check if more than half of the p-values are less than 0.05
if passedCount > 3
    fprintf('PASSED\n');
else
    fprintf('NOT PASSED\n');
end
