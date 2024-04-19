
clear;clc
addpath('C:\Users\patri\Documents\GitHub\MATLAB\Diplomka\funkcie');

where_to_store = "C:\Users\patri\Documents\GitHub\MATLAB\Diplomka\smiesko ukazat\fft";
M = load("C:\Users\patri\Desktop\diplomka\Zaznamy\Finalisti - skopirovane z ostatnych\Uz navzorkovane\Attack_2_d010.mat");
cely_tok = M.a;

cely_tok = cely_tok(1:5000);


keep_frequencies = 1;
[~, y_final1] = fourier_smooth(cely_tok, keep_frequencies);

keep_frequencies = 2;
[~, y_final2] = fourier_smooth(cely_tok, keep_frequencies);

keep_frequencies = 3;
[~, y_final3] = fourier_smooth(cely_tok, keep_frequencies);


keep_frequencies = 5;
[~, y_final5] = fourier_smooth(cely_tok, keep_frequencies);


keep_frequencies = 10;
[~, y_final10] = fourier_smooth(cely_tok, keep_frequencies);


figure1 = figure;
%{
plot(y_final1,'r','LineWidth', 2)
hold on
plot(y_final2,'g','LineWidth', 2)
hold on
%}
plot(y_final3,'b','LineWidth', 2)
hold on
plot(y_final5,'g','LineWidth', 2)
hold on
plot(y_final10,'r','LineWidth', 2)
title("Frekvencie 3,5 a 10")
xlabel("Čas")
ylabel("Amplitúda")
legend("3 frekvencie","5 frekvencií","10 frekvencií");
%saveas(figure1,"3_5_10_frekvencií.png");

figure2 = figure;
plot(M.a)
title("Útok Attack2d010")
xlabel("Čas")
ylabel("Počet paketov")
legend("Data");
%saveas(figure2,"Utok2.png");




% po jednom ukladane
%{
figure1 = figure;
plot(cely_tok)
title("Frekvencie FFT")
hold on
plot(y_final10,'r','LineWidth', 2)
xlabel("Čas")
ylabel("Počet paketov")
legend("data","10 najväčších frekvencií");
saveas(figure1,"frekvencia 10.png");

figure2 = figure;
plot(fft_data);
title("Vyhladené dáta cez 10 frekvencií")
xlabel("Čas")
ylabel("Počet paketov")
legend("data po FFT");
saveas(figure2,"data_frekvencia10.png");
%}








