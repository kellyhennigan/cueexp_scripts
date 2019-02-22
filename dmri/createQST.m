function createQST(qsDir,templatefile,volPaths,fgPaths,fgColors,vis_idx,outfilename)
% -------------------------------------------------------------------------
% usage: create a quench state file (.qst)
%
% INPUT:
%   qsDir - directory to save out quench state file
%   templatefile - .qst template file (must be in qsDir)
%   volPaths - cell array of strings specifying paths to volume files to
%       load (.nii.gz)
%   fgPaths - " " fiber files to load (.pdb)
%   fgPaths - index of 1 and 0 indicating whether the corresponding fg is
%       visible
%   fgColors - Nx3 array of RGB values corresponding to input fiber groups
%
% OUTPUT: saves out a .qst file to directory qsDir
%
% author: Kelly, kelhennigan@gmail.com, 12-Mar-2015

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% set up

cd(qsDir);

% if visible index isn't given, make all input FGs visible
if notDefined('vis_idx')
    vis_idx = ones(numel(fgPaths),1);
end

% get some info about the fiber files
fibernumline = [];
for i=1:numel(fgPaths)
    i
    fg=mtrImportFibers(fgPaths{i});
    fgfilenames{i} = [fg.name '.pdb'];
    nFibers(i)=numel(fg.fibers);
    fibernumline = [fibernumline, repmat(i,1,nFibers(i))]; % for single fiber assignment line
end

a=1; % if an out_fname file already exists, assign a new name
while (exist(outfilename,'file'))
    oldoutfilename=outfilename;
    [~,fstr]=fileparts(oldoutfilename);
    outfilename = [fstr '_' num2str(a) '.qst'];
    fprintf(['\noutfile ' oldoutfilename ' already exists;\nchanging name to ' outfilename '\n\n']);
    a=a+1;
end


% open outfile for writing & template file for reading
fclose('all'); % close any open files
fid=fopen(outfilename,'a'); % create this file & set it up for writing
fid1=fopen(templatefile);


%% do it

% print out header info
tline = fgets(fid1);
while ~strncmp(tline,'--- Volumes ---',15)
    fprintf(fid,'%s',tline);
    tline = fgets(fid1);
end

% print out volume info
fprintf(fid,'--- Volumes ---\n');
fprintf(fid,'%s%d\n','Num Volumes :',numel(volPaths));
for i=1:numel(volPaths)
    fprintf(fid,'%s\n',volPaths{i});
end
fprintf(fid,'\n'); % blank row


% print out fg info
fprintf(fid,'--- PDB Info ---\n');
fprintf(fid,sprintf('Num PDB''s: %d\n',numel(fgPaths)));
for i=1:numel(fgPaths)
    fprintf(fid,'%s\n',fgPaths{i});
end


% print out pathway assignment info
fprintf(fid,'--- Pathway Assignment ---\n');
fprintf(fid,'Locked: 1\n');
fprintf(fid,'Selected Group: 1\n');
fprintf(fid,sprintf('Num Assigned: %d\n',sum(nFibers)));
fprintf(fid,repmat('%d ',1,sum(nFibers)),fibernumline);


% print out pathway groups info
nFGs = numel(fgPaths)+5;  % arbitrary decision - change if necessary
fprintf(fid,'--- Pathway Groups ---\n');
fprintf(fid,'Num Groups: %d\n',nFGs);
printOutFgInfo(fid,'Trash',[.5 .5 .5],1,1)
for i=1:numel(fgPaths)
    printOutFgInfo(fid,fgfilenames{i},fgColors(i,:),vis_idx(i),1);
end
for i=numel(fgPaths)+1:nFGs-1
    printOutFgInfo(fid,['FG ' num2str(i)],rand(1,3),1,1);
end
fprintf(fid,'\n'); % blank row

% scroll down through template file until 'camera position' is reached
while ~strncmp(tline,'Camera Position',15)
    tline = fgets(fid1);
end

% once its reached, copy the rest of the template file line by line until
% end of file (feof)
while ~feof(fid1)
    fprintf(fid,'%s',tline);
    tline = fgets(fid1);
end

fclose('all');  % close all open files

end

function printOutFgInfo(fid,Name,Color,Visible,Active)

if notDefined('fid')
    error('file identifier must be given');
end
if notDefined('Name')
    Name = 'FG X';
end
if notDefined('Color')
    Color = rand(1,3);
end
if notDefined('Visible')
    Visible = 1;
end
if notDefined('Active')
    Active = 1;
end

% print name line
fprintf(fid,'Name: %s\n',Name);

% print color line
if isnumeric(Color)
    fprintf(fid,'Color: %1.3f %1.3f %1.3f 1\n',Color);
elseif ischar(Color)
    fprintf(fid,'Color: %s 1\n',Color);
else
    error('Color input must be either numeric or a string');
end

% print visible and active lines
fprintf(fid,'Visible: %s\n', num2str(Visible));
fprintf(fid,'Active: %s\n', num2str(Active));

fprintf(fid,'\n'); % blank row

end




