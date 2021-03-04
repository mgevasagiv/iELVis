global globalFsDir;
globalFsDir='E:\Data_p\FreeSurferWinMirror';

patients = {'485','486',  '487',  '488', '489', '490', '496', '497', '498', '499', '505',   '510',  '515','520'};
PgroupAvgCoords=[];
PgroupLabels=[];
PgroupIsLeft=[];
SgroupAvgCoords=[];
SgroupLabels=[];
SgroupIsLeft=[];

[subGroup, cmap]  = defineSubGroups_stimAnatomy();

% Load SW/spindle indices
summaryFile = 'E:\Data_p\ClosedLoopDataset\stimEffectResults\allContactsStimResults.mat';
mm = matfile(summaryFile);
corticalStimEffectIndices = mm.corticalStimEffectIndices;
runData = mm.runData;

missingContacts = [];
probe_elec_coord = cell(1,1);
contactID = [];     
for iContact = 1:length(corticalStimEffectIndices.allSWEvent)
    disp(iContact)
    currPt = num2str(corticalStimEffectIndices.pt_vec(iContact));
    if ismember(corticalStimEffectIndices.pt_vec(iContact), subGroup{3})
        continue
    end
    
    % Load new data if pt num changed 
    if iContact == 1 || corticalStimEffectIndices.pt_vec(iContact) ~= corticalStimEffectIndices.pt_vec(iContact-1)
        disp('switching pt')
        disp(currPt)
        subPath = fullfile(globalFsDir,char(currPt));
        elecReconPath=fullfile(subPath,'elec_recon');
        filename = fullfile(elecReconPath, sprintf('%sPostimpLoc.txt',char(currPt)));
        [elec_name, elec_n, x, y, z, Hem, D] = textread(filename,'%s %d %f %f %f %s %s', 200);
        
        % pt index in runData (needed for MACRO file link)
        for iiP = 1:length(runData)
            if strcmp(runData(iiP).patientName(2:end),currPt)
                iPatient = iiP;
            end
        end
    end
    
    % Get the full contact name for each contact
    try
        % load macro montage for area name
        macroMontage = load(runData(iPatient).macroMontageFileName);
        macroMontage = macroMontage.MacroMontage;
        ChNum = corticalStimEffectIndices.chNum_vec(iContact);
        ChArea = macroMontage(corticalStimEffectIndices.chNum_vec(iContact)).Area;
        if ChNum == 1
            ChLabel = sprintf('%s%d',ChArea,ChNum);
        else
            c = true; cnt = 1;
            while(c)
                if ChNum-cnt >= 1
                    A = macroMontage(corticalStimEffectIndices.chNum_vec(iContact)-cnt).Area;
                    if strcmpi(A,ChArea)
                        cnt = cnt + 1;
                    else
                        c = 0;
                    end
                else
                    c = 0;
                end
            end
            ChLabel = sprintf('%s%d',ChArea,cnt);
        end  
    catch
        disp('probe area-name doesn''t match options')
    end
    
    contact_ind = [];
    for ii = 1:length(elec_name)
        if strcmpi(ChLabel(1:end-1),elec_name{ii}) && ...
                strcmpi(ChLabel(end),num2str(elec_n(ii)))
            contact_ind = ii;
        end
    end
    if ~isempty(contact_ind); disp(elec_name{contact_ind}); end
    if isempty(contact_ind); warning('contact missing in mloc file');
        missingContacts = [missingContacts, iContact];
        continue
    else
        elec_coord_pt_space = [x(contact_ind), y(contact_ind), z(contact_ind)];
        cfg=[];
        cfg.plotEm = 0;
        cfg.isSubdural=0; % 0 indicates that an electrode is a depth electrode
        cfg.elecCoord = elec_coord_pt_space;
        cfg.elecNames{1,1} = ChLabel;
        cfg.isLeft = strcmpi(ChLabel(1),'L');
        
        [avgCoords, ELEC_NAMES, isLeft]=sub2AvgBrain(currPt,cfg);
        
        PgroupAvgCoords=[PgroupAvgCoords; avgCoords];
        PgroupLabels=[PgroupLabels, ELEC_NAMES];
        PgroupIsLeft=[PgroupIsLeft; isLeft];
        contactID = [contactID, iContact];
        clear avgCoords ELEC_NAMES isLeft
    end
