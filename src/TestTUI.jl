module TestTUI
#=
Remaining problems:
- bug in TerminalUserInterfaces.terminal_size()
- printing of outputs is cut off. See `paragraph.jl` in TerminalUserInterfaces

ToDo:
- help text for unfinished tasks in "results" box
=#

using Glob
using Revise
using Parameters
using Pkg
using Suppressor
using TerminalUserInterfaces
const TUI = TerminalUserInterfaces


const DEVDIR = get(ENV, "JULIA_PKG_DEVDIR", joinpath(homedir(), ".julia/dev"))

include("./utils.jl")
include("./test.jl")
include("./textwidget.jl")
include("./tui.jl")


function testtui(
        pattern = "*";
        dir = DEVDIR)
    testtui(findpackages(pattern, dir))
end

#=
Tasks:
1. watch package directories and requeue changed packages
2. empty queue and update testresults
3. update UI
=#

function startwatching(packagepaths, results, channel)
    for (packagepath, result) in zip(packagepaths, results)
        paths = sourcepaths(packagepath)
        @async begin
            entr(paths, pause = .5) do
                try
                    if result.state != Queued
                        result.state = Queued
                        push!(channel, packagepath)
                    end
                catch e
                    @error e
                end
            end
        end
    end
end

function starttesting(resultdict, channel)
    for packagepath in channel
        try
            result = resultdict[packagepath]
            result.state = Running
            newresult = runtests(packagepath)
            if result.state != Queued
                result.output = newresult.output
                result.state = newresult.state
            end
        catch e
            @error e
        end
    end
end


function testtui(packagepaths::Vector{String})
    @assert all(istestablepackage.(packagepaths))
    packagepaths = sort(packagepaths)
    names = [splitpath(path)[end] for path in packagepaths]
    results = [TestResult(name) for name in names]
    resultdict = Dict(zip(packagepaths, results))

    channel = Channel{String}(100)
    startwatching(packagepaths, results, channel)
    Threads.@spawn starttesting(resultdict, channel)

    @async begin
        tuiloop(results)
    end

    return results, channel
end

export testtui, runtests

end
