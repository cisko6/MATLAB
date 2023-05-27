
clear

load('Attack_8.mat')


Nt=a;
N = length(Nt);
t = linspace(1,N,N);


okno = 1024;
%okno = 2048;
%okno = 4096;
%okno = 3000;
for i=1:N-okno
    %entropia a pravdepodobnosti P
    dataP  = Nt(i:okno-1+i);
    pdfP = hist(dataP)./sum(hist(dataP));

    n = length(pdfP);
    for k=1:n
        if pdfP(k)==0
            pdfP(k) = 10^(-20);
        end
    end
    EntP(i) = -sum(pdfP.*log(pdfP));

    %pravdepodobnosti Q
    dataQ = Nt(i+1:okno+i);
    pdfQ = hist(dataQ)./sum(hist(dataQ));

    %vzorec pre krizovu entropiu
    krizovaEnt(i) = EntP(i)*(log(pdfP/pdfQ));
    if krizovaEnt(i)<0
        krizovaEnt(i)=krizovaEnt(i)*(-1);
    end

    m(i)  = mean(dataP);
end



% tcw1: time compute window - x-ova os pre jedno-oknove parametre
tcw1 = linspace(okno,N,N-okno);

% vykreli utok Nt, klzavy priemer m a Entrorpie v jednom obrazku, 800*Ent
% som dal preto, aby bola Entropia v jedmnej mierke, este je dobre
% zvyraznit vlozenou ciarou, kde zacal utok

%plot(t,Nt)
plot(tcw1,krizovaEnt,'r')
%plot(krizovaEnt,'r')


