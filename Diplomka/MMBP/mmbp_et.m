

%ET MMBP
%26 27 29

%%%%%%%%%%%%%%%%%%%%%%%% ET ET2 %%%%%%%%%%%%%%%%%%%%%%%%

%et = ((alfa_2 + beta_2)/(beta_2 * p_2)) - 1;
%et2 = % netusim čo je q

lastNonZeroIndex = find(sampled_mmbp_data, 1, 'last');
sampled_mmbp_data = sampled_mmbp_data(1:lastNonZeroIndex);

et = sampled_mmbp_data(lastNonZeroIndex) / lastNonZeroIndex; % ked sa na tento vzorec divam po case tak toto "sampled_mmbp_data(lastNonZeroIndex)" je zle lebo nemam kumulativne casy

ti = diff(sampled_mmbp_data);
ti2 = ti.^2;
n = max(sampled_mmbp_data);
et2 = (1/(n - 1)) * sum(ti2);

%%% TOTO JE LEPSIE 

%{
%clc; clear;

% vstup kumulovane medzery

M = importdata("C:\Users\patri\Desktop\diplomka\TIS\Cele zaznamy\TIS medzery\kumulovane medzery\0104.txt");

dlzka_dat = length(M);

%%%%%%%%%%%%%% Zistenie ET, ET2 %%%%%%%%%%%%%%

et = M(dlzka_dat)/dlzka_dat;

ti = diff(M);
ti2 = ti.^2;

n = max(M);
et2 = (1/(n - 1)) * sum(ti2);

disp(et)
disp(et2)


%}
