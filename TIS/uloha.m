
compute_window = 20;
max_hist_cislo = 0.001;

nasobok_koef = 20;
nasobok_spic = 5;

% num_bins_pocty_medzery = 800;
% num_bins_kB = 24;
% num_bins_TCP_medzery = 800;
% num_bins_UDP_medzery = 800;
% 
% num_bins_pocty = 100;
% num_bins_TCP = 15;
% num_bins_UDP = 12;



%M = readtable("C:\Users\patri\Downloads\tok\01 tsharkPONDELOK4.csv");%full csv
%M = readtable("C:\Users\patri\Downloads\miniTok\01 tsharkPONDELOK4_0.csv");%minitok
%M = readtable("C:\Users\patri\Downloads\miniShark\01 tsharkPONDELOK4_0_0.csv");%minitok ntbk

%M = readtable("C:\Users\patri\Downloads\časti_toku\druha_cast\druha_cast.csv");%druha cast ntbk
%M = readtable("C:\Users\patri\Downloads\časti_toku\tretia_cast\tretia_cast.csv");%tretia cast ntbk
%M = readtable("C:\Users\patri\Downloads\časti_toku\stvrta_cast\01 tsharkPONDELOK4_5_0.csv");%stvrta cast ntbk
%M = readtable("C:\Users\patri\Downloads\časti_toku\piata_cast\piata_cast.csv");%piata cast ntbk

%X = readtable("C:\Users\patri\Downloads\tok\01 tsharkPONDELOK4_0.csv"); M = X(2500000:5000001,1:14); % prva cast
%M = readtable("C:\Users\patri\Downloads\časti_toku\druha_cast\druha_cast.csv");%druha cast
%M = readtable("C:\Users\patri\Downloads\časti_toku\tretia_cast\tretia_cast.csv");
%M = readtable("C:\Users\patri\Downloads\časti_toku\stvrta_cast\01 tsharkPONDELOK4_5_1.csv");
%M = readtable("C:\Users\patri\Downloads\časti_toku\piata_cast\piata_cast.csv");

%M = readtable("C:\Users\patri\Downloads\modelovanie\pokracovanie\01 tsharkPONDELOK4_1_0.csv");

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
data_kB_TCP = zeros(1,dlzka_csv);
UDP = zeros(1,dlzka_csv);
data_kB_UDP = zeros(1,dlzka_csv);

%slotovanie
data_informacie = M.Var8;
protokoly_vsetky = M.Var13;
for i=1:dlzka_csv
    if pom_s == sekundy_floored(i)
        data(index) = data(index) + 1;
        data_kB(index) = data_kB(index) + data_informacie(i);
        %protokoly
        switch protokoly_vsetky{i}
            case 'TCP'
                TCP(index) = TCP(index) + 1;
                data_kB_TCP(index) = data_kB_TCP(index) + data_informacie(i);
            case 'UDP'
                UDP(index) = UDP(index) + 1;
                data_kB_UDP(index) = data_kB_UDP(index) + data_informacie(i);
        end
        continue
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
    if sekundy(i) > sekundy(i+1)
        medzery(i) = ( 60 - sekundy(i) ) + sekundy(i+1);
        if medzery(i) > 0.2
            medzery(i) = 0.2;
        end
        continue
    end
    medzery(i) = sekundy(i+1) - sekundy(i);
    if medzery(i) > 0.2
        medzery(i) = 0.2;
    end

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


            if stary_TCP_cas > novy_TCP_cas
                medzery_TCP(index_medzery_TCP) = ( 60 - stary_TCP_cas ) + novy_TCP_cas;
                if medzery_TCP(index_medzery_TCP) > 0.2
                    medzery_TCP(index_medzery_TCP) = 0.2;
                end

                stary_TCP_cas = sekundy(i);
                novy_TCP_cas = 0;
                index_medzery_TCP = index_medzery_TCP + 1;
                continue
            end

            medzery_TCP(index_medzery_TCP) = novy_TCP_cas - stary_TCP_cas;
            if medzery_TCP(index_medzery_TCP) > 0.2
                medzery_TCP(index_medzery_TCP) = 0.2;
            end

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

            if stary_UDP_cas > novy_UDP_cas%stary_UDP_cas > 30 && novy_UDP_cas < 30
                medzery_UDP(index_medzery_UDP) = ( 60 - stary_UDP_cas ) + novy_UDP_cas;
                if medzery_UDP(index_medzery_UDP) > 0.2
                    medzery_UDP(index_medzery_UDP) = 0.2;
                end

                stary_UDP_cas = sekundy(i);
                novy_UDP_cas = 0;
                index_medzery_UDP = index_medzery_UDP + 1;
                continue
            end

            medzery_UDP(index_medzery_UDP) = novy_UDP_cas - stary_UDP_cas;
            if medzery_UDP(index_medzery_UDP) > 0.2
                medzery_UDP(index_medzery_UDP) = 0.2;
            end

            stary_UDP_cas = sekundy(i);
            novy_UDP_cas = 0;
            index_medzery_UDP = index_medzery_UDP + 1;
    end
