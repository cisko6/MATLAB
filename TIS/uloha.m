


%M = readtable("C:\Users\patri\Downloads\miniShark\01 tsharkPONDELOK4_0_0.csv");ntbk
M = readtable("C:\Users\patri\Downloads\tok\01 tsharkPONDELOK4.csv");
%M = readtable("C:\Users\patri\Downloads\tok\01 tsharkPONDELOK4_0.csv");
dlzka_csv = height(M)-1;

data_casy = M.Var6;
hodiny = data_casy.Hour;
minuty = data_casy.Minute;
sekundy = floor(data_casy.Second);

pocet_sekund = 1;

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

data_plot = data(1:index);
plot(data_plot);