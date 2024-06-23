% Predpokladajme, že máte vektory 'latent' a 't'
latent = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120];
t = linspace(1, length(latent), length(latent));

% Požadované farby v správnom poradí
desired_colors = {'b', [1, 0.5, 0], [0.85, 0.85, 0], 'm', 'g', 'c', 'r', 'b', [1, 0.5, 0], [0.85, 0.85, 0], 'm', 'g'};

% Vytvorenie stĺpcového diagramu s požadovanými farbami
figure; % Vytvorí nový obrázok
for i = 1:length(latent)
    bar(t(i), latent(i), 'facecolor', desired_colors{i}, 'barwidth', 0.5); % nastavenie farby pre každý stĺpec
    hold on; % udržiavanie grafu na obrazovke, aby sa pridávali ďalšie stĺpce
end

% Pridanie označenia osí x a y a nadpisu
xlabel('Index');
ylabel('Latent');
title('Stĺpcový diagram s požadovanými farbami');

% Vypnutie režimu udržiavania grafu na obrazovke
hold off;
