% script to set up behavioral data for cue reactivity study


% TO DO:

% -don't copy over out files if they already exist
% -add extra rows to mid and midi stim files
% -make sure that saving out with writetable() produces same result as
% previous stim files

%%
p=getCuePaths; % get experiment paths

rawDir = '/Users/kelly/Google Drive/cuefmri';

% input subject id:
subjid = input('enter subject id: ','s');

% make subject out dir if it doesn't exist
subjOutDir = fullfile(p.data,subjid,'behavior');
if ~exist(subjOutDir,'dir')
    mkdir(subjOutDir);
end

doOverwrite=1; % 1 to overwrite files while copying stim files, 0 to not overwrite


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CUE TASK

%%%%%%%%%%%% stim timing file
% inFile = [subjid '_m.csv'];
inFile = [subjid '_m.csv'];
inPath = fullfile(rawDir,'cue','task_files','data',inFile);
outPath{1} = fullfile(rawDir,'cue','behavioral_data',[subjid '_cue_matrix.csv']);
outPath{2} = fullfile(subjOutDir,'cue_matrix.csv');

% check that stim file exists
if exist(inPath,'file')
    
    % make sure it has the right # of rows
    T=readtable(inPath,'Delimiter',',','ReadVariableNames',true);
    if size(T,1)==432
        fprintf('\n\ncue stim file looks good!\n');
        
        
        % check if outfile already exists
        for i=1:2
            if exist(outPath{i},'file')
                if doOverwrite
                    fprintf(['\n copying over pre-existing file: ' outPath{i} '...\n']);
                    copyfile(inPath,outPath{i});
                else
                    fprintf(['\nfile: ' outPath{i} '\n already exists; NOT overwriting...\n']);
                end
            else
                copyfile(inPath,outPath{i});
            end
        end
        
    else
        fprintf(['\n\ncue stim file:\n' inFile '\nhas unexpected # of rows...manually check this!\n']);
    end
    
else
    fprintf(['\n\ncouldnt find cue stim file:\n' inFile '\ncheck filename for typos, etc.\n']);
end

clear inFile inPath outPath T

%%%%%%%%% rating file
% inFile = [subjid '_ratings.csv'];
inFile = [subjid '_ratings.csv'];
inPath = fullfile(rawDir,'cue','task_files','data',inFile);
outPath{1} = fullfile(rawDir,'cue','behavioral_data',[subjid '_cue_ratings.csv']);
outPath{2} = fullfile(subjOutDir,'cue_ratings.csv');

% check that stim file exists
if exist(inPath,'file')
    
    % make sure it has the right # of rows
    T=readtable(inPath,'Delimiter',',','ReadVariableNames',true);
    if size(T,1)==4
        fprintf('\n\ncue ratings file looks good!\n');
        
        % check if outfile already exists
        for i=1:2
            if exist(outPath{i},'file')
                if doOverwrite
                    fprintf(['\n copying over pre-existing file: ' outPath{i} '...\n']);
                    copyfile(inPath,outPath{i});
                else
                    fprintf(['\nfile: ' outPath{i} '\n already exists; NOT overwriting...\n']);
                end
            else
                copyfile(inPath,outPath{i});
            end
        end
        
    else
        fprintf(['\n\ncue ratings file:\n' inFile '\nhas unexpected size...manually check this!\n']);
    end
    
else
    
    fprintf(['\n\ncouldnt find cue ratings file:\n' inFile '\ncheck filename for typos, etc.\n']);
end

clear inFile inPath outPath T i

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MID

% stim timing file
inFiles = {[subjid '_b1.csv'],[subjid '_b2.csv']};
inDir = fullfile(rawDir,'mid','task_files','MID','data');
outPath{1} = fullfile(rawDir,'mid','behavioral_data',[subjid '_mid_matrix.csv']);
outPath{2} = fullfile(subjOutDir,'mid_matrix.csv');
outPath{3} = fullfile(subjOutDir,'mid_matrix_wEnd.csv');

% find inFiles



