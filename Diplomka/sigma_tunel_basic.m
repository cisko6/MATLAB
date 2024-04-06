
clear

% čo je okno?

load('C:\Users\patri\Downloads\Atack_3_1024.mat','nu')
data = nu;

N  = length(data);  
predict_window = 512;

k = 10; % nasobok sigmi
for i=1:N-predict_window
    [dH,hH] = vypocitaj_hranice_tunelu(data(i:predict_window+i),predict_window,k);
    dH_final(i) = dH;
    hH_final(i) = hH;
end

t  = linspace(1,N,N);
t2 = linspace(predict_window,N,N-predict_window);
plot(t,data,t2,dH_final,'r',t2,hH_final,'r',0,1)


%Hpred=data(predict_window+1:N);
%dHpred = [ dH(1) dH(1:N-predict_window-1)];
%hHpred = [ hH(1) hH(1:N-predict_window-1)];
%mx2 = linspace(tunnel_window,N,N-okno-tunnel_window);
%plot(mx2,Hpred-hHpred)

function [dH,hH] = vypocitaj_hranice_tunelu(data,predict_window,k)
    mH =     mean(data(1:predict_window));
    sH = sqrt(cov(data(1:predict_window)));

    dH = mH - k*sH;
    hH = mH + k*sH;
end



