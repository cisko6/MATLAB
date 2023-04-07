clear
clc

%M = readtable("C:\Users\patri\Downloads\miniShark\01 tsharkPONDELOK4_0_0.csv");ntbk
%M = readtable("C:\Users\patri\Downloads\tok\01 tsharkPONDELOK4.csv");%full csv
M = readtable("C:\Users\patri\Downloads\miniTok\01 tsharkPONDELOK4_0.csv");
dlzka_csv = height(M)-1;

data_casy = M.Var6;
hodiny = data_casy.Hour;
minuty = data_casy.Minute;
sekundy = floor(data_casy.Second);

%inicializacia cyklu
pom_h = hodiny(1);
pom_m = minuty(1);
pom_s = sekundy(1);
index = 1;
data = zeros(1,dlzka_csv);

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

%VYPISY
data_plot = data(1:index);

m = mean(data_plot); % klzavy priemer
s  = sqrt(cov(data_plot)); % smerodajna odchylka
V = sqrt(cov(data_plot))/mean(data_plot); % koeficient variabilnosti
K  = kurtosis(data_plot); % sikmost
Skw = max(skewness(data_plot),0); % spicatost
d0 = data_plot - m; % centrovane data
Engf = sqrt(d0*d0')./i; % priemerna energia centrovanych dat

fprintf("klzavy priemer: %f\n",m);
fprintf("smerodajna odchylka: %f\n\n",s);
fprintf("koeficient variabilnosti: %f\n",V);
fprintf("sikmost: %f\n",K);
fprintf("spicatost: %f\n",Skw);
fprintf("priemerna energia centrovanych dat: %f\n",Engf);

plot(data_plot);





