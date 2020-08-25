

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


function sourcepaths(packagepath)
    srcfolder = joinpath(packagepath, "src")
    @assert isdir(srcfolder)
    files1 = glob("*.jl", srcfolder)
    files2 = glob("**/*.jl", srcfolder)
    folders = glob("**/", srcfolder)
    return vcat(files1, files2, folders)
end
