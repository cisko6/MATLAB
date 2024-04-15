
function vysl = zisti_pocetnosti(data)
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
    
    vysl = zeros(1, max(zeroLengths)+1);
    for i = 1:length(zeroLengths)
        vysl(zeroLengths(i)+1) = vysl(zeroLengths(i)+1) + 1;
    end

    count = 0;
    for i = 1:length(data)-1
        if data(i) == 1 && data(i+1) == 1
            count = count + 1;
        end
    end
    vysl(1) = count;
end
