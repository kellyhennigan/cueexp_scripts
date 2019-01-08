

clear all
close all
clc; 

plotTubes=0; 
nfibers=100;
fg_rad=.1;  % radius of fiber pathway tubes (only matters if plotTubes=1)

cd /Users/kelly/cueexp/data/tm160117

t1=niftiRead('t1.nii.gz');

cd fibers/mrtrix_fa

fg1=fgRead('DAL_naccL_belowAC_autoclean.pdb')
fg2=fgRead('DAL_naccL_aboveAC_autoclean.pdb')
fgc=fgRead('DAL_caudateL_lmax8.tck');
fgp=fgRead('DAL_putamenL_lmax8.tck');

cols=getDTIColors({'nacc','nacc','caudate','putamen'});
cols{2}= [244 101 7]./255;       % orange

h=  AFQ_RenderFibers(fg1,'tubes',plotTubes,'color',cols{1},'numfibers',nfibers);
AFQ_RenderFibers(fg2,'tubes',plotTubes,'color',cols{2},'numfibers',nfibers,'newfig',0);
  AFQ_RenderFibers(fgc,'tubes',plotTubes,'color',cols{3},'numfibers',nfibers,'newfig',0);
  AFQ_RenderFibers(fgp,'tubes',plotTubes,'color',cols{4},'numfibers',nfibers,'newfig',0);
    AFQ_RenderRoi(roi1,[1 0 0],'mesh','surface')     
  AFQ_AddImageTo3dPlot(t1,[-1, 0, 0]);
  delete(h);

  
[msh, fdNii, lightH]=AFQ_RenderFibersOnCortex(fg, segmentation, afq, template, fgnums, colormap)

        AFQ_RenderFibers(getSubFG(fg,o_idx),'tubes',0,'color',[1 0 0],'rois',roi1,roi2);
        AFQ_RenderFibers(fgOut,'tubes',0,'color',[0 0 1],'newfig',0);
    else
        AFQ_RenderFibers(fgOut,'tubes',0,'color',[0 0 1],'rois',roi1,roi2);
    end
    %     AFQ_RenderFibers(fgOut,'tubes',0,'color',[0 0 1],'rois',roi1,roi2);
    %     AFQ_RenderFibers(getSubFG(fg,o_idx),'tubes',0,'color',[1 0 0],'newfig',0);
    
end