end

% inicializacia statistickych premennych
m = zeros(1,dlzka_csv);s = zeros(1,dlzka_csv);V = zeros(1,dlzka_csv);K = zeros(1,dlzka_csv);Skw = zeros(1,dlzka_csv);
m_kB = zeros(1,dlzka_csv);s_kB = zeros(1,dlzka_csv);V_kB = zeros(1,dlzka_csv);K_kB = zeros(1,dlzka_csv);Skw_kB = zeros(1,dlzka_csv);
m_TCP = zeros(1,dlzka_csv);s_TCP = zeros(1,dlzka_csv);V_TCP = zeros(1,dlzka_csv);K_TCP = zeros(1,dlzka_csv);Skw_TCP = zeros(1,dlzka_csv);
m_UDP = zeros(1,dlzka_csv);s_UDP = zeros(1,dlzka_csv);V_UDP = zeros(1,dlzka_csv);K_UDP = zeros(1,dlzka_csv);Skw_UDP = zeros(1,dlzka_csv);
m_TCP_kB = zeros(1,dlzka_csv);s_TCP_kB = zeros(1,dlzka_csv);V_TCP_kB = zeros(1,dlzka_csv);K_TCP_kB = zeros(1,dlzka_csv);Skw_TCP_kB = zeros(1,dlzka_csv);
m_UDP_kB = zeros(1,dlzka_csv);s_UDP_kB = zeros(1,dlzka_csv);V_UDP_kB = zeros(1,dlzka_csv);K_UDP_kB = zeros(1,dlzka_csv);Skw_UDP_kB = zeros(1,dlzka_csv);

% vypocty
for i=1:index-compute_window+1
    data_pom = data(i:compute_window+i-1);
    data_pom2 = data_kB(i:compute_window+i-1);
    data_pom3 = TCP(i:compute_window+i-1);
    data_pom4 = UDP(i:compute_window+i-1);
    data_pom5 = data_kB_TCP(i:compute_window+i-1);
    data_pom6 = data_kB_UDP(i:compute_window+i-1);

    [m,s,V,K,Skw] = vypocitaj_statisticke_parametre(data_pom,compute_window,i,nasobok_koef,nasobok_spic,m,s,V,K,Skw);
    [m_kB,s_kB,V_kB,K_kB,Skw_kB] = vypocitaj_statisticke_parametre(data_pom2,compute_window,i,nasobok_koef,nasobok_spic,m_kB,s_kB,V_kB,K_kB,Skw_kB);
    [m_TCP,s_TCP,V_TCP,K_TCP,Skw_TCP] = vypocitaj_statisticke_parametre(data_pom3,compute_window,i,nasobok_koef,nasobok_spic,m_TCP,s_TCP,V_TCP,K_TCP,Skw_TCP);
    [m_UDP,s_UDP,V_UDP,K_UDP,Skw_UDP] = vypocitaj_statisticke_parametre(data_pom4,compute_window,i,nasobok_koef,nasobok_spic,m_UDP,s_UDP,V_UDP,K_UDP,Skw_UDP);
    [m_TCP_kB,s_TCP_kB,V_TCP_kB,K_TCP_kB,Skw_TCP_kB] = vypocitaj_statisticke_parametre(data_pom5,compute_window,i,nasobok_koef,nasobok_spic,m_TCP_kB,s_TCP_kB,V_TCP_kB,K_TCP_kB,Skw_TCP_kB);
    [m_UDP_kB,s_UDP_kB,V_UDP_kB,K_UDP_kB,Skw_UDP_kB] = vypocitaj_statisticke_parametre(data_pom6,compute_window,i,nasobok_koef,nasobok_spic,m_UDP_kB,s_UDP_kB,V_UDP_kB,K_UDP_kB,Skw_UDP_kB);
