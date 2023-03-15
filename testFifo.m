
bufferSize = 10;

bufferIndex = 1;

data = 1:30;

for i = 1:length(data)
    buffer(bufferIndex) = data(i);
    
    bufferIndex = mod(bufferIndex, bufferSize) + 1;
end

disp(buffer);











