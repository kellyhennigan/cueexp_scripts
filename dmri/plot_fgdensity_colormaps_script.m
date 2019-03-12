% plot out color map

clear all
close all

% get experiment-specific paths & cd to main data dir
p = getCuePaths;
dataDir=p.data;
cd(dataDir);

outDir = fullfile(p.figures,'fg_densities','colormaps');

if ~exist(outDir,'dir')
    mkdir(outDir)
end


targets={'nacc','nacc','caudate','putamen'};

fgStrs={'belowAC','aboveAC','',''};

%%

cd(outDir)

j=1;
for j=1:numel(targets)
cols=getDTIFDColors(targets{j},fgStrs{j});

fig=setupFig
image(1:8)
colormap(cols{1})


print(gcf,'-dpng','-r300',[targets{j} fgStrs{j}]);

end
