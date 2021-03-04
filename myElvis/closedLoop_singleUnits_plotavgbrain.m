global globalFsDir;
globalFsDir='E:\Data_p\FreeSurferWinMirror';

outputFigureFolder = fullfile(globalFsDir,'anatomyPlotsFigures');
outputFigureFolder2 = 'E:\Dropbox\ILLUSTRATOR\Figure3\links\SU examples';
figName = sprintf('phaseLocking_example_anatomy');

% Example 1 - Fig 3 phase-locking example
ptNum = '487';
cfg=[]; 
cfg.view='omni';
cfg.surfType='pial';
cfg.ignoreDepthElec='n';
cfg.opaqueness=0.3;
cfg.showLabels='n';
cfg.elecColors = [0 0 1; 0 0 0];
cfg.elecColorScale = [0 64];
cfg.elecNames = {'RAH1','ROF2'};
cfg.title=ptNum;
cfgOut=plotPialSurf(ptNum,cfg);

a = gcf;
% Some WYSIWYG options:
set(gcf,'DefaultAxesFontSize',8);
set(gcf,'DefaultAxesFontName','arial');
colormap('jet');
set(gcf,'name',figName);

set(gcf,'renderer','zbuffer');
res = 600;
eval(['print ', [outputFigureFolder,'\',figName], ' -f', num2str(a.Number),sprintf(' -dtiff  -r%d',res), '-cmyk' ]); % adding r600 slows down this process significantly!
copyfile([outputFigureFolder,'\',figName,'.tif'], outputFigureFolder2)
