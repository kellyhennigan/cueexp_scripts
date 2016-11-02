function concatMidBehData(b1,b2,outFilePath)
% -------------------------------------------------------------------------
% usage: takes in blocks 1 and 2 stim files from mid or midi task,
% concatenates, and saves out concatenated file as outFilePath.

%
% INPUT:
%   b1 - block 1 csv stim file
%   b2 - block 2 csv stim file
%   outFilePath - name/path of saved out concatenated file

% OUTPUT:
%   saves outFilePath to specified path; also outFilePath w/blank lines, if
%   add4Vols==1
%
% NOTES:
%
% author: Kelly, kelhennigan@gmail.com, 04-Apr-2016

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% do it

% if outFilePath already exists, do nothing
if exist(outFilePath,'file')
    fprintf(['\n outFile, ' outFilePath '\n already exists! ' ...
        'So, not concatenating & writing out to that file.\n']);
    
else
    
    % get block 1 data
    [trial,TR,trialonset,trialtype,target_ms,rt,cue_value,win,trial_gain,...
        total,iti,drift,total_winpercent,binned_winpercent,header]=getMidBehData(b1);
    
    
    % there should be 252 TRs in run 1 for mid, or 288 TRs in run 1 for midi
    if ~(numel(TR)==252 || numel(TR)==288)
        error(['\n\nthere are an unexpected # of entries in block 1;\n'...
            'expecting 252 TRs if mid or 288 TRs if midi\n,'...
            'but there are %d entries (not including header).\n'...
            'Check this out before concatenating...\n\n'],numel(TR));
    end
    
    % format specification for concatenated stim file
    formatSpec = '%d,%d,%.4f,%d,%.4f,%.4f,%s,%d,%s,%s,%d,%.4f,%.4f,%.4f\n'; % data format
    
    
    % create new concatenated stim file
    fid=fopen(outFilePath,'w'); % create this file & set it up for writing
    
    
    % write file header
    fprintf(fid,'%s\n',header); % write header
    
    
    % write block 1 data to new concatenated file
    for i=1:numel(TR)
        fprintf(fid,formatSpec,trial(i),TR(i),trialonset(i),trialtype(i),...
            target_ms(i),rt(i),cue_value{i},win(i),trial_gain{i},total{i},iti(i),...
            drift(i),total_winpercent(i),binned_winpercent(i));
    end
    
    
    % get block 2 data
    [trial,TR,trialonset,trialtype,target_ms,rt,cue_value,win,trial_gain,...
        total,iti,drift,total_winpercent,binned_winpercent]=getMidBehData(b2);
    
    
    % there should be 288 TRs in run 2 for either mid or midi
    if numel(TR)~=288
        error(['\n\nthere are an unexpected # of entries in block 1;\n'...
            'expecting 288 TRs, but there are %d entries (not including header).\n'...
            'Check this out before concatenating...\n\n'],numel(TR));
    end
    
    % write block 2 data to new concatenated file
    for i=1:numel(TR)
        fprintf(fid,formatSpec,trial(i),TR(i),trialonset(i),trialtype(i),...
            target_ms(i),rt(i),cue_value{i},win(i),trial_gain{i},total{i},iti(i),...
            drift(i),total_winpercent(i),binned_winpercent(i));
    end
    
    
    fclose(fid);
    
end





