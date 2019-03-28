function ind=getStrIndices(c1,c2)
% -------------------------------------------------------------------------
% usage: for a cell of strings c1, return index for where they are located
% (if at all) in cell array c2. Note this only returns the index for the
% first index of a given string found. I.e., if a string in c1 appears more
% than once in c2, only the index for its first instance will be returned.

% for example: 

% c1= {'this','is','a','test'};
% 
% c2={'It','is','only','a','test'};

% getStrIndices(c1,c2)

% = [nan 2 4 5];
% 
% INPUT:
%   c1 - cell array of strings
%   c2 - another cell array of strings
% 
% OUTPUT:
%   ind - indices of where the strings in c1 are located in c2
% 
% NOTES:
% 
% author: Kelly, kelhennigan@gmail.com, 26-Jul-2018

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


a = ismember(c1,c2);

ind=[];

for i=1:numel(a)

    if a(i)
        this_ind=find(ismember(c2,c1(i)));
        ind(i,1) = this_ind(1);
    else
        ind(i,1) = nan;
    end
    
end

