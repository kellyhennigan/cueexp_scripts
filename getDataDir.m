function data_dir = getDataDir()
% -------------------------------------------------------------------------
% usage: function to get path to cue experiment data directory, which is
% different depending on which computer this function is running on
% 
% OUTPUT:
%   data_dir - string specifiying data directory path
% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cName=getComputerName;

if strcmp(cName,'cnic2')               % cni server
    data_dir = '/home/hennigan/cueexp/data';
else                                       % assume its my laptop
    data_dir = '/Users/Kelly/cueexp/data';
end
