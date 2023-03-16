% Define parameters
lambda = 0.5; % shape parameter
theta = 1; % scale parameter
T = 100; % simulation time

% Generate a random sample of service times using a custom function
lindley = @(n) theta./(1 - exprnd(1/lambda, [1, n]));
service_times = lindley(T);

% Simulate the arrival process using a Poisson process
interarrival_times = exprnd(1/lambda, [1, T]);
arrival_times = cumsum(interarrival_times);

% Calculate the departure times of each customer
departure_times = arrival_times + service_times;

% Calculate the buffer level over time
buffer = zeros(1, T);
for i = 1:T
    % Count the number of customers or packets in the buffer at time i
    buffer(i) = sum(arrival_times <= i & departure_times > i);
end

plot(buffer)
xlabel('Time')
ylabel('Buffer level')
title('Lindley buffer simulation')
