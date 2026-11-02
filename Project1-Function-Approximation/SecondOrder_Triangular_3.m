% Implementation of Fuzzy System
% Triangular Membership Functions
% Second Order

% Clear workspace
clear; close all; clc;

% Define the range for x
x = 0:0.05:25;  % Fine sampling for better precision

% Define the original function g(x)
g = 2 * cos(2.5 * x) + sin(4 * x) + 1.1 * cos(0.3 * x);

% Compute the first derivative dg/dx
dg_dx = -5 * sin(2.5 * x) + 4 * cos(4 * x) - 0.33 * sin(0.3 * x);

% Compute the second derivative d^2g/dx^2
d2g_dx2 = -12.5 * cos(2.5 * x) - 16 * sin(4 * x) - 0.099 * cos(0.3 * x);

% Find the maximum value of d^2g/dx^2
[max_d2g_dx2, idx] = max(abs(d2g_dx2));
max_x = x(idx);  % x-value at which the maximum occurs

figure;
plot(x, d2g_dx2, 'r', 'LineWidth', 2);
hold on;
plot(max_x, -max_d2g_dx2, 'ko', 'MarkerSize', 8, 'DisplayName', 'Max d2g/dx2');
title('Derivative d2g/dx2');
xlabel('x');
ylabel('d2g/d2x');
legend('d2g/d2x', 'Max d2g/d2x');
grid on;

% Define epsilon
epsilon = 0.02;

% Calculate h using the second-order approximation formula
h = sqrt((8 * epsilon) / max_d2g_dx2);

% Calculate the number of membership functions
num_mf = ceil((25 - 0) / h);  % Use ceil to ensure an integer number

% Display the results
disp(['Maximum value of d^2g/dx^2: ', num2str(max_d2g_dx2)]);
disp(['Calculated h: ', num2str(h)]);
disp(['Number of Membership Functions: ', num2str(num_mf)]);

% Define the centers of the triangular membership functions
e = linspace(0, 25, num_mf);  % Centers

% Define the triangular membership functions
x_fine = linspace(0, 25, 1000);  % Fine grid for plotting
mf_values = zeros(num_mf, length(x_fine));  % Store values of each MF

for i = 1:num_mf
    % Define the parameters for each triangle
    if i == 1
        a = 0;  % First triangle starts at 0
    else
        a = e(i-1);  % Left base of the triangle
    end
    
    e_i = e(i);  % Center of the triangle
    
    if i == num_mf
        b = 25;  % Last triangle ends at 25
    else
        b = e(i+1);  % Right base of the triangle
    end
    
    % Calculate membership values for the current triangle
    mf_values(i, :) = max(0, min((x_fine - a) / (e_i - a), (b - x_fine) / (b - e_i)));
end

% Define the output centers for each triangular membership function
y_hat = 2 * cos(2.5 * e) + sin(4 * e) + 1.1 * cos(0.3 * e);  % Output centers (y_hat_j)

% Apply the approximation formula
numerator = zeros(1, length(x_fine));
denominator = zeros(1, length(x_fine));

for i = 1:num_mf
    numerator = numerator + y_hat(i) * mf_values(i, :);
    denominator = denominator + mf_values(i, :);
end

% Avoid division by zero
denominator(denominator == 0) = eps;

% Calculate f(x)
f_approx = numerator ./ denominator;

% Plot the triangular membership functions
% figure;
% hold on;
% for i = 1:num_mf
%     plot(x_fine, mf_values(i, :), 'LineWidth', 1.5, 'DisplayName', ['MF ', num2str(i)]);
% end
% title('Triangular Membership Functions with Second-Order Approximation');
% xlabel('x');
% ylabel('Membership Degree');
% legend('show');
% grid on;

% Plot the results
figure;
plot(x_fine, 2 * cos(2.5 * x_fine) + sin(4 * x_fine) + 1.1 * cos(0.3 * x_fine), 'k-', 'LineWidth', 2.5, 'DisplayName', 'Original g(x)');
hold on;
plot(x_fine, f_approx, 'r--', 'LineWidth', 2.5, 'DisplayName', 'Approximated f(x)');
title('Function Approximation 2nd Order - Triangular');
xlabel('x');
ylabel('f(x)');
legend('show');
grid on;

% Display approximation quality
mse = mean((f_approx - (2 * cos(2.5 * x_fine) + sin(4 * x_fine) + 1.1 * cos(0.3 * x_fine))).^2);
disp(['Mean Squared Error (MSE): ', num2str(mse)]);

% Display Max Error
err = max(abs(f_approx - (2 * cos(2.5 * x_fine) + sin(4 * x_fine) + 1.1 * cos(0.3 * x_fine))));
disp(['Max Error: ', num2str(err)]);