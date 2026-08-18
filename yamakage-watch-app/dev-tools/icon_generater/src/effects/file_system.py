import glob
import os
from pathlib import Path

from result import Err, Ok, Result


def get_svg_files(
    input_dir: Path,
) -> Result[list[str], str]:
    files = sorted(
        glob.glob(os.path.join(input_dir, "*.svg"))
    )
    return (
        Ok(files)
        if files
        else Err(f"No SVG files found in: {input_dir}")
    )


def ensure_dir(path: Path) -> Result[None, str]:
    try:
        os.makedirs(path, exist_ok=True)
        return Ok(None)
    except Exception as e:
        return Err(
            f"Failed to create directory ({path}): {e}"
        )


def write_text_file(
    filepath: str, content: str
) -> Result[None, str]:
    try:
        with open(filepath, "w", encoding="utf-8") as f:
            f.write(content)
        return Ok(None)
    except Exception as e:
        return Err(
            f"Failed to write file ({filepath}): {e}"
        )
