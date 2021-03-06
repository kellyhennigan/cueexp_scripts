function p = getCuePaths(subject)
% -------------------------------------------------------------------------
% usage: get a structural array containing all relevant paths for this
% experiment. Also moves the experiment's "scripts" directory to the top of
% the search path. If a subject id string is given, subject-specific
% directories will also be returned.

%
% INPUT:
%   subject (optional) - subject id string

%
% OUTPUT:
%   p - structural array containing relevant paths
%
%
% author: Kelly, kelhennigan@gmail.com, 09-Nov-2014
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get base directory address
baseDir = getCueBaseDir;


% define structural array p for output
p = struct();

p.baseDir = baseDir;
p.data = fullfile(p.baseDir, 'data');
p.figures = fullfile(p.baseDir, 'figures');
p.figures_dti = fullfile(p.baseDir, 'figures_dti');
p.scripts = fullfile(p.baseDir, 'scripts');

% place scripts directory at the top of the search path
path([p.scripts '/paper_fig_scripts'],path);
path([p.scripts '/dmri'],path);
path([p.scripts '/dmri/paper_figs'],path);
path(p.scripts,path);



% subject directories
if ~notDefined('subject')
    p.subj = fullfile(p.data, subject);  % subject directory
    p.behavior    = fullfile(p.subj, 'behavior');
    %     p.design_mats = fullfile(p.subj, 'design_mats');
    %     p.dti_proc   = fullfile(p.subj, 'dti80trilin');
    p.func_proc_cue   = fullfile(p.subj, 'func_proc_cue');
    p.raw         = fullfile(p.subj, 'raw');
    p.regs        = fullfile(p.subj, 'regs');
    %     p.ROIs        = fullfile(p.subj, 'ROIs');
    %     p.results        = fullfile(p.subj, 'results');
    p.t1          = fullfile(p.subj, 't1');
end



end % function


