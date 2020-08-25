

"""
    TestState

                          +->Passed+--+
                          |           |
None+-->Queued+-->Running+-->Failed+--+
           ^              |           |
           |              +->Errored+-+
           |                          |
           +--------------------------+
"""
@enum TestState Passed Failed Errored Queued Running Initial
@with_kw mutable struct TestResult
    name::String
    state::TestState = Initial
    output::String = ""
end
TestResult(name::String) = TestResult(name = name)


function runtests(pkgfolder)::TestResult
    prevpkg = Pkg.project().path

    # Activate test subpackage
    testfolder = joinpath(pkgfolder, "test")
    @suppress Pkg.activate(testfolder)
    @suppress Pkg.instantiate()

    # Run tests for package and capture output
    state = Passed
    output = @capture_out try
        @suppress_err include(joinpath(testfolder, "runtests.jl"))
    catch e
        if (e isa LoadError) && (occursin("did not pass", string(e.error)))
            state = Failed
        else
            state = Errored
        end
        println(e)
    end

    # Restore active project
    @suppress Pkg.activate(prevpkg)

    return TestResult(
        splitpath(pkgfolder)[end],
        state,
        output,
    )
end
