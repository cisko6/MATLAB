clear
clc

Hist1 = [ 6 3 7 5 6 3 ];
Hist2 = [ 5 5 5 5 5 5 ];

%Hist1 = [ 6 3 7 5 6 ];
%Hist2 = [ 5 5 5 5 5 ];

chi2stat = chisquaretest(Hist1,Hist2);
df = length(Hist1) - 1;
chi_alfa = 0.05;
critical_value = chi2inv(1 - chi_alfa, df);
p_value = 1 - chi2cdf(chi2stat, df); % toto funguje 100% dobre



function chi2_stat = chisquaretest(expected, observed)
    pseudo_count = 1;
    chi2_stat = sum((observed - expected).^2 ./ (expected)); % + pseudo_count
end
