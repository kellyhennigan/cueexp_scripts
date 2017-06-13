function [fgOut,o_idx] = pruneFG_crosshemisphere(fg,doPlot)
% -------------------------------------------------------------------------
% usage: takes in a fiber group in the left or right hemisphere and
% eliminates any pathways that deviate into the contralateral hemisphere. 

%
% INPUT:
%   fg - fiber group loaded using fgRead() (mrVista function)
%   doPlot - 1 to plot fiber group in blue & eliminated pathways in red
%
% OUTPUT:
%   fgOut - fiber group without bad fibers
%   o_idx - index of omitted fibers

%
% NOTES:
%  - this should only be used on fiber groups that are NOT expected to
% cross the midline. 

%  - also: assumes that the coordinates in the fiber group are in some
%  standard space, where left hemisphere coordinates are x < 0 & right
%  hemisphere coords are x > 0
%
% 
% author: Kelly, hennigan@stanford.edu, 11-Apr-2017

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% default is not to plot
if ~exist('doPlot','var') || isempty(doPlot)
    doPlot = 0;
end

fprintf(['\n\n# of fibers before pruning: ' num2str(numel(fg.fibers)) '\n']);


%% define an omit idx based on deviating into the contralateral hemisphere

% get the mean x-coordinate for pathway endpoints 
meanXCoords = mean(cell2mat(cellfun(@(x) [x(1,1),x(1,end)], fg.fibers,'uniformoutput',0)));

% if in left side, eliminate fibers that stray into right hemi 
if meanXCoords(1) < 0 && meanXCoords(2) < 0
   o_idx=cell2mat(cellfun(@(x) any(x(1,:)>1), fg.fibers, 'UniformOutput',0));
   
   
% if in right side, eliminate fibers that stray into left hemi    
elseif meanXCoords(1) > 0 && meanXCoords(2) > 0 
     o_idx=cell2mat(cellfun(@(x) any(x(1,:)<-1), fg.fibers, 'UniformOutput',0));
    
     
% if the fiber group crosses hemispheres, dont eliminate any pathways
else
    fprintf(['\n\nthis fiber group appears to cross hemispheres,\n',...
        'based on mean x-coordinate endpoints: %.1f and %.1f,\n',...
        'so no pathways will be eliminated...\n'],meanXCoords(:));
    o_idx = [];
end


%%%%%%%%%%%%%%%%%%%%%%
%% prune away deviant fibers

fgOut = fg; 

keep_idx=ones(numel(fg.fibers),1);
keep_idx(o_idx) = 0;

fgOut = getSubFG(fg,find(keep_idx),fg.name);

fprintf(['\n\n# of fibers after pruning: ' num2str(numel(fgOut.fibers)) '\n']);

%% If desired, render kept fibers in blue and omitted fibers in red

if doPlot
    AFQ_RenderFibers(fgOut,'tubes',0,'color',[0 0 1]);
    if ~isempty(find(o_idx))
        AFQ_RenderFibers(getSubFG(fg,o_idx),'tubes',0,'color',[1 0 0],'newfig',0);
    end
    title('eliminated pathways are in red')
end





