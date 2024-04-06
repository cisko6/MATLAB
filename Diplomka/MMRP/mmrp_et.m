
%clc; clear;

% vstup kumulovane medzery

%M = importdata("C:\Users\patri\Desktop\diplomka\Zaznamy\Ďalšie záznamy\TIS cele zaznamy\Cele zaznamy\TIS medzery\kumulovane medzery\0104.txt");

M = importdata("C:\Users\patri\Desktop\diplomka\Zaznamy\Finalisti - skopirovane z ostatnych\Kumulovane medzery\Utok2\Utok2Cely.txt");
%plot(M)
data = M;



N = length(data);

%%%%%%%%%%%%%% Zistenie ET, ET2 %%%%%%%%%%%%%%

ET = data(N)/N;

ti = diff(data);
ti2 = ti.^2;

ET2 = sum(ti2)/(N - 1);

fprintf('ET=%.15f\n', ET);
fprintf('ET2=%.15f\n', ET2);

MMRP_beta = (2 * ET) / (ET2 + ET);
MMRP_alfa = MMRP_beta * ET;

fprintf('MMRP alfa=%.15f\n', MMRP_alfa);
fprintf('MMRP beta=%.15f\n', MMRP_beta);




%figure
%slot_window = 0.01;
%data = cumulatedSpaces_to_casy(data, slot_window);
%plot(data);




function sampled_data = cumulatedSpaces_to_casy(kumul_medzery, slot_window)

    maxTime = max(kumul_medzery);
    numBins = ceil(maxTime / slot_window) + 1;
    
    sampled_data = zeros(1, numBins);
    
    for i = 1:length(kumul_medzery)
        binIndex = floor(kumul_medzery(i) / slot_window) + 1;
        
        sampled_data(binIndex) = sampled_data(binIndex) + 1;
    end
end