cd ~/cueexp/data/fgMeasures/mrtrix_fa/

% get SuperFiber info 

load('DAL_naccL_belowAC_dil2_autoclean.mat')

node = 60; 
subjidx=find(strcmp(subjects,'jh160702'));

cd ../..
cd data/jh160702/dti96trilin/
[dt,t1]=dtiLoadDt6('dt6.mat');
cd bin
b0=niftiRead('b0.nii.gz');

xyz=round(SuperFibers(subjidx).fibers{1}(:,node)');

ijk=round(mrAnatXformCoords(b0.qto_ijk,xyz));

t=squeeze(dt.dt6(ijk(1),ijk(2),ijk(3),:))
Q = [t(1), t(4), t(5);
t(4), t(2), t(6);
t(5), t(6), t(3)];

N=60;
newFig=1;
col=[];
AFQ_RenderEllipsoid(Q,xyz,N,col,newFig)
camlight; lighting phong; material shiny;
set(gca, 'Projection', 'perspective');
xlabel('x')
ylabel('y')
zlabel('z')


%% goal is to evaluate the correspondence between
% 1) the principal diffusion direction (direction of AD; principal eigenvector) 
% and the MFB trajectory, and 
% 2) the degree of variability across subjects in this metric