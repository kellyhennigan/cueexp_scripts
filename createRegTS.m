function [reg,regc]=createRegTS(eventOnsets,vals,nTRs,convolve,saveFileName)
% -------------------------------------------------------------------------
% usage: create regressor time series for cue experiment
%
% INPUT:
%   eventOnsets - event onsets (in units of TRs) to include in regressor
%   vals - vector either the same length as eventOnsets indicating the
%          value to give each event or a single integer of value to give
%          all events
%   nTRs - number of TRs to model convolve - 'spm' to convolve reg time
%   series with spm's hrf, 'waver' to use afni's hrf (NOT YET IMPLEMENTED),
%   otherwise 0. Default is 0.
%   saveFileName - filepath for saving out regressor; if not given,
%   then the regressor won't be saved.
%
%
% OUTPUT:
%   reg - regressor time series
%   regc - convolved regressor time series
%
% NOTES:
%
% author: Kelly, kelhennigan@gmail.com, 20-Dec-2015

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if notDefined('convolve')
    convolve = 0;
end

if notDefined('saveFileName')
    saveOut = 0;
    if strcmp(convolve,'waver')
        error('saveFileName must be defined for "waver" convolution');
    end
else
    saveOut = 1;
end


% define (not convolved) regressor time series
reg = zeros(nTRs,1);
reg(eventOnsets)=vals; % set regressor at event onset times to value in vals


% save out if desired
if saveOut
    [outDir,regName,fs]=fileparts(saveFileName);
    dlmwrite(saveFileName,reg);
    fprintf(['reg file ' regName fs ' saved.\n']);
end


% do convolution if desired
regc = [];
if convolve
    
    TR = 2; % repetition time for cue experiment
    
    % spm's hrf
    if strcmp(convolve,'spm')
        hrf = spm_hrf(TR);
        regc = conv(reg,hrf); % convolve
        regc = regc(1:nTRs);  % make sure it has the right # of vols
        regc = regc./max(abs(regc)); % scale it to max=1
        if saveOut
            saveFileName2 = fullfile(outDir,[regName 'c' fs]);
            dlmwrite(saveFileName2,regc);
            fprintf(['reg file ' regName 'c' fs ' saved.\n']);
        end
        
        
        % afni's hrf waver
    elseif strcmp(convolve,'waver')
        
        % get afni bin dir (there's surely a better way to do this)
        homeDir = getHomeDir;
        if strcmp(homeDir,'/home/hennigan')  % CNI VM server
            afniDir = '/usr/lib/afni/bin/';
        else
            afniDir = '~/abin/';
        end
        
        saveFileName2 = fullfile(outDir,[regName 'ca' fs]);
        cmd = [afniDir 'waver -dt ' num2str(TR) ' -GAM -peak 1 -numout ' num2str(nTRs) ...
            ' -input ' saveFileName ' > ' saveFileName2]
        system(cmd)
        fprintf(['reg file ' regName 'ca' fs ' saved.\n']);
        regc = dlmread(saveFileName2);
        
    end
        
      
        
end