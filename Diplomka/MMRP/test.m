clc
clear
x = [1,2,3];
y = [2,3,4];
z = [3,4,5];
plot(x,'b')
hold on
plot(y,'r')
hold on
plot(z,'m')
legend("tok","alfa","beta");
ylabel("Počet paketov")
xlabel("Čas(s)")