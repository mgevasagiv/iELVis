groupAvgCoords=[];
groupLabels=[];
groupIsLeft=[]; 
w=1; W=1; %

% this code created groupAvgCoords, which gives you a matrix with the
% coordiantes of the electrodes from all the patients in MNI dimension

%PATIENTS_INFO is a structure wich containsfor each patient the name of the
%patient and the names of the responsives electrodes

% the code is only for micro because it does not take into consideration
% the depth of the electrode (because for micro I created a probe with only
% one contact)

for Pat_index=[1:14]; %[1:length(subs)];
    
    if ~isempty(PATIENTS_INFO{Pat_index})
    fprintf('Working on Participant %s\n',char(PATIENTS_INFO{Pat_index}.name));
    
elecNames_s=PATIENTS_INFO{Pat_index}.name;

% this first "if" is specific for a patient of mine and the second "if" is
% to add "_micro" to the end of the name in my data
for i=1:size(elecNames_s,2)
if ~strcmp(PATIENTS_INFO{Pat_index}.patient,'d011') & ismember(elecNames_s{i}(end), num2str([0:9]))
    elecNames_s{i}(end)=[];end
if ~ismember(elecNames_s{i}(1),{'L', 'R'}); elecNames_s{i}(1)=[]; end
    elecNames{i}=[elecNames_s{i} '_micro'];
end

fsDir=getFsurfSubDir();
subPath = fullfile(fsDir,char(PATIENTS_INFO{Pat_index}.patient));
elecReconPath=fullfile(subPath,'elec_recon');
load([elecReconPath '/elec_cell'])

for p=1:size(elec_cell,1)
elecLabels{p,1}=elec_cell{p,1}; %name 
eCoords(p,1)=(elec_cell{p,3}); %coordinate x
eCoords(p,2)=(elec_cell{p,4});%y
eCoords(p,3)=(elec_cell{p,5}); %z
end


c=1;
% find the coordinates of the responsive electrodes
  for k=1:length(elecNames)
    
    IND(k)=find(strcmp(upper(elecNames{k}),upper(elecLabels)));
    elec_coor_micro(k,1:3)=eCoords(IND(k),:);
    w=w+1;
    if elecNames{k}(1)=='L'
        elec_coor_micro(k,4)=1;
    else         elec_coor_micro(k,4)=0;
    end
    elecNames{k}(end+1)='1'; % this is the depth but the micro (because Icreated an array of ine contact) it it always 1 
  end
  
  
cfg=[];
cfg.plotEm=0;
cfg.isSubdural=zeros(1,length(elecNames));
cfg.elecCoord=elec_coor_micro;
cfg.elecNames=elecNames;
cfg.isLeft=elec_coor_micro(:,4);

    [avgCoords, ELEC_NAMES, isLeft]=sub2AvgBrain(PATIENTS_INFO{Pat_index}.patient,cfg);
    groupAvgCoords=[groupAvgCoords; avgCoords];
    groupLabels=[groupLabels, ELEC_NAMES];
    groupIsLeft=[groupIsLeft; isLeft];
    clear IND elec_cell elec_coor_micro elecNames elecNames_s elecLabels eCoords MIN MAX minn maxx ampl amp
    end
end

%% to plot the electrodes on MNI brain

c=1;


groupAvgCoords_jitter=groupAvgCoords;

% if you want to create a map from blue to red
[ blueRedColorMap ] = getBlueGreyRedCmap();
cmap = getBlueGreyRedCmap(); 
cmapIndex=linspace(-100,100, size(cmap,1));


gain_norm=% responses/latencies/gain...;
interpolatedRGB=(interp1(cmapIndex,cmap,gain_norm));  %produces an 3-collumn array of RGB values based on color map and effectMagnitude
interpolatedRGB(find(sig==0),:)=0*ones(length(find(sig==0)),3);

% creating differnent size for the spheres according to the num of stim (I
% modified he code to be able to plot differnent sizes for different
% electrodes so at leasst at the beginning you may want to use one size
for i=1:length(num_ofstim_perregion)
    if num_ofstim_perregion(i)<=15
        ELECSIZE_real(i)=2;
    elseif num_ofstim_perregion(i)>15 & num_ofstim_perregion(i)<=30
        ELECSIZE_real(i)=3;
    elseif num_ofstim_perregion(i)>30 & num_ofstim_perregion(i)<=50
        ELECSIZE_real(i)=4;
    else
        ELECSIZE_real(i)=5;
    end
end

cfg=[];
 cfg.clickElec='y';
cfg.elecColors=(interpolatedRGB); %only if you want to plot  values
cfg.elecColorScale=[-100 100]; %same
cfg.elecCoord=[groupAvgCoords_jitter groupIsLeft];
cfg.elecNames=groupLabels;
 cfg.elecUnits='gain (%)';
 cfg.opaqueness=0.3;
 cfg.elecShape='sphere';
cfg.elecSize=ELECSIZE_real';
cfg.edgeBlack=ones(1,79); %in the original code you have to write 1 or 0...
%so all the electrodes contours are in black or not. I changed the code so
%I can plot specific electrodes with a black contours (I didn't use it in
%the figures in the end)
cfg.showLabels='n';
cfg.surfType='PIAL';
  cfg.view='l';
% cfg.title='PT001-2 on Avg. Brain';
cfgOut=plotPialSurf('fsaverage',cfg);
colormap(cmap)

cfg.view='r';
cfgOut=plotPialSurf('fsaverage',cfg);
colormap(cmap)

