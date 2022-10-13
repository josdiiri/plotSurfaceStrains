%% Get the strain data from RPT------------------------------------------%%
% to get the data from the RPT file, run the code below
[strainData, modelData] = loadStrainData_RSOS ;

[~,nameAppend] = fileparts(cd) ;
save(['Strains_' nameAppend '.mat'],'strainData')

%% Get the previously save model and strain data
% to load previously saved data, run the code below
[fName1,path1] = uigetfile('*.mat','Select the strain file') ;
load(fullfile(path1,fName1))

[fName2,path2] = uigetfile('*.mat','Select the 3D model file') ;
modelData = load(fullfile(path2,fName2)) ;

%% Plot the surface strains for individual models -----------------------%%
clc
close all
disp(' ')
disp('***Plotting strains from individual models***')

% USER PARAMETERS ---------------------------------------------------------
% Enter the limits for colormaps (in microstrains)
maxValueDirectStrains    = 600 ;
maxValuePrincipalStrains = 600 ;
maxValueRatio            = 150 ;
% END USER PARAMETERS -----------------------------------------------------


% Prepare the mandible and teeth 3D models --------------------------------
boneModels.Mandible = modelData.Mandible ;
boneModels.Teeth    = modelData.Teeth ;

% rotation matrix to align the model for plotting

% if using human model uncomment the following line
rotationMatrix = [0 0 -1; 0 1 0; 1 0 0]; 

% if using the macaque model, uncomment the following lines
% rotationMatrix = [-0.9958   -0.0382   -0.0828
%                    0.0731   -0.8770   -0.4749
%                   -0.0545   -0.4790    0.8761] ;

%--------------------------------------------------------------------------


% Define the colormaps ----------------------------------------------------
cmPS    = customcolormap([0 0.5 1],[0 0 0; 1 0 0; 1 1 1]) ; % for principal strains
cmDS    = colormap_signed(256,0.5) ; % for direct strains
cmRatio = customcolormap_preset('orange-white-purple') ; % for strain ratios
%--------------------------------------------------------------------------


% Create scale and colormap inputs for plots ------------------------------
% For colormaps
ColorMaps = {cmPS cmPS cmRatio cmDS cmDS cmDS cmDS cmDS cmDS} ;

% For colormap scales
cmLimsPS    = [0 maxValuePrincipalStrains] ;
cmLimsDS    = [-maxValueDirectStrains maxValueDirectStrains] ;
cmLimsRatio = [-maxValueRatio maxValueRatio] ;

ColorMapsAxes = [cmLimsPS; cmLimsPS; cmLimsRatio; ...
    cmLimsDS; cmLimsDS; cmLimsDS; cmLimsDS; cmLimsDS; cmLimsDS] ;
%--------------------------------------------------------------------------


% Define the views of the plots -------------------------------------------
views = [-180 0; 0 0; -90 0; 90 0] ; % for human data
% frontal view, posterior view, left view, right view
%--------------------------------------------------------------------------

% Define the views of the plots -------------------------------------------
labelPos = [1 0.5 0.2]  ; % for human data

%--------------------------------------------------------------------------


% Create the plots --------------------------------------------------------
nStrainModels = size(strainData,2) - 1 ; % number of strain models

strainLabels = {'\epsilon_{1}','|\epsilon_{3}|','|\epsilon_{1}/\epsilon_{3}|',...
    '\epsilon_{xx}','\epsilon_{yy}','\epsilon_{zz}',...
    '\epsilon_{xy}','\epsilon_{xz}','\epsilon_{yz}'} ;

