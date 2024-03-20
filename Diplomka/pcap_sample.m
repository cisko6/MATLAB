
%clear
%clc

% vstup kumulovane medzery

%M = readtable("C:\Users\patri\Desktop\diplomka\TIS\Po vybranych kuskoch\0207_3051.csv");

data_casy = M.Var6;
n1 = numel(data_casy);

%data_casy = data_casy(1:ceil(n1/10)); %0207
%slot_window = 0.1;       %0207

%data_casy = data_casy(500000:ceil(n1/6)); %0402
%slot_window = 0.1;       %0402

%data_casy = data_casy(20000:ceil(n1/20)); %0504a pre medzery
%data_casy = data_casy(20000:2500000); %0504a pre pcap
%slot_window = 0.01;    %0504a

%data_casy = data_casy(ceil(15*n1/40):ceil(17*n1/40)); %0504b
%slot_window = 0.01;    %0504b

%data_casy = data_casy(ceil(27*n1/40):ceil(31*n1/40)); %0504c
%slot_window = 0.1;    %0504c

%data_casy = data_casy(1:ceil(n1/20)); %0605a
%slot_window = 0.01;    %0605a

%data_casy = data_casy(ceil(6*n1/20):ceil(7*n1/20)); %0605b 12 000 000 : 14 000 000
%slot_window = 0.01;    %0605b

%data_casy = data_casy(ceil(6*n1/20):ceil(7*n1/20)); %0605b 12 000 000 : 14 000 000
%slot_window = 0.01;    %0605b

%data_casy = data_casy(ceil(4*n1/32):ceil(6*n1/32)); %0701
slot_window = 0.1;    %0701

tStart = min(data_casy);
tEnd = max(data_casy);

timeBins = tStart:seconds(slot_window):tEnd;

[counts, ~] = histcounts(data_casy, timeBins);

plot(counts)
