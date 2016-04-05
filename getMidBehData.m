function [trial,TR,trialonset,trialtype,target_ms,rt,cue_value,hit,trial_gain,...
    total,iti,drift,total_winpercent,binned_winpercent,header]=getMidBehData(filePath)
% -------------------------------------------------------------------------
% usage: loads mid behavioral data 
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

% format specification for columns in stim files
formatSpec = '%d%d%f%d%f%f%s%d%s%s%d%f%f%f%[^\n\r]';

% open, read, and close b1 file 
fileID = fopen(filePath,'r');
header = fgetl(fileID); % get header 
d = textscan(fileID, formatSpec, 'Delimiter',',','ReturnOnError', false);
fclose(fileID);

% define var names based on header
varNames=textscan(header,'%s','Delimiter',',');
varNames = varNames{:};

% use column headers as variable names for data
for k = 1:numel(varNames)
   eval([varNames{k} '= d{k};']);
end

% to do: change precision of floats so they're not crazy long
% trialonset = fprintf('%.4f\n',trialonset)
