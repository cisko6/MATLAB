
function [alfa, beta, n] = MMRP_zisti_alfBet_peakIsChanged(data, average_multiplier)
    lambda_avg = mean(data);
    max_data = max(data);
    n = round(average_multiplier * lambda_avg);
    if n > max_data
        n = max_data;
    end

    peak_count = numel(find(data==n));
    if peak_count == 0
        peak_count = 1;
    end
    ppeak = peak_count/length(data);

    alfa = 1 - (ppeak * n/lambda_avg)^(1/(n-1));
    beta = (lambda_avg * alfa) / (n - lambda_avg);
end