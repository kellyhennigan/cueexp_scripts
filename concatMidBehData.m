function concatMidBehData(b1,b2,outFilePath)
% -------------------------------------------------------------------------
% usage: takes in blocks 1 and 2 stim files, concatenates, and saves out
% concatenated file as outFilePath. If outFilePath isn't given then it won't be
% saved.
% 
% INPUT:
%   b1 - block 1 csv stim file 
%   b2 - block 2 csv stim file 
% 
% OUTPUT:
%   var1 - etc.
% 
% NOTES:
% 
% author: Kelly, kelhennigan@gmail.com, 04-Apr-2016

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% do it

% format specification for columns in stim files
% formatSpec = '%d, %d, %.4f, %d, %.4f, %.4f, %s, %d, %s, %s, %d, %.4f, %.4f, %.4f\n'; % data format
formatSpec = '%d,%d,%.4f,%d,%.4f,%.4f,%s,%d,%s,%s,%d,%.4f,%.4f,%.4f\n'; % data format


% create new concatenated stim file
fid=fopen(outFilePath,'w'); % create this file & set it up for writing 

% get block 1 data 
[trial,TR,trialonset,trialtype,target_ms,rt,cue_value,hit,trial_gain,...
    total,iti,drift,total_winpercent,binned_winpercent,header]=getMidBehData(b1);

% write file header
fprintf(fid,'%s\n',header); % write header



% write block 1 data to new concatenated file
for i=1:numel(TR)
    fprintf(fid,formatSpec,trial(i),TR(i),trialonset(i),trialtype(i),...
        target_ms(i),rt(i),cue_value{i},hit(i),trial_gain{i},total{i},iti(i),...
        drift(i),total_winpercent(i),binned_winpercent(i));
end

    
% get block 2 data 
[trial,TR,trialonset,trialtype,target_ms,rt,cue_value,hit,trial_gain,...
    total,iti,drift,total_winpercent,binned_winpercent]=getMidBehData(b2);


% write block 2 data to new concatenated file
for i=1:numel(TR)
    fprintf(fid,formatSpec,trial(i),TR(i),trialonset(i),trialtype(i),...
        target_ms(i),rt(i),cue_value{i},hit(i),trial_gain{i},total{i},iti(i),...
        drift(i),total_winpercent(i),binned_winpercent(i));
end


fclose(fid);







