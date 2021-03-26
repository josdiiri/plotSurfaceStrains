function [StrainOutput, modelData] = loadStrainData

% This function is used to read and process the strain data from the RPT
% files.

%% load the 3D MODEL
[fName1,path1] = uigetfile('*.mat','Select the file with the 3D models') ;
modelData = load(fullfile(path1,fName1)) ; % loaded as modelData

%% Select the STRAIN data

% Here you should select all the models that you want to compare
[Files,pathName] = uigetfile('*.rpt','Select the strain file(s)',...
    'multiselect','on') ;

% prepare the output files
Labels = {'File';'Nodes';'Strains'} ;
nFiles = numel(Files) ;
StrainOutput = cell(3,nFiles+1) ;
StrainOutput(:,1) = Labels ;

clc
disp('Loading and processing the RPT (strain) files')

% get the data    
for i = 1:nFiles
    fileName = Files{i} ;
    
    disp(' ')
    disp(['--> Processing file ' num2str(i) ' of ' num2str(nFiles)])
    disp(['File: "' fileName '"'])
    
    % read the RPT files and extract the data
    [NodesXYZ,NodesID,strains,strainNodesID,NodesLabels] = ...
        readRPTfiles(fullfile(pathName,fileName)) ;
    % NodesXYZ is a n1*3 matrix of the XYZ position of the nodes of the model
    % NodesID is a n1*1 vector of the ID number of the nodes
    % strains is a n2*6 matrix of the direct strains
    %           (e_11,e_22,e_33,e_12,e_13,e_23)
    % strainNodesID is a n2*2 matrix of the ID of the nodes and the ID of
    %           the individual elements attached to each node
    % NodesLabels is a n1*1 vector with the labels identifying the material
    %           of the model
    
    correctionFactor = 1e6 ; % correction factor from strains to microstrains
    strainData = table(strainNodesID,strains.*correctionFactor,...
        'VariableNames',{'nodesID','directStrain'}) ;
    
    % initialize the output table
    nodeData = table(NodesID,NodesLabels,NodesXYZ) ;
        
    % reduce the data so that we only work with the strain data of the
    % nodes that matches the nodes of the surface model
    [redNodeData,redStrainData] = matchModelStrainNodes(modelData.Mand, ...
        nodeData, strainData, 1) ;

    % calculate the principal strains
    [PSmag,PSdir] = PrincStrains(redStrainData.directStrain, eye(3)) ;
    
    % Because there are multiple elements attached per node, we need to
    % calculate either the mean or the median so that we can have just one
    % point per node
    statistic = 'median' ;
    averageStrain = averageStrainPerNode(redNodeData.NodesID,...
        redStrainData.nodesID(:,1),...
        [redStrainData.directStrain PSmag PSdir], statistic) ;
    
    % write the output table
    outputTable = table(redNodeData.NodesID,averageStrain(:,1:6),averageStrain(:,7:9),...
        averageStrain(:,10:18),'VariableNames',{'nodesID','directStrain','PSmag','PSdir'}) ;

    StrainOutput(1,i+1) = {fileName(1:end-4)} ;
    StrainOutput(2,i+1) = {redNodeData} ;
    StrainOutput(3,i+1) = {outputTable} ;
end