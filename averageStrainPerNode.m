function averageStrain = averageStrainPerNode(nodeID,strainNodeID,strain,method)

% Each node is associated to multiple elements, so this code calculates an
% average value each individual node. 

nNodes = size(nodeID,1) ;
nVars =  size(strain,2) ;

averageStrain = nan(nNodes,nVars) ;

if any(strcmpi(method,{'mean','average'}))
    fn = @mean ;
elseif strcmpi(method,'median')
    fn = @median ;
elseif strcmpi(method,'mode')
    fn = @mode ;
end


for j = 1:nNodes
    textwaitbar(j, nNodes,'Averaging the strains');
    idxNodes = strainNodeID==nodeID(j) ;
    averageStrain(j,:) = fn(strain(idxNodes,:),1) ;
end
