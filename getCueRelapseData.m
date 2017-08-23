function [ri,relapseDate,notes]=getCueRelapseData(subjects)
% -------------------------------------------------------------------------
% usage: get relapse index for patients from cue fmri experiment.
%
% INPUT:
%   subjects - cell array with subject ids strings of subjects to return
%   relapse index for
%
%
% OUTPUT:
%   ri - index of ones and zeros indicating relapse (1) or non-relapse (0)
%   relapseDate - date of relapse
%   notes - any notes written in spreadsheet

% NOTES:
%
% author: Kelly, kelhennigan@gmail.com, 06-Sep-2016

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if ischar(subjects)
    subjects = splitstring(subjects);
end

ri = []; % relapse index
relapseDate={}; % date of 1st relapse
notes = {}; % subj notes

docid = '1_6dQvMQQuLPFo8ciPSvaaOAcW3RrGHtzpx3uX3oaHWk'; % doc id for google sheet w/relapse data
try
    d = GetGoogleSpreadsheet(docid); % load google sheet as cell array
    
    
    % if the google sheet couldn't be accessed, use these values (update as
    % often as possible):
catch
    warning(['\ngoogle sheet couldnt be accessed, probably bc your offline.' ...
        'Using hard coded values that may not be the most updated...'])
    
    d(:,1) = { 'Subject ID'
        'ag151024'
        'si151120'
        'tf151127'
        'wr151127'
        'ja151218'
        'wh160130'
        'nb160221'
        'as160317'
        'rv160413'
        'ja160416'
        'rt160420'
        'cm160510'
        'tj160529'
        'at160601'
        'zm160627'
        'jf160703'
        'cg160715'
        'rs160730'
        'nc160905'
        'gm160909'
        'lm160914'
        'jb161004'
        'rc161007'
        'se161021'
        'mr161024'
        'al170316'
        'jd170330'
        'jw170330'
        'tg170423'
        'jc170501'
        'hp170601'
        'rl170603'
        'rf170610'
        'mr170621'
        'ds170728'
        'as170730'
        'rc170730'
        };
    
    d(:,2)={'Relapse (1=yes, 0=no/not yet)'
        0
        1
        1
        1
        1
        0
        1
        1
        0
        0
        0
        0
        1
        0
        0
        0
        1
        0
        0
        1
        1
        0
        1
        0
        0
        0
        1
        1
        nan
        0
        1
        0
        0
        0
        nan
        nan
        1
        };
    
return     

end

% find columns with desired data
cj = find(strncmp(d(1,:),'Relapse',7));
cj_date = find(strncmp(d(1,:),'Date of relapse',15)); 
cj_notes = find(strncmp(d(1,:),'notes',5)); 


for i=1:numel(subjects)

  
    % get row with this subject id
    idx=find(ismember(d(:,1),subjects{i}));
    
    % if cant find subject id, assign vals to nan
    if isempty(idx)
        ri(i,1) = nan;
        relapseDate{i,1} = nan;
        notes{i,1} = '';
        

    else
        
        %  if there's no entered data for this subject, assign vals to nan;
%         otherwise, get subject's data
        if isempty(d{idx,cj})
            ri(i,1) = nan;
        else
            ri(i,1) = str2num(d{idx,cj});
        end
        
        %  do the same for relapse date
        if isempty(d{idx,cj_date})
            relapseDate{i,1} = nan;
        else
            relapseDate{i,1} = d{idx,cj_date};
        end
        
         %  do the same for notes
        if isempty(d{idx,cj_notes})
            notes{i,1} = '';
        else
            notes{i,1} = d{idx,cj_notes};
        end
        
    end % isempty(idx)

    
end % subj loop
