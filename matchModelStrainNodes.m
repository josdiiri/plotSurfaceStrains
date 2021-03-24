function [selectedNodes,selectedStrainData] = matchModelStrainNodes(model, ...
    nodeData, strainData)

% XYZ position of the nodes of the 3D model
modelXYZ = model.Points ;

% find the indices of the nodes of the strain data that matches the points
% of the 3D model
idxT = findClosestPoint(modelXYZ,nodeData.NodesXYZ,1) ;

% get the selected nodes
selectedNodes = nodeData(idxT,:) ;

% find the selected nodes in the strain data
isSelectedNode = ismember(strainData.nodesID(:,1),selectedNodes.NodesID) ;
selectedStrainData = strainData(isSelectedNode,:) ;
