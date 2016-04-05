function homeDir = getHomeDir()
% -------------------------------------------------------------------------
% usage: function to get path to cue experiment base directory, which is
% different depending on which computer this function is running on
% 
% OUTPUT:
%   homeDir - string specifiying home directory path
% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cName=getComputerName;

if strcmp(cName,'cnic2')               % cni server
    homeDir = '/home/hennigan';
else                                   % assume its my laptop
    homeDir = '/Users/Kelly';
end
