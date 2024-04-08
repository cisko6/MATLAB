
function [ET,ET2] = zisti_et_from_bits(mmrp_bits)
    pocetnosti = zisti_pocetnosti(mmrp_bits);
    N = sum(pocetnosti);
    ET = 0;
    ET2 = 0;
    for i=1:length(pocetnosti)
        ET = ET + ( (i-1) * pocetnosti(i)/N );
        ET2 = ET2 + ( ((i-1)^2) * pocetnosti(i)/N );
    end
end