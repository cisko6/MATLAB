function sampled_data = sample_pcap(pcap, slot_window)
    data_casy = datetime([pcap(:).Timestamp] / 1e6, 'ConvertFrom', 'posixtime');

    tStart = min(data_casy);
    tEnd = max(data_casy);
    
    timeBins = tStart:seconds(slot_window):tEnd;
    [sampled_data, ~] = histcounts(data_casy, timeBins);
end