"""Gera ícones/splash do Android e empacota emojis+sons em iMakerAssets.res (RCDATA)."""
import os, struct, sys
from PIL import Image

RAIZ = sys.argv[1]
ASSETS = os.path.join(RAIZ, "Assets")
ICONE = os.path.join(ASSETS, "Icone")
os.makedirs(ICONE, exist_ok=True)

base = Image.open(os.path.join(ASSETS, "Emojis", "icone_1024.png")).convert("RGBA")
for s in (36, 48, 72, 96, 144, 192):
    base.resize((s, s), Image.LANCZOS).save(os.path.join(ICONE, f"launcher_{s}.png"))
for w, h in ((426, 320), (470, 320), (640, 480), (960, 720)):
    img = Image.new("RGBA", (w, h), (11, 11, 11, 255))
    s = int(h * 0.6)
    ic = base.resize((s, s), Image.LANCZOS)
    img.paste(ic, ((w - s) // 2, (h - s) // 2), ic)
    img.save(os.path.join(ICONE, f"splash_{w}x{h}.png"))
os.replace(os.path.join(ASSETS, "Emojis", "icone_1024.png"), os.path.join(ICONE, "icone_1024.png"))

# ---- RES (formato Win32 .res, lido pelo linker do Delphi em todas as plataformas)
def name_bytes(nome):
    b = nome.upper().encode("utf-16-le") + b"\x00\x00"
    if len(b) % 4:
        b += b"\x00" * (4 - len(b) % 4)
    return b

def entry(nome, data):
    tipo = struct.pack("<HH", 0xFFFF, 10)          # RT_RCDATA
    nm = name_bytes(nome)
    hdr_rest = struct.pack("<IHHII", 0, 0x0030, 0x0416, 0, 0)  # DataVersion, Flags, Lang pt-BR, Version, Characteristics
    header_size = 8 + len(tipo) + len(nm) + len(hdr_rest)
    out = struct.pack("<II", len(data), header_size) + tipo + nm + hdr_rest + data
    if len(out) % 4:
        out += b"\x00" * (4 - len(out) % 4)
    return out

itens = []
for pasta, prefixo in (("Emojis", "EMOJI_"), ("Sons", "SOM_")):
    for f in sorted(os.listdir(os.path.join(ASSETS, pasta))):
        nome = prefixo + os.path.splitext(f)[0].split("_", 1)[1].upper()
        itens.append((nome, os.path.join("Assets", pasta, f)))

res = struct.pack("<IIHHHHIHHII", 0, 32, 0xFFFF, 0, 0xFFFF, 0, 0, 0, 0, 0, 0)
rc = ["// Recursos do iMaker (emojis e sons).",
      "// O iMakerAssets.res já vem compilado. Se alterar algum arquivo, recompile com:",
      "//   brcc32 iMakerAssets.rc", ""]
for nome, rel in itens:
    res += entry(nome, open(os.path.join(RAIZ, rel), "rb").read())
    rc.append(f'{nome:<16} RCDATA "{rel}"')
open(os.path.join(RAIZ, "iMakerAssets.res"), "wb").write(res)
open(os.path.join(RAIZ, "iMakerAssets.rc"), "w", newline="\r\n").write("\n".join(rc) + "\n")
print(len(res), [n for n, _ in itens])