for i = 1:nStrainModels
    disp(['--> Plotting figure ' num2str(i) ' of ' num2str(nStrainModels)])
    
    % Strain labels
    strainModelLabel = strainData{1,i+1} ;
    
    % add the appropriate plate model
    if contains(strainModelLabel,'biplanar','ignoreCase',1)
        plateModels.BiplanarSuperior = modelData.model_Biplanar_Superior ;
        plateModels.BiplanarInferior = modelData.model_Biplanar_Inferior ;
    elseif contains(strainModelLabel,'champy','ignoreCase',1)
        plateModels.Champy = modelData.model_Champy ;
    else
        plateModels = [] ;
    end
    
    % get the strain data of the specific treatment
    strains    = strainData{3,i+1} ;
    psData     = strains.PSmagnitude ; % principal strain magnitudes
    directData = strains.Strain ; % direct strain 
    
    % process the strain magnitudes for plotting
    absPS = abs(psData(:,[1 3])) ; % absolute PS1 and PS3
    PSratio = (abs(psData(:,1)./psData(:,3))-1).*100 ; % PS1/PS3 (percetage difference)
    
    % create data to plot
    data2plot = [absPS PSratio directData] ;
    
    % plot the surface strains
    plotSurfaceStrains(boneModels,plateModels,data2plot,...
        rotationMatrix,ColorMapsAxes,ColorMaps,strainLabels,views,labelPos)
    
    exportgraphics(gcf,[strainModelLabel '.tif'],'resolution',300)
end

%% Plot differences between strain models

clc
close all
disp(' ')
disp('***Plotting strains from comparisons between models***')

% USER PARAMETERS ---------------------------------------------------------
% Enter the limits for colormaps (in microstrains)
maxValue    = 400 ;

% END USER PARAMETERS -----------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMPARISONS %%%%
% This sections define the comparisons to be run among the models. The
% numbers correspond to the location of the data on the Strain cell. Thus,
% each pair of values corresponds to a single comparison
% e.g. Comparisons = [1 2; 3 4] ;

Comparisons = [2 6; 4 6; 3 7; 5 7; 4 2; 5 3] ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Select the parameters to plot
% (1-3: e1,e2, e3 ::: 4-6: e_xx,e_yy,e_zz: 7-9 ::: e_xy, e_xz, e_yz)
vars2plot = [1 3 4:9] ;
nVars = numel(vars2plot) ;

labels = {'\epsilon_{1}','|\epsilon_{3}|',...
    '\epsilon_{xx}','\epsilon_{yy}','\epsilon_{zz}',...
    '\epsilon_{xy}','\epsilon_{xz}','\epsilon_{yz}'} ;

colormapAxes = repmat([-maxValue maxValue],nVars,1) ;
cm = colormap_signed(256,0.5);
ColorMaps = repmat({cm},nVars,1) ;
views = [-180 0; 0 0; -90 0; 90 0] ;

% Prepare the mandible and teeth 3D models --------------------------------
boneModels.Mandible = modelData.Mandible ;
boneModels.Teeth    = modelData.Teeth ;
rotationMatrix = [0 0 -1; 0 1 0; 1 0 0] ; % rotation matrix to align the model
%--------------------------------------------------------------------------

labelPos = [1 0.5 0.2]  ; % for human data

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate the differences
nComparisons = size(Comparisons,1) ;
DiffData = cell(nComparisons,2) ;

for i = 1:nComparisons
    disp(['--> Plotting figure ' num2str(i) ' of ' num2str(nComparisons)])
    
    % indices of the comparisons
    cIdx = Comparisons(i,:) ; 
    
    % get the labels of the comparisons
    figureName = [strainData{1,cIdx(1)} ' - ' strainData{1,cIdx(2)}] ;
    
    % get the data of the specific comparisons
    data1 = strainData{3,cIdx(1)} ;
    data2 = strainData{3,cIdx(2)} ;
    
    % process the data
    dDirectStrain = data1.Strain - data2.Strain ;
    dPS           = abs(data1.PSmagnitude)   - abs(data2.PSmagnitude) ;
    data2plot = [dPS dDirectStrain] ;
    data2plot = data2plot(:,vars2plot) ;
    
    % plot the differences between models
    plotSurfaceStrains(boneModels,[],data2plot,rotationMatrix,colormapAxes,...
        ColorMaps,labels,views,labelPos)
    
    exportgraphics(gcf,[figureName '.tif'],'resolution',300)

end
