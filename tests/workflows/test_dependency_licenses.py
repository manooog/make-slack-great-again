"""Keep pinned dependencies and their license/attribution files consistent."""

import re
from pathlib import Path


root = Path(__file__).resolve().parents[2]


def read(rel: str) -> str:
    return (root / rel).read_text()


def fetch_declarations(rel: str) -> dict[str, tuple[str, str]]:
    text = read(rel)
    found = {}
    for name, url, digest in re.findall(
        r"FetchContent_Declare\(\s*(\w+)\s+URL\s+(\S+)\s+URL_HASH\s+SHA256=([0-9a-f]{64})",
        text,
        re.S,
    ):
        found[name] = (url, digest)
    return found


declarations = {
    **fetch_declarations("src/net/posix/posix.cmake"),
    **fetch_declarations("src/text/font_libs.cmake"),
}
assert set(declarations) == {"msga_mbedtls", "msga_freetype", "msga_harfbuzz"}, declarations
for name, (url, digest) in declarations.items():
    assert url.startswith("https://"), (name, url)
    assert re.fullmatch(r"[0-9a-f]{64}", digest), (name, digest)

mbedtls_url, mbedtls_hash = declarations["msga_mbedtls"]
nix = read("nix/package.nix")
assert mbedtls_url in nix, "nix/package.nix does not use the pinned Mbed TLS tarball"
assert mbedtls_hash in nix, "nix/package.nix does not use the pinned Mbed TLS hash"

notice = read("THIRD_PARTY_LICENSES")
for version in ("Mbed TLS 3.6.7", "FreeType 2.14.3", "HarfBuzz 12.2.0"):
    assert version in notice, f"THIRD_PARTY_LICENSES is missing {version}"
for heading in (
    "libdbus (COPYING from dbus-1.14.10)",
    "libwebp (COPYING from the libwebp source tree)",
):
    assert heading in notice, f"THIRD_PARTY_LICENSES is missing the {heading} text"

release = read(".github/workflows/release.yml")
assert "cp LICENSE THIRD_PARTY_LICENSES dist/" in release
for asset in ("dist/LICENSE", "dist/THIRD_PARTY_LICENSES"):
    assert asset in release, f"release workflow does not publish {asset}"

assert "../LICENSE" in nix and "../THIRD_PARTY_LICENSES" in nix
assert "$out/share/licenses/msga/LICENSE" in nix
assert "$out/share/licenses/msga/THIRD_PARTY_LICENSES" in nix

readme = read("README.md")
assert "](LICENSE)" in readme and "](THIRD_PARTY_LICENSES)" in readme
assert "`LICENSE` and `THIRD_PARTY_LICENSES`" in readme
print("Dependency and license inventory checks passed.")
