

function sampled_data = cumulatedSpaces_to_casy(kumul_medzery, slot_window)
    maxTime = max(kumul_medzery);
    numBins = ceil(maxTime / slot_window) + 1;

    sampled_data = zeros(1, numBins);
    for i = 1:length(kumul_medzery)
        binIndex = floor(kumul_medzery(i) / slot_window) + 1;
        sampled_data(binIndex) = sampled_data(binIndex) + 1;
    end
end