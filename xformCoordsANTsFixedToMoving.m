function outCoords = xformCoordsANTsFixedToMoving(inCoords,xform_aff,xform_warp)
% -------------------------------------------------------------------------
% usage: this function calls ANTs software to transform points in "fixed" 
% space to moving space. 
% 
% INPUT:
%   inCoords - Mx3 matrix of coordinates in real space; each row is a 3d coord
%              OR a filepath that contains coords in rows (i.e., each row
%              has an x,y,z coordinate)
%   xform_aff - filename of affine xform from inCoords to outCoords space
%   xform_invWarp (optional) - filename of inverse warp xform from inCoords to outCoords space
% 
% OUTPUT:
%   outCoords - xformed coords
% 
% 
% NOTES: this function calls ANTs software to transform points in "fixed" 
% space to moving space. 

% For example, say you used ANTs to coregister/transform a subject's t1 volume
% (moving) to a mni t1 template (fixed). 

% That would produce affine (txt), warp (nii.gz), and inverse warp (nii.gz)
% transform files, such as:
        % t12mni_xform_Affine.txt 
        % t12mni_xform_Warp.nii.gz 
        % t12mni_xform_InverseWarp.nii.gz 
        
% Based on documentation here: 
% https://github.com/ANTsX/ANTs/wiki/Forward-and-inverse-warps-for-warping-images,-pointsets-and-Jacobians#transforming-a-point-set

% the call for transforming points from fixed to moving space is (weirdly): 

% antsApplyTransformsToPoints \
%   -d 3 \
%   -i landmarksInFixedSpace.csv \
%   -o landmarksInMovingSpace.csv \
%   -t movingToFixed_1Warp.nii.gz \
%   -t movingToFixed_0GenericAffine.mat 


% Also, ANTs requires coords to be in a csv file and in ITK style (LPS
%   orientation). So, these things must be accomodated. 

% see here for more info: http://manpages.org/antsapplytransformstopoints
% 
% and I'm using syntax based on here:
% https://github.com/ANTsX/ANTs/wiki/Forward-and-inverse-warps-for-warping-images,-pointsets-and-Jacobians#transforming-a-point-set

% author: Kelly, kelhennigan@gmail.com, 16-Dec-2016

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 

if notDefined('xform_invWarp')
    xform_invWarp = '';
end

% if inCoords is a file name, load it
if isstr(inCoords)
    inCoords=dlmread(inCoords);
end

% in case coords appear to be listed in columns, flip them to be in rows
if size(inCoords,2)~=3
   if size(inCoords,1)==3
       inCoords=inCoords';
   else
    error('inCoords must be 3d.')
   end
end


% define temporary files for writing out inCoords & outCoords
inFile = [tempname '.csv']; 
outFile = [tempname '.csv']; 


%%%%%%%%%%  convert inCoords to ITK style (LPS format)
inCoordsITK = [inCoords(:,1:2).*-1 inCoords(:,3)];

%%%%%%%%%% write out inCoords to temp file
csvwrite_with_headers(inFile,[inCoordsITK zeros(size(inCoordsITK,1),1)],{'x','y','z','t'})
% csvread(inFile,1,0)


% %%%% syntax is based on documentation here: 
% https://github.com/ANTsX/ANTs/wiki/Forward-and-inverse-warps-for-warping-images,-pointsets-and-Jacobians

% %%%%%%%%% get part of the command that specifies xforms
xform_str = [' -t ' xform_aff];
if ~isempty(xform_warp) % add warp xform first, if given
   xform_str = [' -t ' xform_warp xform_str];
end



%%%%%%%%%  add ants directory to path 
system('export PATH=$PATH:~/repos/antsbin/bin');

% note: for some reason exporting ants path isn't working here - 
% the antsApplyTransformsToPoints command isn't found,
% even though it works for xformANTS and xformInvANTS functions. So, for
% now just define the ants directory and explicitly add that to the
% command:
antspath = '~/repos/antsbin/bin';

% %%%%%%%%%  define and execute ants command
cmd = [antspath '/antsApplyTransformsToPoints -d 3 -i ' inFile ' -o ' outFile xform_str];
cmd
system(cmd);

 

%%%%%%%%%  read in xformed coords
outCoordsITK = csvread(outFile,1,0);


%%%%%%%%%%  convert back to nifti (as opposed to ITK) format 
outCoords = [outCoordsITK(:,1:2).*-1 outCoordsITK(:,3)];



