function [NodesXYZ,NodesID,Strain,BricksNodesID,NodesLabels,StrainLabels] = ...
    readRPTfiles(PathFile)

% Function that reads the RPT files 

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

% read the second introductory text
introText2 = textscan(fid,'%s',2,'Delimiter','\n') ;

% read the strain data
strainData = textscan(fid,'%s %f %f %f %f %f %f %f %f',...
    'delimiter',' ','MultipleDelimsAsOne',1) ;
BricksNodesID = cell2mat(strainData(2:3)) ;
Strain = cell2mat(strainData(4:end)) ;
StrainLabels = strainData{:,1} ;

if all(isnan(Strain(:,5)))
    Strain = Strain(:,[1 3 4]) ;
end

% close the file
fclose(fid) ;