
function [dH, hH] = vytvor_hranice_tunelu(data,sigma_nasobok)
    mH =     mean(data);
    sH = sqrt(cov(data));

    k = sigma_nasobok;
    dH = mH - k*sH;
    hH = mH + k*sH;
end