end

%%%%%%%%%%%%%%%%%%%%%%%% MODELOVANIE EXP %%%%%%%%%%%%%%%%%%%%%%%%
% ET_exp = mean(medzery);
% lambda_exp = 1/ET_exp;
% x1 = linspace(0, 0.02, 1000);
% y = lambda_exp * exp((-lambda_exp) * x1);
% 
% 
% histogram(medzery,NumBins=2000);
% hold on;
% plot(x1,(y*50));


%plot udaje
data_plot = data(1:index);
data_plot_kB = data_kB(1:index);

data_TCP = TCP(1:index);
data_TCP_medzery = medzery_TCP(1:index_medzery_TCP);
data_plot_TCP_kB = data_kB_TCP(1:index);

data_UDP = UDP(1:index);
data_UDP_medzery = medzery_UDP(1:index_medzery_UDP);
data_plot_UDP_kB = data_kB_UDP(1:index);

VYPISY
subcislo = 5;

subplot(subcislo,1,1);
plot(data_plot,'blue');
hold on
plot(m,'red');
hold on
plot(s,'green');
hold off
xlim([0 index]);
xlabel("Čas");
ylabel("Počet paketov");
legend('počty paketov','priemer','smer.odchylka','Location','northwest');
title("Compute window = "+compute_window+", \color{blue}počty paketov ,\color{red}priemer, \color{green}smer.odchylka");

subplot(subcislo,1,2);
plot(V,'cyan');
hold on
plot(K,'black');
hold on
plot(Skw,'magenta');
hold off
xlim([0 index]);
xlabel("Čas");
legend('koef. var.','sikmost','spicatost','Location','northwest');
title("\color{black}sikmost, \color{magenta}"+nasobok_spic+"x spicatost ,\color{cyan} "+nasobok_koef+"xkoef. var.");

subplot(subcislo,1,3);
histogram(data_plot, 'Normalization', 'probability','NumBins',num_bins_pocty);
histogram(data_plot, 'Normalization', 'probability');
xlabel("Počet paketov rozdelených do tried");
ylabel("Pravdepodobnosti");
title('histogram toku');

subplot(subcislo,1,4);
plot(medzery);
xlim([0 dlzka_csv]);
xlabel("Počet medzier");
ylabel("Čas");
title('medzery');

subplot(subcislo,1,5);
histogram(medzery, 'Normalization', 'probability','NumBins',num_bins_pocty_medzery);
histogram(medzery, 'Normalization', 'probability');
xlim([0 max_hist_cislo]);
xlabel("Čas rozdelený do tried");
ylabel("Pravdepodobnosti");
title('histogram medzier');

figure
%%%%%%%%%%%% VELKOSTI INFORMACIE kB %%%%%%%%%%%%%%
subcislo2 = 3;

subplot(subcislo2,1,1);
plot(data_plot_kB,'blue');
hold on
plot(m_kB,'red');
hold on
plot(s_kB,'green');
hold off
xlim([0 index]);
xlabel("Čas");
ylabel("Veľkosť paketov");
legend('Veľkosť informácie','priemer','smer.odchylka','Location','northwest');
title("Veľkosť informácie za sekundu v kB - Compute window = "+compute_window+", \color{blue}kB ,\color{red}priemer, \color{green}smer.odchylka");

