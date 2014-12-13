classdef graphUi < hgsetget
    
    properties
        totalGraph
        currentDisplayedIndices = [];
        currentGraph = [];
        handles
        hcmenu = [];
        editText = [];
    end
    
    methods
        function init(self,totalGraph_,startNode)
            
            title('Search (Bottom Left); Left-click to expand graph; Right-click an artist for options');
            self.totalGraph = totalGraph_;
            self.currentGraph = [];
            self.currentDisplayedIndices = [];
            self.handles = [];
            self.hcmenu = [];
            self.editText = uicontrol('style','edit','units','normalized','position',[0.05 .05 .1 .05],'backgroundcolor',[1 1 1],'callback',@(e,v)self.init(self.totalGraph,get(gcbo,'String')));
            if nargin > 2
                self.updateGraphWith(startNode);
            end
                
            
        end
        
        function updateGraphWith(self,searchNode)
            if isempty(searchNode) || isequal(searchNode,0);
                title('Error: String not found');
                return;
            end

            [~,inds,e] = linkNeighbors(self.totalGraph,searchNode,10);
            if isempty(e)
                title('Error: String not found');
                return;
            end
            
            originalLength = length(self.currentDisplayedIndices(:));
            
            newInds = cat(1,self.currentDisplayedIndices(:),inds(:),e(:));
            nNew = originalLength - length(newInds);
            [~,index] = unique(newInds,'first');        %# Capture the index, ignore the actual values
            newInds = newInds(sort(index));
            self.currentDisplayedIndices = newInds;
            
            tempGraph = self.totalGraph;
            tempGraph = tempGraph.retainNodes(self.currentDisplayedIndices);
            
            if ~isempty(self.currentGraph)
                cPlotLocs = self.currentGraph.internalPlotLocations;
                
                tempGraph.anchorPlotLocations = true(originalLength,1);
                ind = find(strcmpi(searchNode,self.currentGraph.nodeNames));
                if ~isempty(tempGraph.internalPlotLocations)
                    cLoc = tempGraph.internalPlotLocations(ind,:);
                else
                    cLoc = [0 0];
                end
                cLocs = bsxfun(@plus,cLoc,randn(nNew,2)/10);
                tempGraph.internalPlotLocations = cat(1,cPlotLocs,cLocs);
            end
            
            tempGraph = tempGraph.retainNodes(tempGraph.degree > 0);
            tempGraph = tempGraph.optimizePlotLocationsHooke('plotOnIter',0,'maxIters',3000);
            self.currentGraph = tempGraph;
            self.handles = plot(tempGraph);
            self.setContextMenus;
            
            set(gca,'buttondownfcn',@(e,g)handleClick(self,e,g));%
            
        end
        
        function  setContextMenus(self)
            
            self.hcmenu = uicontextmenu;
        end
        
        function handleClick(self,e,g)
            location = g.IntersectionPoint;
            d = prtDistanceEuclidean(location(1:2),self.currentGraph.plotLocations);
            [val,ind] = min(d);
            name = self.currentGraph.nodeNames{ind};
            fprintf('Clicked on %s\n',name);
            self.hcmenu = uicontextmenu;
            switch g.Button
                case 3
                    html1 = sprintf('http://www.amazon.com/s?url=search-alias%%3Daps&field-keywords=%s',name);
                    uimenu(self.hcmenu,'Label',sprintf('Amazon: %s',name),'Callback',@(x,y)web(html1,'-browser'));
                    html2 = sprintf('spotify:search:%s',strrep(name,' ','+'));
                    uimenu(self.hcmenu,'Label',sprintf('Spotify: %s',name),'Callback',@(x,y)web(html2,'-browser'));
                    html3 = sprintf('http://www.wikipedia.com/wiki/%s',name);
                    uimenu(self.hcmenu,'Label',sprintf('Wikipedia: %s',name),'Callback',@(x,y)web(html3,'-browser'));
                    self.hcmenu.Visible = 'on';
                    set(self.hcmenu,'Position',get(gcf,'CurrentPoint'))
                otherwise
                    updateGraphWith(self,name);
            end
        end
    end
end