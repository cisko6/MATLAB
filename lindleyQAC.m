% Parameters
c = 1; % capacity
a = [2 5 1 3 4]; % incoming packets at each time step
T = length(a); % number of time steps

% Initialize the buffer
q = zeros(1, T+1); % buffer state at each time step
q(1) = 0; % initial buffer state

% Simulate the buffer
for t = 1:T
    q(t+1) = max(q(t) + a(t) - c, 0);
end

% Plot the buffer state
figure;
stem(0:T, q);
xlabel('Time step');
ylabel('Buffer state');
title('Lindley buffer simulation');
