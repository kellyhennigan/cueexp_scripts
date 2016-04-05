function addLastVolsMid(inFile)
% ------------------------------------------------------------------
% usage: takes in a concatenated MID stim file and adds 4 blank rows at the
% end of run 1 and run 2. # of vols in each run are hard-coded based on
% cuefmri experiment. 

% INPUT:
%   inFile - filepath of mid_matrix.csv file

% 
% OUTPUT:
%   saves out mid_matrix_wEnd.csv to same dir as input mid_matrix.csv
% 
% 
% author: Kelly, kelhennigan@gmail.com, 04-Apr-2016

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% do it

% get data
[trial,TR,trialonset,trialtype,target_ms,rt,cue_value,hit,trial_gain,...
    total,iti,drift,total_winpercent,binned_winpercent]=getMidBehData(inFile);


if addLastVols
    fprintf(fid,'\n\n\n\n');
end
% header string in stim files
headline =  'trial,TR,trialonset,trialtype,target_ms,rt,cue_value,hit,trial_gain,total,iti,drift,total_winpercent,binned_winpercent';


% format specification for columns in stim files
% formatSpec = '%d, %d, %.4f, %d, %.4f, %.4f, %s, %d, %s, %s, %d, %.4f, %.4f, %.4f\n'; % data format
formatSpec = '%d,%d,%.4f,%d,%.4f,%.4f,%s,%d,%s,%s,%d,%.4f,%.4f,%.4f\n'; % data format




% create new concatenated stim file & write header
fid=fopen(outFilePath,'w'); % create this file & set it up for writing 
fprintf(fid,'%s\n',headline); % write header


% get block 1 data 
[trial,TR,trialonset,trialtype,target_ms,rt,cue_value,hit,trial_gain,...
    total,iti,drift,total_winpercent,binned_winpercent]=getMidBehData(b1);


% write block 1 data to new concatenated file
for i=1:numel(TR)
    fprintf(fid,formatSpec,trial(i),TR(i),trialonset(i),trialtype(i),...
        target_ms(i),rt(i),cue_value{i},hit(i),trial_gain{i},total{i},iti(i),...
        drift(i),total_winpercent(i),binned_winpercent(i));
end

if addLastVols
    fprintf(fid,'\n\n\n\n');
end
    


% write block 2 data to new concatenated file
for i=1:numel(TR)
    fprintf(fid,formatSpec,trial(i),TR(i),trialonset(i),trialtype(i),...
        target_ms(i),rt(i),cue_value{i},hit(i),trial_gain{i},total{i},iti(i),...
        drift(i),total_winpercent(i),binned_winpercent(i));
end

if addLastVols
    fprintf(fid,'\n\n\n\n');
end


fclose(fid);

[trial,TR,trialonset,trialtype,target_ms,rt,cue_value,hit,trial_gain,...
    total,iti,drift,total_winpercent,binned_winpercent]=getMidBehData(outFilePath);






