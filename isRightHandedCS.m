function [isRight,newCS] = isRightHandedCS(CS)
% This code makes sure that a coordinate system is a right-handed
% coordinate system. 
% Each row represents an axis

newCS = CS ;

axis3 = cross(CS(1,:),CS(2,:)) ;

if sign(axis3)~=sign(CS(3,:))
    isRight = false ;
    newCS(3,:) = -CS(3,:) ;
else
    isRight = true ;
end