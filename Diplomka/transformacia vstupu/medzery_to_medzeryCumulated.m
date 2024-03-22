
clear
clc

% vstup nekumulovane medzery

folder_path = "C:\Users\patri\Desktop\diplomka\TIS\TIS medzery\medzery\0907.txt";
[~, folder_name, ~] = fileparts(folder_path);

data = importdata(folder_path);
cumulated_spaces = cumulate_spaces(data);


matrix_column_vector = cumulated_spaces(:);
file_name = sprintf('%s.txt', folder_name);
fileID = fopen(file_name, 'w');
fprintf(fileID, '%f\n', matrix_column_vector);
fclose(fileID);


function [cumulated_spaces] = cumulate_spaces(data)
    cumulated_spaces = zeros(1,ceil(length(data)));
    cumulated_spaces(1) = data(1);
    for i=2:length(data)
        cumulated_spaces(i) = cumulated_spaces(i-1) + data(i);
    end
end