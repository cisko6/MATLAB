
clear
clc

observed = [6 3 7 5 6 3];
expected = [5 5 5 5 5 5];

chi2_stat = sum(((observed-expected).^2)./expected);

df = length(observed) - 1;
chi_alfa = 0.05;
critical_value = chi2inv(1 - chi_alfa, df);
p_value = 1 - chi2cdf(chi2_stat, df);


