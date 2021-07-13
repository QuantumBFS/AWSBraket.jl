using Documenter, AWSBraket, DocThemeIndigo
using AWSBraket.Schema
indigo = DocThemeIndigo.install(AWSBraket)

makedocs(;
    modules=[AWSBraket, Schema],
    authors="Roger-luo <rogerluo.rl18@gmail.com> and contributors",
    repo="https://github.com/QuantumBFS/AWSBraket.jl/blob/{commit}{path}#{line}",
    sitename="AWSBraket.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://QuantumBFS.github.io/AWSBraket.jl",
        assets=String[indigo, "assets/default.css"],
    ),
    pages=[
        "Quick Start" => "index.md",
        "Schema" => "schema.md",
    ],
)

deploydocs(;
    repo="github.com/QuantumBFS/AWSBraket.jl",
)
