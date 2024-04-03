
clear;clc

% vstup csv,pcap - vystup nekumulovane medzery

folder_path = "C:\Users\patri\Desktop\diplomka\Zaznamy\záznamy\Real Utoky\fri-01-20141113.Time\fri-01-20141113.Time.csv";
[~, folder_name, ~] = fileparts(folder_path);

% pcap
%{
pcapAll = pcapReader(folder_path);
pcap = pcapAll.readAll; % toto zakomentovat ked nechcem cakat rok

data_casy = datetime([pcap(:).Timestamp] / 1e6, 'ConvertFrom', 'posixtime');
sekundy = second(data_casy);
minuty = minute(data_casy);
dlzka_suboru = pcapAll.PacketsRead;
%}

% csv
%{
%M = readtable(folder_path);
dlzka_suboru = height(M)-1;
data_casy = M.Var6;
minuty = data_casy.Minute;
sekundy = data_casy.Second;
%}

medzery = create_spaces_from_csvPcap(dlzka_suboru, sekundy, minuty);
plot(medzery);


% test zobrazenie medzier

figure
slot_window = 0.1;
sampled_data = medzery_to_casy(medzery, slot_window);
lastNonZeroIndex = find(sampled_data, 1, 'last');
sampled_data = sampled_data(1:lastNonZeroIndex);
plot(sampled_data)



% zapisat do foldera
matrix_column_vector = medzery(:);
file_name = sprintf('%s.txt', folder_name);
fileID = fopen(file_name, 'w');
fprintf(fileID, '%f\n', matrix_column_vector);
fclose(fileID);

function medzery = create_spaces_from_csvPcap(dlzka_csv, sekundy, minuty)
    medzery = zeros(1,dlzka_csv);
    for i=1:dlzka_csv-1
    
        medzery(i) = sekundy(i+1) - sekundy(i);
    
        if minuty(i) ~= minuty(i+1)
            medzery(i) = medzery(i) + 60;
        end
    
        if medzery(i) < 0
            medzery(i) = 0.0001;
        end
    
    end
end


%%%%%%%%%%%%%%%toto len test

function sampled_data = medzery_to_casy(data, slot_window)
    sampled_index = 1;
    sampled_data = zeros(1,length(data));
    pom_sucet = 0;
    
    for i=1:length(data)
        pom_sucet = pom_sucet + data(i);
    
        if pom_sucet < slot_window
            sampled_data(sampled_index) = sampled_data(sampled_index) + 1;
        else
            sampled_index = sampled_index + 1;
            sampled_data(sampled_index) = sampled_data(sampled_index) + 1;
            pom_sucet = 0;
        end
    end
end


