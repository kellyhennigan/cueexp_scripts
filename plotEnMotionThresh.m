function figH = plotEnMotionThresh(en,en_thresh,ts,ts_str,censorprevTR)
% -------------------------------------------------------------------------
% usage: say a little about the function's purpose and use here
%
% INPUT:
%   en - euclidean norm of motion
%   en_thresh - threshold for determining "bad" movement
%   ts (optional) - time series from the scan. Plotting this along with the
%      euclideam norm can help determine how movement effects the MR signal
%   ts_str (optional) - string identifying time series ts (e.g., 'nacc')
%   censorprevTR (optional) - 1 to censor the previous TR for bad motion
%   volumes, otherwise, 0

% OUTPUT:
%   figH - figure handle
%   if ts is given, then 3 plots will be made: 1) motion plot showing motion
%   threshold, 2) time series, 3) time series with "bad motion" volumes
%   censored.

% NOTES:

% here's a  excerpt from AFNI documentation regarding the use of euclidean
% norm, found here:
% https://afni.nimh.nih.gov/pub/dist/doc/program_help/1d_tool.py.html

% Consideration of the euclidean_norm method:
%
%            For censoring, the euclidean_norm method is used (sqrt(sum squares)).
%            This combines rotations (in degrees) with shifts (in mm) as if they
%            had the same weight.
%
%            Note that assuming rotations are about the center of mass (which
%            should produce a minimum average distance), then the average arc
%            length (averaged over the brain mask) of a voxel rotated by 1 degree
%            (about the CM) is the following (for the given datasets):
%
%               TT_N27+tlrc:        0.967 mm (average radius = 55.43 mm)
%               MNIa_caez_N27+tlrc: 1.042 mm (average radius = 59.69 mm)
%               MNI_avg152T1+tlrc:  1.088 mm (average radius = 62.32 mm)
%
%            The point of these numbers is to suggest that equating degrees and
%            mm should be fine.  The average distance caused by a 1 degree
%            rotation is very close to 1 mm (in an adult human).
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% if ts isn't given, define it as empty
if ~exist('ts','var')
    ts ='';
end
if notDefined('ts_str')
    ts_str ='time series';
end
if notDefined('censorprevTR')
    censorprevTR = 0; 
end


% find the number of volumes that have bad motion
badidx=find(abs(en)>en_thresh); 
nBad=numel(badidx);

if censorprevTR==1
    badidx=unique([badidx;badidx-1]);
end


% plot
figH = figure('Visible','off');
% figH = figure
set(gcf,'Color','w','InvertHardCopy','off','PaperPositionMode','auto');

% make 3 plots if ts is given, otherwise plot just the euclidean norm
if ~isempty(ts)
    subplot(3,1,1)
end

hold on
plot(en,'color',[.15 .55 .82],'linewidth',1.5)
set(gca,'box','off');
plot(ones(numel(en),1).*en_thresh,'color',[.86 .2 .18]);
ylabel('head motion (in ~mm units)','FontSize',8)

title(sprintf('# of bad motion vols: %d; %% of data: %.1f',nBad,100.*(nBad./numel(en))),'FontSize',10)

if ~isempty(ts)
    subplot(3,1,2)
    plot(ts,'color',[.16 .63 .6],'linewidth',1.5)
    set(gca,'box','off');
    ylabel('MR signal','FontSize',8)
    xlabel('TRs','FontSize',8)
    title([ts_str ' time series'],'FontSize',10)
    
    tscensored=ts;
    tscensored(badidx)=0;
    
    subplot(3,1,3)
    plot(tscensored,'color',[.16 .63 .6],'linewidth',1.5)
    set(gca,'box','off');
    ylabel('MR signal','FontSize',8)
    xlabel('TRs','FontSize',8)
    title([ts_str ' time series (with bad motion vols censored)'],'FontSize',10)
    
    
end

