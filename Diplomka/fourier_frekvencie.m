clear

load("C:\Users\patri\Documents\GitHub\MATLAB\Utoky\Attack_2_d010.mat")
N = 1000;
a = a(1:N);
t = linspace(1,N,N);
plot(t,a)
ylim([-1000 1000])
title("1")
figure
grid on
c =fft(a)./N;
%c(1)=0;
ca = abs(c);
y1 =    2*real(c(6))*cos(5*t*2*pi/N)-2*imag(c(6))*sin(5*t*2*pi/N)+c(1);
y2 = y1+2*real(c(2))*cos(1*t*2*pi/N)-2*imag(c(2))*sin(1*t*2*pi/N);
y3 = y2+2*real(c(7))*cos(6*t*2*pi/N)-2*imag(c(7))*sin(6*t*2*pi/N);
plot(t,a,t,y1,'r-',t,y2,'g-',t,y3,'k-')
ylim([-1000 1000])
title("2")
figure
y=a-y3;
plot(t,y)
hold on 
plot(t,a)
ylim([-1000 1000])
title("3")

figure
y=a-y2;
plot(t,y)
ylim([-1000 1000])
title("4")

figure
y=a-y1;
plot(t,y)
ylim([-1000 1000])
title("5")
