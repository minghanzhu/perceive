function [files,folder,fullfname] = perceive_ffind(string,ret_cell,rec)
if ~exist('ret_cell','var')
    ret_cell = 1;
end

if ~exist('rec','var')
    rec = 0;
end


if ~rec
    x = dir(string);
    % omit directories and empty entries
    x = x(~cellfun('isempty', {x.date}) & cellfun(@(x)x==false,{x.isdir}));
    files = {x.name};

    % initialize (optimization, but also needs to be done in case 'files' are
    % empty - otherwise, folder gets not defined
    folder=cell(1,length(files));
    for a =1:length(files)
        ff = fileparts(string);
        if ~isempty(ff)
            folder{a} = ff;
        else
            folder{a} = cd;
        end

    end


else
    
    rdirs=find_folders;
    outfiles=ffind(string,1,0);
    outfolders = {};
    folders = {};
    for a = 1:length(outfiles)
        outfolders{a} = cd;
    end
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
ris = logical(sum([ismember(files,'.') ,ismember(files,'..')],2));
files(ris)=[];
folder(ris)=[];
[files,x]=unique(files);
folder = folder(x);
% keyboard
fullfname=cell(1,length(folder));
if ~isempty(files)
    if ~ret_cell && length(files) == 1
        files = files{1};
        fullfname = [folder{1} filesep files];
    elseif iscell(files) && isempty(files{1})
        files = [];
        folder = [];
        fullfname = [];
    elseif iscell(files)
        for a=1:length(files)
            fullfname{a} = [folder{a} filesep files{a}];
        end   
    end
else
    folder = [];
    fullfnames = [];
end
    



% keyboard

