% Parameters
c = 1; % kapacita
a = [2 5 1 3 4]; % prichadzajuce pakety
T = length(a); % čas

% Inicializacia buffra
q = zeros(1, T+1);
q(1) = 0;

% Simulacia buffra
for t = 1:T
    q(t+1) = max(q(t) + a(t) - c, 0);
end

figure;
stem(0:T, q);
xlabel('Time step');
ylabel('Buffer state');
title('Lindley buffer simulation');
