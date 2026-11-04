% Recursive Least Squares Training
% Clear workspace
clear; close all; clc;

% Define the true function g(x)
function_value = 2*cos(2.5*(0:0.05:25)) + sin(4*(0:0.05:25)) + 1.1*cos(0.3*(0:0.05:25));

% Generate data
x_vals = linspace(0, 25, 100); % Training input points
y_vals = 2*cos(2.5*x_vals) + sin(4*x_vals) + 1.1*cos(0.3*x_vals); % True outputs

% Create test data
x_test = linspace(0, 25, 1000); % Test input points
y_true = 2*cos(2.5*x_test) + sin(4*x_test) + 1.1*cos(0.3*x_test); % True outputs for testing

% Initialization
theta = [0; 0; 0; 0]; % Initial parameters (4 coefficients)
P = 100000 * eye(4); % Covariance matrix (large value indicates uncertainty)
lambda = 0.999; % Forgetting factor

% Recursive Least Squares Algorithm
for t = 1:length(x_vals)
    % Construct feature vector for current input
    x_t = [cos(2.5*x_vals(t)); sin(4*x_vals(t)); cos(0.3*x_vals(t)); 1];
    y_t = y_vals(t); % Actual output for current input

    % Predicted output
    y_pred = theta' * x_t;

    % Compute error
    error = y_t - y_pred;

    % Update gain vector
    K_t = P * x_t / (lambda + x_t' * P * x_t);

    % Update parameter estimates
    theta = theta + K_t * error;

    % Update covariance matrix
    P = (P - K_t * x_t' * P) / lambda;
end

% Display the estimated parameters
fprintf('Estimated Parameters:\n');
fprintf('theta_1 = %.4f, theta_2 = %.4f, theta_3 = %.4f, theta_4 = %.4f\n', theta(1), theta(2), theta(3), theta(4));

% Generate predictions for evaluation
y_pred_vals = zeros(size(x_vals));
for i = 1:length(x_vals)
    x_t = [cos(2.5*x_vals(i)); sin(4*x_vals(i)); cos(0.3*x_vals(i)); 1];
    y_pred_vals(i) = theta' * x_t;
end

% Plot results
figure;
plot(x_test, y_true, 'k-', 'LineWidth', 2); % True function
hold on;
plot(x_vals, y_pred_vals, 'r--', 'LineWidth', 2); % RLS approximation
legend('True Function', 'RLS Approximation');
xlabel('x');
ylabel('Function Value');
title('Recursive Least Squares Approximation');
grid on;

% Compute error metrics
abs_error = abs(y_vals - y_pred_vals);
min_error = min(abs_error);
max_error = max(abs_error);
mse_error = mean(abs_error.^2);

% Display error metrics
disp('Error Metrics:');
fprintf('Minimum Error: %f\n', min_error);
fprintf('Maximum Error: %f\n', max_error);
fprintf('MSE Error: %f\n', mse_error);
