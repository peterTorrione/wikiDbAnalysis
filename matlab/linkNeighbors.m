function [neighbors,inds,entry] = linkNeighbors(graph,entry,nNeighbors)

if isa(entry,'char');
    entry = find(strcmpi(graph.nodeNames,entry));
end
if isempty(entry)
    neighbors = [];
    inds = [];
    entry = [];
    return;
end
% [nLinksTo,linksToSorted] = sort(graph.graph(entry,:),'descend');
% [nLinksFrom,linksFromSorted] = sort(graph.graph(:,entry),'descend');
% mutualNeighbors = graph.graph(:,entry) & graph.graph(entry,:)';

graphNorm = graph.graph;
graphNorm = graphNorm - diag(diag(graphNorm));
% graphNorm = bsxfun(@rdivide,graphNorm,sum(graphNorm,2));
graphNormVec = graphNorm(entry,:);
d = prtDistanceEuclidean(full(graphNormVec),full(graphNorm));

d(~graph.graph(:,entry) & ~graph.graph(entry,:)') = inf;

[v,sortD] = sort(d,'ascend');
sortD = sortD(sortD ~= entry);
neighbors = graph.nodeNames(sortD(1:nNeighbors));
inds = sortD(1:nNeighbors);