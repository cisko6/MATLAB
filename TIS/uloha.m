clear
clc

compute_window = 10;
nasobok_koef = 20;
nasobok_spic = 5;

num_bins_pocty_medzery = 2000;
num_bins_kB = 20;
num_bins_TCP_medzery = 1000;
num_bins_UDP_medzery = 800;

num_bins_pocty = 10;
num_bins_TCP = 10;
num_bins_UDP = 12;

%M = readtable("C:\Users\patri\Downloads\tok\01 tsharkPONDELOK4.csv");%full csv
%M = readtable("C:\Users\patri\Downloads\miniTok\01 tsharkPONDELOK4_0.csv");%minitok
%M = readtable("C:\Users\patri\Downloads\miniShark\01 tsharkPONDELOK4_0_0.csv");%minitok ntbk

%M = readtable("C:\Users\patri\Downloads\časti_toku\druha_cast\druha_cast.csv");%druha cast ntbk
%M = readtable("C:\Users\patri\Downloads\časti_toku\tretia_cast\tretia_cast.csv");%tretia cast ntbk
%M = readtable("C:\Users\patri\Downloads\časti_toku\stvrta_cast\01 tsharkPONDELOK4_5_0.csv");%stvrta cast ntbk
%M = readtable("C:\Users\patri\Downloads\časti_toku\piata_cast\piata_cast.csv");%piata cast ntbk


%X = readtable("C:\Users\patri\Downloads\tok\01 tsharkPONDELOK4_0.csv"); M = X(2500000:5000001,1:14); % prva cast, CW = 100
M = readtable("C:\Users\patri\Downloads\časti_toku\druha_cast\druha_cast.csv");%druha cast CW = 20
%M = readtable("C:\Users\patri\Downloads\časti_toku\tretia_cast\tretia_cast.csv");
%M = readtable("C:\Users\patri\Downloads\časti_toku\stvrta_cast\01 tsharkPONDELOK4_5_1.csv");
%M = readtable("C:\Users\patri\Downloads\časti_toku\piata_cast\piata_cast.csv");

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
TCP = zeros(1,dlzka_csv);
UDP = zeros(1,dlzka_csv);

%slotovanie
data_informacie = M.Var8;
protokoly_vsetky = M.Var13;
for i=1:dlzka_csv
    if pom_h == hodiny(i)
        if pom_m == minuty(i)
            if pom_s == sekundy_floored(i)
                data(index) = data(index) + 1;
                data_kB(index) = data_kB(index) + data_informacie(i);
                %protokoly
                switch protokoly_vsetky{i}
                    case 'TCP'
                        TCP(index) = TCP(index) + 1;
                    case 'UDP'
                        UDP(index) = UDP(index) + 1;
                end
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
   
    %protokoly
    switch protokoly_vsetky{i}
        case 'TCP'
            TCP(index) = TCP(index) + 1;
        case 'UDP'
            UDP(index) = UDP(index) + 1;
    end
end

% medzery
medzery = zeros(1,dlzka_csv);
medzery_TCP = zeros(1,dlzka_csv);
index_medzery_TCP = 1;
stary_TCP_cas = 0;
novy_TCP_cas = 0;
medzery_UDP = zeros(1,dlzka_csv);
index_medzery_UDP = 1;
stary_UDP_cas = 0;
novy_UDP_cas = 0;

