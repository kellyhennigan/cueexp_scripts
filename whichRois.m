function roiNames = whichRois(roiDir,roiStr)
% -------------------------------------------------------------------------
% usage: use this to search for ROI nifti files in a directory (roiDir)
% that contain the string (roiStr), propose them to the user, and take in
% user input for desired ROI names to return
% 
% INPUT:
%   roiDir - directory path containing roi nifti files
%   roiStr - rois should contain this string in their nifti file name
% 
% OUTPUT:
%   roiNames - cell array of roi file names (sans the string, roiStr)
% 
% NOTES:
% 
% author: Kelly, kelhennigan@gmail.com, 10-Aug-2017

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if notDefined('roiStr')
    roiStr = '';
end


% find ROIs in directory roiDir
a=dir([roiDir '/*']);
while strcmp(a(1).name(1),'.')
    a(1)=[];
end
allRoiNames = cellfun(@(x) strrep(x,roiStr,''), {a(:).name},'uniformoutput',0);


% display all found ROIs & ask user which are desired
disp(allRoiNames');
fprintf('\nwhich ROIs to process? \n');
roiNames = input('enter roi name(s), or hit return for all ROIs above: ','s');
if isempty(roiNames)
    roiNames = allRoiNames;
else
    roiNames = splitstring(roiNames);
end

