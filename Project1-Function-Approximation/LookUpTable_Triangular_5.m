% Implementation of Fuzzy System 
% Triangular Membership Functions
% Lookup Table

% Clear workspace
clear; close all; clc;

% Define target function
full_x = 0:0.05:25;
full_y = 2*cos(2.5*full_x) + sin(4*full_x) + 1.1*cos(0.3*full_x);

% Create sparse dataset
sparse_points = 500;
sparse_indices = unique(round(linspace(1, length(full_x), sparse_points)));
x = full_x(sparse_indices);
y = full_y(sparse_indices);

% Fuzzy membership function parameters
num_mf = 300;  % Number of membership functions
x_min = min(x);
x_max = max(x);
y_min = min(y);
y_max = max(y);

% Define membership function centers for input and output
x_centers = linspace(x_min, x_max, num_mf);
y_centers = linspace(y_min, y_max, num_mf);
support_width = (x_max - x_min) / (num_mf - 1);

% Step 2 and 3: Create fuzzy rules and assign degrees
rules = zeros(length(x), 3); % [input center, output center, degree]
for i = 1:length(x)
    % Find nearest center for input
    [~, input_mf_idx] = min(abs(x_centers - x(i)));
    
    % Find nearest center for output
    [~, output_mf_idx] = min(abs(y_centers - y(i)));
    
    % Calculate rule degree
    input_membership = triangular_mf(x(i), x_centers(input_mf_idx), support_width);
    output_membership = triangular_mf(y(i), y_centers(output_mf_idx), support_width);
    rule_weight = min(input_membership, output_membership);
    
    rules(i,:) = [input_mf_idx, output_mf_idx, rule_weight];
end

% Step 4: Form rule base
unique_rules = unique(rules(:,1:2), 'rows');
final_rules = zeros(size(unique_rules,1), 3);
for i = 1:size(unique_rules,1)
    rule_indices = all(rules(:,1:2) == unique_rules(i,:), 2);
    [max_weight, ~] = max(rules(rule_indices, 3));
    final_rules(i,:) = [unique_rules(i,:), max_weight];
end

% Step 5: Calculate fuzzy system output
lookup_output = zeros(size(full_x));
for i = 1:length(full_x)
    numerator = 0;
    denominator = 0;
    
    % Calculate output using all rules
    for j = 1:size(final_rules,1)
        input_mf_idx = final_rules(j,1);
        output_mf_idx = final_rules(j,2);
        rule_weight = final_rules(j,3);
        
        % Current input membership degree
        current_membership = triangular_mf(full_x(i), x_centers(input_mf_idx), support_width);
        
        % Calculate weighted output
        firing_strength = min(current_membership, rule_weight);
        numerator = numerator + firing_strength * y_centers(output_mf_idx);
        denominator = denominator + firing_strength;
    end
    
    % Calculate final output
    if denominator > 0
        lookup_output(i) = numerator / denominator;
    else
        % If no rules are activated
        [~, nearest_idx] = min(abs(x - full_x(i)));
        lookup_output(i) = y(nearest_idx);
    end
end

% Calculate errors
lookup_error = lookup_output - full_y;
abs_lookup_error = abs(lookup_error);
min_error = min(abs_lookup_error);
max_error = max(abs_lookup_error);
mse_error = mean(abs_lookup_error.^2);

% Display results
figure;
plot(full_x, full_y, 'k-', 'LineWidth', 2.5);
hold on;
plot(x, y, 'ro', 'MarkerFaceColor', 'r');
title('Original Function and Sparse Points');
xlabel('x');
ylabel('f(x)');
legend('Full Function', 'Sparse Points');

figure;
plot(full_x, full_y, 'k-', full_x, lookup_output, 'r--', 'LineWidth', 2.5);
title('Fuzzy System Approximation - Lookup Table - Triangular');
xlabel('x');
ylabel('f(x)');
legend('Original', 'Approximation');

% Display error metrics
disp('Fuzzy System Error Metrics:');
fprintf('Minimum Error: %f\n', min_error);
fprintf('Maximum Error: %f\n', max_error);
fprintf('MSE Error: %f\n', mse_error);
fprintf('Maximum Absolute Error: %f\n', max(abs(lookup_output - full_y)));

% Triangular membership function
function mu = triangular_mf(x, center, width)
    if abs(x - center) >= width
        mu = 0;
    else
        mu = 1 - abs(x - center) / width;
    end
end