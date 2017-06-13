% plot roi time courses by subject 

% this will produce a figure with a timecourse plot for each subject

clear all
close all

%%%%%%%%%%%%%%% ask user for info about which subjects, roi, etc. to plot
p = getCuePaths();
dataDir = p.data;
figDir = p.figures;


task = 'cue';
group = 'patients';
[subjects,gi]=getCueSubjects(task,group);


% roi to process
roiName = 'nacc_desai';


tcDir = ['timecourses_' task '_afni_woOutliers' ];
% tcDir = ['timecourses_' task '_afni' ];

nTRs = 10; % # of TRs to plot
TR = 2; % 2 sec TR
t = 0:TR:TR*(nTRs-1); % time points (in seconds) to plot
xt = t; %  xticks on the plotted x axis

useSpline = 0; % if 1, time series will be upsampled by TR*10


saveFig = 1; % 1 to save out figures

numberFigs = 0; % 1 to number the figs' outnames (useful for viewing in Preview)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%r
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% get task specific conditions/groups to plot

% plotGroups & plotStims should be cell arrays specifying
% the desired groups and stims to plot in figures. plotStimStrs gives a
% string that describes the stim in a given plot. Each row of the cell
% array should have info for a single figure, e.g.:

% % % plotGroups = {'controls';
% % %     'controls patients'};
% % %
% % % plotStims = {'alcohol drugs food neutral';
% % %     'drugs'};

% would be for making 2 figures: the 1st would plot alc, drugs, etc. for
% just the controls and the 2nd would plot drugs for controls vs patients.

% stim = 'drugs-neutral';
% group = 'patients';

stim = 'drugs';
group = 'patients';


stimStr = stim;


%% get ROI time courses


inDir = fullfile(dataDir,tcDir,roiName); % time courses dir for this ROI

if strfind(stim,'-')
    stim1 = stim(1:strfind(stim,'-')-1);
    stim2 = stim(strfind(stim,'-')+1:end);
    [tc1,subjects]=loadRoiTimeCourses(fullfile(inDir,[stim1 '.csv']),group,1:nTRs);
    [tc2,~]=loadRoiTimeCourses(fullfile(inDir,[stim2 '.csv']),group,1:nTRs);
    tc=tc1-tc2;
else
    stimFile = fullfile(inDir,[stim '.csv']);
    [tc,subjects]=loadRoiTimeCourses(stimFile,group,1:nTRs);
end
 
%%%%%%
% put each subjects time course into its own cell in an array 
tc=mat2cell(tc,[ones(size(tc,1),1)],[size(tc,2)]); 


% make sure all the time courses are loaded
if any(cellfun(@isempty, tc))
    tc
    error('\hold up - time courses for at least one stim/group weren''t loaded.')
end



n = numel(subjects);


if (useSpline) %  upsample time courses
    t_orig = t;
    t = t(1):diff(t(1:2))/10:t(end); % upsampled x10 time course
    tc = cellfun(@(x) spline(t_orig,xt,t), tc, 'uniformoutput',0);
end


%% set up all plotting params

% fig title
figtitle = [strrep(roiName,'_',' ') ' response to ' stim ' by subject'];

% x and y labels
xlab = 'time (in seconds) relative to cue onset';
ylab = '%\Delta BOLD';


% labels for each line plot (goes in the legend)
pLabels = subjects;


%%%%%% colors: 

% line colors - Nx3 matrix of rgb vals (1 row/subject)
% cols = solarizedColors(n);

% to do colors by relapse:  
[ri,~]=getCueRelapseData(subjects);
 cols3 = getCueExpColors(3);
 cols = repmat(cols3(3,:),numel(subjects),1); % nan vals are green 
 cols(ri==1,:)=repmat(cols3(2,:),numel(ri(ri==1)),1); %relapse vals is red
 cols(ri==0,:)=repmat(cols3(1,:),numel(ri(ri==0)),1); % non-relapse is blue

 


% filename, if saving
savePath = [];
if saveFig
  
    outDir = fullfile(figDir,tcDir,roiName);
    if ~exist(outDir,'dir')
        mkdir(outDir)
    end
      % nomenclature: roiName_stimStr_groupStr
    outName = [roiName '_' stimStr '_by subject'];
    savePath = fullfile(outDir,outName);
end


%% finally, plot the thing!

fprintf(['\n\n plotting figure: ' figtitle '...\n\n']);

   
[fig,leg]=plotNiceLines(t,tc,{},cols,[],pLabels,xlab,ylab,figtitle,savePath);
set(leg,'Location','EastOutside')
if savePath
    print(gcf,'-dpng','-r300',savePath);
end

fprintf('done.\n\n')