subplot(subcislo2,1,2);
plot(V_kB,'cyan');
hold on
plot(K_kB,'black');
hold on
plot(Skw_kB,'magenta');
hold off
xlim([0 index]);
xlabel("Čas");
legend('koef. var.','sikmost','spicatost','Location','northwest');
title("\color{black}sikmost, \color{magenta}"+nasobok_spic+"x spicatost ,\color{cyan} "+nasobok_koef+"xkoef. var.");

subplot(subcislo2,1,3);
histogram(data_plot_kB, 'Normalization', 'probability','NumBins',num_bins_kB);
histogram(data_plot_kB, 'Normalization', 'probability');
xlabel("Veľkosť paketov rozdelených do tried");
ylabel("Pravdepodobnosti");
title("histogram kB");

figure
%%%%%%%%%%%%%%%%% TCP %%%%%%%%%%%%%%%%%%%
subcislo3 = 5;

subplot(subcislo3,1,1);
plot(data_TCP,'blue');
hold on
plot(m_TCP,'red');
hold on
plot(s_TCP);
xlim([0 index]);
xlabel("Čas");
ylabel("Počet paketov");
legend('počty TCP','priemer','smer.odchylka','Location','northwest');
title("Compute window = "+compute_window+", \color{blue}počty TCP ,\color{red}priemer, \color{green}smer.odchylka");

subplot(subcislo3,1,2);
plot(V_TCP,'cyan');
hold on
plot(K_TCP,'black');
hold on
plot(Skw_TCP,'magenta');
hold off
xlim([0 index]);
xlabel("Čas");
legend('koef. var.','sikmost','spicatost','Location','northwest');
title("\color{black}sikmost, \color{magenta}"+nasobok_spic+"x spicatost ,\color{cyan} "+nasobok_koef+"xkoef. var.");

subplot(subcislo3,1,3);
histogram(data_TCP, 'Normalization', 'probability','NumBins',num_bins_TCP);
histogram(data_TCP, 'Normalization', 'probability');
xlabel("Počet paketov rozdelených do tried");
ylabel("Pravdepodobnosti");
title("histogram TCP");

subplot(subcislo3,1,4);
plot(data_TCP_medzery);
xlim([0 index_medzery_TCP]);
xlabel("Počet medzier");
ylabel("Čas");
title('medzery');

subplot(subcislo3,1,5);
histogram(data_TCP_medzery, 'Normalization', 'probability','NumBins',num_bins_TCP_medzery);
histogram(data_TCP_medzery, 'Normalization', 'probability');
xlim([0 max_hist_cislo]);
xlabel("Čas rozdelený do tried");
ylabel("Pravdepodobnosti");
title('histogram medzier');


figure
%%%%%%%%%%%%%%%%% UDP %%%%%%%%%%%%%%%%%%%

subplot(subcislo3,1,1);
plot(data_UDP,'blue');
hold on
plot(m_UDP,'red');
hold on
plot(s_UDP);
xlim([0 index]);
xlabel("Čas");
ylabel("Počet paketov");
legend('počty UDP','priemer','smer.odchylka','Location','northwest');
title("Compute window = "+compute_window+", \color{blue}počty UDP ,\color{red}priemer, \color{green}smer.odchylka");

subplot(subcislo3,1,2);
plot(V_UDP,'cyan');
hold on
plot(K_UDP,'black');
hold on
plot(Skw_UDP,'magenta');
hold off
xlim([0 index]);
xlabel("Čas");
legend('koef. var.','sikmost','spicatost','Location','northwest');
title("\color{black}sikmost, \color{magenta}"+nasobok_spic+"x spicatost ,\color{cyan} "+nasobok_koef+"xkoef. var.");

subplot(subcislo3,1,3);
histogram(data_UDP, 'Normalization', 'probability','NumBins',num_bins_UDP);
histogram(data_UDP, 'Normalization', 'probability');
xlabel("Počet paketov rozdelených do tried");
ylabel("Pravdepodobnosti");
title("histogram UDP");

