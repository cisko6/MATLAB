

folder_path = "C:\Users\patri\Desktop\najdene utoky\A1\Moloch-180418-10-04-anonymized.pcap";

%pcapAll = pcapReader(folder_path);
%pcap = pcapAll.readAll; % toto zakomentovat ked nechcem cakat rok

slot_window = 0.1;
sampled_data = sample_pcap(pcap, slot_window);
plot(sampled_data)

function sampled_data = sample_pcap(pcap, slot_window)
    data_casy = datetime([pcap(:).Timestamp] / 1e6, 'ConvertFrom', 'posixtime');

    tStart = min(data_casy);
    tEnd = max(data_casy);
    
    timeBins = tStart:seconds(slot_window):tEnd;
    
    [sampled_data, ~] = histcounts(data_casy, timeBins);
end