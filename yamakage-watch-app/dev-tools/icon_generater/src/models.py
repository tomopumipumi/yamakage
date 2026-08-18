from dataclasses import dataclass


@dataclass(frozen=True)
class IconMeta:
    filename: str
    char_id: int
    char_str: str
    const_name: str
    svg_path: str
