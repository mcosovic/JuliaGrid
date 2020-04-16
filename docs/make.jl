using Documenter

makedocs(
    sitename = "JuliaGrid",
    modules = [ JuliaGrid ],
    doctest = false,
    pages = [
        "Home" => "index.md",
        "Power Flow" => "man/flow.md"
    ]
)

deploydocs(
    repo = "github.com/mcosovic/JuliaGrid.git",
    target = "build",
)
