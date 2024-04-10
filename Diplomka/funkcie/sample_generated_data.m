

function [sampled_data] = sample_generated_data(data_bits, N)
    N = round(N);
    dlzka_dat = length(data_bits)/N;
    pocet_bitov = ceil(N*dlzka_dat);
    sampled_data = zeros(1,pocet_bitov);
    try
        pom_sum = sum(data_bits(1:N));
    catch
        fprintf("CATCH: sample_generated_data - pom_sum\n");
        disp(data_bits);
        return
    end
    sampled_data(1) = pom_sum;

    for i=1:(pocet_bitov/N)-1
        try
            pom_sum = sum(data_bits((i*N)+1:(i*N)+N));
        catch
            break
        end
        sampled_data(i+1) = pom_sum;
    end
    %sampled_data = sampled_data(1:dlzka_dat);
    sampled_data = sampled_data(1:find(sampled_data, 1, 'last'));
end
