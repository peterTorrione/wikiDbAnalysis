%%
clear all;
lineCount = 1;
linkFile = 'C:\Users\pete\Dropbox (CoVar)\data\wikipedia\linkfile_2014_12_06_music_weasel.txt';

f = fopen(linkFile,'r');

lineCount = 1;
while ~feof(f)
    cLine = fgetl(f);
    trueInd = strfind(cLine,':Band:');
    entity = strtrim(lower(cLine(1:trueInd-1)));
    linkList = cLine(trueInd+6:end);
    linkList = strrep(linkList,'"','''');
    linkStruct = regexp(linkList,'''(?<link>[^('',)]*)'', ','names');
    lastLink = regexp(linkList,'''(?<link>[^('',)]*)''\]','names');
    linkStruct = cat(2,linkStruct,lastLink);
    
    linkCell = {linkStruct.link};
    linkCell = strtrim(linkCell);
    linkCell = linkCell(~strcmpi(linkCell,']'));
    linkCell = linkCell(~strcmpi(linkCell,''));
    db(lineCount).linkCell = lower(linkCell);
    db(lineCount).entity = entity;
    if lineCount == 1
        db = repmat(db,150000,1);
    end
    lineCount = lineCount + 1;
    if ~mod(lineCount,100)
        disp(lineCount);
    end
end
fclose(f);

remove = false(length(db),1);
for i = 1:length(db);
    remove(i) = ~isempty(strfind(lower(db(i).entity),'award')) || ~isempty(strfind(lower(db(i).entity),'tour'));
    if ~mod(i,10000)
        disp(i);
    end
end
db = db(~remove);

[~,ia] = unique(lower({db.entity}));
db = db(ia);


%%
linkText = cat(2,db.linkCell);
[uLinkInds,uLinks] = prtUtilStringsToClassNumbers(linkText);

%%
linkMatrix = spalloc(length(db),length(uLinks),550000);
entities = {db.entity};
entityIndex = nan(length(db),1);
start = 1;

for dbInd = 1:length(db);
    
    entityInd = find(strcmpi(db(dbInd).entity,uLinks));
    if ~isempty(entityInd)
        entityIndex(dbInd) = entityInd;
    end
    
    db(dbInd).linkVec = uLinkInds(start:start+length(db(dbInd).linkCell)-1);
    start = start + length(db(dbInd).linkCell);
    
    cLinks = db(dbInd).linkVec;
    cuLinkInds = unique(cLinks);
    if length(cuLinkInds) > 1
        c = hist(cLinks,cuLinkInds);
    else
        c = 1;
    end
    linkMatrix(dbInd,cuLinkInds) = linkMatrix(dbInd,cuLinkInds) + c;

    if ~mod(dbInd,1000)
        disp(dbInd);
    end
end

save musicLinkMatrix_2014_12_05.mat linkMatrix entityIndex
save musicLinkDatabase_2014_12_05.mat db uLinkInds uLinks

%%

load musicLinkMatrix_2014_12_05.mat linkMatrix entityIndex
load musicLinkDatabase_2014_12_05.mat db uLinkInds uLinks
% load musicLinkMatrix.mat linkMatrix entityIndex
% load musicLinkDatabase.mat db uLinkInds uLinks
entities = {db.entity};
%%
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

%%
clc
close all;
graphX = linkMatrixSmall;
graphXsymmetric = (graphX+graphX')./2;
degree = sum(graphXsymmetric,2);

degree1 = sum(graphXsymmetric,1);
degree2 = sum(graphXsymmetric,2);

titles = entitiesSmall;
titles = strrep(titles,'_','\_');

minDegree = 50;
gAsymmetric = prtDataTypeGraph(graphX(degree2 > minDegree,degree2 > minDegree),titles(degree2 > minDegree));

vSmallGraph = graphXsymmetric(degree > minDegree,degree > minDegree);
vSmallTitles = titles(degree > minDegree);
g = prtDataTypeGraph(vSmallGraph,vSmallTitles);
gui = graphUi;
gui.init(g);
% g = g.optimizePlotLocationsTsne;
% plot(g)
% 
%%
nNeighbors = 10;
neighbors = nan(size(vSmallGraph,1),nNeighbors);
inds = nan(size(vSmallGraph,1),nNeighbors);
vSmallGraphObj = prtDataTypeGraph(vSmallGraph,vSmallTitles);
for i = 1:size(vSmallGraph,1);
    [~,neighbors(i,:)] = linkNeighbors(vSmallGraphObj,i,nNeighbors);
    disp(i)
end

%%
save smallGraphData.mat vSmallGraph inds vSmallTitles

%%
load smallGraphData.mat vSmallGraph vSmallNeighbors vSmallTitles
vvSmallGraphObj = prtDataTypeGraph(vSmallGraph*2,vSmallTitles);
wikiGraphToFile('testGraphSmall.txt',vvSmallGraphObj,vSmallNeighbors)

%%

d = sum(vSmallGraph,2);
retain = d > 100;
vvSmallGraph = vSmallGraph(retain,retain);
vvSmallTitles = vSmallTitles(retain);

nNeighbors = 5;
neighbors = nan(size(vvSmallGraph,1),nNeighbors);
vvSmallGraphObj = prtDataTypeGraph(vvSmallGraph*2,vvSmallTitles);
for i = 1:size(vvSmallGraph,1);
    [~,neighbors(i,:)] = linkNeighbors(vvSmallGraphObj,i,nNeighbors);
    disp(i)
end


%%
wikiGraphToFile('testOutVerySmall.txt',vvSmallGraphObj,neighbors)