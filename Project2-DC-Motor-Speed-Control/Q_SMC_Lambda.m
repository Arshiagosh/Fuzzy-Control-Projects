clc; clear; close all;

% Define motor parameters
R = 1.0;    L = 0.5;    Ke0 = 0.05;  Kt0 = 0.05;
J = 0.01;   B = 0.003; Is = 5;     tau_c = 0.2;
VDZ = 2.0;  TL = 0.3;

% Nonlinear functions
Ke = @(i) Ke0 * i / sqrt(i^2 + Is^2);
Kt = @(i) Kt0 * i / sqrt(i^2 + Is^2);
fF = @(w) tau_c * sign(w);

% Simulation parameters
dt = 0.0001; t = 0:dt:20; n = length(t);
i = zeros(n,1); w = zeros(n,1); V = zeros(n,1);
lambda_history = zeros(n,1);  % Initialize Lambda history
w_setpoint = 50;

% SMC parameters
lambda_min = 0.1;   lambda_max = 10;  % Lambda adjustment range
phi = 0.5;          % Boundary layer thickness
K_smc = 20;         % Control gain

% Fuzzy parameters
e_range = [-50, 50];        de_range = [-100, 100];
e_terms = {'NB', 'NM', 'NS', 'ZO', 'PS', 'PM', 'PB'};
de_terms = {'NB', 'NM', 'NS', 'ZO', 'PS', 'PM', 'PB'};

% Lambda adjustment rules (e, de, output)
rules_lambda = { 
    'NB', 'NB', 'VL'; 
    'NB', 'NM', 'L'; 
    'NS', 'NS', 'M'; 
    'ZO', 'ZO', 'S'; 
    'PS', 'PS', 'M'; 
    'PM', 'PM', 'L'; 
    'PB', 'PB', 'VL' 
};

% Membership function
triangular_mf = @(x, a, b, c) max(0, min((x - a)/(b - a), (c - x)/(c - b)));

% Initialize variables
prev_error = 0;

% Simulation loop
for k = 1:n-1
    error = w_setpoint - w(k);
    derivative = (error - prev_error) / dt;
    
    % Normalize inputs
    e_norm = max(min(error, e_range(2)), e_range(1));
    de_norm = max(min(derivative, de_range(2)), de_range(1));
    
    % Fuzzify error and derivative
    mu_e = zeros(1,7); mu_de = zeros(1,7);
    for i1 = 1:7
        mu_e(i1) = triangular_mf(e_norm, -50 + (i1-1)*14.28, -50 + i1*14.28, -50 + (i1+1)*14.28);
        mu_de(i1) = triangular_mf(de_norm, -100 + (i1-1)*28.57, -100 + i1*28.57, -100 + (i1+1)*28.57);
    end
    
    % Evaluate fuzzy rules for Lambda
    lambda_adj = eval_fuzzy(rules_lambda, e_terms, de_terms, mu_e, mu_de);
    lambda = lambda_min + (lambda_max - lambda_min) * lambda_adj;
    lambda_history(k) = lambda;  % Store Lambda
    
    % Compute sliding surface
    s = lambda * error + derivative;
    
    % SMC control law with saturation
    V_eff = K_smc * sat(s / phi);
    
    % Apply voltage constraints and deadzone
    if abs(V_eff) <= VDZ
        V_eff = 0;
    else
        V_eff = V_eff - sign(V_eff) * VDZ;
    end
    V_eff = max(min(V_eff, 24), -24);
    
    V(k) = V_eff;
    
    % Motor dynamics
    di_dt = (V_eff - R*i(k) - Ke(i(k))*w(k)) / L;
    dw_dt = (Kt(i(k))*i(k) - B*w(k) - fF(w(k)) - TL) / J;
    
    % Update states
    i(k+1) = i(k) + di_dt * dt;
    w(k+1) = w(k) + dw_dt * dt;
    prev_error = error;
end

% Assign last values
V(n) = V_eff;
lambda_history(n) = lambda;  % Final Lambda value

% Plot results
figure;
subplot(3,1,1); 
plot(t, i, 'LineWidth', 1.5); grid on; title('Armature Current');

subplot(3,1,2); 
plot(t, w, 'LineWidth', 1.5); grid on; title('Angular Velocity');
yline(w_setpoint, '--r', 'Setpoint');

subplot(3,1,3); 
plot(t, V, 'LineWidth', 1.5); grid on; title('Input Voltage');

figure;
plot(t, lambda_history, 'LineWidth', 1.5); grid on; 
title('Adaptive Lambda Adjustment');
xlabel('Time (sec)'); ylabel('\lambda');

% Saturation function
function y = sat(x)
    if x > 1
        y = 1;
    elseif x < -1
        y = -1;
    else
        y = x;
    end
end

% Fuzzy evaluation function for Lambda
function lambda_adj = eval_fuzzy(rules, e_terms, de_terms, mu_e, mu_de)
    numerator = 0; denominator = 0;
    for r = 1:size(rules, 1)
        e_idx = find(strcmp(e_terms, rules{r,1}));
        de_idx = find(strcmp(de_terms, rules{r,2}));
        output_term = rules{r,3};
        strength = min(mu_e(e_idx), mu_de(de_idx));
        switch output_term
            case 'VL', val = 1.0;
            case 'L',  val = 0.75;
            case 'M',  val = 0.5;
            case 'S',  val = 0.25;
            case 'VS', val = 0.1;
        end
        numerator = numerator + strength * val;
        denominator = denominator + strength;
    end
    if denominator > 0
        lambda_adj = numerator / denominator;
    else
        lambda_adj = 0.5;
    end
end