subplot(subcislo3,1,4);
plot(data_UDP_medzery);
xlim([0 index_medzery_UDP]);
xlabel("Počet medzier");
ylabel("Čas");
title('medzery');

subplot(subcislo3,1,5);
histogram(data_UDP_medzery, 'Normalization', 'probability','NumBins',num_bins_UDP_medzery);
histogram(data_UDP_medzery, 'Normalization', 'probability','NumBins',5000);
histogram(data_UDP_medzery, 'Normalization', 'probability');
xlim([0 max_hist_cislo]);
xlabel("Čas rozdelený do tried");
ylabel("Pravdepodobnosti");
title('histogram medzier');

figure

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% VELKOSTI INFORMACII TCP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

subcislo4 = 3;

subplot(subcislo4,1,1);
plot(data_plot_TCP_kB);
hold on
plot(m_TCP_kB,'red');
hold on
plot(s_TCP_kB,'green');
hold off
xlim([0 index]);
xlabel("Čas");
ylabel("Veľkosť paketov");
legend('veľkosti informácií TCP','priemer','smer.odchylka','Location','northwest');
title("Compute window = "+compute_window+", \color{blue}veľkosti informácií TCP ,\color{red}priemer, \color{green}smer.odchylka");


subplot(subcislo4,1,2);
plot(V_TCP_kB,'cyan');
hold on
plot(K_TCP_kB,'black');
hold on
plot(Skw_TCP_kB,'magenta');
hold off
xlim([0 index]);
xlabel("Čas");
legend('koef. var.','sikmost','spicatost','Location','northwest');
title("\color{black}sikmost, \color{magenta}"+nasobok_spic+"x spicatost ,\color{cyan} "+nasobok_koef+"xkoef. var.");

subplot(subcislo4,1,3);
histogram(data_plot_TCP_kB, 'Normalization', 'probability','NumBins',20);
xlabel("Veľkosti paketov rozdelených do tried");
ylabel("Pravdepodobnosti");
title('histogram veľkosti informácií TCP');



figure

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% VELKOSTI INFORMACII UDP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(subcislo4,1,1);
plot(data_plot_UDP_kB);
hold on
plot(m_UDP_kB,'red');
hold on
plot(s_UDP_kB,'green');
hold off
xlim([0 index]);
xlabel("Čas");
ylabel("Veľkosť paketov");
legend('veľkosti informácií UDP','priemer','smer.odchylka','Location','northwest');
title("Compute window = "+compute_window+", \color{blue}veľkosti informácií UDP ,\color{red}priemer, \color{green}smer.odchylka");


subplot(subcislo4,1,2);
plot(V_UDP_kB,'cyan');
hold on
plot(K_UDP_kB,'black');
hold on
plot(Skw_UDP_kB,'magenta');
hold off
xlim([0 index]);
xlabel("Čas");
legend('koef. var.','sikmost','spicatost','Location','northwest');
title("\color{black}sikmost, \color{magenta}"+nasobok_spic+"x spicatost ,\color{cyan} "+nasobok_koef+"xkoef. var.");

subplot(subcislo4,1,3);
histogram(data_plot_UDP_kB, 'Normalization', 'probability', 'NumBins',50);
xlabel("Veľkosti paketov rozdelených do tried");
ylabel("Pravdepodobnosti");
title('histogram veľkosti informácií UDP');


function [m,s,V,K,Skw] = vypocitaj_statisticke_parametre(data_pom,compute_window,i,nasobok_koef,nasobok_spic,m,s,V,K,Skw)
    m(i+compute_window-1) = mean(data_pom); % klzavy priemer
    s(i+compute_window-1)  = sqrt(cov(data_pom)); % smerodajna odchylka
    V(i+compute_window-1) = nasobok_koef*sqrt(cov(data_pom))/mean(data_pom); % koeficient variabilnosti
    K(i+compute_window-1)  = kurtosis(data_pom); % sikmost
    Skw(i+compute_window-1) = nasobok_spic*max(skewness(data_pom),0); % spicatost
end



