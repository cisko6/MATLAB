
clear;clc

% vstup csv - TIS

where_to_store = "C:\Users\patri\Desktop\TCP_UDP";
attack_file = "C:\Users\patri\Desktop\diplomka\Zaznamy\záznamy\Pcapy s protokolmi\TIS zaznamy - po kuskoch\0701_1403.csv";

M = readtable(attack_file);


slot_window = 0.1;
dlzka_pcapu = height(M) - 1;
data_kb = M.Var8;
protocols = M.Var13;


%{
% vytvorenie nekumulovanych medzier
data_casy = M.Var6;
minuty = data_casy.Minute;
sekundy = data_casy.Second;
medzery = create_spaces_from_csvPcap(dlzka_pcapu, sekundy, minuty);

% slotovanie pocty
sampled_data = sample_pcap(data_casy, slot_window);
%}

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
lastNonZeroIndex = find(sampled_data, 1, 'last');
sampled_data = sampled_data(1:lastNonZeroIndex);
lastNonZeroIndex = find(tcp_pocty, 1, 'last');
tcp_pocty = tcp_pocty(1:lastNonZeroIndex);
lastNonZeroIndex = find(udp_pocty, 1, 'last');
udp_pocty = udp_pocty(1:lastNonZeroIndex);
lastNonZeroIndex = find(other_pocty, 1, 'last');
other_pocty = other_pocty(1:lastNonZeroIndex);

max1 = max(max(tcp_pocty),max(udp_pocty));
maxFinal = max(max1,max(other_pocty));


figure1 = figure;
plot(sampled_data);
xlim([0 length(sampled_data)])
grid on
xlabel("Čas")
ylabel("Počet paketov")
title("Celkové počty paketov - vzorkovacie okno="+ slot_window +"s")
saveas(figure1,fullfile(where_to_store,"celkovy_pocet_paketov.png"));

figure2 = figure;

subplot(3,1,1)
plot(tcp_pocty);
xlim([0 length(tcp_pocty)])
ylim([0 maxFinal])
grid on
xlabel("Čas")
ylabel("Počet paketov")
title("Počty TCP")

subplot(3,1,2)
plot(udp_pocty);
xlim([0 length(tcp_pocty)])
ylim([0 maxFinal])
grid on
xlabel("Čas")
ylabel("Počet paketov")
title("Počty UDP")

subplot(3,1,3)
plot(other_pocty);
xlim([0 length(tcp_pocty)])
ylim([0 maxFinal])
grid on
xlabel("Čas")
ylabel("Počet paketov")
title("Počty paketov iných ako TCP a UDP")
saveas(figure2,fullfile(where_to_store,"pocet_paketov_TCP_UDP_Other.png"));

%

lastNonZeroIndex = find(sampled_data_kb, 1, 'last');
sampled_data_kb = sampled_data_kb(1:lastNonZeroIndex);
lastNonZeroIndex = find(tcp_kB, 1, 'last');
tcp_kB = tcp_kB(1:lastNonZeroIndex);
lastNonZeroIndex = find(udp_kB, 1, 'last');
udp_kB = udp_kB(1:lastNonZeroIndex);
lastNonZeroIndex = find(other_kb, 1, 'last');
other_kb = other_kb(1:lastNonZeroIndex);

max1 = max(max(tcp_kB),max(udp_kB));
maxFinal = max(max1,max(other_kb));


figure3 = figure;
plot(sampled_data_kb);
xlim([0 length(sampled_data_kb)])
grid on
xlabel("Čas")
ylabel("Veľkosť paketov")
title("Celková veľkosť paketov - vzorkovacie okno="+ slot_window +"s")
saveas(figure3,fullfile(where_to_store,"celkova_velkost_paketov.png"));

figure4 = figure;
subplot(3,1,1)
plot(tcp_kB);
xlim([0 length(tcp_kB)])
ylim([0 maxFinal])
grid on
xlabel("Čas")
ylabel("Veľkosť paketov")
title("Veľkost paketov TCP")

subplot(3,1,2)
plot(udp_kB);
xlim([0 length(tcp_kB)])
ylim([0 maxFinal])
grid on
xlabel("Čas")
ylabel("Veľkosť paketov")
title("Veľkost paketov UDP")

subplot(3,1,3)
plot(other_kb);
xlim([0 length(tcp_kB)])
ylim([0 maxFinal])
grid on
xlabel("Čas")
ylabel("Veľkosť paketov")
title("Veľkost paketov iných ako TCP a UDP")
saveas(figure4,fullfile(where_to_store,"velkost_paketov_TCP_UDP_Other.png"));

close("all")





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
