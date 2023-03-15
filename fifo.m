clear

load('Attack_3_d010.mat')

Nt=a;

dlzkaPcapu = length(Nt);

t = linspace(1,dlzkaPcapu,dlzkaPcapu);


% okno - dlzka vypoctoveho okno
okno = 3000;
d = 100;
Plost = 0.01;

for i=1:2%dlzkaPcapu-okno
    data  = Nt(i:okno-1+i);

    pdf = hist(data)./sum(hist(data));
    dlzkaPdf = length(pdf);
    for k=1:dlzkaPdf
        if pdf(k)==0
           pdf(k) = 10^(-20);
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Y = log(Plost)/(-d);
    
    lambda = 0;
    while true
        %lambdaTheta = 0;

        for k=1:10
            pom(k) = (exp(lambda*k))*pdf(k);
        end

        lambdaTheta = log(sum(pom));

        if lambdaTheta >= Y
            break
        end


        lambda = lambda + 0.001;
    end




    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    c = lambdaTheta/lambda;
    
    velkostBuffra = d*c;


end

% tcw1: time compute window - x-ova os pre jedno-oknove parametre

tcw1 = linspace(okno,dlzkaPcapu,dlzkaPcapu-okno);

% vykreli utok Nt, klzavy priemer m a Entrorpie v jednom obrazku, 800*Ent
% som dal preto, aby bola Entropia v jedmnej mierke, este je dobre
% zvyraznit vlozenou ciarou, kde zacal utok

%plot(t,Nt,tcw1)
