% Parameters
c = 2; % kapacita
T = 100; % čas
priemerPrichodov = 1;

a = exprnd(priemerPrichodov, [1, T]); % prichadzajuce pakety

% Inicializacia buffra
q = zeros(1, T+1);
q(1) = 0;

% Simulacia buffra
for t = 1:T
    q(t+1) = max(q(t) + a(t) - c, 0);
end

plot(q);
xlabel('Time step');
ylabel('Buffer state');
title('Lindley buffer simulation');
