clc; clear; close all;

% Define parameters
R = 1.0;           % Armature resistance (Ohms)
L = 0.5;           % Armature inductance (H)
Ke0 = 0.05;        % Back EMF constant (Vs/rad)
Kt0 = 0.05;        % Torque constant (Nm/A)
J = 0.01;          % Rotor inertia (kg*m^2)
B = 0.003;         % Viscous damping (Nm/s)
Is = 5;            % Saturation current (A)
tau_c = 0.2;       % Coulomb friction torque (Nm)
VDZ = 2.0;         % Dead zone voltage threshold (V)
TL = 0.2;          % Load torque (Nm)

% Define nonlinear functions
Ke = @(i) Ke0 * i / sqrt(i^2 + Is^2); % Back EMF saturation
Kt = @(i) Kt0 * i / sqrt(i^2 + Is^2); % Torque saturation
fF = @(w) tau_c * sign(w);            % Coulomb friction

% Fixed-step solver parameters
dt = 0.0001;       % Time step (s)
t = 0:dt:10;       % Simulation time vector (0 to 10s)
n = length(t);     % Number of steps

% Preallocate states
i = zeros(n, 1);   % Armature current
w = zeros(n, 1);   % Angular velocity
V = zeros(n, 1);   % Input voltage (to be logged)

% Setpoint (desired angular velocity)
w_setpoint = 50;  % rad/s

% Define fuzzy membership functions
N = 15;  % Number of fuzzy sets for each input (Negative, Zero, Positive)
y_range = [-50, 50];  % Range for error (e = w_setpoint - w)
u_range = [-240, 240];  % Range for u

% Define centers of fuzzy sets
y_centers = linspace(y_range(1), y_range(2), 2*N + 1);

% Define triangular membership functions
triangular_mf = @(y, c, w) max(0, 1 - abs(y - c) / w);
mf_width = (y_range(2) - y_range(1)) / (2 * N);

mu_A = @(y, l) triangular_mf(y, y_centers(l), mf_width);

% Define fuzzy rules (centers of output fuzzy sets)
u_centers = linspace(u_range(1), u_range(2), 2*N + 1);  % Control signal centers

% Initialize error and change in error
e = 0;
de = 0;

% Euler integration loop
for k = 1:n-1
    % Calculate error and change in error
    e_prev = e;
    e = w_setpoint - w(k);
    de = e - e_prev;
    
    % Evaluate fuzzy controller
    numerator = 0;
    denominator = 0;
    
    for l = 1:(2*N + 1)
        mu = mu_A(e, l);  % Membership value for the l-th fuzzy set
        numerator = numerator + u_centers(l) * mu;
        denominator = denominator + mu;
    end
    
    % Defuzzify to get control signal
    if denominator == 0
        u = 0;  % Avoid division by zero
    else
        u = numerator / denominator;
    end
    
    % Apply voltage limits (saturation)
    u = max(min(u, 24), -24); % Limit voltage to ±24V
    
    % Calculate dead zone voltage (Fdz)
    if abs(u) <= VDZ
        V_eff = 0;
    else
        V_eff = u - sign(u) * VDZ; % Effective voltage
    end
    
    % Log the input voltage
    V(k) = V_eff;
    
    % Calculate derivatives (no algebraic loops)
    di_dt = (V_eff - R*i(k) - Ke(i(k))*w(k)) / L;
    dw_dt = (Kt(i(k))*i(k) - B*w(k) - fF(w(k)) - TL) / J;
    
    % Update states
    i(k+1) = i(k) + di_dt * dt;
    w(k+1) = w(k) + dw_dt * dt;
end

% Log the final input voltage
V(n) = V_eff;

% Plot results
figure;
subplot(3,1,1);
plot(t, i, 'LineWidth', 1.5);
grid on;
title('Armature Current (i)');
xlabel('Time (s)');
ylabel('Current (A)');

subplot(3,1,2);
plot(t, w, 'LineWidth', 1.5);
grid on;
title('Angular Velocity (\omega)');
xlabel('Time (s)');
ylabel('Speed (rad/s)');

subplot(3,1,3);
plot(t, V, 'LineWidth', 1.5);
grid on;
title('Input Voltage (V)');
xlabel('Time (s)');
ylabel('Voltage (V)');