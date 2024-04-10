
function sampled_data = sample_csvPcap(csvPcap, slot_window)
    data_casy = csvPcap.Var6;

    tStart = min(data_casy);
    tEnd = max(data_casy);
    
    timeBins = tStart:seconds(slot_window):tEnd;
    [sampled_data, ~] = histcounts(data_casy, timeBins);
end