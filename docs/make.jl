using Documenter
using Changelog
using FileExplorer

Changelog.generate(
    Changelog.Documenter(),                     # output type
    joinpath(@__DIR__, "../CHANGELOG.md"),      # input file
    joinpath(@__DIR__, "src/CHANGELOG.md");     # output file
    repo = "mkoculak/FileExplorer.jl",          # default repository for links
)

makedocs(
    format = Documenter.HTML(
        assets = [
            "assets/favicon.ico",
        ]
    ),
    sitename="FileExplorer.jl",
    pages = [
        "Home" => "index.md",
        "List view" => "ls.md",
        "Tree view" => "browse.md",
        "Customisation" => "customisation.md",
        "CHANGELOG" => "CHANGELOG.md",
        "Reference" => "reference.md",
    ]
    )

deploydocs(
    repo = "github.com/mkoculak/FileExplorer.jl.git",
)