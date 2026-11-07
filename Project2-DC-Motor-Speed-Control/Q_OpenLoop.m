clc; clear; close all;

% Define parameters
R = 1.0;           % Armature resistance (Ohms)
L = 0.5;           % Armature inductance (H)
Ke0 = 0.05;        % Back EMF constant (Vs/rad)
Kt0 = 0.05;        % Torque constant (Nm/A)
J = 0.01;          % Rotor inertia (kg*m^2)
B = 0.003;         % -Changed Viscous damping (Nm/s)
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
t = 0:dt:10;       % Simulation time vector (0 to 5s)
n = length(t);    % Number of steps

% Preallocate states
i = zeros(n, 1);  % Armature current
w = zeros(n, 1);  % Angular velocity

% Input voltage: +12V for t >= 0 (modify to -12 for reverse)
V = 24 * (t >= 0); 

% Euler integration loop
for k = 1:n-1
    % Calculate dead zone voltage (Fdz)
    if abs(V(k)) <= VDZ
        V_eff = 0;
    else
        V_eff = V(k) - sign(V(k)) * VDZ; % Effective voltage
    end
    
    % Calculate derivatives (no algebraic loops)
    di_dt = (V_eff - R*i(k) - Ke(i(k))*w(k)) / L;
    dw_dt = (Kt(i(k))*i(k) - B*w(k) - fF(w(k)) - TL) / J;
    
    % Update states
    i(k+1) = i(k) + di_dt * dt;
    w(k+1) = w(k) + dw_dt * dt;
end

% Plot results
figure;
subplot(2,1,1);
plot(t, i, 'LineWidth', 1.5);
grid on;
title('Armature Current (i)');
xlabel('Time (s)');
ylabel('Current (A)');

subplot(2,1,2);
plot(t, w, 'LineWidth', 1.5);
grid on;
title('Angular Velocity (\omega)');
xlabel('Time (s)');
ylabel('Speed (rad/s)');