function [files,folder,fullfname] = perceive_ffind(string,cell,rec)
% PERCEIVE_FFIND Find files matching a pattern with advanced handling for different OS
%
% Inputs:
%   string - Search pattern/string to find files
%   cell   - Flag to return results as cell array (default: 1)
%   rec    - Flag for recursive search (default: 0)
%
% Outputs:
%   files     - Found filenames (as cell array or char depending on cell flag)
%   folder    - Corresponding folders for each file
%   fullfname - Full file paths (folder + filename)

% Set default parameters if not provided
if ~exist('cell','var')
    cell = 1;
end

if ~exist('rec','var')
    rec = 0;
end

% Non-recursive file search
if ~rec
    % Get initial file listing
    x = ls(string);
    if size(x,1)>1
        % Windows-style output: convert matrix to cell array
        files = cellstr(ls(string));
    else
        % Unix-style output: handle space/tab separated string
        % On unix, the output of 'ls' is a rich text, see the help for LS:
        %  >> On UNIX, LS returns a character row vector of filenames
        %  >> separated by tab and space characters.
        % On top of that, the text terminates with a newline.
        % Therefore, we can't split only on spaces, but also on tabs and newlines:
        files = strsplit(x);
        % On unix, splitting on newlines can result in the last entry being empty,
        % so we remove empty entries:
        if ~isempty(files)
            nonempty=repmat(true,1,length(files));
            for i=1:length(files)
                if isempty(files{i})
                    nonempty(i)=false;
                end
            end
            files=files(nonempty);
        end
    end
    
    % Determine folder for each file
    for a =1:length(files)
        ff = fileparts(string);
        if ~isempty(ff)
            folder{a} = ff;
        else
            folder{a} = cd;
        end
    end

else
    % Recursive file search implementation
    rdirs=find_folders;  % Get list of subdirectories
    outfiles=ffind(string,1,0);  % Find files in current directory
    outfolders = {};
    folders = {};
    
    % Initialize folders for files in current directory
    for a = 1:length(outfiles)
        outfolders{a} = cd;
    end
    
    % Search in all subdirectories
    for a=1:length(rdirs)
        files=ffind([rdirs{a} filesep string],1,0);
        if ~isempty(files)
            for b = 1:length(files)
                folders{b,1} = [rdirs{a}];
            end
            outfiles = [outfiles;files];
            outfolders = [outfolders;folders];
        end
    end
    files = outfiles;
    folder = outfolders;
end

% Remove '.' and '..' from results and ensure uniqueness
ris = logical(sum([ismember(files,'.') ,ismember(files,'..')],2));
if ris
    files(ris)=[];
    folder(ris)=[];
    [files,x]=unique(files);
    folder = folder(x);
end

% Format output based on input parameters and results
if ~isempty(files)
    if ~cell && length(files) == 1
        % Single file result when cell=0
        files = files{1};
        fullfname = [folder{1} filesep files];
    elseif iscell(files) && isempty(files{1})
        % No files found
        files = [];
        folder = [];
        fullfname = [];
    elseif iscell(files)
        % Multiple files found - construct full file paths
        for a=1:length(files)
            % Extract only the filename and extension from the ls output item.
            % files{a} might be just 'name.ext' or 'path/name.ext' depending on ls behavior.
            [~, name_only, ext_only] = fileparts(files{a});
            actual_filename = [name_only, ext_only];
            
            % Handle special cases for directory names and files without extensions
            if isempty(actual_filename) && ~isempty(files{a}) && endsWith(files{a}, filesep)
                % Handle directory names ending with filesep
                trimmed_file_entry = files{a}(1:end-length(filesep));
                [~, name_only, ext_only] = fileparts(trimmed_file_entry);
                actual_filename = [name_only, ext_only];
            elseif isempty(actual_filename) && ~isempty(files{a})
                % Handle filenames without extensions
                actual_filename = files{a};
            end

            % Construct full file path using folder and filename
            fullfname{a,1} = fullfile(folder{a}, actual_filename);
        end   
    end
else
    % No files found - return empty results
    folder = [];
    fullfname = [];
end
    



% keyboard

