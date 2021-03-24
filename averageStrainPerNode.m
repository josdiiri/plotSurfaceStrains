function oStrain = averageStrainPerNode(nodeID,strainNodeID,strain,method)

nNodes = size(nodeID,1) ;
nVars =  size(strain,2) ;

oStrain = nan(nNodes,nVars) ;

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
    oStrain(j,:) = fn(strain(idxNodes,:),1) ;
end
