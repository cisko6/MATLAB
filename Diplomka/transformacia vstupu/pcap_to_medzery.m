
folder_path = "C:\Users\patri\Desktop\_TestovacieDatasety\CSE-CIC-IDS2018\Friday-02-03-2018\CSE-CIC-IDS2018_Friday-02-03-2018_SmallPcaps\capDESKTOP-AN3U28N-172.31.66.85PCAP.pcap";
pcapAll = pcapReader(folder_path);
%pcap = pcapAll.readAll;
%data = pcap;
slot_window = 0.01;

medzery = create_spaces_from_pcap(data);
casy = sample_pcap(data,slot_window);

figure
plot(medzery);
figure
plot(casy);

function medzery = create_spaces_from_pcap(pcap)
    data_casy = datetime([pcap(:).Timestamp] / 1e6, 'ConvertFrom', 'posixtime');
    seconds = second(data_casy);
    minutes = minute(data_casy);
    N = length(data_casy);

    medzery = zeros(1,N);
    for i=1:N-1
    
        medzery(i) = seconds(i+1) - seconds(i);
    
        if minutes(i) ~= minutes(i+1)
            medzery(i) = medzery(i) + 60;
        end
    
        if medzery(i) < 0
            medzery(i) = 0.0001;
        end
    end
end

%%%

function sampled_data = sample_pcap(pcap, slot_window)
    data_casy = datetime([pcap(:).Timestamp] / 1e6, 'ConvertFrom', 'posixtime');

    tStart = min(data_casy);
    tEnd = max(data_casy);
    
    timeBins = tStart:seconds(slot_window):tEnd;
    
    [sampled_data, ~] = histcounts(data_casy, timeBins);
end