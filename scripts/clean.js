import fs from "node:fs";

[
    "node_modules",
    ".venv",
    ".wrangler",
    ".bin",
    "target",
    "__pycache__",
    ".pdm-build",
    ".ruff_cache"
]
.map((dirName) => {
    fs
        .globSync(`**/${dirName}`)
        .map(target => 
            fs.rmSync(target, { recursive: true, force: true })
        );
});


console.log('Cleanup completed.');