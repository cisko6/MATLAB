
clear

% čo je okno?

M = load('C:\Users\patri\Documents\GitHub\MATLAB\Utoky\Attack_1.mat');
data = M.a;

%load('C:\Users\patri\Downloads\Atack_3_1024.mat','nu')
%data = nu  ;

N  = length(data);  
okno = 0; 
rozsah = 512;


for i=0:N-okno-rozsah-1
    if mod(i,10000)==0
       i;
    end
    mH(i+1) =     mean(data(1+i:rozsah+i));
    sH(i+1) = sqrt(cov(data(1+i:rozsah+i)));
end
k = 3; % nasobok sigmi
dH = mH - k*sH;
hH = mH + k*sH;

xx  = linspace(1,N,N);
mxx = linspace(rozsah,N,N-okno-rozsah);
plot(xx,data,mxx,dH,'r',mxx,hH,'r',0,1)

%Hpred=data(rozsah+1:N);
%dHpred = [ dH(1) dH(1:N-okno-rozsah-1)];
%hHpred = [ hH(1) hH(1:N-okno-rozsah-1)];
%mx2 = linspace(rozsah,N,N-okno-rozsah);
%plot(mx2,Hpred-hHpred)


