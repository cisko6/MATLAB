

function [mmbp_bits] = generate_mmbp(n,dlzka_dat, alfa,beta,p)
    
    pocet_bitov = n * dlzka_dat;
    mmbp_bits = zeros(1,ceil(dlzka_dat));
    stav = 1;

    for i=1:pocet_bitov
        if stav == 1
            pravd_p = 1.*rand();
            if pravd_p <= p
                mmbp_bits(i) = 1;
            else
                mmbp_bits(i) = 0;
            end
    
            pravd = 1.*rand();
            if pravd >= (1 - alfa)
                stav = 0;
            end
        else
            mmbp_bits(i) = 0;
    
            pravd = 1.*rand();
            if pravd >= (1-beta)
                stav = 1;
            end
        end
    end
    mmbp_bits = mmbp_bits(1:find(mmbp_bits, 1, 'last'));
end
