
clc;clear


X = readmatrix('falosne_hlasenia.txt'); typ_merania = "falosne_hlasenia";
%X = readmatrix('doba_rozpoznania.txt'); typ_merania = "doba_rozpoznania";


X(isnan(X)) = max(X(:));
X = (X - mean(X)) ./ std(X);
[coeff, score, latent] = pca(X);
% score = hlavné komponenty
% coeff = vlastné vektory
% latent = vlastné hodnoty

% vypočítanie množstva informacie v % v 2D a 3D
latent = latent';
percento_informacii_2D = (latent(1)+latent(2))/(sum(latent))*100;
percento_informacii_3D = (latent(1)+latent(2)+latent(3))/(sum(latent))*100;

figure1 = figure;
group_indices = [ones(16,1); 2*ones(16,1); 3*ones(16,1); 4*ones(16,1)];
scatter(score(:,1), score(:,2), 100, group_indices, 'filled');
dx = 0.02; dy = 0.15;
text(score(:,1)+dx, score(:,2)+dy, string(1:64), 'FontSize', 8);
colormap([0 0 1; 1 0 0; 0.6 0.6 1; 1 0.6 0.6]); % 'Modrá', 'Červená', 'Svetlomodrá', 'Svetločervená'
cb = colorbar('Ticks', [1.375, 2.125, 2.875, 3.625], 'TickLabels', {'Chi-kvadrát', 'DKL', 'Chi-kvadrát', 'DKL'});
set(cb, 'YDir', 'reverse');
grid on;
if typ_merania == "doba_rozpoznania"
    title(sprintf("2D, doba rozpoznania štatistík - %.1f%% informácie",percento_informacii_2D));
elseif typ_merania == "falosne_hlasenia"
    title(sprintf("2D, falošné hlásenia štatistík - %.1f%% informácie",percento_informacii_2D));
end
xlabel('Prvý komponent');
ylabel('Druhý komponent');

figure2 = figure;
scatter3(score(:,1), score(:,2), score(:,3), 100, group_indices, 'filled');
colormap([0 0 1; 1 0 0; 0.6 0.6 1; 1 0.6 0.6]); % 'Modrá', 'Červená', 'Svetlomodrá', 'Svetločervená'
cb = colorbar('Ticks', [1.375, 2.125, 2.875, 3.625], 'TickLabels', {'Chi-kvadrát', 'DKL', 'Chi-kvadrát', 'DKL'});
set(cb, 'YDir', 'reverse');
if typ_merania == "doba_rozpoznania"
    title(sprintf("3D, doba rozpoznania štatistík - %.1f%% informácie",percento_informacii_3D));
elseif typ_merania == "falosne_hlasenia"
    title(sprintf("3D, falošné hlásenia štatistík - %.1f%% informácie",percento_informacii_3D));
end
xlabel('Prvý komponent');
ylabel('Druhý komponent');
zlabel('Tretí komponent');
dx = 0.15;dy = 0.15;dz = 0.15;
text(score(:,1) + dx, score(:,2) + dy, score(:,3) + dz, string(1:64), 'FontSize', 8);

if typ_merania == "doba_rozpoznania"
    saveas(figure1,"Statistika_2D_doba_rozpoznania.png")
    saveas(figure2,"Statistika_3D_doba_rozpoznania.png")
elseif typ_merania == "falosne_hlasenia"
    saveas(figure1,"Statistika_2D_falosne_hlasenia.png")
    saveas(figure2,"Statistika_3D_falosne_hlasenia.png")
end

