


function [alfa, beta, n] = MMRP_zisti_alfBet_peakIsMax(data)
    % zistenie n, lambda_avg, ppeak
    n = ceil(max(data));
    if n == 0
        n = 1;
    end
    % mean, max, ppeak
    lambda_avg = mean(data);
    peak_count = numel(find(data==n));
    ppeak = peak_count/length(data);
    
    %alfa beta
    alfa = 1 - (ppeak * n/lambda_avg)^(1/(n-1));
    beta = (lambda_avg * alfa) / (n - lambda_avg);
end