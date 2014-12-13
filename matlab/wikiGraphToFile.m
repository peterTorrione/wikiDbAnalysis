function wikiGraphToFile(fileOut,graph,neighbors)

[i,j,val] = find(graph.graph);
data_dump = [i-1,j-1,val];


fid = fopen(fileOut,'w');
fprintf( fid,'<graph>\n');
fprintf( fid,'%d %d %f\n', data_dump' );
fprintf( fid,'</graph>\n');
fprintf( fid,'<nodeNames>\n');
fprintf( fid,'%s\n',graph.nodeNames{:});
fprintf( fid,'</nodeNames>\n');
fprintf( fid,'<neighbors>\n');
strSpec = repmat('%d ',1,size(neighbors,2));
fprintf( fid,[strSpec,'\n'],neighbors'-1);
fprintf( fid,'</neighbors>\n');
fclose(fid);