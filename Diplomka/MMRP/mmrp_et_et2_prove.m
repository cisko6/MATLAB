
clc
clear

chi_alfa = 0.05;
pocet_tried_hist = 10;

alfa = 0.1;
beta = 0.3;
n = 8;
pocet_generovanych = 10000;

% generovanie dát
mmrp_bits = generate_mmrp(n,pocet_generovanych, alfa,beta);

% zistenie ET, ET2
[ET,ET2] = zisti_et_from_bits(mmrp_bits);

beta2 = 2*ET/(ET2 + ET);
alfa2 = beta2 * ET;

fprintf('ET=%.15f\n', ET);
fprintf('ET2=%.15f\n\n', ET2);
fprintf('MMBP alfa ma byt: %.3f, je: %.3f\n',alfa, alfa2);
fprintf('MMBP beta ma byt: %.3f, je: %.3f\n',beta, beta2);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



