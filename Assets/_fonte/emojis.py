"""Gera os emojis do iMaker (ficha de canastra preta e dourada) em SVG -> PNG."""
import os, subprocess, sys

OUT = sys.argv[1]
os.makedirs(OUT, exist_ok=True)

INK = "#111111"
GOLD_DEFS = """
<defs>
  <radialGradient id="g" cx="40%" cy="35%" r="70%">
    <stop offset="0" stop-color="#FFF1A8"/>
    <stop offset="0.45" stop-color="#F5C842"/>
    <stop offset="1" stop-color="#B8860B"/>
  </radialGradient>
  <radialGradient id="gs" cx="40%" cy="35%" r="70%">
    <stop offset="0" stop-color="#E6E1CF"/>
    <stop offset="0.5" stop-color="#BFB28A"/>
    <stop offset="1" stop-color="#7C6F4A"/>
  </radialGradient>
  <linearGradient id="card" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0" stop-color="#FFFFFF"/><stop offset="1" stop-color="#ECECEC"/>
  </linearGradient>
</defs>"""


def chip(fill="url(#g)", cx=128, cy=140, r=92):
    return f"""
  <circle cx="{cx}" cy="{cy+5}" r="{r}" fill="#000" opacity="0.25"/>
  <circle cx="{cx}" cy="{cy}" r="{r}" fill="{fill}" stroke="{INK}" stroke-width="8"/>
  <circle cx="{cx}" cy="{cy}" r="{r-11}" fill="none" stroke="{INK}" stroke-width="9" stroke-dasharray="16 20" opacity="0.9"/>
  <circle cx="{cx}" cy="{cy}" r="{r-24}" fill="none" stroke="#FFFFFF" stroke-width="3" opacity="0.35"/>"""


def eyes_happy(cy=128):
    return f"""<path d="M84 {cy} q14 -18 28 0" fill="none" stroke="{INK}" stroke-width="9" stroke-linecap="round"/>
  <path d="M144 {cy} q14 -18 28 0" fill="none" stroke="{INK}" stroke-width="9" stroke-linecap="round"/>"""


def eyes_round(cy=126, dx=0):
    return f"""<ellipse cx="{98+dx}" cy="{cy}" rx="9" ry="12" fill="{INK}"/>
  <ellipse cx="{158+dx}" cy="{cy}" rx="9" ry="12" fill="{INK}"/>
  <circle cx="{101+dx}" cy="{cy-4}" r="3" fill="#fff"/><circle cx="{161+dx}" cy="{cy-4}" r="3" fill="#fff"/>"""


def svg(body):
    return f'<svg xmlns="http://www.w3.org/2000/svg" width="256" height="256" viewBox="0 0 256 256">{GOLD_DEFS}{body}</svg>'


def crown(y=30):
    return f"""<path d="M78 {y+44} L70 {y} L104 {y+24} L128 {y-6} L152 {y+24} L186 {y} L178 {y+44} Z"
     fill="#FFD54A" stroke="{INK}" stroke-width="7" stroke-linejoin="round"/>
  <circle cx="128" cy="{y+28}" r="7" fill="{INK}"/>"""


def sparkle(x, y, s=1.0, c="#FFD54A"):
    return f'<path transform="translate({x} {y}) scale({s})" d="M0 -14 L4 -4 L14 0 L4 4 L0 14 L-4 4 L-14 0 L-4 -4 Z" fill="{c}" stroke="{INK}" stroke-width="2.5"/>'


def card(x, y, rot, label="A"):
    return f"""<g transform="translate({x} {y}) rotate({rot})">
    <rect x="-24" y="-34" width="48" height="68" rx="7" fill="url(#card)" stroke="{INK}" stroke-width="5"/>
    <text x="-14" y="-12" font-family="DejaVu Sans" font-weight="bold" font-size="18" fill="{INK}">{label}</text>
    <path d="M0 2 l9 10 l-9 10 l-9 -10 z" fill="#E8B423" stroke="{INK}" stroke-width="2.5"/>
  </g>"""


E = {}

# Vitória: coroa, olhos felizes, sorriso aberto, brilhos
E["vitoria"] = svg(chip() + crown(26) + eyes_happy(132) + f"""
  <path d="M86 156 Q128 206 170 156 Z" fill="{INK}"/>
  <path d="M104 178 Q128 194 152 178 Q128 188 104 178 Z" fill="#E5484D"/>
  <ellipse cx="78" cy="160" rx="11" ry="7" fill="#FF8A65" opacity="0.6"/>
  <ellipse cx="178" cy="160" rx="11" ry="7" fill="#FF8A65" opacity="0.6"/>"""
  + sparkle(32, 70, 1.2) + sparkle(222, 92, 1.0) + sparkle(214, 210, 0.8) + sparkle(40, 206, 0.7))

