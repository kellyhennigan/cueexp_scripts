function [fgOut,o_idx] = pruneMFBFG(subject,lr,fg,roi1,roi2,doPlot,thresh)
% fgOut = pruneDaNaccPathways(fgIn)
% -------------------------------------------------------------------------
% usage: takes in a fiber group and 2 ROIs the fibers are connecting and
% identifies fibers that deviate > 3 voxels from the most extreme x,y, and
% z coords of teh ROIs
%
% also: removes any fibers that go below the AC (based on having a z-coord
% greater than 1)
%
% INPUT:
%   fg - .pdb format pathways
%   roi1 - .mat roi file
%   roi2 - " " roi 2
%   doPlot - plot fgs
%
% OUTPUT:
%   fgOut - fiber group without bad fibers
%   o_idx - index of omitted fibers

%
% NOTES:
%
% author: Kelly, kelhennigan@gmail.com, 01-Apr-2015

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% default is not to plot
if notDefined('doPlot')
    doPlot = 0;
end

fprintf(['\n\n# of fibers before pruning: ' num2str(numel(fg.fibers)) '\n']);

keep_idx=ones(numel(fg.fibers),1); % index of which fibers to keep

%% identify fibers that go under the AC for removal

yend=cellfun(@(x) x(2,end), fg.fibers);
zend=cellfun(@(x) x(3,end), fg.fibers);



%%%%%%%%%%% LEFT SIDE %%%%%%%%%%%
if strcmp(lr,'L')
    
    if strcmp(subject,'cg160715')
        keep_idx(yend<1 & zend<-2)=0;
    elseif strcmp(subject,'ph161104')
        keep_idx(yend<1 & zend<0)=0;
        keep_idx(zend<1)=0;
    else
       keep_idx(yend<1 & zend<0)=0;
    end
    
    %%%%%%%%%%% RIGHT SIDE %%%%%%%%%%%
elseif strcmp(lr,'R')
    
    if strcmp(subject,'bp160213')
        keep_idx(yend<1 & zend<-2)=0;
    else
        keep_idx(yend<1 & zend<0)=0;
    end
    
end % left or right
    
%     %%%%%%%%%%% RIGHT SIDE %%%%%%%%%%%
% elseif strcmp(lr,'R')
%     if strcmp(subject,'er170121') || strcmp(subject,'jh160702') ||  strcmp(subject,'lm160914') ||  strcmp(subject,'rc161007') ||  strcmp(subject,'vb170914') || strcmp(subject,'zm160627')
%         max_thresh(3)=0;
%         
%     elseif strcmp(subject,'dd170610')
%         max_thresh(3)=-1;
%     elseif strcmp(subject,'rl170603') || strcmp(subject,'ts170927')
%         max_thresh(2)=5;
%     end
%     
% end




%% define min and max coords based on min and max ROI coords
min_thresh = min([roi1.coords;roi2.coords])-thresh;
max_thresh = max([roi1.coords;roi2.coords])+thresh;



%%  identify fibers that deviate outside bounding box 

o_idx = find(keep_idx==0);
for i=1:3
    this_idx=cellfun(@(x) any(x(i,:)<min_thresh(i)) || any(x(i,:)>max_thresh(i)), fg.fibers, 'UniformOutput',0);
    o_idx = unique([o_idx; find(vertcat(this_idx{:}))]);
end
o_idx

%% prune away deviant fibers

keep_idx(o_idx) = 0;

fgOut = getSubFG(fg,find(keep_idx),fg.name);

fprintf(['\n\n# of fibers after pruning: ' num2str(numel(fgOut.fibers)) '\n']);

%% If desired, render kept fibers in blue and omitted fibers in red

if doPlot
    if ~isempty(o_idx)
        AFQ_RenderFibers(getSubFG(fg,find(keep_idx==0)),'tubes',0,'color',[1 0 0],'rois',roi1,roi2);
        AFQ_RenderFibers(fgOut,'tubes',0,'color',[0 0 1],'newfig',0);
    else
        AFQ_RenderFibers(fgOut,'tubes',0,'color',[0 0 1],'rois',roi1,roi2);
    end
    %     AFQ_RenderFibers(fgOut,'tubes',0,'color',[0 0 1],'rois',roi1,roi2);
    %     AFQ_RenderFibers(getSubFG(fg,o_idx),'tubes',0,'color',[1 0 0],'newfig',0);
    
end



%%



