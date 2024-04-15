
function [diverg] = divergencia(obs1,obs2,pocet_tried_hist)
    [pravdP] = histcounts(obs1, pocet_tried_hist,'Normalization', 'probability');
    [pravdQ] = histcounts(obs2, pocet_tried_hist ,'Normalization', 'probability');

    pravdP(pravdP == 0) = 10^(-20);
    pravdQ(pravdQ == 0) = 10^(-20);

    diverg = sum(pravdP .* log(pravdP ./ pravdQ));
end