end         
% Display effect for targeted stimulation patients
pt_vec = corticalStimEffectIndices.pt_vec(~ismember(contactID,subGroup{2}) );
allSWEvent = corticalStimEffectIndices.allSWEvent(~ismember(contactID,subGroup{2}),:);
allSpEvent = corticalStimEffectIndices.allSpEvent(~ismember(contactID,subGroup{2}),:);
allSWSpEvent = corticalStimEffectIndices.allSWSpEvent(~ismember(contactID,subGroup{2}),:);
DIFF =  allSpEvent(:,1)-allSpEvent(:,2);


anatomyInfo.patients = pt_vec;
anatomyInfo.allSWEvent = allSWEvent;
anatomyInfo.allSpEvent = allSpEvent;

anatomyInfo.PgroupAvgCoords = PgroupAvgCoords;
anatomyInfo.PgroupLabels = PgroupLabels;
anatomyInfo.PgroupIsLeft = PgroupIsLeft;

save(fullfile(globalFsDir,'anatomyPlotsData','stimEffectSleepOsc'),'anatomyInfo')

%% Plotting stim and probe on one brain
anatomyInfo = load(fullfile(globalFsDir,'anatomyPlotsData','stimEffectSleepOsc'),'anatomyInfo');
anatomyInfo = anatomyInfo.anatomyInfo;
pt_vec = anatomyInfo.patients;
anatomyInfo.patients = pt_vec;
allSWEvent = anatomyInfo.allSWEvent;
allSpEvent = anatomyInfo.allSpEvent;
DIFF =  allSpEvent(:,1)-allSpEvent(:,2);

figName = sprintf('stimEffects_locations');
f0 = figure('Name', figName,'NumberTitle','off');
% Some WYSIWYG options:
set(gcf,'DefaultAxesFontSize',10);
set(gcf,'DefaultAxesFontName','arial');
set(gcf,'PaperUnits','centimeters','PaperPosition',[0.2 0.2 19 24.7]); % this size is the maximal to fit on an A4 paper when printing to PDF
set(gcf,'PaperOrientation','portrait');
set(gcf,'Units','centimeters','Position', get(gcf,'paperPosition')+[1 1 0 0]);
colormap('jet');

ax1 = axes('position',[0.1,0.1,.2,.2],'units','centimeters');
ax2 = axes('position',[0.4,0.1,.2,.2],'units','centimeters');
ax3 = axes('position',[0.1,0.3,.2,.2],'units','centimeters');
ax4 = axes('position',[0.4,0.3,.2,.2],'units','centimeters');
ax5 = axes('position',[0.1,0.5,.2,.2],'units','centimeters');
ax6 = axes('position',[0.4,0.5,.2,.2],'units','centimeters');
ax7 = axes('position',[0.1,0.7,.2,.2],'units','centimeters');
ax8 = axes('position',[0.4,0.7,.2,.2],'units','centimeters');

N = 64;
% map = colormap('jet');
% map = brewermap(N,'RdYlBu');
map = brewermap(N,'RdBu');
map = flipud(map);
values = linspace(-2,2,N);
[colorBin,~] = discretize(DIFF,values);
colorBin(find(DIFF > values(end))) = length(values);
elecColors = map(colorBin,:);

