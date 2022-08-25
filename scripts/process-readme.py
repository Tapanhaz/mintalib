"""
script to translate README.md local urls
creates output/README.md for usage with pypi
Developer use only!
"""

import re
import argparse
import posixpath

import configparser

from pathlib import Path

root = Path(__file__).parent.parent


def get_project_url():
    setupcfg = root.joinpath("setup.cfg")

    if setupcfg.exists():
        config = configparser.ConfigParser()
        config.read(setupcfg)
        return config.get('metadata', 'url')

    setup = root.joinpath("setup.py")
    contents = setup.read_text()

    match = re.search(r"(?xm) ^ \s* url \s* = \s* ([\"']) ([^\"']+) \1 \s* $", contents)

    if not match:
        raise ValueError("Cound not extract url!")

    url = match.group(2)

    return url


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-v", "--verbose", action="store_true", help="verbose mode")
    parser.set_defaults(verbose=True)

    options = parser.parse_args()
    verbose = options.verbose

    readme = root.joinpath("README.md").resolve(strict=True)
    output = root.joinpath("output").resolve(strict=True)

    project_url = get_project_url()

    print("project_url", project_url)

    branch = "main"

    def replace(m):
        exclam, alt, url = m.groups()
        ftype = "raw" if exclam else "blob"
        if url.startswith("/"):
            url = posixpath.join(project_url, ftype, branch, url[1:])
            result = f"{exclam}[{alt}]({url})"
            if verbose:
                print("mapping", m.group(0), "->", result)
        else:
            result = m.group(0)
        return result

    text = readme.read_text()

    textout = re.sub(r"(?x)(\!?)\[([^]]*)\]\(([^)]+)\)", replace, text)

    outfile = output.joinpath("README.md")

    print(f"Updating {outfile} ...")
    outfile.write_text(textout)


if __name__ == "__main__":
    main()
