

x = [1,2,3,4,5,6,7,8,9,10];
y = [12,22,32,42,53,64,71,84,92,101];
z = [122,272,382,482,583,646,718,849,801,901];

subplot(3,1,1)
xx = histogram(x);

subplot(3,1,2)
yy = histogram(y);

subplot(3,1,3)
zz = histogram(z);

% nastavenie trom histogramom rovnaku X os
maxValue = max(max(xx.BinEdges),max(yy.BinEdges));
maxValue = max(maxValue,max(zz.BinEdges));

xlim(xx.Parent, [0 maxValue])
xlim(yy.Parent, [0 maxValue])
xlim(zz.Parent, [0 maxValue])

% nastavenie trom histogramom rovnaku Y os (da chybu lebo je to skopirovane z ineho mfile)
ylim_hist = max( ...
            max(histcounts(data_casy, 'Normalization', 'probability')), ...
            max(histcounts(mmrp_sampled, 'Normalization', 'probability')));
ylim_hist = max(ylim_hist, max(histcounts(mmrp_sampled_fourier, 'Normalization', 'probability')));

histogram(mmrp_sampled_fourier,'Normalization', 'probability');
ylim([0 ylim_hist])


