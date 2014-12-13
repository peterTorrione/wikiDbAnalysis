%%
clear all;
lineCount = 1;
linkFile = 'C:\Users\pete\Dropbox (CoVar)\data\wikipedia\linkfile.txt';

f = fopen(linkFile,'r');

lineCount = 1;
while ~feof(f)
    cLine = fgetl(f);
    trueInd = strfind(cLine,':True:');
    entity = strtrim(lower(cLine(1:trueInd-1)));
    linkList = cLine(trueInd+6:end);
    linkStruct = regexp(linkList,'''(?<link>[^('',)]*)','names');
    linkStruct = linkStruct(1:2:end);
    linkCell = {linkStruct.link};
    linkCell = strtrim(linkCell);
    linkCell = linkCell(~strcmpi(linkCell,']'));
    linkCell = linkCell(~strcmpi(linkCell,''));
    db(lineCount).linkCell = lower(linkCell);
    db(lineCount).entity = entity;
    lineCount = lineCount + 1;
    if ~mod(lineCount,100)
        disp(lineCount);
    end
end
fclose(f);

[~,ia] = unique(lower({db.entity}));
db = db(ia);


%%
linkText = cat(2,db.linkCell);
[uLinkInds,uLinks] = prtUtilStringsToClassNumbers(linkText);
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

    if ~mod(dbInd,10)
        disp(dbInd);
    end
end

%%
removeRows = isnan(entityIndex);
linkMatrixSmall = linkMatrix(~removeRows,entityIndex(~removeRows));
entitiesSmall = entities(~removeRows);

minLinks = 2;
% while any(sum(linkMatrixSmall) < minLinks)
remove = sum(linkMatrixSmall) < minLinks;
linkMatrixSmall = linkMatrixSmall(~remove,~remove);
entitiesSmall = entitiesSmall(~remove);

unique(entitiesSmall(sum(linkMatrixSmall) > 10))
% end

%%

graphX = linkMatrixSmall;
% graphX(graphX < 2) = 0;
graphX = (graphX+graphX')./2;
degree = sum(graphX,2);

titles = entitiesSmall;
titles = strrep(titles,'_','\_');

minDegree = 5;
g = prtDataTypeGraph(graphX(degree > minDegree,degree > minDegree),titles(degree > minDegree));
g = g.optimizePlotLocationsTsne;
plot(g)