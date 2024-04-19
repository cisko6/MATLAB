
Xr = rand(32,8);
Xb = binornd(10,0.5,32,8);
X = [ Xr
      Xb ];
m = mean(X);
X0 = X -m;

%x = linspace(1,8,8);
%plot(x,X0(1:32,:),'-b',x,X0(33:64,:),'-r')
%grid on

R = cov(X0);
[U,S,V] = svd(R); % to iste co PCA
L = diag(S);
Inf3 = (L(1)+L(2)+L(3))/(sum(L));
Inf2 = (L(1)+L(2))/(sum(L));
C0 = X0*U;



score = C0;
num_rows = 64;
figure;
scatter(score(:,1), score(:,2), 100, linspace(1, num_rows, num_rows), 'filled');
dx = 0.02; dy = 0.02;
text(score(:,1)+dx, score(:,2)+dy, string(1:num_rows), 'FontSize', 8);
colorbar;
grid on
title('PCA 2D Projection with Labels');
xlabel('Prvý hlavný komponent');
ylabel('Druhý hlavný komponent');

figure;
scatter3(score(:,1), score(:,2), score(:,3), 100, linspace(1, num_rows, num_rows), 'filled');
colorbar;
title('PCA 3D Projection with Labels');
xlabel('Prvý hlavný komponent');
ylabel('Druhý hlavný komponent');
zlabel('Tretí hlavný komponent');
dx = 0.05;
dy = 0.05;
dz = 0.05;
text(score(:,1) + dx, score(:,2) + dy, score(:,3) + dz, string(1:num_rows), 'FontSize', 8);


%{
figure
plot(x,C0(1:32,:),'-b',x,C0(33:64,:),'-r')
grid on
%plot(C0(1:32,1),C0(1:32,2),'b')
%hold on
%plot(C0(33:64,1),C0(33:64,2),'*r')
%grid on
plot3(C0(1:32,1),C0(1:32,2),C0(1:32,3),'b*')
hold on
plot3(C0(33:64,1),C0(33:64,2),C0(33:64,3),'r*')
grid on
%}
