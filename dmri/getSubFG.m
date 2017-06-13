function subFG = getSubFG(fg, idx, fgname)

% this function takes a .pdb fiber structure and an index and
% returns the subgroup of fibers as specified by the index


subFG = fg;

subFG.fibers = subFG.fibers(idx);

if isfield(subFG,'pathwayInfo')
    subFG.pathwayInfo=subFG.pathwayInfo(idx);
end

if isfield(subFG,'params')
    for p = 1:length(subFG.params)
        if isfield(subFG.params{p},'stat')
            subFG.params{p}.stat = subFG.params{p}.stat(idx);
        end
    end
end

if notDefined('fgname')
    subFG.name = subFG.name;
else
    subFG.name = fgname;
end
