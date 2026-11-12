% Define variables
x1 = linspace(0, 100, 100); % Speed of the car (0 to 100)
x2 = linspace(0, 10, 100);  % Acceleration of the car (0 to 10)
y = linspace(0, 5, 100);    % Force on the pedal (0 to 5)

% Define membership functions
mu_slow = @(x1) 1 ./ (1 + exp((x1 - 45) / 5));
mu_small = @(x2) 1 ./ (1 + exp((x2 - 5) / 5));
mu_large = @(y) 1 ./ (1 + exp(2 * (-y + 1.25)));

% Calculate membership degrees for all combinations
mu_slow_vals = mu_slow(x1);
mu_small_vals = mu_small(x2);
mu_large_vals = mu_large(y);

% Grid for 3D plotting
[X1, X2] = meshgrid(x1, x2);

% t norm Infernce (Min)
t_norm_product = @(mu1, mu2) mu1 .* mu2;

% Mamdani Product Inference
mu_mamdani_product = @(mu1, mu2) mu1 .* mu2;

% Mamdani Min Inference
mu_mamdani_min = @(mu1, mu2) min(mu1, mu2);

% Dienes-Rescher Inference
mu_dienes_rescher = @(mu1, mu2) max(1 - mu1, mu2);

% Lukasiewicz Inference
mu_lukasiewicz = @(mu1, mu2) min(1, 1- mu1 + mu2);

% Zadeh Inference
mu_zadeh = @(mu1, mu2) max(min(mu1, mu2), 1 - mu1);

% Visualize the results
figure;
surf(X1, X2, t_norm_product(mu_slow(X1), mu_small(X2)));
xlabel('x_1: Speed of the Car');
ylabel('x_2: Acceleration of the Car');
zlabel('Membership Degree');
title('FP1');
xlim([0 100]);
ylim([0 10]);
zlim([0 1]);

mu_FP1 = linspace(0, 1, 100);
% Force to pedal vs inference output in 3D for each method
[Y1, Y] = meshgrid(mu_FP1, y);
figure;
subplot(2,3,1);
surf(Y1, Y, mu_mamdani_product(mu_FP1, mu_large(Y)));
xlabel('FP1');
ylabel('y: Force to the Pedal');
zlabel('Membership Degree');
title('Mamdani Product - Force');
xlim([0 1]);
ylim([0 5]);
zlim([0 1]);

subplot(2,3,2);
surf(Y1, Y, mu_mamdani_min(mu_FP1, mu_large(Y)));
xlabel('FP1');
ylabel('y: Force to the Pedal');
zlabel('Membership Degree');
title('Mamdani Min - Force');
xlim([0 1]);
ylim([0 5]);
zlim([0 1]);

subplot(2,3,3);
surf(Y1, Y, mu_dienes_rescher(mu_FP1, mu_large(Y)));
xlabel('FP1');
ylabel('y: Force to the Pedal');
zlabel('Membership Degree');
title('Dienes-Rescher - Force');
xlim([0 1]);
ylim([0 5]);
zlim([0 1]);

subplot(2,3,4);
surf(Y1, Y, mu_lukasiewicz(mu_FP1, mu_large(Y)));
xlabel('FP1');
ylabel('y: Force to the Pedal');
zlabel('Membership Degree');
title('Lukasiewicz - Force');
xlim([0 1]);
ylim([0 5]);
zlim([0 1]);

subplot(2,3,5);
surf(Y1, Y, mu_zadeh(mu_FP1, mu_large(Y)));
xlabel('FP1');
ylabel('y: Force to the Pedal');
zlabel('Membership Degree');
title('Zadeh - Force');
xlim([0 1]);
ylim([0 5]);
zlim([0 1]);
