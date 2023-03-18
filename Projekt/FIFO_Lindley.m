clear
clc

load('C:\Users\patri\OneDrive\Documents\GitHub\MATLAB\Utoky\Attack_3_d010.mat')

Nt=a;
dlzkaPcapu = length(Nt);
t = linspace(1,dlzkaPcapu,dlzkaPcapu);

% okno - dlzka vypoctoveho okno
okno = 3000;
d = 100;
Plost = 0.01;

for i=1:dlzkaPcapu-okno
    data  = Nt(i:okno-1+i);

    pdf = hist(data)./sum(hist(data));
    dlzkaPdf = length(pdf);
    for k=1:dlzkaPdf
        if pdf(k)==0
           pdf(k) = 10^(-20);
        end
    end

    Y = log(Plost)/(-d);
    
    % vypocet thety
    theta = 0;
    while true

        for k=1:10
            pom(k) = (exp(theta*k))*pdf(k);
        end

        lambdaTheta = log(sum(pom));

        if lambdaTheta >= Y
            break
        end

        theta = theta + 0.0001;
    end

    % nastavenie kapacity a velkosti buffra
    c = lambdaTheta/theta;
    velkostBuffra = d*c;

end

% tcw1: time compute window - x-ova os pre jedno-oknove parametre

tcw1 = linspace(okno,dlzkaPcapu,dlzkaPcapu-okno);

%plot(t,Nt,tcw1)











