function [d,pa,na,familiarity,image_types]=...
    getQualtricsData(filepath,subjects)
% -------------------------------------------------------------------------
% usage: this function is to import data from the qualtrics survey taken by
% subjects in the cue fmri task.
%
%
% INPUT:
%   filepath - filepath to qualtrics .csv file
%   filepath2 - filepath to image type list
%   subjects (optional) - cell array or string of subject ids to return data for


% OUTPUT:
%   d - structural array with subject demographic info (age, etc.)
%   valence - subject x image valence ratings
% 	arousal - " " arousal ratings
%   familiarity - " " familiarity ratings
%   image_type - image types corresponding to ratings:
%   1=alcohol,
%   2=drugs,
%   3=food
%   4=neutral
%
%
%
% TO DO: add optional 'subjects' input so user can specify specific
% subjects to return data for

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize variables.


if notDefined('filepath')
    filepath = '~/Google Drive/cuefmri/cue/behavioral_data/qualtrics_data/Post_Scan_Survey 6.csv';
end


if notDefined('subjects')
    subjects = []; % this means just return all the qualtrics data
end
if ischar(subjects)
    subjects = {subjects};
end


% output variables
d = struct();
pa = [];
na = [];
familiarity = [];
image_type = [];
image_names = [];


% internal variables
delimiter = ',';
startRow = 3;


%% Format string for each line of text:

formatSpec = [repmat('%*s',1,7) '%s%s%f%s%f%f%s%f%f%f%f%s%f%s%f%s%f%s%f%s' repmat('%f',1,288) '%[^\n\r]'];

%% Open the text file.

fileID = fopen(filepath,'r');

% if fileID=-1, this means the file couldn't be opened. Return empty
% values.
if fileID==-1
    return
end

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);

%% Close the text file.
fclose(fileID);


%% if cell array of subject get index of subjects to return data for

% flip subject id cell array to be in rows if its in columns

qsubs = dataArray{:, 4}; % list of subject ids in qualtrics data

% get a subject index for which data to return
if isempty(subjects)
    si = 1:numel(qsubs);
else
    for i=1:numel(subjects)
        idx=find(strcmp(subjects{i},qsubs));
        if ~isempty(idx)
            si(i)=idx;
        else
            si(i) = nan;
            fprintf(['\n\nwarning: no qualtrics data found for subject: ' subjects{i} '\n\n'])
        end
    end
end
si(isnan(si)) = [];


%% Put subject demographics, etc. data in a structural array

% d is a structural array for subject-specific data

d.subjid = dataArray{4}(si);

d.StartDate = dataArray{1}(si);
d.EndDate = dataArray{2}(si);
d.Finished = dataArray{3}(si);
d.age = dataArray{5}(si);
d.food_restrictions = dataArray{6}(si);
d.food_restrictions_text = dataArray{7}(si);
d.hungry = dataArray{8}(si);
d.thirsty = dataArray{9}(si);
d.sex = dataArray{10}(si);
d.primary_lang = dataArray{11}(si);
d.primary_lang_text = dataArray{12}(si);
d.live_in_US = dataArray{13}(si);
d.live_in_US_text = dataArray{14}(si);
d.education = dataArray{15}(si);
d.education2 = dataArray{16}(si);
d.classify = dataArray{17}(si);
d.classify2 = dataArray{18}(si);
d.alc_morals = dataArray{19}(si);
d.alc_morals2 = dataArray{20}(si);


%% get image ratings as a numeric matrix

valence = [dataArray{22:4:308}]; valence = valence(si,:);
arousal = [dataArray{23:4:308}]; arousal = arousal(si,:);
familiarity = [dataArray{24:4:308}]; familiarity = familiarity(si,:);


% make sure valence, arousal, and familiarty rating matrices are the same
% size
if ~isequal(size(valence),size(arousal),size(familiarity))
    error('size of valence, arousal, and familiarity ratings don''t match! Fix this before continuing.')
end

% make sure there are ratings for 72 images
if size(valence,2)~=72
    error(['ratings only loaded for ' num2str(size(valence,2)) ' images - look into this!']);
end


%% transform valence & arousal ratings to positive & negative arousal

[pa,na]=va2pana(valence,arousal);



%% get image types

image_types = getQualtricsImageTypes;

[pa,na,familiarity,image_types]=reorderQualtricsData(pa,na,familiarity,image_types);


end % getQualtricsData

% returns image types from qualtrics ratings
% this is also saved in the file:
% /cuefmri/cue/behavioral_data/qualtrics_data/qualtrics_survey_image_types
function image_types = getQualtricsImageTypes

image_types = [1 2 3 4 1 2 1 4 4 2 3 1 4 3 4 2 3 3 3 4 2 1 1 2 2 3 2 3 ...
    1 4 4 4 3 1 4 4 1 2 1 3 2 1 2 3 4 1 3 2 1 3 2 3 4 4 3 2 2 3 3 1 4 2 ...
    1 2 4 1 2 3 4 1 4 1];

end


% reorder the qualtrics ratings to be in the same order as
% they were presented during the cue task in the scanner
function [pa,na,familiarity,image_types]=reorderQualtricsData(pa,na,familiarity,image_types)

reorder_idx = [23 15 22 21 3 28 45 6 33 12 7 10 37 30 5 55 24 65 43 52 ...
    16 50 58 1 27 39 59 38 2 71 41 61 53 34 29 54 56 68 25 69 13 72 64 ...
    14 18 42 4 60 46 17 20 48 8 63 9 66 11 32 19 57 44 35 40 62 31 51 26 ...
    47 49 70 36 67];

pa = pa(:,reorder_idx);
na = na(:,reorder_idx);
familiarity = familiarity(:,reorder_idx);
image_types = image_types(reorder_idx);

end
