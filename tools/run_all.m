function run_all()
%RUN_ALL Run every script in the repository and save its figures.
%   Each script runs in its own folder with invisible figures; every figure it
%   opens is saved as figures/<script>_<n>.png and the printed output goes to
%   figures/<script>.txt. Base MATLAB only (no toolboxes).
root = fileparts(fileparts(mfilename('fullpath')));
folders = {'Project1-Function-Approximation', 'Project2-DC-Motor-Speed-Control', ...
           'Class-Exercise-Mamdani-Car-Pedal'};
reset(groot);
set(groot, 'defaultFigureVisible', 'off');
set(groot, 'defaultTextInterpreter', 'tex');
set(groot, 'defaultAxesTickLabelInterpreter', 'tex');
set(groot, 'defaultLegendInterpreter', 'tex');
for f = 1:numel(folders)
    folder = fullfile(root, folders{f});
    figdir = fullfile(folder, 'figures');
    if ~exist(figdir, 'dir'), mkdir(figdir); end
    scripts = dir(fullfile(folder, '*.m'));
    for s = 1:numel(scripts)
        [~, name] = fileparts(scripts(s).name);
        fprintf('== %s/%s\n', folders{f}, name);
        run_one(folder, name, figdir);
    end
end
set(groot, 'defaultFigureVisible', 'on');
end

function run_one(folder, name, figdir)
old = cd(folder);
cleanup = onCleanup(@() cd(old));
close all force;
logfile = fullfile(figdir, [name '.txt']);
if exist(logfile, 'file'), delete(logfile); end
diary(logfile);
t = tic;
try
    evalin('base', sprintf('clear; run(''%s'');', fullfile(folder, [name '.m'])));
catch err
    fprintf(2, 'ERROR in %s: %s\n', name, err.message);
end
fprintf('[elapsed %.1f s]\n', toc(t));
diary off;
set(groot, 'defaultFigureVisible', 'off');
figs = flip(findall(groot, 'Type', 'figure'));
[~, order] = sort(arrayfun(@(h) h.Number, figs));
figs = figs(order);
for k = 1:numel(figs)
    set(figs(k), 'PaperPositionMode', 'auto');
    print(figs(k), fullfile(figdir, sprintf('%s_%d.png', name, k)), '-dpng', '-r130');
end
close all force;
end
