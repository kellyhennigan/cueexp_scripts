function [d,pa,na,famil,image_types]=getQualtricsData(filepath,subjects)
% -------------------------------------------------------------------------
% usage: this function is to import data from the qualtrics survey taken by
% subjects in the cue fmri task.
%
%
% INPUT:
%   filepath - filepath to qualtrics .csv file
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
    filepath = '/Users/Kelly/cueexp/data/qualtrics_data/Post_Scan_Survey_170505.csv';
end


if notDefined('subjects')
    subjects = []; % this means just return all the qualtrics data
end
if ischar(subjects)
    subjects = {subjects};
end


% output variables -
d = struct(); % structu array w/subjects' demographics info
pa = [];        % positive arousal ratings
na = [];        % negative arousal ratings
famil = [];   % familiarity
image_types = []; % image types



%% import data

% internal variables
delimiter = ',';
startRow = 3;

formatSpec = [repmat('%*s',1,7) '%s%s%f%s%f%f%s%f%f%f%f%s%f%s%f%s%f%s%f%s%f%s' repmat('%f',1,288) '%*[^\n]'];

% Open the text file
fileID = fopen(filepath,'r');

% if fileID=-1, this means the file couldn't be opened. Return empty
% values.
if fileID==-1
    return
end

% Read columns of data according to format string.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);

% Close the text file
fclose(fileID);



%% get image ratings as a numeric matrix & convert valence/arousal to pa/na

valence = [dataArray{24:4:310}];
arousal = [dataArray{25:4:310}];
familQ = [dataArray{26:4:310}];

% make sure valence, arousal, and familiarty rating matrices are the same
% size
if ~isequal(size(valence),size(arousal),size(familQ))
    error('size of valence, arousal, and familiarity ratings don''t match! Fix this before continuing.')
end

% make sure there are ratings for 72 images
if size(valence,2)~=72
    error(['ratings only loaded for ' num2str(size(valence,2)) ' images - look into this!']);
end

% transform valence & arousal ratings to positive & negative arousal
[paQ,naQ]=va2pana(valence,arousal);


% get image types
image_types = getQualtricsImageTypes;

% reorder qualtrics data to match cue presentation in fmri task
[paQ,naQ,familQ,image_types]=reorderQualtricsData(paQ,naQ,familQ,image_types);


%% now loop through subjects to get ratings & demographics info

qsubs = dataArray{:, 4}; % list of subject ids in qualtrics data

% if no subjects are given as input, return data as listed in qualtrics
if isempty(subjects)
    subjects = qsubs;
end

d.subjid = subjects;

