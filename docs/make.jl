using TestTUI
using Documenter

makedocs(;
    modules=[TestTUI],
    authors="lorenzoh <lorenz.ohly@gmail.com> and contributors",
    repo="https://github.com/lorenzoh/TestTUI.jl/blob/{commit}{path}#L{line}",
    sitename="TestTUI.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://lorenzoh.github.io/TestTUI.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/lorenzoh/TestTUI.jl",
)
