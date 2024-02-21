
clear
clc

observed = [6 3 7 5 6 3];
expected = [5 5 5 5 5 5];

%observed = [81	261	402	198	58];
%expected = [51	428	338	168	16];

chi2_stat = sum(((observed-expected).^2)./expected);

df = length(observed) - 1;
chi_alfa = 0.05;
critical_value = chi2inv(1 - chi_alfa, df);
p_value = 1 - chi2cdf(chi2_stat, df);

fprintf("chi2stat: %f\ncritical value: %f\np_value: %f\n",chi2_stat,critical_value,p_value)



% test ci sa rovnaju funkcie chi statistiky
chi2_stat2 = chisquaretest(expected, observed);
function chi2_stat = chisquaretest(expected, observed)
    chi2_stat = sum((observed - expected).^2 ./ (expected));
end
