
%clear
%clc

% vstup pcap

%M = readtable("C:\Users\patri\Desktop\diplomka\TIS\Po vybranych kuskoch\0207_3051.csv");

max_size_kb = 50000;
slot_window = 0.1;

dlzka_pcapu = height(M) - 1;
data_kb = M.Var8;
protocols = M.Var13;

sampled_data_kb = zeros(1,dlzka_pcapu);
tcp_pocty = zeros(1,dlzka_pcapu);
udp_pocty = zeros(1,dlzka_pcapu);

%%%%%%%%%%%%%%%% velkost paketov

index_size = 1;
pom_size = 0;
for i=1:dlzka_pcapu
    pom_size = pom_size + data_kb(i);
    if pom_size < max_size_kb
        sampled_data_kb(index_size) = sampled_data_kb(index_size) + 1;
        continue
    end

    % prvy co prekroci hranicu tak sa prirata este k staremu
    sampled_data_kb(index_size) = sampled_data_kb(index_size) + 1;
    index_size = index_size + 1;
    pom_size = 0;
end

%%%%%%%%%%%%%%%% pocty tcp udp

% slotovanie pocty
data_casy = M.Var6;

tStart = min(data_casy);
tEnd = max(data_casy);
timeBins = tStart:seconds(slot_window):tEnd;
[counts, ~] = histcounts(data_casy, timeBins);

% vytvorenie nekumulovanych medzier
minuty = data_casy.Minute;
sekundy = data_casy.Second;
medzery = zeros(1,dlzka_pcapu);
for i=1:dlzka_pcapu

    medzery(i) = sekundy(i+1) - sekundy(i);

    if minuty(i) ~= minuty(i+1)
        medzery(i) = medzery(i) + 60;
    end

    if medzery(i) < 0
        medzery(i) = 0.0001;
    end

end


% tcp udp pocty
index_tcp = 1;
index_udp = 1;
pom_sucet = 0;

for i=1:dlzka_pcapu
    pom_sucet = pom_sucet + medzery(i);

    if pom_sucet < slot_window
        switch protocols{i}
            case 'TCP'
                tcp_pocty(index_tcp) = tcp_pocty(index_tcp) + 1;
                %data_kB_TCP(index) = data_kB_TCP(index) + data_informacie(i);
            case 'UDP'
                udp_pocty(index_udp) = udp_pocty(index_udp) + 1;
                %data_kB_UDP(index) = data_kB_UDP(index) + data_informacie(i);
        end
    else
        index_tcp = index_tcp + 1;
        index_udp = index_udp + 1;
        switch protocols{i}
            case 'TCP'
                tcp_pocty(index_tcp) = tcp_pocty(index_tcp) + 1;
                %data_kB_TCP(index) = data_kB_TCP(index) + data_informacie(i);
            case 'UDP'
                udp_pocty(index_udp) = udp_pocty(index_udp) + 1;
                %data_kB_UDP(index) = data_kB_UDP(index) + data_informacie(i);
        end
        pom_sucet = 0;
    end
end

%%%%%%%%%%%%%%%%

subplot(4,1,1)
lastNonZeroIndex = find(counts, 1, 'last');
counts = counts(1:lastNonZeroIndex);
plot(counts);
xlim([1 lastNonZeroIndex])
title("Pocty paketov za "+ slot_window +"s")

subplot(4,1,2)
lastNonZeroIndex = find(sampled_data_kb, 1, 'last');
sampled_data_kb = sampled_data_kb(1:lastNonZeroIndex);
plot(sampled_data_kb);
xlim([1 lastNonZeroIndex])
title("Velkost informacie navzorkovana na "+ max_size_kb)

subplot(4,1,3)
lastNonZeroIndex = find(tcp_pocty, 1, 'last');
tcp_pocty = tcp_pocty(1:lastNonZeroIndex);
plot(tcp_pocty);
xlim([1 lastNonZeroIndex])
title("Pocty TCP za "+ slot_window +"s")

subplot(4,1,4)
lastNonZeroIndex = find(udp_pocty, 1, 'last');
udp_pocty = udp_pocty(1:lastNonZeroIndex);
plot(udp_pocty);
xlim([1 lastNonZeroIndex])
title("Pocty UDP za "+ slot_window +"s")










