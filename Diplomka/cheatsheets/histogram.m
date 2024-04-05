

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

% nastavenie dvom histogramom rovnaku Y os (da chybu lebo je to skopirovane z ineho mfile)
y_for_hist = max([hist_data.Values, hist_mmrp.Values]);

ylim(hist_data.Parent, [0 y_for_hist])
ylim(hist_mmrp.Parent, [0 y_for_hist])


%%%%%%%%%%%% CELA UKAZKA PREMIOVA
        ylim_hist = max( ...
                    max(histcounts(data, 'Normalization', 'probability')), ...
                    max(histcounts(gen_sampled, 'Normalization', 'probability')));
        
        if ylim_hist <= 0.1
            ylim_hist = ylim_hist + 0.01;
        elseif ylim_hist > 0.1 && ylim_hist < 0.5
            ylim_hist = ylim_hist + 0.05;
        else
            ylim_hist = ylim_hist + 0.2;
        end

        figure12 = figure;
        aa = histogram(data,'Normalization', 'probability');
        ylim([0 ylim_hist])
        title(sprintf('Hist data od %d do %d',1,posun_dat));
        xlabel("Triedy")
        ylabel("P");

        figure13 = figure;
        bb = histogram(gen_sampled,'Normalization', 'probability');
        ylim([0 ylim_hist])
        title(sprintf('Hist %s od %d do %d', simulacia,1,posun_dat));
        xlabel("Triedy")
        ylabel("P");
        
        % nastavenie X os pre histogramy
        xlim_hist = max(max(aa.BinEdges),max(bb.BinEdges));
        xlim(aa.Parent, [0 xlim_hist])
        xlim(bb.Parent, [0 xlim_hist])

        saveas(figure12,fullfile(simul_folder_path,sprintf('Hist data od %d do %d.fig', 1,posun_dat)));
        saveas(figure12,fullfile(simul_folder_path,sprintf('Hist data od %d do %d.png', 1,posun_dat)));

        saveas(figure13,fullfile(simul_folder_path,sprintf('Hist %s od %d do %d.fig', simulacia,1,posun_dat)));
        saveas(figure13,fullfile(simul_folder_path,sprintf('Hist %s od %d do %d.png', simulacia,1,posun_dat)));
