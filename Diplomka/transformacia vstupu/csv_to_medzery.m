
%clear;clc

% vstup pcap - vystup nekumulovane medzery

folder_path = "C:\Users\patri\Desktop\diplomka\TIS\Po vybranych kuskoch\0207_3051.csv";
%M = readtable(folder_path);

[~, folder_name, ~] = fileparts(folder_path);

dlzka_csv = height(M)-1;
data_casy = M.Var6;
minuty = data_casy.Minute;
sekundy = data_casy.Second;

medzery = create_spaces_from_csvPcap(dlzka_csv, sekundy, minuty);
plot(medzery);

% zapisat do foldera

%matrix_column_vector = medzery(:);
%file_name = sprintf('%s.txt', folder_name);
%fileID = fopen(file_name, 'w');
%fprintf(fileID, '%f\n', matrix_column_vector);
%fclose(fileID);

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


