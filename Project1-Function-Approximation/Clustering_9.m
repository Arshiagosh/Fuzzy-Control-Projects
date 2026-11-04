% Implementation of Fuzzy System 
% Clustering-based Approximation
% Clear workspace
clear; close all; clc;

% Define target function
full_x = 0:0.05:25;
full_y = 2*cos(2.5*full_x) + sin(4*full_x) + 1.1*cos(0.3*full_x);

% Create sparse dataset (training data)
sparse_points = 500;
sparse_indices = unique(round(linspace(1, length(full_x), sparse_points)));
x_train = full_x(sparse_indices);
y_train = full_y(sparse_indices);

% Step 1: Apply k-means clustering
M = 200; % Number of clusters
centroids = linspace(min(x_train), max(x_train), M)'; % Initialize centroids
cluster_counts = zeros(M, 1); % Points per cluster
sigma = zeros(M, 1); % Spread of each cluster
y_bar = zeros(M, 1); % Mean output per cluster

% Assign points to nearest centroids
for i = 1:length(x_train)
    [~, nearest] = min(abs(centroids - x_train(i)));
    cluster_counts(nearest) = cluster_counts(nearest) + 1;
    y_bar(nearest) = y_bar(nearest) + y_train(i);
    sigma(nearest) = sigma(nearest) + (x_train(i) - centroids(nearest))^2;
end

% Finalize cluster parameters
for j = 1:M
    if cluster_counts(j) > 0
        y_bar(j) = y_bar(j) / cluster_counts(j);
        sigma(j) = sqrt(sigma(j) / cluster_counts(j));
    else
        sigma(j) = 1; % Avoid zero spread
    end
end

% Step 2: Function approximation using Gaussian membership functions
full_y_pred = zeros(size(full_x));
for i = 1:length(full_x)
    memberships = exp(-(full_x(i) - centroids).^2 ./ (2 * sigma.^2));
    memberships = memberships / sum(memberships); % Normalize
    full_y_pred(i) = sum(y_bar .* memberships);
end

% Step 3: Calculate errors
errors = full_y - full_y_pred;
min_error = min(abs(errors));
max_error = max(abs(errors));
mean_error = mean(abs(errors));
MSE = mean(errors.^2);

% Display error metrics
disp('Error Metrics:');
fprintf('Minimum Error: %.4f\n', min_error);
fprintf('Maximum Error: %.4f\n', max_error);
fprintf('Mean Error: %.4f\n', mean_error);
fprintf('MSE (MSE): %.4f\n', MSE);

% Step 4: Plot results
figure;
plot(full_x, full_y, 'k-', 'LineWidth', 2.5); % Original function
hold on;
plot(full_x, full_y_pred, 'r--', 'LineWidth', 2.5); % Approximation
legend('Original Function', 'Clustering-based Approximation');
title('Function Approximation');
xlabel('x');
ylabel('f(x)');
grid on;
