

function [mmrp_data] = generate_mmrp(n,dlzka_dat, alfa,beta)
    mmrp_data = zeros(1,ceil(dlzka_dat));

    stav = 1;
    for i=1:n*dlzka_dat
        if stav == 1
            mmrp_data(i) = 1;
    
            pravd = 1.*rand();
            if pravd >= (1 - alfa)
                stav = 0;
            end
        else
            mmrp_data(i) = 0;
    
            pravd = 1.*rand();
            if pravd >= (1-beta)
                stav = 1;
            end
        end
    end
    mmrp_data = mmrp_data(1:find(mmrp_data, 1, 'last'));
end


