clc
clear

M = readtable("C:\Users\patri\Downloads\miniShark\01 tsharkPONDELOK4_0_0.csv");
dlzka_csv = height(M)-1;

full_data = M.Var6;
x = "123";
datapom = num2str(x) - '0';

data(1,1) = split(x,"3");

