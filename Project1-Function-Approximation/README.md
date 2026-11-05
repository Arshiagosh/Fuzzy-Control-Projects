# Project 1: Approximating a nonlinear function with fuzzy systems

Approximate g(x) = 2cos(2.5x) + sin(4x) + 1.1cos(0.3x) on [0, 25] to ε = 0.02. The required part uses first- and second-order accuracy designs with triangular and Gaussian membership functions. The bonus part uses data-driven designs: lookup table, gradient descent and clustering. Every fuzzy system is written by hand in base MATLAB.

| Script | Design | Rules | Max error |
|---|---|---|---|
| `FirstOrder_Triangular_1.m` | first-order accuracy, triangular | 11117 | 1.8e-5 |
| `FirstOrder_Gaussian_2.m` | first-order accuracy, Gaussian | 11117 | 0.0056 |
| `SecondOrder_Triangular_3.m` | second-order accuracy, triangular | 333 | 0.0199 |
| `SecondOrder_Gaussian_4.m` | second-order accuracy, Gaussian | 334 | 0.189 |
| `LookUpTable_Triangular_5.m` | lookup table from 500 samples | 300 | 0.104 |
| `LookUpTable_Gaussian_6.m` | lookup table, Gaussian | 300 | 0.474 |
| `GradientDescent_7.m` | 50 Gaussian rules trained by gradient descent | 50 | 0.330 |
| `RecursiveLeastSquare_8.m` | RLS on the true basis functions (sanity check, not fuzzy) | - | 1e-6 |
| `Clustering_9.m` | nearest-neighbour clustering | 200 | 0.423 |

- [`report_en.pdf`](report_en.pdf): English summary with the design rules and results (LaTeX source next to it)
- `figures/`: plots and printed output (`*.txt`) from running every script with [`tools/run_all.m`](../tools/run_all.m)

**Changes for this repository:** `GradientDecent_7.m` was renamed to `GradientDescent_7.m`. In scripts 5, 6 and 8 the printed "MSE" was computed as `mean(abs_error.*2)` (twice the mean absolute error); it is now `mean(abs_error.^2)`.
