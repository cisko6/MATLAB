
clc;clear
close all

% vypocitaj vzdialenosti pre dobu rozpoznania
X = readmatrix('doba_rozpoznania.txt');
X(isnan(X)) = max(X(:));
X = (X - mean(X)) ./ std(X);
[coeff1, score1, latent1] = pca(X);
vzdialenosti1 = sqrt(sum(score1.^2, 2));

% vypocitaj vzdialenosti pre falosne hlasenia
Y = readmatrix('falosne_hlasenia.txt');
Y(isnan(Y)) = max(Y(:));
Y = (Y - mean(Y)) ./ std(Y);
[coeff2, score2, latent2] = pca(Y);
vzdialenosti2 = sqrt(sum(score2.^2, 2));


sucet_vzdialenosti = zeros(1,length(vzdialenosti1));
for i = 1:length(vzdialenosti1)
    sucet_vzdialenosti(i) = vzdialenosti1(i) + vzdialenosti2(i);
end

[sorted_distances, sorted_indices] = sort(sucet_vzdialenosti);
fprintf("Metódy zoradené od najmenšieho súčtu vzdialenosti k 0 po najväčšiu\n");
for i = 1:length(sorted_indices)
    fprintf("%d - vzdialenost: %f\n", sorted_indices(i), sorted_distances(i));
end