% brain
cfg=[]; 
cfg.view='li';
cfg.ignoreDepthElec='n';
cfg.opaqueness=0.3;
cfg.elecSize = 2;
cfg.elecColors = elecColors;
cfg.elecColorScale = [0 64];
cfg.showLabels='n';
cfg.title= '';
cfg.edgeBlack = 'n';
cfg.elecCoord = [anatomyInfo.PgroupAvgCoords,anatomyInfo.PgroupIsLeft];  
cfg.elecNames = anatomyInfo.PgroupLabels;
cfg.axis = ax1;
cfgOut=plotPialSurf('fsaverage',cfg);
colorbar(ax1,'off')
cfg.view='ri';
cfg.axis = ax2;
cfgOut=plotPialSurf('fsaverage',cfg);
colorbar(ax2,'off')

cfg=[]; 
cfg.ignoreDepthElec='n';
cfg.opaqueness=0.3;
cfg.elecSize = 3;
cfg.elecColors = elecColors;
cfg.elecColorScale = [0 64];
cfg.showLabels='n';
cfg.title= '';
cfg.edgeBlack = 'n';
cfg.elecCoord = [anatomyInfo.PgroupAvgCoords,anatomyInfo.PgroupIsLeft];  
cfg.elecNames = anatomyInfo.PgroupLabels;
cfg.axis = ax3;
cfg.view='lm';
cfgOut=plotPialSurf('fsaverage',cfg);
cfg.view='rm';
cfg.axis = ax4;
cfgOut=plotPialSurf('fsaverage',cfg);


cfg=[]; 
cfg.ignoreDepthElec='n';
cfg.opaqueness=0.3;
cfg.elecSize = 3;
cfg.elecColors = elecColors;
cfg.elecColorScale = [0 64];
cfg.showLabels='n';
cfg.title= '';
cfg.edgeBlack = 'n';
cfg.elecCoord = [anatomyInfo.PgroupAvgCoords,anatomyInfo.PgroupIsLeft];  
cfg.elecNames = anatomyInfo.PgroupLabels;
cfg.axis = ax5;
cfg.view='lsv';
cfgOut=plotPialSurf('fsaverage',cfg);
cfg.view='rsv';
cfg.axis = ax6;
cfgOut=plotPialSurf('fsaverage',cfg);


brainView.light=[1 0 0];
brainView.hem='r';
brainView.eyes=[45 0]
cfg.view=brainView

cfg=[]; 
cfg.ignoreDepthElec='n';
cfg.opaqueness=0.3;
cfg.elecSize = 3;
cfg.elecColors = elecColors;
cfg.elecColorScale = [0 64];
cfg.showLabels='n';
cfg.title= '';
cfg.edgeBlack = 'n';
cfg.elecCoord = [anatomyInfo.PgroupAvgCoords,anatomyInfo.PgroupIsLeft];  
cfg.elecNames = anatomyInfo.PgroupLabels;
cfg.axis = ax7;
cfg.view='l';
cfgOut=plotPialSurf('fsaverage',cfg);
view(ax7,[-94,27])

cfg.view='r';
cfg.axis = ax8;
cfgOut=plotPialSurf('fsaverage',cfg);
view(ax8,[94,27])

outputFigureFolder = fullfile(globalFsDir,'anatomyPlotsFigures');

a = gcf;
set(f0,'renderer','zbuffer');
% res = 400;
% eval(['print ', [outputFigureFolder,'\',figName], ' -f', num2str(a.Number),sprintf(' -depsc  -r%d',res), '-cmyk' ]); % adding r600 slows down this process significantly!
res = 600;
eval(['print ', [outputFigureFolder,'\',figName], ' -f', num2str(a.Number),sprintf(' -dtiff  -r%d',res), '-cmyk' ]); % adding r600 slows down this process significantly!

figure
figName = 'rendererColorbar';
imagesc(1*ones(1,64),1:64,values)
colormap(map)
cc = colorbar;
cc.TickDirection = 'out';
cc.Ticks = [-2,0,2];
title(sprintf('axis limits- [%f,%f]',values(1),values(end)))
a = gcf;
res = 600;
eval(['print ', [outputFigureFolder,'\',figName], ' -f', num2str(a.Number),sprintf(' -dtiff  -r%d',res), '-cmyk' ]); % adding r600 slows down this process significantly!
