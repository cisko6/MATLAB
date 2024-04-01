
clear;clc

% vstup csv - TIS

M = readtable("C:\Users\patri\Desktop\diplomka\TIS\Po vybranych kuskoch\0207_3051.csv");

slot_window = 0.1;
dlzka_pcapu = height(M) - 1;
data_kb = M.Var8;
protocols = M.Var13;

%%%%%%%%%%%%%%%% velkost paketov navzorkovana na dany pocet kB - blbost
%max_size_kb = 50000; kB
%index_size = 1;
%pom_size = 0;
%for i=1:dlzka_pcapu
%    pom_size = pom_size + data_kb(i);
%    if pom_size < max_size_kb
%        sampled_data_kb(index_size) = sampled_data_kb(index_size) + 1;
%        continue
%    end

    % prvy co prekroci hranicu tak sa prirata este k staremu
%    sampled_data_kb(index_size) = sampled_data_kb(index_size) + 1;
%    index_size = index_size + 1;
%    pom_size = 0;
%end

% vytvorenie nekumulovanych medzier
data_casy = M.Var6;
minuty = data_casy.Minute;
sekundy = data_casy.Second;
medzery = create_spaces_from_csvPcap(dlzka_pcapu, sekundy, minuty);

% slotovanie pocty
sampled_data = sample_pcap(data_casy, slot_window);

% pocty + velkost = zaznamu, tcp, udp, other
sampled_data_kb = zeros(1,dlzka_pcapu);
tcp_pocty = zeros(1,dlzka_pcapu);
tcp_kB = zeros(1,dlzka_pcapu);
udp_pocty = zeros(1,dlzka_pcapu);
udp_kB = zeros(1,dlzka_pcapu);
other_pocty = zeros(1,dlzka_pcapu);
other_kb = zeros(1,dlzka_pcapu);

index_tcp = 1;
index_tcp_kb = 1;
index_udp = 1;
index_udp_kb = 1;
index_kb = 1;
index_other = 1;
index_other_kb = 1;
pom_sucet = 0;

for i=1:dlzka_pcapu
    pom_sucet = pom_sucet + medzery(i);

    if pom_sucet < slot_window
        sampled_data_kb(index_kb) = sampled_data_kb(index_kb) + data_kb(i);
        if strcmp(protocols{i}, 'TCP')
            tcp_pocty(index_tcp) = tcp_pocty(index_tcp) + 1;
            tcp_kB(index_tcp_kb) = tcp_kB(index_tcp_kb) + data_kb(i);
        elseif strcmp(protocols{i}, 'UDP')
            udp_pocty(index_udp) = udp_pocty(index_udp) + 1;
            udp_kB(index_udp_kb) = udp_kB(index_udp_kb) + data_kb(i);
        else
            other_pocty(index_other) = other_pocty(index_other) + 1;
            other_kb(index_other_kb) = other_kb(index_other_kb) + data_kb(i);
        end
    else
        index_kb = index_kb + 1;
        index_tcp = index_tcp + 1;
        index_tcp_kb = index_tcp_kb + 1;
        index_udp = index_udp + 1;
        index_udp_kb = index_udp_kb + 1;
        index_other = index_other + 1;
        index_other_kb = index_other_kb + 1;

        sampled_data_kb(index_kb) = sampled_data_kb(index_kb) + data_kb(i);
        if strcmp(protocols{i}, 'TCP')
            tcp_pocty(index_tcp) = tcp_pocty(index_tcp) + 1;
            tcp_kB(index_tcp_kb) = tcp_kB(index_tcp_kb) + data_kb(i);
        elseif strcmp(protocols{i}, 'UDP')
            udp_pocty(index_udp) = udp_pocty(index_udp) + 1;
            udp_kB(index_udp_kb) = udp_kB(index_udp_kb) + data_kb(i);
        else
            other_pocty(index_other) = other_pocty(index_other) + 1;
            other_kb(index_other_kb) = other_kb(index_other_kb) + data_kb(i);
        end

        pom_sucet = 0;
    end
end

%%%%%%%%%%%%%%%%

subplot(4,1,1)
lastNonZeroIndex = find(sampled_data, 1, 'last');
sampled_data = sampled_data(1:lastNonZeroIndex);
plot(sampled_data);
xlim([1 lastNonZeroIndex])
title("Pocty paketov - slot window="+ slot_window +"s")

subplot(4,1,2)
lastNonZeroIndex = find(sampled_data_kb, 1, 'last');
sampled_data_kb = sampled_data_kb(1:lastNonZeroIndex);
plot(sampled_data_kb);
xlim([1 lastNonZeroIndex])
title("Velkost paketov")

subplot(4,1,3)
lastNonZeroIndex = find(other_pocty, 1, 'last');
other_pocty = other_pocty(1:lastNonZeroIndex);
plot(other_pocty);
xlim([1 lastNonZeroIndex])
title("Pocty paketov inych ako TCP a UDP")

subplot(4,1,4)
lastNonZeroIndex = find(other_kb, 1, 'last');
other_kb = other_kb(1:lastNonZeroIndex);
plot(other_kb);
xlim([1 lastNonZeroIndex])
title("Velkost paketov inych ako TCP a UDP")


figure

subplot(4,1,1)
lastNonZeroIndex = find(tcp_pocty, 1, 'last');
tcp_pocty = tcp_pocty(1:lastNonZeroIndex);
plot(tcp_pocty);
xlim([1 lastNonZeroIndex])
title("Pocty TCP")

subplot(4,1,2)
lastNonZeroIndex = find(tcp_kB, 1, 'last');
tcp_kB = tcp_kB(1:lastNonZeroIndex);
plot(tcp_kB);
xlim([1 lastNonZeroIndex])
title("Velkost paketov TCP")

subplot(4,1,3)
lastNonZeroIndex = find(udp_pocty, 1, 'last');
udp_pocty = udp_pocty(1:lastNonZeroIndex);
plot(udp_pocty);
xlim([1 lastNonZeroIndex])
title("Pocty UDP")

subplot(4,1,4)
lastNonZeroIndex = find(udp_kB, 1, 'last');
udp_kB = udp_kB(1:lastNonZeroIndex);
plot(udp_kB);
xlim([1 lastNonZeroIndex])
title("Velkost paketov UDP")

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function medzery = create_spaces_from_csvPcap(dlzka_csv, sekundy, minuty)
    medzery = zeros(1,dlzka_csv);
    for i=1:dlzka_csv-1
    
        medzery(i) = sekundy(i+1) - sekundy(i);
    
        if minuty(i) ~= minuty(i+1)
            medzery(i) = medzery(i) + 60;
        end
    
        if medzery(i) < 0
            medzery(i) = 0.0001;
        end
    end
end

function sampled_data = sample_pcap(data_casy, slot_window)
    tStart = min(data_casy);
    tEnd = max(data_casy);
    
    timeBins = tStart:seconds(slot_window):tEnd;
    
    [sampled_data, ~] = histcounts(data_casy, timeBins);
end
