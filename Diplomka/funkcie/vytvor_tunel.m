

function [dH, hH, N] = vytvor_tunel(data,sigma_nasobok,predict_window)
    N = length(data);
    for i=0:N-predict_window-1
        mH(i+1) =     mean(data(1+i:predict_window+i));
        sH(i+1) = sqrt(cov(data(1+i:predict_window+i)));
    end
    k = sigma_nasobok;
    dH = mH - k*sH;
    hH = mH + k*sH;
end