for i=1:dlzka_csv
    %časy
    if sekundy(i) > 1 && sekundy(i+1) < 1
        medzery(i) = ( 60 - sekundy(i) ) + sekundy(i+1);
        continue
    end
    medzery(i) = sekundy(i+1) - sekundy(i);

    %TCP, UDP
    switch protokoly_vsetky{i}
        case 'TCP'
            if stary_TCP_cas == 0
                stary_TCP_cas = sekundy(i);
                continue
            end

            for j=i:dlzka_csv
                if protokoly_vsetky(j+1) == "TCP" % hladanie dalsi TCP
                    novy_TCP_cas = sekundy(j+1);
                    break
                end
            end
            if novy_TCP_cas == 0 %ci neni posledny
                continue
            end


            if stary_TCP_cas > 30 && novy_TCP_cas < 30
                medzery_TCP(index_medzery_TCP) = ( 60 - stary_TCP_cas ) + novy_TCP_cas;

                stary_TCP_cas = sekundy(i);
                novy_TCP_cas = 0;
                index_medzery_TCP = index_medzery_TCP + 1;
                continue
            end

            medzery_TCP(index_medzery_TCP) = novy_TCP_cas - stary_TCP_cas;

            stary_TCP_cas = sekundy(i);
            novy_TCP_cas = 0;
            index_medzery_TCP = index_medzery_TCP + 1;

        %%%%%%%%%%%%%%%%%UDP%%%%%%%%%%%%%%%%%%
        case 'UDP'
            if stary_UDP_cas == 0
                stary_UDP_cas = sekundy(i);
                continue
            end

            for j=i:dlzka_csv
                if protokoly_vsetky(j+1) == "UDP" % hladanie dalsi UDP
                    novy_UDP_cas = sekundy(j+1);
                    break
                end
            end
            if novy_UDP_cas == 0 %ci neni posledny
                continue
            end

            if stary_UDP_cas > 30 && novy_UDP_cas < 30
                medzery_UDP(index_medzery_UDP) = ( 60 - stary_UDP_cas ) + novy_UDP_cas;

                stary_UDP_cas = sekundy(i);
                novy_UDP_cas = 0;
                index_medzery_UDP = index_medzery_UDP + 1;
                continue
            end

            medzery_UDP(index_medzery_UDP) = novy_UDP_cas - stary_UDP_cas;

            stary_UDP_cas = sekundy(i);
            novy_UDP_cas = 0;
            index_medzery_UDP = index_medzery_UDP + 1;
    end
end

% vypocty
for i=1:index-compute_window+1
    data_pom = data(i:compute_window+i-1);
    data_pom2 = data_kB(i:compute_window+i-1);
    data_pom3 = TCP(i:compute_window+i-1);
    data_pom4 = UDP(i:compute_window+i-1);

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

    %TCP
    m_TCP(i+compute_window-1) = mean(data_pom3); % klzavy priemer
    s_TCP(i+compute_window-1)  = sqrt(cov(data_pom3)); % smerodajna odchylka
    V_TCP(i+compute_window-1) = nasobok_koef*sqrt(cov(data_pom3))/mean(data_pom3); % koeficient variabilnosti
    K_TCP(i+compute_window-1)  = kurtosis(data_pom3); % sikmost
    Skw_TCP(i+compute_window-1) = nasobok_spic*max(skewness(data_pom3),0); % spicatost

    %UDP
    m_UDP(i+compute_window-1) = mean(data_pom4); % klzavy priemer
    s_UDP(i+compute_window-1)  = sqrt(cov(data_pom4)); % smerodajna odchylka
    V_UDP(i+compute_window-1) = nasobok_koef*sqrt(cov(data_pom4))/mean(data_pom4); % koeficient variabilnosti
    K_UDP(i+compute_window-1)  = kurtosis(data_pom4); % sikmost
    Skw_UDP(i+compute_window-1) = nasobok_spic*max(skewness(data_pom4),0); % spicatost
end

%VYPISY
data_plot = data(1:index);
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
histogram(data_plot, 'Normalization', 'probability','NumBins',num_bins_pocty);
title('histogram toku');

subplot(subcislo,1,4);
plot(medzery);
title('medzery');

subplot(subcislo,1,5);
histogram(medzery, 'Normalization', 'probability','NumBins',num_bins_pocty_medzery);
title('histogram medzier');

figure
%%%%%%%%%%%%% VELKOSTI INFORMACIE kB %%%%%%%%%%%%%%
data_plot_kB = data_kB(1:index);
subcislo2 = 3;

