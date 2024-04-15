function [fourier_data, y_final] = fourier_smooth(data, keep_frequencies)
    
    N = length(data);
    t = linspace(1,N,N);

    % fft
    c = fft(data)./N;
    c(1)=0;
    ca = abs(c);
    
    % zisti najvacsie indexy
    c_pom = c(1:floor(length(c)/2));
    biggest_indexes = zeros(1, keep_frequencies);
    for i = 1:keep_frequencies
        [~, index] = max(c_pom);
        biggest_indexes(i) = index;
        c_pom(index) = 0;
    end
    
    % ponechaj iba par frekvencii
    y_pom = 0;
    for i = 1:keep_frequencies
        y_final = y_pom + 2*real(c(biggest_indexes(i)))*cos((biggest_indexes(i)-1)*t*2*pi/N)-2*imag(c(biggest_indexes(i)))*sin((biggest_indexes(i)-1)*t*2*pi/N)+c(1);
        y_pom = y_final;
    end
    
    fourier_data = data-y_final;
    fourier_data(fourier_data < 0) = 0;
    fourier_data = round(fourier_data);

    y_final = y_final+mean(data);
end