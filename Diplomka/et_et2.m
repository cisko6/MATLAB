
%clc; clear;

% vstup kumulovane medzery

%M = importdata("C:\Users\patri\Desktop\diplomka\TIS\Cele zaznamy\TIS medzery\kumulovane medzery\0104.txt");

dlzka_dat = length(M);

%%%%%%%%%%%%%% Zistenie ET, ET2 %%%%%%%%%%%%%%

et = M(dlzka_dat)/dlzka_dat;

ti = diff(M);
ti2 = ti.^2;

n = max(M);
et2 = (1/(n - 1)) * sum(ti2);

disp(et)
disp(et2)