% check that stim files exist
if exist(fullfile(inDir,inFiles{1}),'file') && exist(fullfile(inDir,inFiles{2}),'file')
    
    % make sure the files have right # of rows; if they do, append b2 to b1
    T1=readtable(fullfile(inDir,inFiles{1}),'Delimiter',',','ReadVariableNames',true);
    T2=readtable(fullfile(inDir,inFiles{2}),'Delimiter',',','ReadVariableNames',true);
    if size(T1,1)==252 && size(T2,1)==288
        fprintf('\n\nMID stim files look good!\n');
        T = [T1;T2];
        
        % check if outfile already exists
        for i=1:2
            if exist(outPath{i},'file')
                if doOverwrite
                    fprintf(['\n copying over pre-existing file: ' outPath{i} '...\n']);
                    writetable(T,outPath{i});
                else
                    fprintf(['\nfile: ' outPath{i} '\n already exists; NOT overwriting...\n']);
                end
            else
                writetable(T,outPath{i});
            end
        end
        
        % add extra rows to ends of blocks so that these TRs won't be
        % unnecessarily not included in the analysis
%         Tnull = readtable(fullfile(p.baseDir,'misc','mid_matrix_nan_4TRs.csv'));
        Tnull=array2table(nan(4,size(T1,2)),'VariableNames',T.Properties.VariableNames);
        Tnull.cue_value=repmat({'nan'},4,1);  Tnull.trial_gain=repmat({'nan'},4,1);  Tnull.total=repmat({'nan'},4,1);
         T=[T1;Tnull;T2;Tnull];
        
        % check if outfile already exists
        if exist(outPath{3},'file')
            if doOverwrite
                fprintf(['\n copying over pre-existing file: ' outPath{3} '...\n']);
                writetable(T,outPath{3});
            else
                fprintf(['\nfile: ' outPath{3} '\n already exists; NOT overwriting...\n']);
            end
        else
            writetable(T,outPath{3});
        end
        
    else
        fprintf(['\n\nMID stim files:\n' inFiles{1} ' and/or ' inFiles{2} '\nhave unexpected # of rows...manually check this!\n']);
    end
    
else
    
    fprintf(['\n\ncouldnt find MID stim files:\n' inFiles{1} ' and/or ' inFiles{2} '\ncheck filename for typos, etc.\n']);
end

clear inFiles inDir outPath T1 T2 Tnull T i



%%%%%%%%% rating file
inFile = [subjid '_ratings.csv'];
inPath = fullfile(rawDir,'mid','task_files','MID','data',inFile);
outPath{1} = fullfile(rawDir,'mid','behavioral_data',[subjid '_mid_ratings.csv']);
outPath{2} = fullfile(subjOutDir,'mid_ratings.csv');

% check that stim file exists
if exist(inPath,'file')
    
    % make sure it has the right # of rows
    T=readtable(inPath,'Delimiter',',','ReadVariableNames',true);
    if size(T,1)==6
        fprintf('\n\nmid ratings file looks good!\n');
        
        % check if outfile already exists
        for i=1:2
            if exist(outPath{i},'file')
                if doOverwrite
                    fprintf(['\n copying over pre-existing file: ' outPath{i} '...\n']);
                    copyfile(inPath,outPath{i});
                else
                    fprintf(['\nfile: ' outPath{i} '\n already exists; NOT overwriting...\n']);
                end
            else
                copyfile(inPath,outPath{i});
            end
        end
        
    else
        fprintf(['\n\nmid ratings file:\n' inFile '\nhas unexpected size...manually check this!\n']);
    end
    
else
    
    fprintf(['\n\ncouldnt find MID ratings file:\n' inFile '\ncheck filename for typos, etc.\n']);
end

clear inFile inPath outPath T i


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MIDI


% stim timing file
inFiles = {[subjid '_b1.csv'],[subjid '_b2.csv']};
% inFiles = {[subjid '_b1_MIDI.csv'],[subjid '_b2_MIDI.csv']};

