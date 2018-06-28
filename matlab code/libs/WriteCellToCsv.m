function WriteCellToCsv(filename, cellArray)
%--------------------------------------------------------------------------
% @description:	WriteCellToCsv 
%				Write a cell array to a comma separated value file.
% 				WriteCellToCsv(FILENAME, C) writes cell array C into FILENAME as 
%				comma separated values.
% @note:		This is my customised version of the csv writer in the 
%				acknowledgement, to handle nested cells better. 
%				This function is not completely compatible with CSVWRITE.
% 				Offsets are not supported and 0 values are not omitted.
% 				See also CSVWRITE, CSVREAD, DLMREAD, DLMWRITE, WK1READ, WK1WRITE.
% @acknowledge:	http://www.mathworks.com/matlabcentral/fileexchange/
%				loadFile.do?objectId=7363&objectType=FILE
%--------------------------------------------------------------------------

	% The cell array is traversed, the contents of each cell are converted
	% to a string, and a CSV file is written using low level fprintf
	% statements.
	[rows, cols] = size(cellArray);
	fid = fopen(filename, 'w');
	for i_row = 1:1:rows
		file_line = '';
		for i_col = 1:1:cols
			% Retrieve the cell contents:
			contents = cellArray{i_row,i_col};
			
			% If it contains a nested cell, we now transform that into a
			% matrix
			if iscell(contents)
				contents = cell2mat(contents(:,:));
			end
			if isnumeric(contents)
				contents = num2str(contents);
			elseif isempty(contents)
				contents = '';
			end
			if i_col<cols
				file_line = [file_line, contents, ','];
			else
				file_line = [file_line, contents];
			end
		end
		count = fprintf(fid,'%s\n',file_line);
	end
	st = fclose(fid);
	if st == -1
		error('Error on CSV file write.')
	end
end



