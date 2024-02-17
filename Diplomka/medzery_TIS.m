
%M = readtable("C:\Users\patri\Downloads\TIS zaznamy\01 tsharkPONDELOK4.csv");

dlzka_csv = height(M)-1;
data_casy = M.Var6;

minuty = data_casy.Minute;
sekundy = data_casy.Second;

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

plot(medzery);

% Reshape the matrix to a column vector
matrix_column_vector = medzery(:);

% Specify the file name
file_name = 'pod_sebou.txt';

% Open the file for writing
fileID = fopen(file_name, 'w');

% Write the values to the file
fprintf(fileID, '%f\n', matrix_column_vector);

% Close the file
fclose(fileID);

%dlmwrite("test.txt", medzery);
%writematrix(medzery, 'MyFile.txt')
