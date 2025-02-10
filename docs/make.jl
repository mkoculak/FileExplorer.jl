using Documenter, FileExplorer

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
        "Reference" => "reference.md",
    ]
    )

deploydocs(
    repo = "github.com/mkoculak/FileExplorer.jl.git",
)