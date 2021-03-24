function makeHeadlight

% adds a front light to all images in the current figure

h = get(gcf,'children') ;
hAxis = findobj(h,'type','Axes') ;

for i = 1:numel(hAxis)
    set(gcf,'CurrentAxes',hAxis(i))
    
    lightHandle = findobj(hAxis(i),'type','light') ;
    
    if isempty(lightHandle)
        camlight('headlight')
        clear('lightHandle')
    else
        for ii = 1:numel(lightHandle)
            camlight(lightHandle(ii),'headlight')
        end
        clear('lightHandle','ii')
    end
    material dull
    lighting gouraud
end