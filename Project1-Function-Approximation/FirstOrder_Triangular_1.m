% Implementation of Fuzzy System 
% Triangular Membership Functions
% First Order

% Clear workspace
clear; close all; clc;

% Define the function g(x) and its derivative dg/dx
x = 0:0.05:25;  % Fine sampling for better precision
g = 2 * cos(2.5 * x) + sin(4 * x) + 1.1 * cos(0.3 * x);  % g(x)

% Compute the derivative dg/dx
dg_dx = -5 * sin(2.5 * x) + 4 * cos(4 * x) - 0.33 * sin(0.3 * x);

% Find the maximum value of dg/dx
[max_dg_dx, idx] = max(dg_dx);
max_x = x(idx);  % x-value at which the maximum occurs

% Plot g(x) and dg/dx for visualization
figure;
plot(x, g, 'k', 'LineWidth', 2, 'DisplayName', 'g(x)');
legend('g(x)');
title('Function g(x)');
xlabel('x');
ylabel('g(x)');
grid on;

figure;
plot(x, dg_dx, 'r', 'LineWidth', 1.5);
hold on;
plot(max_x, max_dg_dx, 'ko', 'MarkerSize', 8, 'DisplayName', 'Max dg/dx');
title('Derivative dg/dx');
xlabel('x');
ylabel('dg/dx');
legend('dg/dx', 'Max dg/dx');
grid on;

% Display the maximum derivative
disp(['Maximum value of dg/dx: ', num2str(max_dg_dx)]);
disp(['At x = ', num2str(max_x)]);

% Define epsilon
epsilon = 0.02;

% Calculate max(dg/dx) from the previous step
% Derivative dg/dx already defined
[max_dg_dx, ~] = max(dg_dx);

% Calculate h
h = epsilon / max_dg_dx;

% Calculate the number of membership functions
num_mf = ceil((25 - 0) / h);  % Use ceil to ensure an integer number

% Display the results
disp(['Maximum value of dg/dx: ', num2str(max_dg_dx)]);
disp(['Calculated h: ', num2str(h)]);
disp(['Number of Membership Functions: ', num2str(num_mf)]);

% Define the range for x
x_start = 0;
x_end = 25;

% Step size h from the previous calculation
h =  epsilon / max_dg_dx;

% Number of membership functions
num_mf = ceil((x_end - x_start) / h);

% %Testing
% num_mf = 10;
% h = 25/10;

% Calculate the centers of the membership functions
e = linspace(x_start, x_end, num_mf);  % Centers

% Define the triangular membership functions
x = linspace(x_start, x_end, 1000);  % Fine grid for plotting
mf_values = zeros(num_mf, length(x));  % Store values of each MF

for i = 1:num_mf
    % Define the parameters for each triangle
    if i == 1
        a = x_start;  % First triangle starts at x_start
    else
        a = e(i-1);
    end
    e_i = e(i);
    
    if i == num_mf
        b = x_end;  % Last triangle ends at x_end
    else
        b = e(i+1);
    end
    
    % Calculate the membership values for the current triangle
    mf_values(i, :) = max(0, min((x - a) / (e_i - a), (b - x) / (b - e_i)));
end

% % Plot the triangular membership functions
% figure;
% hold on;
% for i = 1:num_mf
%     plot(x, mf_values(i, :), 'LineWidth', 1.5, 'DisplayName', ['MF ', num2str(i)]);
% end
% title('Triangular Membership Functions');
% xlabel('x');
% ylabel('Membership Degree');
% grid on;

% Centers of membership functions
e = linspace(x_start, x_end, num_mf);  % Centers

% Define triangular membership functions and their centers
mf_values = zeros(num_mf, length(x));  % Store membership values
y_hat = 2 * cos(2.5 * e) + sin(4 * e) + 1.1 * cos(0.3 * e);  % Output centers (y_hat_j)

for i = 1:num_mf
    % Define the parameters for each triangle
    if i == 1
        a = x_start;  % First triangle starts at x_start
    else
        a = e(i-1);
    end
    
    e_i = e(i);
    
    if i == num_mf
        b = x_end;  % Last triangle ends at x_end
    else
        b = e(i+1);
    end
    
    % Calculate membership values for the current triangle
    mf_values(i, :) = max(0, min((x - a) / (e_i - a), (b - x) / (b - e_i)));
end

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

% Plot the results
figure;
plot(x, 2 * cos(2.5 * x) + sin(4 * x) + 1.1 * cos(0.3 * x), 'k-', 'LineWidth', 2.5 , 'DisplayName', 'Original g(x)');
hold on;
plot(x, f_approx, 'r--', 'LineWidth', 2.5, 'DisplayName', 'Approximated f(x)');
title('Function Approximation 1st Order - Triangular');
xlabel('x');
ylabel('f(x)');
legend('show');
grid on;

% Display approximation quality
mse = mean((f_approx - (2 * cos(2.5 * x) + sin(4 * x) + 1.1 * cos(0.3 * x))).^2);
disp(['Mean Squared Error (MSE): ', num2str(mse)]);

% Display Max Error
err = max(abs(f_approx - (2 * cos(2.5 * x) + sin(4 * x) + 1.1 * cos(0.3 * x))));
disp(['Max Error: ', num2str(err)]);

