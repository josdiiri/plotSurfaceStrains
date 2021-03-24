function newPatch = rotatePatch(Patch,RotMatrix)

if isobject(Patch)
    if all(size(RotMatrix)==4) || size(RotMatrix,2)==16
        newPoints = rotateT(Patch.Points,RotMatrix) ;
    else
        newPoints = (RotMatrix*Patch.Points')' ;
    end
    newPatch = triangulation(Patch.ConnectivityList,newPoints) ;
else    
    newPatch = Patch ;
    
    if all(size(RotMatrix)==4) || size(RotMatrix,2)==16
        newPatch.vertices = rotateT(Patch.vertices,RotMatrix) ;
    else
        newPatch.vertices = (RotMatrix*Patch.vertices')' ;
    end
end