function [trial,TR,trialonset,trialtype,target_ms,rt,cue_value,win,trial_gain,...
    total,iti,drift,total_winpercent,binned_winpercent,header]=getMidBehData(filePath)
% -------------------------------------------------------------------------
% usage: loads mid or midi behavioral data 
% 
% INPUT:
%   filepath - string specifying which stim file
% 
% OUTPUT:
%   column headers of mid behavioral stim file & header, which is a string
%   of all those column headers
% 
% author: Kelly, kelhennigan@gmail.com, 04-Apr-2016

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% do it

% columns: 
    % trial	 
    % TR	 
    % trialonset	
    % trialtype	
    % target_ms	
    % rt	
    % cue_value	
    % hit	
    % trial_gain	
    % total	
    % iti	
    % drift	
    % total_winpercent	
    % binned_winpercent

% if file doesn't exist, throw an error
if ~exist(filePath,'file')
    error(['cant find input stim file, ' filePath ' check for typos']);
end

% format specification for columns in stim files
formatSpec = '%d%d%f%d%f%f%s%d%s%s%d%f%f%f%[^\n\r]';

% open stim file for reading 
fileID = fopen(filePath,'r');

% get header 
header = fgetl(fileID); 

% (try to) read data 
try
    d = textscan(fileID, formatSpec, 'Delimiter',',','ReturnOnError', false);
catch ME
    if (strcmp(ME.identifier,'MATLAB:textscan:handleErrorAndShowInfo'))
   fprintf(['\n something is wrong with the stim file.\n' ...
       'Check name and filepath, or maybe the scan was restarted\n' ...
       'and theres an extra header row in there.\n' ...
       'Check it out before continuing.\n\n']);
    end
    rethrow(ME);
end

% close file
fclose(fileID);

% define var names based on header
varNames=textscan(header,'%s','Delimiter',',');
varNames = varNames{:};

% col 8 is 'hit' for mid & 'hit/win' for midi; change to 'win' to avoid
% confusion
varNames{8} = 'win';


% use column headers as variable names for data
for k = 1:numel(varNames)
   eval([varNames{k} '= d{k};']);
end

% to do: change precision of floats so they're not crazy long
% trialonset = fprintf('%.4f\n',trialonset)
