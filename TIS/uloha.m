clear
clc

compute_window = 5;

%M = readtable("C:\Users\patri\Downloads\miniShark\01 tsharkPONDELOK4_0_0.csv");ntbk
%M = readtable("C:\Users\patri\Downloads\tok\01 tsharkPONDELOK4.csv");%full csv
M = readtable("C:\Users\patri\Downloads\miniTok\01 tsharkPONDELOK4_0.csv");
dlzka_csv = height(M)-1;

data_casy = M.Var6;
hodiny = data_casy.Hour;
minuty = data_casy.Minute;
sekundy = floor(data_casy.Second);

%inicializacia cyklu slotovania
pom_h = hodiny(1);
pom_m = minuty(1);
pom_s = sekundy(1);
index = 1;
data = zeros(1,dlzka_csv);

%slotovanie
for i=1:dlzka_csv
    if pom_h == hodiny(i)
        if pom_m == minuty(i)
            if pom_s == sekundy(i)
                data(index) = data(index) + 1;
                continue
            end
        end
    end
    
    pom_h = hodiny(i);
    pom_m = minuty(i);
    pom_s = sekundy(i);

    index = index + 1;
    data(index) = data(index) + 1;
end

%
for i=1:index-compute_window+1
    data_pom = data(i:compute_window+i-1);

    m(i+compute_window-1) = mean(data_pom); % klzavy priemer
    s(i+compute_window-1)  = sqrt(cov(data_pom)); % smerodajna odchylka
    V(i+compute_window-1) = sqrt(cov(data_pom))/mean(data_pom); % koeficient variabilnosti
    K(i+compute_window-1)  = kurtosis(data_pom); % sikmost
    Skw(i+compute_window-1) = max(skewness(data_pom),0); % spicatost

    %d0(:) = 0;
    %d0 = data_pom - m; % centrovane data
    %Engf(i) = sqrt(d0*d0')./i; % priemerna energia centrovanych dat
end

%VYPISY
data_plot = data(1:index);


subplot(2,1,1);
plot(data_plot,'blue');
hold on
plot(m,'red');
hold on
plot(s,'green');
hold off
xlim([0 index]);
title("Compute window = "+compute_window+", \color{blue}tok ,\color{red}priemer, \color{green}smer.odchylka");

subplot(2,1,2);
plot(V,'cyan');
hold on
plot(K,'black');
hold on
plot(Skw,'magenta');
hold off
xlim([0 index]);
title('\color{black}sikmost, \color{magenta}spicatost ,\color{cyan}koef. var.');


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










