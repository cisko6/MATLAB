
function medzery = pcap_to_medzery(pcap)
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
