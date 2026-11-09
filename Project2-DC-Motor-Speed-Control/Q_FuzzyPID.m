clc; clear; close all;

% Define parameters
R = 1.0;    L = 0.5;    Ke0 = 0.05;  Kt0 = 0.05;
J = 0.01;   B = 0.003; Is = 5;     tau_c = 0.2;
VDZ = 2.0;  TL = 0.2;

% Define nonlinear functions
Ke = @(i) Ke0 * i / sqrt(i^2 + Is^2);
Kt = @(i) Kt0 * i / sqrt(i^2 + Is^2);
fF = @(w) tau_c * sign(w);

% Simulation parameters
dt = 0.0001; t = 0:dt:20; n = length(t);
i = zeros(n,1); w = zeros(n,1); V = zeros(n,1);
w_setpoint = 50;

% PID gains with ranges
Kp_min = 1; Kp_max = 10; Ki_min = 0; Ki_max = 5; Kd_min = 0; Kd_max = 5;
Kp = Kp_min; Ki = Ki_min; Kd = Kd_min;

% Initialize PID terms
integral = 0; prev_error = 0;

% Fuzzy supervisor parameters
e_range = [-50, 50]; de_range = [-100, 100];

% Membership function definition
triangular_mf = @(x, a, b, c) max(0, min((x - a)/(b - a), (c - x)/(c - b)));

e_terms = {'NB', 'NM', 'NS', 'ZO', 'PS', 'PM', 'PB'};
de_terms = {'NB', 'NM', 'NS', 'ZO', 'PS', 'PM', 'PB'};
output_terms = {'VS', 'S', 'M', 'L', 'VL'};

% Define rule tables for Kp, Ki, Kd
rules_Kp = { 
    'NB', 'NB', 'VS'; 'NB', 'NM', 'VS'; 'NB', 'NS', 'VS'; 'NB', 'ZO', 'L'; 'NB', 'PS', 'M'; 'NB', 'PM', 'S'; 'NB', 'PB', 'VL';
    'NM', 'NB', 'VS'; 'NM', 'NM', 'VS'; 'NM', 'NS', 'L';  'NM', 'ZO', 'L'; 'NM', 'PS', 'M'; 'NM', 'PM', 'S'; 'NM', 'PB', 'VL';
    'NS', 'NB', 'VS'; 'NS', 'NM', 'L';  'NS', 'NS', 'L';  'NS', 'ZO', 'M'; 'NS', 'PS', 'M'; 'NS', 'PM', 'S'; 'NS', 'PB', 'VL';
    'ZO', 'NB', 'L';  'ZO', 'NM', 'L';  'ZO', 'NS', 'M';  'ZO', 'ZO', 'M'; 'ZO', 'PS', 'M'; 'ZO', 'PM', 'L'; 'ZO', 'PB', 'L';
    'PS', 'NB', 'VL'; 'PS', 'NM', 'S';  'PS', 'NS', 'M';  'PS', 'ZO', 'M'; 'PS', 'PS', 'L'; 'PS', 'PM', 'L'; 'PS', 'PB', 'VS';
    'PM', 'NB', 'VL'; 'PM', 'NM', 'S';  'PM', 'NS', 'M';  'PM', 'ZO', 'L'; 'PM', 'PS', 'L'; 'PM', 'PM', 'VS'; 'PM', 'PB', 'VS';
    'PB', 'NB', 'VL'; 'PB', 'NM', 'S';  'PB', 'NS', 'M';  'PB', 'ZO', 'L'; 'PB', 'PS', 'VS'; 'PB', 'PM', 'VS'; 'PB', 'PB', 'VS';
};

rules_Ki = { 
    'NB', 'NB', 'VL'; 'NB', 'NM', 'VL'; 'NB', 'NS', 'VL'; 'NB', 'ZO', 'L';  'NB', 'PS', 'M';  'NB', 'PM', 'S';  'NB', 'PB', 'VS';
    'NM', 'NB', 'VL'; 'NM', 'NM', 'VL'; 'NM', 'NS', 'L';  'NM', 'ZO', 'L';  'NM', 'PS', 'M';  'NM', 'PM', 'S';  'NM', 'PB', 'VS';
    'NS', 'NB', 'VL'; 'NS', 'NM', 'L';  'NS', 'NS', 'L';  'NS', 'ZO', 'M';  'NS', 'PS', 'M';  'NS', 'PM', 'S';  'NS', 'PB', 'VS';
    'ZO', 'NB', 'L';  'ZO', 'NM', 'L';  'ZO', 'NS', 'M';  'ZO', 'ZO', 'VS'; 'ZO', 'PS', 'M';  'ZO', 'PM', 'L';  'ZO', 'PB', 'L';
    'PS', 'NB', 'VS'; 'PS', 'NM', 'S';  'PS', 'NS', 'M';  'PS', 'ZO', 'M';  'PS', 'PS', 'L';  'PS', 'PM', 'L';  'PS', 'PB', 'VL';
    'PM', 'NB', 'VS'; 'PM', 'NM', 'S';  'PM', 'NS', 'M';  'PM', 'ZO', 'L';  'PM', 'PS', 'L';  'PM', 'PM', 'VL'; 'PM', 'PB', 'VL';
    'PB', 'NB', 'VS'; 'PB', 'NM', 'S';  'PB', 'NS', 'M';  'PB', 'ZO', 'L';  'PB', 'PS', 'VL'; 'PB', 'PM', 'VL'; 'PB', 'PB', 'VL';
};

