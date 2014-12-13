
load musicLinkMatrix.mat linkMatrix entityIndex
load musicLinkDatabase.mat db uLinkInds uLinks
entities = {db.entity};
%% Some book-keeping... 
removeStrList = {'cantautori','cantautore','list of','in music','multi','singer','vocalist','jazz','seven ages of rock',...
    'festival','music of','music scene','band leader','bandleader'};
removeRows = isnan(entityIndex)';
for i = 1:length(removeStrList)
    removeRows = removeRows | cellfun(@(c)~isempty(strfind(c,removeStrList{i})),entities);
end
linkMatrixSmall = linkMatrix(~removeRows,entityIndex(~removeRows));
entitiesSmall = entities(~removeRows);

minLinks = 2;
% while any(sum(linkMatrixSmall) < minLinks)
remove = sum(linkMatrixSmall) < minLinks;
linkMatrixSmall = linkMatrixSmall(~remove,~remove);
entitiesSmall = entitiesSmall(~remove);

%% The GUI
clc
close all;
graphX = linkMatrixSmall;
graphXsymmetric = (graphX+graphX');
degree = sum(graphXsymmetric,2);

degree1 = sum(graphXsymmetric,1);
degree2 = sum(graphXsymmetric,2);

titles = entitiesSmall;
titles = strrep(titles,'_','\_');

minDegree = 20;
gAsymmetric = prtDataTypeGraph(graphX(degree2 > minDegree,degree2 > minDegree),titles(degree2 > minDegree));

g = prtDataTypeGraph(graphXsymmetric(degree > minDegree,degree > minDegree),titles(degree > minDegree));
gui = graphUi;
gui.init(g);
% g = g.optimizePlotLocationsTsne;
% plot(g)
% 
% %%