subplot(subcislo2,1,1);
plot(data_plot_kB,'blue');
hold on
plot(m_kB,'red');
hold on
plot(s_kB,'green');
hold off
xlim([0 index]);
title("kB - Compute window = "+compute_window+", \color{blue}kB ,\color{red}priemer, \color{green}smer.odchylka");

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
histogram(data_plot_kB, 'Normalization', 'probability','NumBins',num_bins_kB);
title("histogram kB");

figure
%%%%%%%%%%%%%%%%%% TCP %%%%%%%%%%%%%%%%%%%
subcislo3 = 5;
data_TCP = TCP(1:index);
data_TCP_medzery = medzery_TCP(1:index_medzery_TCP);

subplot(subcislo3,1,1);
plot(data_TCP,'blue');
hold on
plot(m_TCP,'red');
hold on
plot(s_TCP);
xlim([0 index]);
title("Compute window = "+compute_window+", \color{blue}TCP ,\color{red}priemer, \color{green}smer.odchylka");

subplot(subcislo3,1,2);
plot(V_TCP,'cyan');
hold on
plot(K_TCP,'black');
hold on
plot(Skw_TCP,'magenta');
hold off
xlim([0 index]);
title("\color{black}sikmost, \color{magenta}"+nasobok_spic+"x spicatost ,\color{cyan} "+nasobok_koef+"xkoef. var.");

subplot(subcislo3,1,3);
histogram(data_TCP, 'Normalization', 'probability','NumBins',num_bins_TCP);
title("histogram TCP");

subplot(subcislo3,1,4);
plot(data_TCP_medzery);
xlim([0 index_medzery_TCP]);
title('medzery');

subplot(subcislo3,1,5);
histogram(data_TCP_medzery, 'Normalization', 'probability','NumBins',num_bins_TCP_medzery);
title('histogram medzier');
figure

%%%%%%%%%%%%%%%%%% UDP %%%%%%%%%%%%%%%%%%%
data_UDP = UDP(1:index);
data_UDP_medzery = medzery_UDP(1:index_medzery_UDP);

subplot(subcislo3,1,1);
plot(data_UDP,'blue');
hold on
plot(m_UDP,'red');
hold on
plot(s_UDP);
xlim([0 index]);
title("Compute window = "+compute_window+", \color{blue}UDP ,\color{red}priemer, \color{green}smer.odchylka");

subplot(subcislo3,1,2);
plot(V_UDP,'cyan');
hold on
plot(K_UDP,'black');
hold on
plot(Skw_UDP,'magenta');
hold off
xlim([0 index]);
title("\color{black}sikmost, \color{magenta}"+nasobok_spic+"x spicatost ,\color{cyan} "+nasobok_koef+"xkoef. var.");

subplot(subcislo3,1,3);
histogram(data_UDP, 'Normalization', 'probability','NumBins',num_bins_UDP);
title("histogram UDP");

subplot(subcislo3,1,4);
plot(data_UDP_medzery);
xlim([0 index_medzery_UDP]);
title('medzery');

subplot(subcislo3,1,5);
histogram(data_UDP_medzery, 'Normalization', 'probability','NumBins',num_bins_UDP_medzery);
title('histogram medzier');






%PRINTY
m(1) = mean(data_plot); % klzavy priemer
s(1)  = sqrt(cov(data_plot)); % smerodajna odchylka
V(1) = sqrt(cov(data_plot))/mean(data_plot); % koeficient variabilnosti
K(1)  = kurtosis(data_plot); % sikmost
Skw(1) = max(skewness(data_plot),0); % spicatost

fprintf("klzavy priemer: %f\n",m(1));
fprintf("smerodajna odchylka: %f\n\n",s(1));
fprintf("koeficient variabilnosti: %f\n",V(1));
fprintf("sikmost: %f\n",K(1));
fprintf("spicatost: %f\n",Skw(1));









