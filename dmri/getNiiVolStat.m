function desiredStat = getNiiVolStat(vol,xform,desiredStatStr)
% -------------------------------------------------------------------------
% usage: get some useful info about a nifti file. Meant to be a shortcut
% for getting info about fiber density files. Same as getNiiVolStat except
% takes a 3d volume of data and an xform instead of a nifti struct.

% INPUT:
%   vol - 3d volume of data 
%   xform - 4x4 xform from img to acpc space. If not given, returned
%               coords will be in img space. 
%   desiredStatStr - string specifying what stat is desired. Options are listed
%             below. 

% OUTPUT:
%   desiredStat - requested stat.



% author: Kelly, kelhennigan@gmail.com, 26-Apr-2015

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%



% if no xform is given, return img coords
if notDefined('xform')
    xform = eye(4);  xform(4,:)=1;
end


%% get the desired stat

switch lower(desiredStatStr)

case 'com'  % return center of mass
    
    desiredStat = mrAnatXformCoords(xform,centerofmass(vol)); 
    

case 'max'  % return acpc coords of max voxel 

    [max_val,idx]=max(vol(:)); 
    [i j k]=ind2sub(size(vol),idx);
    max_coords = mrAnatXformCoords(xform,[i j k]);
    
    desiredStat = [max_coords,max_val];
    
    
case 'mean'  % return mean acpc coords 

    [i j k]=ind2sub(size(vol),find(vol));
    desiredStat = round(mrAnatXformCoords(xform,mean([i j k])));

    
    
end

   
    

















