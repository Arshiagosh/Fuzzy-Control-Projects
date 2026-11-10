function T = step_metrics()
%STEP_METRICS Speed-step metrics for the Project 2 controllers.
%   Runs each closed-loop script, reads the speed w(t) it leaves in the
%   workspace and reports rise time (10-90 %), overshoot, 2 % settling time,
%   final value and steady-state error against the 50 rad/s set-point.
%   Writes Project2-DC-Motor-Speed-Control/figures/metrics.csv.
root = fileparts(fileparts(mfilename('fullpath')));
folder = fullfile(root, 'Project2-DC-Motor-Speed-Control');
names = {'Q_PIDClassic', 'Q_Linear', 'Q_FuzzyPID', 'Q_SMC_Lambda'};
ref = 50;
reset(groot); set(groot, 'defaultFigureVisible', 'off');
rows = cell(numel(names), 7);
for k = 1:numel(names)
    old = cd(folder);
    evalin('base', sprintf('clear; run(''%s'');', fullfile(folder, [names{k} '.m'])));
    cd(old); close all force;
    t = evalin('base', 't'); w = evalin('base', 'w'); t = t(:); w = w(:);
    i10 = find(w >= 0.1*ref, 1); i90 = find(w >= 0.9*ref, 1);
    tr = t(i90) - t(i10);
    os = max(0, (max(w) - ref) / ref * 100);
    outside = find(abs(w - ref) > 0.02*ref, 1, 'last');
    if isempty(outside), ts = 0; elseif outside == numel(t), ts = NaN; else, ts = t(outside + 1); end
    rows(k, :) = {names{k}, t(end), tr, os, ts, w(end), ref - w(end)};
end
T = cell2table(rows, 'VariableNames', {'script', 'T_end_s', 'rise_10_90_s', ...
    'overshoot_pct', 'settling_2pct_s', 'final_rad_s', 'ss_error_rad_s'});
disp(T);
writetable(T, fullfile(folder, 'figures', 'metrics.csv'));
set(groot, 'defaultFigureVisible', 'on');
end
