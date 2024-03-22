
clc
clear

% vyskusajte na 10000 0/1 z Bernouliho p = 0.7, stredna hodnota musi byt
% priblizne ET = 3/7, diperzia 3/49?
pocet_generovanych = 1000;
p = 0.7;
max_hodnota = 1;

%generuj bernoulli
data = binornd(max_hodnota,p,1,pocet_generovanych);

zeroLengths = [];
zeroCount = 0;

for i = 1:length(data)
    if data(i) == 0
        zeroCount = zeroCount + 1;
    else
        if zeroCount > 0
            zeroLengths = [zeroLengths, zeroCount];
            zeroCount = 0;
        end
    end
end

if zeroCount > 0
    zeroLengths = [zeroLengths, zeroCount];
end

outArray = zeros(1, max(zeroLengths));

for i = 1:length(zeroLengths)
    outArray(zeroLengths(i)) = outArray(zeroLengths(i)) + 1;
end

disp(outArray);

% et

meanLength = sum(zeroLengths) / length(zeroLengths);
disp(meanLength);

