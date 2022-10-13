function [NodeData,StrainData] = readRPTfiles(PathFile)

% open the formatted text
fid = fopen(fullfile(PathFile),'r') ;

% read the first introductory text
introText1 = textscan(fid,'%s',16,'Delimiter','\n') ;

% read the node data
nodeData = textscan(fid,'%s %f %f %f %f %f %f %f',...
    'delimiter',' ','MultipleDelimsAsOne',1) ;
NodesID = cell2mat(nodeData(2)) ;
NodesXYZ = cell2mat(nodeData(3:5)) ;
NodesLabels = nodeData{:,1} ;
if size(NodesLabels,1)~=size(NodesXYZ,1)
    NodesLabels(end)=[] ;
end
NodeData = table(NodesLabels,NodesID,NodesXYZ,...
    'VariableNames',{'NodesLabel','NodesID','NodesXYZ'}) ;

% read the second introductory text
introText2 = textscan(fid,'%s',2,'Delimiter','\n') ;

% read the strain data
strainData = textscan(fid,'%s %f %f %f %f %f %f %f %f',...
    'delimiter',' ','MultipleDelimsAsOne',1) ;
BricksNodesID = cell2mat(strainData(2:3)) ;
Strain = cell2mat(strainData(4:end)) ;
StrainLabels = strainData{:,1} ;

% check the number of columns with actual data
isEmptyColumn = all(isnan(Strain),1) ;

if sum(isEmptyColumn)==0 % all columns have data (i.e., direct strains)
    tmpStrain = Strain ;
    varDesc = {'','','variables are e11,e22,e33,e12,e23,e13'} ;
elseif sum(isEmptyColumn)==5 % 1 column has data (von Mises stress)
    tmpStrain = Strain(:,1) ;
    varDesc = {'','','variables are e_vonMises'} ;
elseif sum(isEmptyColumn)==2 % 4 columns have data (principal strains)
    tmpStrain = Strain(:,[1 3 4]) ;
    varDesc = {'','','variables are e1,e2,e3'} ;
end

StrainData = table(BricksNodesID(:,1),BricksNodesID(:,2),tmpStrain,...
    'VariableNames',{'NodesID','AttachedElement','Strain'}) ;
StrainData.Properties.VariableDescriptions = varDesc ;

% close the file
fclose(fid) ;
