import os
from typing import Any

from models import IconMeta


def create_icon_metadata(
    svg_files: list[str], start_id: int
) -> list[IconMeta]:
    def make_meta(idx: int, path: str) -> IconMeta:
        filename = os.path.splitext(os.path.basename(path))[
            0
        ]
        char_id = start_id + idx
        return IconMeta(
            filename=filename,
            char_id=char_id,
            char_str=chr(char_id),
            const_name=filename.replace("-", "_")
            .replace(" ", "_")
            .upper(),
            svg_path=path,
        )

    return [
        make_meta(i, f) for i, f in enumerate(svg_files)
    ]


def generate_json_mapping(
    meta_list: list[IconMeta],
) -> dict[str, Any]:
    return {
        m.filename: {
            "char_id": m.char_id,
            "char": m.char_str,
        }
        for m in meta_list
    }


def generate_mc_module(meta_list: list[IconMeta]) -> str:
    lines = [
        f'        const ICON_{m.const_name} = "{m.char_str}";'
        for m in meta_list
    ]
    content = "\n".join(lines)
    return f"// AUTO-GENERATED ICON MAPPING(dev-tools/icon_generater)\nmodule Shared {{\n    module Icons {{\n{content}\n    }}\n}}\n"


def generate_fonts_xml(
    sizes: tuple[int, ...], base_name: str
) -> str:
    lines = ["<resources>"]
    lines.extend(
        [
            f'    <font id="IconFont{size}" filename="{base_name}_{size}.fnt" />'
            for size in sizes
        ]
    )
    lines.append("</resources>")
    return "\n".join(lines)


def generate_fnt_content(
    font_name: str,
    size: int,
    atlas_w: int,
    atlas_h: int,
    num_icons: int,
    fnt_lines: list[str],
) -> str:
    header = (
        f'info face="{font_name}" size={size} bold=0 italic=0 charset="" unicode=1 stretchH=100 smooth=1 aa=1 padding=0,0,0,0 spacing=1,1 outline=0\n'
        f"common lineHeight={size} base={size} scaleW={atlas_w} scaleH={atlas_h} pages=1 packed=0 alphaChnl=1 redChnl=0 greenChnl=0 blueChnl=0\n"
        f'page id=0 file="{font_name}.png"\n'
        f"chars count={num_icons}\n"
    )
    return header + "\n".join(fnt_lines)