rules_Kd = { 
    'NB', 'NB', 'M';  'NB', 'NM', 'S';  'NB', 'NS', 'VS'; 'NB', 'ZO', 'VL'; 'NB', 'PS', 'VS'; 'NB', 'PM', 'S';  'NB', 'PB', 'M';
    'NM', 'NB', 'S';  'NM', 'NM', 'VS'; 'NM', 'NS', 'L';  'NM', 'ZO', 'VL'; 'NM', 'PS', 'L';  'NM', 'PM', 'VS'; 'NM', 'PB', 'S';
    'NS', 'NB', 'VS'; 'NS', 'NM', 'L';  'NS', 'NS', 'VL'; 'NS', 'ZO', 'L';  'NS', 'PS', 'VL'; 'NS', 'PM', 'L';  'NS', 'PB', 'VS';
    'ZO', 'NB', 'VL'; 'ZO', 'NM', 'VL'; 'ZO', 'NS', 'L';  'ZO', 'ZO', 'VS'; 'ZO', 'PS', 'L';  'ZO', 'PM', 'VL'; 'ZO', 'PB', 'VL';
    'PS', 'NB', 'VS'; 'PS', 'NM', 'L';  'PS', 'NS', 'VL'; 'PS', 'ZO', 'L';  'PS', 'PS', 'VL'; 'PS', 'PM', 'L';  'PS', 'PB', 'VS';
    'PM', 'NB', 'S';  'PM', 'NM', 'VS'; 'PM', 'NS', 'L';  'PM', 'ZO', 'VL'; 'PM', 'PS', 'L';  'PM', 'PM', 'VS'; 'PM', 'PB', 'S';
    'PB', 'NB', 'M';  'PB', 'NM', 'S';  'PB', 'NS', 'VS'; 'PB', 'ZO', 'VL'; 'PB', 'PS', 'VS'; 'PB', 'PM', 'S';  'PB', 'PB', 'M';
};

% Euler integration loop
for k = 1:n-1
    error = w_setpoint - w(k);
    derivative = (error - prev_error) / dt;
    integral = integral + error * dt;
    
    e_norm = max(min(error, e_range(2)), e_range(1));
    de_norm = max(min(derivative, de_range(2)), de_range(1));
    
    mu_e = zeros(1, length(e_terms));
    mu_de = zeros(1, length(de_terms));
    
    for i1 = 1:length(e_terms)
        mu_e(i1) = triangular_mf(e_norm, e_range(1) + (i1-1)*10, e_range(1) + i1*10, e_range(1) + (i1+1)*10);
    end
    for i2 = 1:length(de_terms)
        mu_de(i2) = triangular_mf(de_norm, de_range(1) + (i2-1)*20, de_range(1) + i2*20, de_range(1) + (i2+1)*20);
    end
    
    % Adjust PID gains
    Kp = Kp_min + (Kp_max - Kp_min) * eval_fuzzy(rules_Kp ,e_terms, de_terms, mu_e, mu_de);
    Ki = Ki_min + (Ki_max - Ki_min) * eval_fuzzy(rules_Ki,e_terms, de_terms, mu_e, mu_de);
    Kd = Kd_min + (Kd_max - Kd_min) * eval_fuzzy(rules_Kd,e_terms, de_terms, mu_e, mu_de);
    
    % PID control signal
    u_pid = Kp * error + Ki * integral + Kd * derivative;
    u_pid = max(min(u_pid, 24), -24);
    
    if abs(u_pid) <= VDZ
        V_eff = 0;
    else
        V_eff = u_pid - sign(u_pid) * VDZ;
    end
    
    V(k) = V_eff;
    di_dt = (V_eff - R*i(k) - Ke(i(k))*w(k)) / L;
    dw_dt = (Kt(i(k))*i(k) - B*w(k) - fF(w(k)) - TL) / J;
    
    i(k+1) = i(k) + di_dt * dt;
    w(k+1) = w(k) + dw_dt * dt;
    prev_error = error;
end

V(n) = V_eff;
figure;
subplot(3,1,1); plot(t, i, 'LineWidth', 1.5); grid on; title('Armature Current');
subplot(3,1,2); plot(t, w, 'LineWidth', 1.5); grid on; title('Angular Velocity');
subplot(3,1,3); plot(t, V, 'LineWidth', 1.5); grid on; title('Input Voltage');

% Function to evaluate fuzzy rules
    function K_adj = eval_fuzzy(rules, e_terms, de_terms, mu_e, mu_de)
        numerator = 0; denominator = 0;
        for r = 1:size(rules, 1)
            e_idx = find(strcmp(e_terms, rules{r,1}));
            de_idx = find(strcmp(de_terms, rules{r,2}));
            output_term = rules{r,3};
            strength = min(mu_e(e_idx), mu_de(de_idx));
            switch output_term
                case 'VL', output_val = 0.1;
                case 'L',  output_val = 0.3;
                case 'M',  output_val = 0.5;
                case 'S',  output_val = 0.7;
                case 'VS', output_val = 0.9;
            end
            numerator = numerator + strength * output_val;
            denominator = denominator + strength;
        end
        if denominator > 0
            K_adj = numerator / denominator;
        else
            K_adj = 0.5;
        end
    end