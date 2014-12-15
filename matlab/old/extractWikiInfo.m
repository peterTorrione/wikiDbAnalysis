function wikiInfo = extractWikiInfo(wikiPage)

pp = pathParts(wikiPage);
[~,title] = fileparts(wikiPage);
url = cat(2,'wiki\',pp{end});
fid = fopen(wikiPage);
wikiRaw = fread(fid,inf,'char');
fclose(fid);
wikiRaw = char(wikiRaw');

[paragraph,links] = wikiGetFirstParagraph(wikiRaw);
sentences = regexp([' ',paragraph],'(?<sentence>\s+[^.!?]*[.!?])','names');
if ~isempty(sentences)
    firstSentence = sentences(1).sentence(2:end);
    searchString = firstSentence;
else
    firstSentence = '';
    searchString = paragraph;
end

% This needs to be improved...
listStrings = {' list '};
listFound = inf;
for i = 1:length(listStrings)
    listFound = min([listFound,strfind(searchString,listStrings{i})]);
end

% This needs to be improved...
labelStrings = {'record label'};
labelFound = inf;
for i = 1:length(labelStrings)
    labelFound = min([labelFound,strfind(searchString,labelStrings{i})]);
end

% This needs to be improved...
songStrings = {' song ',' composition ',' single '};
songFound = inf;
for i = 1:length(songStrings)
    songFound = min([songFound,strfind(searchString,songStrings{i})]);
end

albumStrings = {' album ',' EP '};
albumFound = inf;
for i = 1:length(albumStrings)
    albumFound = min([albumFound,strfind(searchString,albumStrings{i})]);
end

bandStrings = {' band',' group',' musician',' singer',' DJ'};
bandFound = inf;
for i = 1:length(bandStrings)
    bandFound = min([bandFound,strfind(searchString,bandStrings{i})]);
end

isBand = 0;
isSong = 0;
isAlbum = 0;
isList = listFound < inf | (length(title) > 7 && strcmpi(title(1:7),'List_of'));
isLabel = labelFound < inf;
if ~isList && ~isLabel
    if bandFound < albumFound && bandFound < songFound
        isBand = 1;
    elseif albumFound < bandFound && albumFound < songFound
        isAlbum = 1;
    elseif songFound < bandFound && songFound < albumFound
        isSong = 1;
    end
end

wikiInfo = struct('url',url,'title',title,'paragraph',paragraph,'firstSentence',firstSentence,'links',links,'isList',isList,'isLabel',isLabel,'isBand',isBand,'isSong',isSong,'isAlbum',isAlbum);