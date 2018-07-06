function baseDir = getCueBaseDir()
% -------------------------------------------------------------------------
% usage: function to get path to cue experiment base directory, which is
% different depending on which computer this function is running on
% 
% OUTPUT:
%   baseDir - string specifiying data directory path
% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cName=getComputerName;

if strcmp(cName,'cnic2')               % cni server
    baseDir = '/home/hennigan/cueexp';
else                                   % assume its my laptop
    baseDir = '/Users/kelly/cueexp';
end
