# Project 2: Fuzzy speed control of a DC motor

Speed control (set-point 50 rad/s) of a DC motor with magnetic saturation, an input dead zone, Coulomb friction, a load torque and a ±24 V limit. Five controllers are compared, from open loop to sliding-mode control with a fuzzy-tuned sliding slope.

| Script | Controller | Overshoot | 2 % settling | Final error |
|---|---|---|---|---|
| `Q_OpenLoop.m` | 24 V, no feedback (settles near 120 rad/s) | - | - | - |
| `Q_PIDClassic.m` | PID, Kp = 10, Ki = 2, Kd = 2 | 16.6 % | 12.6 s | -0.22 rad/s |
| `Q_Linear.m` | single-input fuzzy controller (31 rules) | 2.7 % | not within 10 s | 3.31 rad/s |
| `Q_FuzzyPID.m` | PID with gains tuned online by three 7×7 fuzzy rule tables | 37.9 % | 7.3 s | 0.00 rad/s |
| `Q_SMC_Lambda.m` | sliding-mode control, slope λ adapted by a fuzzy system | 0 % | 3.3 s | 0.12 rad/s |

- [`report_en.pdf`](report_en.pdf): English summary with the motor model, the controllers and the comparison (LaTeX source next to it)
- `figures/`: current, speed and voltage plots for each script, and `metrics.csv` from [`tools/step_metrics.m`](../tools/step_metrics.m)
