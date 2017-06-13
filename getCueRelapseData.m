function [ri,time2relapse]=getCueRelapseData(subjects)
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
%   time2relapse - time from FOR discharge to relapse

% NOTES:
%
% author: Kelly, kelhennigan@gmail.com, 06-Sep-2016

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if ischar(subjects)
    subjects = splitstring(subjects);
end

ri = []; % relapse index
time2relapse = []; % time to relapse


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
        'ms170424'
        'jc170501'
        'hp170601'
        'rl170603'};
    
    d(:,4)={'Relapse (1=yes, 0=no/not yet)'
        '0'
        '1'
        '1'
        '1'
        '1'
        '0'
        '1'
        '1'
        '0'
        '0'
        '0'
        '0'
        '1'
        '0'
        '0'
        '0'
        '1'
        '0'
        '0'
        '1'
        'nan'
        '0'
        '1'
        '0'
        '0'
        '0'
        '0'
        '0'
        'nan'
        'nan'
        'nan'
        'nan'
        'nan'
};
    
    

    
    
    d1(:,5) = {'Date of relapse'
        ''
        ''
        ''
        ''
        '10-Aug-2016'
        ''
        '24-Feb-2016'
        ''
        ''
        ''
        ''
        ''
        '2-Jun-2016'
        ''
        ''
        ''
        ''
        ''
        ''
        '4-Sep-2016'
        ''
        ''
        '29-Oct-2016'
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''};
end

for i=1:numel(subjects)
    idx=find(ismember(d(:,1),subjects{i}));
    
    if isempty(idx)
        ri(i,1) = nan;
        time2relapse = nan;
        
    else
        ri(i,1) = str2num(d{idx,4});
        if ~isempty(d{idx,3}) && ~isempty(d{idx,5})
            time2relapse(i,1) = datenum(d{idx,5})-datenum(d{idx,3});
        else
            time2relapse(i,1) = nan;
        end
    end
end
