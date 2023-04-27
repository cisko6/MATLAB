clear
clc

compute_window = 20;
nasobok_koef = 20;
nasobok_spic = 5;

%M = readtable("C:\Users\patri\Downloads\tok\01 tsharkPONDELOK4.csv");%full csv
%M = readtable("C:\Users\patri\Downloads\miniTok\01 tsharkPONDELOK4_0.csv");%minitok

%X = readtable("C:\Users\patri\Downloads\tok\01 tsharkPONDELOK4_0.csv"); M = X(2500000:5000001,1:14); % prva cast, CW = 100
%M = readtable("C:\Users\patri\Downloads\časti_toku\druha_cast\druha_cast.csv");%druha cast CW = 20
%M = readtable("C:\Users\patri\Downloads\časti_toku\tretia_cast\tretia_cast.csv");
%M = readtable("C:\Users\patri\Downloads\časti_toku\stvrta_cast\01 tsharkPONDELOK4_5_1.csv");
M = readtable("C:\Users\patri\Downloads\file.csv");

%M = readtable("C:\Users\patri\Downloads\tok\01 tsharkPONDELOK4_6.csv");

dlzka_csv = height(M)-1;

data_casy = M.Var6;
hodiny = data_casy.Hour;
minuty = data_casy.Minute;
sekundy = data_casy.Second;
sekundy_floored = floor(data_casy.Second);

%inicializacia cyklu slotovania
pom_h = hodiny(1);
pom_m = minuty(1);
pom_s = sekundy_floored(1);
index = 1;
data = zeros(1,dlzka_csv);
data_kB = zeros(1,dlzka_csv);

%slotovanie
data_informacie = M.Var8;
for i=1:dlzka_csv
    if pom_h == hodiny(i)
        if pom_m == minuty(i)
            if pom_s == sekundy_floored(i)
                data(index) = data(index) + 1;
                data_kB(index) = data_kB(index) + data_informacie(i); 
                continue
            end
        end
    end
    
    pom_h = hodiny(i);
    pom_m = minuty(i);
    pom_s = sekundy_floored(i);

    index = index + 1;
    data(index) = data(index) + 1;
    data_kB(index) = data_kB(index) + data_informacie(i);
end

% medzery
medzery = zeros(1,dlzka_csv);
for i=1:dlzka_csv
    if sekundy(i) > 1 && sekundy(i+1) < 1
        medzery(i) = ( 60 - sekundy(i) ) + sekundy(i+1);
        continue
    end
    medzery(i) = sekundy(i+1) - sekundy(i);
end

% vypocty
for i=1:index-compute_window+1
    data_pom = data(i:compute_window+i-1);
    data_pom2 = data_kB(i:compute_window+i-1);

    %data_pocty
    m(i+compute_window-1) = mean(data_pom); % klzavy priemer
    s(i+compute_window-1)  = sqrt(cov(data_pom)); % smerodajna odchylka
    V(i+compute_window-1) = nasobok_koef*sqrt(cov(data_pom))/mean(data_pom); % koeficient variabilnosti
    K(i+compute_window-1)  = kurtosis(data_pom); % sikmost
    Skw(i+compute_window-1) = nasobok_spic*max(skewness(data_pom),0); % spicatost

    %data_kB
    m_kB(i+compute_window-1) = mean(data_pom2); % klzavy priemer
    s_kB(i+compute_window-1)  = sqrt(cov(data_pom2)); % smerodajna odchylka
    V_kB(i+compute_window-1) = nasobok_koef*sqrt(cov(data_pom2))/mean(data_pom2); % koeficient variabilnosti
    K_kB(i+compute_window-1)  = kurtosis(data_pom2); % sikmost
    Skw_kB(i+compute_window-1) = nasobok_spic*max(skewness(data_pom2),0); % spicatost

    %d0(:) = 0;
    %d0 = data_pom - m; % centrovane data
    %Engf(i) = sqrt(d0*d0')./i; % priemerna energia centrovanych dat
end

%VYPISY
data_plot = data(1:index);
data_plot_kB = data_kB(1:index);
subcislo = 5;

subplot(subcislo,1,1);
plot(data_plot,'blue');
hold on
plot(m,'red');
hold on
plot(s,'green');
hold off
xlim([0 index]);
title("Compute window = "+compute_window+", \color{blue}tok ,\color{red}priemer, \color{green}smer.odchylka");

subplot(subcislo,1,2);
plot(V,'cyan');
hold on
plot(K,'black');
hold on
plot(Skw,'magenta');
hold off
xlim([0 index]);
title("\color{black}sikmost, \color{magenta}"+nasobok_spic+"x spicatost ,\color{cyan} "+nasobok_koef+"xkoef. var.");

subplot(subcislo,1,3);
histogram(data_plot, 'Normalization', 'probability');
title('histogram toku');

subplot(subcislo,1,4);
plot(medzery);
title('medzery');

subplot(subcislo,1,5);
histogram(medzery, 'Normalization', 'probability');
title('histogram medzier');

figure
%%%%%%%%%%%%%%%%%%%%%%%%%%%another one
subcislo2 = 3;
subplot(subcislo2,1,1);
plot(data_plot_kB,'blue');
hold on
plot(m_kB,'red');
hold on
plot(s_kB,'green');
hold off
xlim([0 index]);
title("kB - Compute window = "+compute_window+", \color{blue}tok ,\color{red}priemer, \color{green}smer.odchylka");

subplot(subcislo2,1,2);
plot(V_kB,'cyan');
hold on
plot(K_kB,'black');
hold on
plot(Skw_kB,'magenta');
hold off
xlim([0 index]);
title("\color{black}sikmost, \color{magenta}"+nasobok_spic+"x spicatost ,\color{cyan} "+nasobok_koef+"xkoef. var.");

subplot(subcislo2,1,3);
histogram(data_plot_kB, 'Normalization', 'probability');
title("histogram kB");


%PRINTY
m(1) = mean(data_plot); % klzavy priemer
s(1)  = sqrt(cov(data_plot)); % smerodajna odchylka
V(1) = sqrt(cov(data_plot))/mean(data_plot); % koeficient variabilnosti
K(1)  = kurtosis(data_plot); % sikmost
Skw(1) = max(skewness(data_plot),0); % spicatost
%d0 = data_plot - m; % centrovane data
%Engf = sqrt(d0*d0')./i; % priemerna energia centrovanych dat

fprintf("klzavy priemer: %f\n",m(1));
fprintf("smerodajna odchylka: %f\n\n",s(1));
fprintf("koeficient variabilnosti: %f\n",V(1));
fprintf("sikmost: %f\n",K(1));
fprintf("spicatost: %f\n",Skw(1));
%fprintf("priemerna energia centrovanych dat: %f\n",Engf);










