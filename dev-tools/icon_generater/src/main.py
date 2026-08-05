import json
import os

from result import Err, Ok, Result

from config import Config
from core.generators import (
    create_icon_metadata,
    generate_fonts_xml,
    generate_json_mapping,
    generate_mc_module,
)
from core.layout import calculate_grid
from effects.file_system import (
    ensure_dir,
    get_svg_files,
    write_text_file,
)
from effects.image import process_size


def run_pipeline(config: Config) -> Result[str, str]:
    # Create Directory
    res_dir = ensure_dir(config.output_dir)
    if isinstance(res_dir, Err):
        return res_dir

    # Get SVG Files
    res_svg = get_svg_files(config.input_dir)
    if isinstance(res_svg, Err):
        return res_svg
    svg_files = res_svg.unwrap()

    num_icons = len(svg_files)
    print(
        f"Starting conversion... ({num_icons} SVG files in total)"
    )

    # Calculate Layout
    meta_list = create_icon_metadata(
        svg_files, config.start_char_id
    )
    cols, rows = calculate_grid(num_icons)

    # Generate Image
    for size in config.icon_sizes:
        res_size = process_size(
            size, config, meta_list, cols, rows
        )
        if isinstance(res_size, Err):
            return res_size
        font_name = res_size.unwrap()
        print(
            f" Generated: size {size}px ({font_name}.png / .fnt)"
        )

    print("-" * 40)

    # Write File
    res_xml = write_text_file(
        os.path.join(config.output_dir, "fonts.xml"),
        generate_fonts_xml(
            config.icon_sizes, config.base_font_name
        ),
    )
    if isinstance(res_xml, Err):
        return res_xml
    print(" Generated: fonts.xml")

    res_json = write_text_file(
        os.path.join(config.output_dir, "mapping.json"),
        json.dumps(
            generate_json_mapping(meta_list),
            indent=4,
            ensure_ascii=False,
        ),
    )
    if isinstance(res_json, Err):
        return res_json
    print(" Generated: mapping.json")

    res_mc = write_text_file(
        os.path.join(config.output_dir, "IconMapping.mc"),
        generate_mc_module(meta_list),
    )
    if isinstance(res_mc, Err):
        return res_mc
    print(" Generated: IconMapping.mc")

    return Ok(
        f"\nAll tasks completed! Output directory: {config.output_dir}/"
    )


def main() -> None:
    config = Config()
    match run_pipeline(config):
        case Ok(msg):
            print(msg)
        case Err(err_msg):
            print(f"Error: {err_msg}")
            exit(1)


if __name__ == "__main__":
    main()