# Derrota: ficha acinzentada, sobrancelhas tristes, lágrima
E["derrota"] = svg(chip("url(#gs)") + f"""
  <path d="M80 108 L110 118" stroke="{INK}" stroke-width="8" stroke-linecap="round"/>
  <path d="M176 108 L146 118" stroke="{INK}" stroke-width="8" stroke-linecap="round"/>
  {eyes_round(136)}
  <path d="M96 190 Q128 162 160 190" fill="none" stroke="{INK}" stroke-width="9" stroke-linecap="round"/>
  <path d="M168 146 q10 18 0 26 q-10 -8 0 -26 z" fill="#64B5F6" stroke="{INK}" stroke-width="3"/>
  <path d="M60 60 q8 -14 16 0 q8 -14 16 0" fill="none" stroke="#8C8C8C" stroke-width="5" stroke-linecap="round"/>""")

# Rodada iniciada: piscadinha + cartas em leque
E["rodada"] = svg(chip(cy=150, r=86) + f"""
  <path d="M86 140 q14 -16 28 0" fill="none" stroke="{INK}" stroke-width="9" stroke-linecap="round"/>
  <ellipse cx="158" cy="138" rx="9" ry="12" fill="{INK}"/><circle cx="161" cy="134" r="3" fill="#fff"/>
  <path d="M98 172 Q128 196 158 172" fill="none" stroke="{INK}" stroke-width="9" stroke-linecap="round"/>"""
  + card(92, 52, -22, "A") + card(128, 42, 0, "K") + card(164, 52, 22, "Q"))

# Buraco: ficha caindo num buraco, olhos arregalados
E["buraco"] = svg(f"""
  <ellipse cx="128" cy="214" rx="104" ry="30" fill="#000"/>
  <ellipse cx="128" cy="214" rx="104" ry="30" fill="none" stroke="#E8B423" stroke-width="6"/>
  <clipPath id="c"><rect x="0" y="0" width="256" height="214"/></clipPath>
  <g clip-path="url(#c)">{chip(cy=150, r=84)}
    <circle cx="100" cy="128" r="17" fill="#fff" stroke="{INK}" stroke-width="5"/>
    <circle cx="156" cy="128" r="17" fill="#fff" stroke="{INK}" stroke-width="5"/>
    <circle cx="102" cy="132" r="7" fill="{INK}"/><circle cx="154" cy="132" r="7" fill="{INK}"/>
    <ellipse cx="128" cy="180" rx="15" ry="19" fill="{INK}"/>
  </g>
  <path d="M40 120 l-14 -22 M30 140 l-24 -8 M216 120 l14 -22 M226 140 l24 -8" stroke="#E8B423" stroke-width="7" stroke-linecap="round"/>
  <text x="128" y="50" text-anchor="middle" font-family="DejaVu Sans" font-weight="bold" font-size="56" fill="#E8B423" stroke="{INK}" stroke-width="4">!</text>""")

# Virada: olhar determinado e setas circulares
E["virada"] = svg(f"""
  <path d="M40 112 A92 92 0 0 1 196 52" fill="none" stroke="#FFD54A" stroke-width="14" stroke-linecap="round"/>
  <path d="M184 30 L214 58 L176 70 Z" fill="#FFD54A" stroke="{INK}" stroke-width="4" stroke-linejoin="round"/>
  <path d="M216 168 A92 92 0 0 1 60 228" fill="none" stroke="#FFFFFF" stroke-width="14" stroke-linecap="round"/>
  <path d="M72 250 L42 222 L80 210 Z" fill="#FFFFFF" stroke="{INK}" stroke-width="4" stroke-linejoin="round"/>"""
  + chip(cy=140, r=78) + f"""
  <path d="M90 112 L120 124" stroke="{INK}" stroke-width="8" stroke-linecap="round"/>
  <path d="M166 112 L136 124" stroke="{INK}" stroke-width="8" stroke-linecap="round"/>
  <ellipse cx="104" cy="136" rx="8" ry="10" fill="{INK}"/><ellipse cx="152" cy="136" rx="8" ry="10" fill="{INK}"/>
  <path d="M100 168 Q128 186 156 166" fill="none" stroke="{INK}" stroke-width="9" stroke-linecap="round"/>""")

