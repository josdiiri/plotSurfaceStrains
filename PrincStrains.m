function [PSmagnitude,PSdirection,rotS] = PrincStrains (S,Rm)

% This functions employ a rotation matrix (Rm) to
% (i)   create a strain tensor (e) from vectors entered as XX,YY,ZZ,XY,YZ,XZ
% (ii)  perform a transformation of the strains from xyz to x'y'z' coord
%       system to create a tensor called (eprime)
% (iii) calculate principal strains (D) and (V) from (eprime)
%
% Arguments (INPUT)
%  S  -  1 by 6 raw vector with normal and shear strains entered as
%        [XX, YY, ZZ, XY, YZ, XZ]
%  Rm -  3 by 3 array with the rotation matrix (i.e., direction cosines
%        matrix)
%
% Arguments (OUTPUT)
%  Magnitude       - 3 by 1 array of the magnitude of the Principal
%                    strains (PS), which corresponds to the eigenvalues of
%                    the rotated strain tensor
%  Direction       - 3 by 3 array of the direction of the principal
%                    strains [e.g., direction of 1st PS = Direction(:,1) ]
%  RotStrainTensor - 3 by 3 array with the resultant strain tensor after
%                    rotation
%
% Note that this uses the strain transformation method of Ameen: i.e.,
% the shear strains are divided by 2.


nStrains = size(S,1) ;
PSmagnitude = nan(nStrains,3) ;
PSdirection = nan(nStrains,9) ;
rotS = nan(size(S)) ;

for i = 1:nStrains
    textwaitbar(i, nStrains,'Calculating strains');

    e = [ S(i,1)       S(i,4)/2    S(i,5)/2 ; 
          S(i,4)/2     S(i,2)      S(i,6)/2 ; 
          S(i,5)/2     S(i,6)/2    S(i,3) ] ;
    
    % transforms strain tensor to new coordinate system
    % using the direction cosine matrix Rm
    if Rm==eye(3)
        e1 = e ;
    else
        e1 = Rm * e * Rm';
    end
    rotS(i,:) = [e1(1,1) e1(2,2) e1(3,3) e1(1,2) e1(1,3) e1(2,3)] ;
    
      
    if ~all(isnan(e(:)))
    % calculate PS from original data
    [Vo,Do] = eig(e1) ; % columns of Vo are eigenvectors
    [psMag,indO] = sort(diag(Do),'descend') ;
    psDir = Vo(:,indO) ;
    [~,psDir] = isRightHandedCS(psDir) ;

    PSmagnitude(i,:) = psMag ;
    PSdirection(i,:) = psDir(:) ;
    end
end