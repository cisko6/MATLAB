clear

load('Attack_3_d010.mat')


Nt=a;

N = length(Nt);

t = linspace(1,N,N);


% okno - dlzka vypoctoveho okno

okno = 3000;

for i=1:N-okno
    % data - vypoctove okno pre vypocet Entropie
    data  = Nt(i:okno-1+i);
    % vypocet pravdepodobnosti tried z histogramu, Matlab dava asi default
    % 10 tried, niektore mi ale vyskocili nulove, preto som to potom v
    % cykle osetril
    pdf = hist(data)./sum(hist(data));
    n = length(pdf);
    for k=1:n
        if pdf(k)==0
           pdf(k) = 10^(-20);
        end
    end
    % vypocet Entropie pre "data", isto ale v Matlabe najdete nejaku jeho
    % funkciu
    Ent(i) = -sum(pdf.*log(pdf));
    % vypocet priemeru pre "data"
    m(i)  = mean(data); 
end

% tcw1: time compute window - x-ova os pre jedno-oknove parametre

tcw1 = linspace(okno,N,N-okno);

% vykreli utok Nt, klzavy priemer m a Entrorpie v jednom obrazku, 800*Ent
% som dal preto, aby bola Entropia v jedmnej mierke, este je dobre
% zvyraznit vlozenou ciarou, kde zacal utok

plot(t,Nt,tcw1,12000*Ent,'k')

