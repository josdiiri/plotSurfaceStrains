function plotSurfaceStrains(boneModel, plateModels, rotationMatrix, strains,...
    cAxes, ColorMap, labels,viewPos)

if ~isobject(boneModel.Mand)
    boneModel.Mand  = triangulation(boneModel.Mand.faces,...
        boneModel.Mand.vertices) ;
    boneModel.Teeth = triangulation(boneModel.Teeth.faces,...
        boneModel.Teeth.vertices) ;
end

if isempty(plateModels)
    doPlotPlates = false ;
else
    doPlotPlates = true ; 
end
    

nViews = size(viewPos,1) ;
set(figure,'windowstyle','docked','color','w')

nVariables = size(strains,2) ;

for i = 1:nVariables
    cm = ColorMap{i} ;
    for k = 1:nViews % different views
        subplot(nVariables,nViews,(i-1)*nViews+k)
        
        % plot the mandible and teeth surfaces
        trisurf(rotatePatch(boneModel.Mand,rotationMatrix),...
            'FaceVertexCData',strains(:,i),'FaceColor','interp',...
            'edgecolor','none')
        hold on
        trisurf(rotatePatch(boneModel.Teeth,rotationMatrix),...
            'Facecolor',[.9 .9 .9],'edgecolor','none')
        
        % plot plates
        colorPlate = 'k' ;
        if doPlotPlates
            if isobject(plateModels)
                trisurf(rotatePatch(plateModels,rotationMatrix),...
                    'facecolor',colorPlate,'edgecolor','none','facealpha',1) ;
            else
                models = fieldnames(plateModels) ;
                for q = 1:2
                    trisurf(rotatePatch(plateModels.(models{q}),rotationMatrix),...
                        'facecolor',colorPlate,'edgecolor','none','facealpha',1) ;
                end
            end
        end
        
        % define the view
        view(viewPos(k,:));
        axis equal; axis tight; axis vis3d; axis off
        
        % define the colormap
        caxis(cAxes(i,:))
        colormap(gca,cm)
        
        % place label text
        if k==1
            Lims = [xlim; ylim; zlim] ;
            diffLims = sum(Lims,2)./2 ;
            text(Lims(1,2)*1.1,diffLims(2),Lims(3,2),...
                labels{i},'interpreter','tex','fontsize',14,...
                'HorizontalAlignment','right') ; % for occlusal plane X-Y
        end
    end
end
makeHeadlight
figure(gcf)