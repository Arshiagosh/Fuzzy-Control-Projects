% Implementation of Fuzzy System
% Gaussian Membership Functions
% First Order

% Clear workspace
clear; close all; clc;

% Define the range for x
x_start = 0;
x_end = 25;

% Define the function g(x) and its derivative dg/dx
x = 0:0.05:25;  % Fine sampling for better precision
g = 2 * cos(2.5 * x) + sin(4 * x) + 1.1 * cos(0.3 * x);  % g(x)

% Compute the derivative dg/dx
dg_dx = -5 * sin(2.5 * x) + 4 * cos(4 * x) - 0.33 * sin(0.3 * x);

% Define epsilon
epsilon = 0.02;

% Find the maximum value of dg/dx
[max_dg_dx, idx] = max(dg_dx);
max_x = x(idx);  % x-value at which the maximum occurs

% Step size h from the previous calculation
h = epsilon / max_dg_dx;

% Number of membership functions
num_mf = ceil((x_end - x_start) / h);

% %Testing
% num_mf = 10;
% h = 25/10;

% Calculate the centers of the Gaussian membership functions
e = linspace(x_start, x_end, num_mf);  % Centers
sigma = h;  % Spread of each Gaussian (proportional to h)

% Define the Gaussian membership functions
x = linspace(x_start, x_end, 1000);  % Fine grid for plotting
mf_values = zeros(num_mf, length(x));  % Store values of each MF

for i = 1:num_mf
    % Calculate Gaussian membership values
    mf_values(i, :) = exp(-((x - e(i)).^2) / (2 * sigma^2));
end

% Define the output centers for each Gaussian membership function
y_hat = 2 * cos(2.5 * e) + sin(4 * e) + 1.1 * cos(0.3 * e);  % Output centers (y_hat_j)

% Apply the approximation formula
numerator = zeros(1, length(x));
denominator = zeros(1, length(x));

for i = 1:num_mf
    numerator = numerator + y_hat(i) * mf_values(i, :);
    denominator = denominator + mf_values(i, :);
end

% Avoid division by zero
denominator(denominator == 0) = eps;

% Calculate f(x)
f_approx = numerator ./ denominator;

% % Plot the Gaussian membership functions
% figure;
% hold on;
% for i = 1:num_mf
%     plot(x, mf_values(i, :), 'LineWidth', 2, 'DisplayName', ['MF ', num2str(i)]);
% end
% title('Gaussian Membership Functions');
% xlabel('x');
% ylabel('Membership Degree');
% grid on;

% Plot the results
figure;
plot(x, 2 * cos(2.5 * x) + sin(4 * x) + 1.1 * cos(0.3 * x), 'k-', 'LineWidth', 2.5, 'DisplayName', 'Original g(x)');
hold on;
plot(x, f_approx, 'r--', 'LineWidth', 2.5, 'DisplayName', 'Approximated f(x)');
title('Function Approximation 1st Order - Gaussian');
xlabel('x');
ylabel('f(x)');
legend('show');
grid on;

% Display the results
disp(['Maximum value of dg/dx: ', num2str(max_dg_dx)]);
disp(['Calculated h: ', num2str(h)]);
disp(['Number of Membership Functions: ', num2str(num_mf)]);

% Display approximation quality
mse = mean((f_approx - (2 * cos(2.5 * x) + sin(4 * x) + 1.1 * cos(0.3 * x))).^2);
disp(['Mean Squared Error (MSE): ', num2str(mse)]);

% Display Max Error
err = max(abs(f_approx - (2 * cos(2.5 * x) + sin(4 * x) + 1.1 * cos(0.3 * x))));
disp(['Max Error: ', num2str(err)]);

