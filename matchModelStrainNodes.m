function [selectedNodes,selectedStrainData] = matchModelStrainNodes(model, ...
    nodeData, strainData)

% The 3D model mighht not have exactly the same amount of vertices as the
% model used for the strain anaylsis. This code finds the strain nodes or
% vertices that most closely match the position of the 3D model nodes.

disp(' ')
disp('-----> Reducing the number of points to match the stl model')

% XYZ position of the nodes of the 3D model
modelXYZ = model.Points ;

% find the indices of the nodes of the strain data that matches the points
% of the 3D model
idxT = findClosestPoint(modelXYZ,nodeData.NodesXYZ,1) ;

% get the selected nodes
selectedNodes = nodeData(idxT,:) ;

% find the selected nodes in the strain data
isSelectedNode = ismember(strainData.NodesID(:,1),selectedNodes.NodesID) ;
selectedStrainData = strainData(isSelectedNode,:) ;

disp('... and Done! <------')
