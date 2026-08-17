import io
import os
import xml.etree.ElementTree as ET

from PIL import Image
from result import Err, Ok, Result
from resvg import render, usvg

from config import Config
from core.generators import generate_fnt_content
from effects.file_system import write_text_file
from models import IconMeta


def process_size(
    size: int,
    config: Config,
    meta_list: list[IconMeta],
    cols: int,
    rows: int,
) -> Result[str, str]:
    font_name = f"{config.base_font_name}_{size}"
    atlas_w, atlas_h = cols * size, rows * size

    try:
        atlas_img = Image.new(
            "RGBA", (atlas_w, atlas_h), (0, 0, 0, 0)
        )
        fnt_lines = []

        options = usvg.Options.default()
        options.load_system_fonts()

        for idx, meta in enumerate(meta_list):
            with open(
                meta.svg_path, "r", encoding="utf-8"
            ) as f:
                svg_string = f.read()

            root = ET.fromstring(svg_string)
            orig_width = 100.0

            if "width" in root.attrib:
                orig_width = float(
                    root.attrib["width"].replace("px", "")
                )
            elif "viewBox" in root.attrib:
                orig_width = float(
                    root.attrib["viewBox"].split()[2]
                )

            scale_factor = size / orig_width

            tree = usvg.Tree.from_str(svg_string, options)

            transform = (
                scale_factor,
                0.0,
                0.0,
                0.0,
                scale_factor,
                0.0,
            )

            png_data = render(tree, transform)

            if not png_data:
                return Err(
                    f"Failed to convert SVG: {meta.svg_path}"
                )

            img = Image.open(
                io.BytesIO(bytes(png_data))
            ).convert("RGBA")

            col, row = idx % cols, idx // cols
            x, y = col * size, row * size

            atlas_img.paste(img, (x, y), img)
            fnt_lines.append(
                f"char id={meta.char_id} x={x} y={y} width={size} height={size} "
                f"xoffset=0 yoffset=0 xadvance={size} page=0 chnl=15"
            )

        png_out = os.path.join(
            config.output_dir, f"{font_name}.png"
        )
        atlas_img.save(png_out)

        fnt_content = generate_fnt_content(
            font_name,
            size,
            atlas_w,
            atlas_h,
            len(meta_list),
            fnt_lines,
        )
        fnt_out = os.path.join(
            config.output_dir, f"{font_name}.fnt"
        )
        write_text_file(fnt_out, fnt_content).unwrap()

        return Ok(font_name)
    except Exception as e:
        return Err(
            f"An error occurred while processing size {size}px: {e}"
        )
