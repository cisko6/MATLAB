
function [diverg_array] = divergencia(obs1,obs2)
    pdf1 = hist(obs1)./sum(hist(obs1));
    n = length(pdf1);
    for k=1:n
        if pdf1(k)==0
           pdf1(k) = 10^(-20);
        end
    end
    pdf2 = hist(obs2)./sum(hist(obs2));
    n = length(pdf2);
    for k=1:n
        if pdf2(k)==0
           pdf2(k) = 10^(-20);
        end
    end
    diverg_array = -sum(pdf1.*log(pdf1/pdf2));
end
