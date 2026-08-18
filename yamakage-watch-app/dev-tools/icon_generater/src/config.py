from dataclasses import dataclass
from pathlib import Path

project_root = Path(__file__).parent.parent
resources_dir = Path(__file__).parent / "resources"


@dataclass(frozen=True)
class Config:
    input_dir: Path = resources_dir / "svgs"
    output_dir: Path = project_root / "build_fonts"
    icon_sizes: tuple[int, ...] = (40, 48, 62, 92)
    base_font_name: str = "YamakageWatchAppIcons"
    start_char_id: int = 65
