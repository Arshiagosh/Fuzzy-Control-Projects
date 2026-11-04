% Implementation of Fuzzy System
% Gradient Descent Training with Initial System Output and Error/Epoch Plot

% Clear workspace
clear; close all; clc;

% Define target function
full_x = 0:0.05:25;
full_y = 2*cos(2.5*full_x) + sin(4*full_x) + 1.1*cos(0.3*full_x);

% Create sparse dataset (training data)
sparse_points = 200;
sparse_indices = unique(round(linspace(1, length(full_x), sparse_points)));
x_train = full_x(sparse_indices);
y_train = full_y(sparse_indices);

% Step 1: Initialize parameters
M = 50;  % Number of rules
max_epochs = 10000; % Number of training epochs
epsilon = 0.001;  % Error threshold
learning_rate = 0.0001; % Learning rate

x_min = min(x_train);
x_max = max(x_train);

% Initialize centers and widths
centers = linspace(x_min, x_max, M);
center_spacing = (x_max - x_min) / (M - 1);
widths = ones(1, M) * (center_spacing / 2);

% Initialize output weights
output_weights = zeros(M, 1);
for i = 1:M
    [~, idx] = min(abs(x_train - centers(i)));
    output_weights(i) = y_train(idx);
end

% Compute initial output of the system
initial_output = zeros(size(full_x));
for i = 1:length(full_x)
    z = exp(-((full_x(i) - centers).^2) ./ widths.^2)';
    b = sum(z);
    a = sum(output_weights .* z);
    initial_output(i) = a / b;
end

% Plot initial system output
figure;
plot(full_x, full_y, 'k-', full_x, initial_output, 'r--', 'LineWidth', 2);
title('Initial Fuzzy System Output - Gradient Descent');
xlabel('x');
ylabel('f(x)');
legend('Original', 'Initial Approximation');
grid on;

% Prepare for training
error_per_epoch = zeros(max_epochs, 1);

% Training loop
for epoch = 1:max_epochs
    total_error = 0;
    
    for p = 1:length(x_train)
        % Calculate output and error
        z = exp(-((x_train(p) - centers).^2) ./ widths.^2)';
        b = sum(z);
        a = sum(output_weights .* z);
        f = a / b;
        error = y_train(p) - f;
        total_error = total_error + error^2;
        
        % Update centers
        for i = 1:M
            d_center = 2 * error * z(i) / b * ...
                      (output_weights(i) - f) * ...
                      2 * (x_train(p) - centers(i)) / widths(i)^2;
            centers(i) = centers(i) + learning_rate * d_center;
        end
        
        % Update widths
        for i = 1:M
            d_width = 2 * error * z(i) / b * ...
                     (output_weights(i) - f) * ...
                     2 * (x_train(p) - centers(i))^2 / widths(i)^3;
            widths(i) = max(widths(i) + learning_rate * d_width, center_spacing / 10);
        end
        
        % Update output weights
        for i = 1:M
            d_weight = 2 * error * z(i) / b;
            output_weights(i) = output_weights(i) + learning_rate * d_weight;
        end
    end
    
    % Calculate average error
    avg_error = total_error / length(x_train);
    error_per_epoch(epoch) = avg_error;

    % Check convergence
    if avg_error < epsilon
        fprintf('Converged at epoch %d\n', epoch);
        break;
    end
end

% Plot Error per Epoch
figure;
plot(1:epoch, error_per_epoch(1:epoch), 'b-', 'LineWidth', 2);
xlabel('Epoch');
ylabel('Average Error');
title('Error per Epoch - Gradient Descent');
grid on;

% Final Evaluation
output = zeros(size(full_x));
for i = 1:length(full_x)
    z = exp(-((full_x(i) - centers).^2) ./ widths.^2)';
    b = sum(z);
    a = sum(output_weights .* z);
    output(i) = a / b;
end

% Plot final results
figure;
plot(full_x, full_y, 'k-', full_x, output, 'r--', 'LineWidth', 2);
title('Final Fuzzy System Output - Gradient Descent');
xlabel('x');
ylabel('f(x)');
legend('Original', 'Final Approximation');
grid on;

% Display error metrics
l_error = output - full_y;
fprintf('Maximum Error: %f\n', max(abs(l_error)));
fprintf('MSE Error: %f\n', mean(l_error.^2));