# Empate: boca reta, olhos de lado, sinal de igual
E["empate"] = svg(chip() + eyes_round(130, dx=8) + f"""
  <path d="M98 178 L158 178" stroke="{INK}" stroke-width="9" stroke-linecap="round"/>
  <rect x="190" y="36" width="50" height="12" rx="6" fill="#FFFFFF" stroke="{INK}" stroke-width="4"/>
  <rect x="190" y="60" width="50" height="12" rx="6" fill="#FFFFFF" stroke="{INK}" stroke-width="4"/>
  <path d="M180 112 q8 14 0 20 q-8 -6 0 -20z" fill="#64B5F6" stroke="{INK}" stroke-width="3"/>""")

# Pontuação negativa: olhos em X, seta para baixo
E["negativo"] = svg(chip() + f"""
  <path d="M86 116 l24 24 M110 116 l-24 24" stroke="{INK}" stroke-width="9" stroke-linecap="round"/>
  <path d="M146 116 l24 24 M170 116 l-24 24" stroke="{INK}" stroke-width="9" stroke-linecap="round"/>
  <path d="M96 182 q16 -12 32 0 q16 12 32 0" fill="none" stroke="{INK}" stroke-width="8" stroke-linecap="round"/>
  <g transform="translate(206 44)">
    <circle r="32" fill="#E5484D" stroke="{INK}" stroke-width="5"/>
    <path d="M0 -16 L0 14 M-12 2 L0 16 L12 2" fill="none" stroke="#fff" stroke-width="7" stroke-linecap="round" stroke-linejoin="round"/>
  </g>""")

# Rodada de ouro: olhos de estrela e chamas douradas
STAR = "M0 -16 L5 -5 L17 -5 L7 2 L11 14 L0 7 L-11 14 L-7 2 L-17 -5 L-5 -5 Z"
E["ouro"] = svg(f"""
  <path d="M128 4 C150 40 196 40 182 88 C210 70 222 110 214 140 L42 140 C34 110 46 70 74 88 C60 40 106 40 128 4 Z"
        fill="#FF8F00" stroke="{INK}" stroke-width="6" stroke-linejoin="round"/>
  <path d="M128 40 C140 64 170 66 160 100 L96 100 C86 66 116 64 128 40 Z" fill="#FFD54A"/>"""
  + chip(cy=150, r=84) + f"""
  <path transform="translate(100 140) scale(1.25)" d="{STAR}" fill="{INK}"/>
  <path transform="translate(156 140) scale(1.25)" d="{STAR}" fill="{INK}"/>
  <path d="M94 172 Q128 208 162 172 Z" fill="{INK}"/>""")

# Líder: óculos escuros
E["lider"] = svg(chip() + f"""
  <path d="M70 118 L186 118" stroke="{INK}" stroke-width="7"/>
  <path d="M74 118 h48 v8 a22 18 0 0 1 -48 0 z" fill="{INK}"/>
  <path d="M134 118 h48 v8 a22 18 0 0 1 -48 0 z" fill="{INK}"/>
  <path d="M84 124 l10 -4" stroke="#fff" stroke-width="4" stroke-linecap="round" opacity="0.7"/>
  <path d="M144 124 l10 -4" stroke="#fff" stroke-width="4" stroke-linecap="round" opacity="0.7"/>
  <path d="M104 176 Q136 192 160 168" fill="none" stroke="{INK}" stroke-width="9" stroke-linecap="round"/>"""
  + sparkle(214, 62, 1.1))

# Ícone do app: fundo preto, ficha dourada com "iM" e cartas
ICON = f'''<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 256 256">{GOLD_DEFS}
  <rect width="256" height="256" rx="0" fill="#0B0B0B"/>
  {card(84, 70, -18, "A")}{card(172, 70, 18, "K")}
  {chip(cy=150, r=86)}
  <text x="128" y="174" text-anchor="middle" font-family="DejaVu Sans" font-weight="bold" font-size="64" fill="{INK}">iM</text>
</svg>'''

for nome, conteudo in E.items():
    p = os.path.join(OUT, f"emoji_{nome}.svg")
    open(p, "w").write(conteudo)
    subprocess.run(["rsvg-convert", "-w", "256", "-h", "256", p, "-o", p[:-4] + ".png"], check=True)
    os.remove(p)

p = os.path.join(OUT, "icone.svg")
open(p, "w").write(ICON)
subprocess.run(["rsvg-convert", "-w", "1024", "-h", "1024", p, "-o", os.path.join(OUT, "icone_1024.png")], check=True)
os.remove(p)
print("ok", sorted(os.listdir(OUT)))
