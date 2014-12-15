function [paragraph,links] = wikiGetFirstParagraph(wikiRaw)

index2 = strfind(wikiRaw,'</p>');

startTypes = {'<p><b>','<p>"<b>','<p>''<b>','<p><i><b>','<p>'};
index1 = [];
count = 1;
while isempty(index1)
    index1 = strfind(wikiRaw,startTypes{count});
    if ~isempty(index1)
        index1 = index1(index1 < index2(1));
    end
    count = count + 1;
end

paragraph = wikiRaw(index1(1):index2(1)-1);
% See: http://www.mathworks.com/matlabcentral/answers/98555-how-can-i-read-an-html-file-into-matlab-and-discard-the-html-tags
pat = '<[^>]*>';
paragraph = regexprep(paragraph, pat, '');
links = regexp(wikiRaw,'<a href="(?<link>/wiki.*?)"','names');
for i = 1:length(links)
    remove(i) = any(links(i).link == ':') || any(links(i).link == '#');
end
links = links(~remove);
