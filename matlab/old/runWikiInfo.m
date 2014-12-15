%%
clear all;
close all;
dirList = prtUtilSubDir('C:\Users\Pete\Desktop\wiki');

%%
nFiles = length(dirList);
wikiInfo = extractWikiInfo(dirList{1});
wikiInfo = repmat(wikiInfo,nFiles,1);

verbose = false;
for i = 1:length(dirList)
    
    try
        if any(dirList{i} == '#')
            error('catch me');
        end
        wikiInfo(i) = extractWikiInfo(dirList{i});
        if verbose 
            fprintf('Parsed file: %s\n',dirList{i});
        end
    catch ME
        
        %if verbose
            fprintf('Error parsing file: %s\n',dirList{i});
        %end
        wikiInfo(i).paragraph = [];
        wikiInfo(i).links = [];
        wikiInfo(i).isBand = nan;
    end
    if ~mod(i,1000)
        fprintf('%d/%d\n',i,length(dirList));
        disp(wikiInfo(i))
        drawnow;
    end
end
    
% Remove unparseable info:
isNanLabel = isnan([wikiInfo.isBand]);
wikiInfo = wikiInfo(~isNanLabel);

%%
wikiInfo = wikiInfo(logical([wikiInfo.isBand]));

%%
urls = {wikiInfo.url};
for i = 1:length(urls)
    urls{i} = strrep(urls{i},'\','/');
    urls{i} = ['/',urls{i}];
end
links = cat(2,wikiInfo.links);
links = {links.link};
[inds,uniqueUrls] = prtUtilStringsToClassNumbers(urls);

%%
X = sparse(length(wikiInfo),length(wikiInfo));
allLinks = cat(2,wikiInfo.links);
allLinks = {allLinks.link};

linkInds = nan(length(allLinks),1);
for i = 1:length(uniqueUrls);
    linkInds(strcmpi(uniqueUrls{i},allLinks)) = i;
    if ~mod(i,100)
        disp(i/length(uniqueUrls))
    end
end

%%
start = 1;
for i = 1:length(wikiInfo)
    
    stop = start + length(wikiInfo(i).links) - 1;
    currInds = linkInds(start:stop);
    currInds = currInds(~isnan(currInds));
    for j = 1:length(currInds)
        X(i,currInds(j)) = X(i,currInds(j)) + 1;
    end
    X(i,i) = 0;
    start = stop + 1;
    disp(i)
end

%%
graphX = X;
% graphX(graphX < 2) = 0;
graphX = (graphX+graphX')./2;

titles = {wikiInfo.title};
titles = strrep(titles,'_','\_');

degree = sum(graphX,2);
good = degree > 100;

titles = titles(good);
graphX = graphX(good,good);

valid = sum(graphX,2) > 0;
graphX = graphX(valid,valid);
titles = titles(valid);

fprintf('Retained %d/%d\n',size(graphX,1),size(X,1));

% %%
% g = prtDataTypeGraph(graphX,titles);
% g = g.optimizePlotLocationsHooke('maxIters',10000,'velocityDecay',0.99);
% 
% %%
% for i = 1:10;
%     g = g.jigglePlotLocations;
%     g = g.optimizePlotLocationsHooke('maxIters',1000,'velocityDecay',0.99);
% end
% disp('done');

%%

graphX = X;
% graphX(graphX < 2) = 0;
graphX = (graphX+graphX')./2;

titles = {wikiInfo.title};
titles = strrep(titles,'_','\_');

degree = sum(graphX,2);
[degreeSort,sortInds] = sort(degree,'descend');
graphSort = graphX(sortInds,sortInds);
titleSort = titles(sortInds);
g = prtDataTypeGraph;
for degreeInd = [150]; % 800 1200];
    nPreviousNodes = size(g.plotLocations,1);
    
    cGraph = graphSort(1:degreeInd,1:degreeInd);
    if nPreviousNodes > 1
        cLocs = bsxfun(@times,randn(degreeInd,2),std(g.plotLocations));
        cLocs(1:nPreviousNodes,:) = g.plotLocations;
    else
        cLocs = randn(degreeInd,2);
    end
    
    g.graph = cGraph;
    g.nodeNames = titleSort(1:degreeInd);
    g.plotLocations = cLocs;
    g = g.optimizePlotLocationsHooke('maxIters',10000,'velocityDecay',0.99,'ka',3,'optimalDistanceFn',@(g)1./log(g+1),'repelConnectedNodes',false);
    g = g.jigglePlotLocations;
    g = g.optimizePlotLocationsHooke('maxIters',1000,'velocityDecay',0.99,'ka',3,'optimalDistanceFn',@(g)1./log(g+1),'repelConnectedNodes',false);
end
    
%%
graphX = X;
% graphX(graphX < 2) = 0;
graphX = (graphX+graphX')./2;
degree = sum(graphX,2);

titles = {wikiInfo.title};
titles = strrep(titles,'_','\_');

g = prtDataTypeGraph(graphX(degree > 10,degree > 10),titles(degree > 10));
g = g.optimizePlotLocationsTsne;


% %%
% X = sparse(length(bands),length(uLinks));
% 
% start = 1;
% 
% for i = 1:length(bands);
%     stop = start + length(bands(i).links) - 1;
%     currInds = inds(start:stop);
%     for j = 1:length(currInds)
%         X(i,currInds(j)) = X(i,currInds(j)) + 1;
%     end
%     start = stop + 1;
%     disp(i)
% end
% 
% badInds = strcmpi(uLinks,'/wiki/Help:IPA_for_English#Key');
% X = X(:,~badInds);
% uLinks = prtUtilRemoveStrCell(uLinks,'/wiki/Help:IPA_for_English#Key');
% 
% 
% %%
% XnormR = bsxfun(@rdivide,X,max(sum(X,2),1));
% XnormC = bsxfun(@rdivide,X,max(sum(X,1),1));
% %xInner = full(XnormR*XnormR');
% xInner = full(XnormR*XnormC');
% for i = 1:size(xInner,1);
%     xInner(i,i) = 0; 
% end
% xInner = xInner + xInner';
% 
% cBands = bands;
% 
% tooFew = sum(xInner > 0,2) < 3;
% xInner = xInner(~tooFew,~tooFew);
% cBands = cBands(~tooFew);
% 
% % bigEnough = sum(xInner,1) > 1; 
% % sum(bigEnough)
% bigEnough = true(size(xInner,1),1);
% xInner = xInner(bigEnough,bigEnough);
% cBands = cBands(bigEnough);
% 
% bigEnoughTitles = {bands(bigEnough).title};
% bigEnoughTitles = strrep(bigEnoughTitles,'_','\_');
% g = prtDataTypeGraph(round(xInner*1000),bigEnoughTitles);
% %g = g.optimizePlotLocationsCoulomb(100);
% g = g.optimizePlotLocations;
% disp('done');
% 
% % bandInfo = cat(1,