inDir = fullfile(rawDir,'midi','task_files','MIDI','data');
outPath{1} = fullfile(rawDir,'midi','behavioral_data',[subjid '_midi_matrix.csv']);
outPath{2} = fullfile(subjOutDir,'midi_matrix.csv');
outPath{3} = fullfile(subjOutDir,'midi_matrix_wEnd.csv');

% check that stim files exist
if exist(fullfile(inDir,inFiles{1}),'file') && exist(fullfile(inDir,inFiles{2}),'file')
    
    % make sure the files have right # of rows; if they do, append b2 to b1
    T1=readtable(fullfile(inDir,inFiles{1}),'Delimiter',',','ReadVariableNames',true);
    T2=readtable(fullfile(inDir,inFiles{2}),'Delimiter',',','ReadVariableNames',true);
    if size(T1,1)==288 && size(T2,1)==288
        fprintf('\n\nMIDI stim files look good!\n');
        T = [T1;T2];
        
        % check if outfile already exists
        for i=1:2
            if exist(outPath{i},'file')
                if doOverwrite
                    fprintf(['\n copying over pre-existing file: ' outPath{i} '...\n']);
                    writetable(T,outPath{3});
                else
                    fprintf(['\nfile: ' outPath{i} '\n already exists; NOT overwriting...\n']);
                end
            else
                writetable(T,outPath{i});
            end
        end
        
        % add extra rows to ends of blocks so that these TRs won't be
        % unnecessarily not included in the analysis
%         Tnull = readtable(fullfile(p.baseDir,'misc','midi_matrix_nan_4TRs.csv'));
       Tnull=array2table(nan(4,size(T1,2)),'VariableNames',T.Properties.VariableNames);
       Tnull.cue_value=repmat({'nan'},4,1);  Tnull.trial_gain=repmat({'nan'},4,1);  Tnull.total=repmat({'nan'},4,1);
        T=[T1;Tnull;T2;Tnull];
        
        % check if outfile already exists
        if exist(outPath{3},'file')
            if doOverwrite
                fprintf(['\n copying over pre-existing file: ' outPath{3} '...\n']);
                writetable(T,outPath{3});
            else
                fprintf(['\nfile: ' outPath{3} '\n already exists; NOT overwriting...\n']);
            end
        else
            writetable(T,outPath{3});
        end
        
    else
        fprintf(['\n\nMIDI stim files:\n' inFiles{1} ' and/or ' inFiles{2} '\nhave unexpected # of rows...manually check this!\n']);
    end
    
else
    
    fprintf(['\n\ncouldnt find MIDI stim files:\n' inFiles{1} ' and/or ' inFiles{2} '\ncheck filename for typos, etc.\n']);
end

clear inFiles inDir outPath T1 T2 Tnull T i



%%%%%%%%% rating file
inFile = [subjid '_ratings.csv'];
% inFile = [subjid '_ratings_MIDI.csv'];

inPath = fullfile(rawDir,'midi','task_files','MIDI','data',inFile);
outPath{1} = fullfile(rawDir,'midi','behavioral_data',[subjid '_midi_ratings.csv']);
outPath{2} = fullfile(subjOutDir,'midi_ratings.csv');

% check that stim file exists
if exist(inPath,'file')
    
    % make sure it has the right # of rows
    T=readtable(inPath,'Delimiter',',','ReadVariableNames',true);
    if size(T,1)==4
        fprintf('\n\nmidi ratings file looks good!\n');
        
        % check if outfile already exists
        for i=1:2
            if exist(outPath{i},'file')
                if doOverwrite
                    fprintf(['\n copying over pre-existing file: ' outPath{i} '...\n']);
                    copyfile(inPath,outPath{i});
                else
                    fprintf(['\nfile: ' outPath{i} '\n already exists; NOT overwriting...\n']);
                end
            else
                copyfile(inPath,outPath{i});
            end
        end
        
    else
        fprintf(['\n\nmidi ratings file:\n' inFile '\nhas unexpected size...manually check this!\n']);
    end
    
else
    
    fprintf(['\n\ncouldnt find midi ratings file:\n' inFile '\ncheck filename for typos, etc.\n']);
end

clear inFile inPath outPath T i




