% Parametre
c = 2; % kapacita
velkost_buffra = 2; 
T = 100; % čas
priemerPrichodov = 1;

a = exprnd(priemerPrichodov, [1, T]); % prichadzajuce pakety
pr = mean(a);
% Initialize the buffer
q = zeros(1, T+1);
q(1) = 0;
vyhodene = zeros(1,T+1);

% Simulacia buffra
for t = 1:T
    % buffer
    q(t+1) = min(max(q(t) + a(t) - c, 0), velkost_buffra);

    % zahodene pakety
    je_viac = max(q(t) + a(t) - c, 0);
    if je_viac > velkost_buffra
        vyhodene(t) = max(q(t) + a(t) - c, 0);
    end
end


plot(q,'b');
hold on
plot(vyhodene,'r');
hold off
xlabel('Time step');
ylabel('Buffer state');
title(sprintf('Lindley buffer simulation (B=%d)', velkost_buffra));