for i=1:numel(subjects)
    
    % deal with subject-specific issues here:
    
    % subject ja151218's responses are coded with id, 'ja151218_actual'
    if strcmp(subjects{i},'ja151218')
        si=find(strcmp('ja151218_actual',qsubs));
        
        % subject jn160403 was incorrectly entered as jn160402
    elseif strcmp(subjects{i},'jn160403')
        si=find(strcmp('jn160402',qsubs));
        
        % subject cs160214 was incorrectly entered as cs160216
    elseif strcmp(subjects{i},'cs160214')
        si=find(strcmp('cs160216',qsubs));
        
        % subject as160317 was incorrectly entered
    elseif strcmp(subjects{i},'as160317')
        si=find(strcmp('as1603167',qsubs));
  
         % subject ld160918 was incorrectly entered as ld160914
    elseif strcmp(subjects{i},'ld160918')
        si=find(strcmp('ld160914',qsubs));
 
        % subject tj160529 and jw170330 were entered twice; 
    elseif strcmp(subjects{i},'tj160529') || strcmp(subjects{i},'jw170330')
        si=find(strcmp(subjects{i},qsubs));
        si = si(1);
 
        % subject al170316 was incorrectly entered as al160317
    elseif strcmp(subjects{i},'al170316')
        si=find(strcmp('al160317',qsubs));
  
    else
        si=find(strcmp(subjects{i},qsubs));
    end
    
    % if subject's data isn't found, return nan/empty values for that
    % subject
    if isempty(si)
        
        fprintf(['\n\nwarning: no qualtrics data found for subject: ' subjects{i} '\n\n'])
        d.StartDate{i} = '';
        d.EndDate{i,1} = '';
        d.Finished(i,1) = nan;
        d.age(i,1) = nan;
        d.food_restrictions(i,1) = nan;
        d.food_restrictions_text{i,1} = '';
        d.hungry(i,1) = nan;
        d.thirsty(i,1) = nan;
        d.sex(i,1) = nan;
        d.primary_lang(i,1) = nan;
        d.primary_lang_text{i,1} = '';
        d.live_in_US(i,1) = nan;
        d.live_in_US_text{i,1} = '';
        d.education(i,1) = nan;
        d.education2{i,1} = '';
        d.classify(i,1) = nan;
        d.classify2{i,1} = '';
        d.alc_morals(i,1) = nan;
        d.alc_morals2{i,1} = '';
        d.smoke(i,1) = nan;
        d.smoke_perday{i,1} = '';
        
        pa(i,:) = nan(1,72);
        na(i,:) = nan(1,72);
        famil(i,:) = nan(1,72);
        
    else
        
        % fill in data for this subject
        d.StartDate{i,:} = dataArray{1}{si};
        d.EndDate{i,:} = dataArray{2}{si};
        d.Finished(i,1) = dataArray{3}(si);
        d.age(i,1) = dataArray{5}(si);
         d.hungry(i,1) = dataArray{8}(si);
        d.thirsty(i,1) = dataArray{9}(si);
        d.sex(i,1) = dataArray{10}(si);
        
           d.food_restrictions(i,1) = dataArray{6}(si);
        d.food_restrictions_text{i,:} = dataArray{7}{si};
    
             d.primary_lang(i,1) = dataArray{11}(si);
        d.primary_lang_text{i,:} = dataArray{12}{si};
        d.live_in_US(i,1) = dataArray{13}(si);
        d.live_in_US_text{i,:} = dataArray{14}{si};
        d.education(i,1) = dataArray{15}(si);
        d.education2{i,:} = dataArray{16}{si};
        d.classify(i,1) = dataArray{17}(si);
        d.classify2{i,:} = dataArray{18}{si};
        d.alc_morals(i,1) = dataArray{19}(si);
        d.alc_morals2{i,:} = dataArray{20}{si};
        d.smoke(i,1) = dataArray{21}(si);
        d.smoke_perday{i,:} = dataArray{22}{si};
   
        
        pa(i,:) = paQ(si,:);
        na(i,:) = naQ(si,:);
        famil(i,:) = familQ(si,:);
        
    end
    
end % subjects loop

%% recode classify with strings 
% 
% if qd.classify
% d.class
% end

end % function

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


%% 
% age bins: 

% 18 - 20
% 21 - 25
% 26 - 30
% 31 - 40
% 41 - 50
% 50 - 60
% 60 +


% hungry/thirsty: 
% 1=not hungry at all
% 4= somewhat hungry
% 7=very hungry
% 

% sex: 
% Male
% Female
% Decline to state

% primary language:
% English
% Other (fill-in)


% live in US: 
% Yes, my entire life
% Yes, for 5+ years (but not entire life)
% Yes, for 2-5 years
% Yes, for 1-2 years
% Yes, for less than 1 year
% No, I live in: (fill in)


% education: 
%     1= Grammar school
%     2= High school or equivalent
%     3= Some college
%     4= Bachelor's degree
%     5= Master's degree
%     6= Doctoral degree
%     7= Professional degree
% 
% 
% classify: 
%     1= Arab
%     2= Asian/Pacific Islander
%     3= Black
%     4= Caucasian/White
%     5= Hispanic
%     6= Indigenous or Aboriginal
%     7= Latino
%     8= Multiracial
%     9= Would rather not say
