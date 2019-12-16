function [reg,regc]=createRegTS_new(onsets,vals,dur,TR,nTRs,dt,convolve)
% -------------------------------------------------------------------------
% usage: create regressor time series for cue experiment. 
%
% INPUT:
%   onsets - event onsets (in units of SECONDS) to include in regressor
%   vals - vector either the same length as eventOnsets indicating the
%          value to give each event or a single integer of value to give
%          all events
%   dur - duration of events in units of SECONDS or can give 'stick' to make
%          the event durations a stick function. Note at the current time
%          this must be the same duration for all events. 
%   TR - repetition rate (in units of SECONDS)
%   nTRs- total number of volumes acquired
%   dt - sample rate (in units of SECONDS) of the regressor time series
%   convolve - 'spm' to convolve reg time series with spm's hrf, 'waver' to
%       use afni's hrf, otherwise 0 to not do  convolution. Default is 0.
%
%
% OUTPUT:
%   reg - regressor time series (UPSAMPLED)
%   regc - convolved regressor time series
%
% NOTES:

% TO DO: implement having multiple durations
%
% author: Kelly, kelhennigan@gmail.com, 20-Dec-2015

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

% if vals isnt defined, default is 1
if notDefined('vals')
    vals=1;
end

% if dur isnt defined, default is stick function (instantaneous event)
if notDefined('dur')
    dur = 'stick';
end

% dur must be either the string "stick", 1 value, or a vector of values
% that matches the number of onsets
if ~any(strcmp(dur,'stick') || numel(dur)==1 || numel(dur)==numel(onsets))
    error('duration variable dur must be set to either the string stick, be a dingle value interger, or be a vector with the same number of elements as onsets');
end

% if dt isnt defined, default is .1 (tenth of a second)
if notDefined('dt')
    dt = .1;
end

% if TR isnt defined, set it to equal dt
if notDefined('TR')
    TR=dt;
end

% % if nt isn't provided, throw an error
if notDefined('nTRs')
    error('nTRs must be defined')
end

if notDefined('convolve')
    convolve = 0;
end


%% define regressor time series (not convolved)

nt=ceil(TR*nTRs/dt);  % number of time steps for upsampled regressor time series

% define regressor vector
reg = zeros(nt,1); % start with 


% get event onsets in dt units (upsampled units)
onsetsDT = round(onsets/dt)+1; % +1 because reg(1) is t=0


% denote event times in regressor time series with "1"s 
if strcmp(dur,'stick')
    reg(onsetsDT)=vals; % set regressor at event onset times to value in vals
    
else
    
    durDT = round(dur/dt);   % event durations in dt units
   
    % if durDT is a single value, assume all the events are that duration
    if numel(durDT)==1 
        reg(repmat(onsetsDT,1,durDT)+repmat(0:durDT-1,numel(onsetsDT),1))=1;
    
    % if durDT is a vector, assume the values correspond to varying
    % durations of events whose onset time is defined by onsetsDT
    else
        for i=1:numel(onsetsDT)
            reg(onsetsDT(i):durDT(i)-1)=1;
        end
    end
    
end


%% do convolution if desired

regc = [];

% spm's hrf
if strcmp(convolve,'spm')
   
    params = [6 16 1 1 6 0 32];         % set parameters for hrf; defaults are: P = [6 16 1 1 6 0 32];
    hrf = spm_hrf(dt,params);
    regc = conv(reg,hrf); % convolve
    regc = regc(1:nt);
    
% afni's hrf waver
elseif strcmp(convolve,'waver')
    
    regfile = tempname;
    dlmwrite(regfile,reg); % save out reg ts to give as input to waver cmd
    regfilec = tempname;
    
    cmd = ['waver -dt ' num2str(dt) ' -GAM -peak 1 -numout ' num2str(nt) ...
        ' -input ' regfile ' > ' regfilec];
    system(cmd)
    
    regc = dlmread(regfilec);
    
end

fprintf('reg convolved.\n');


%% now downsample reg and convolved reg to be at TR temporal res

reg = reg(1:TR/dt:end); % get at TR time resolution
regc=regc(1:TR/dt:end); % get at TR time resolution
regc = regc./max(abs(regc)); % scale it to max=1
     

   

