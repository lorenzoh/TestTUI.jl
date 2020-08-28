

function findpackages(pattern = "*", dir = DEVDIR)
    collect(filter(istestablepackage, glob(pattern, dir)))
end


function istestablepackage(path)
    isdir(path) || return false
    contents = readdir(path)
    "Project.toml" ∈ contents || return false
    "test" ∈ contents || return false
    "runtests.jl" ∈ readdir(joinpath(path, "test"))
end


function sourcepaths(packagepath; include_tests = true)
    srcfolder = joinpath(packagepath, "src")
    @assert isdir(srcfolder)
    srcpaths = getfoldersandjlfiles(srcfolder)
    if include_tests
        testfolder = joinpath(packagepath, "test")
        srcpaths = vcat(srcpaths, getfoldersandjlfiles(testfolder))
    end
    return srcpaths
end


function getfoldersandjlfiles(folder)
    files1 = glob("*.jl", folder)
    files2 = glob("**/*.jl", folder)
    folders = glob("**/", folder)
    return vcat(files1, files2, folders)
end
