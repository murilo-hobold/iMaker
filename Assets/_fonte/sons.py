"""Sintetiza os efeitos sonoros do iMaker (WAV mono 16 bits, 22050 Hz)."""
import os, sys, wave
import numpy as np

SR = 22050
OUT = sys.argv[1]
os.makedirs(OUT, exist_ok=True)
rng = np.random.default_rng(7)


def t(d):
    return np.arange(int(SR * d)) / SR


def env(n, a=0.005, r=0.1, total=None):
    """Envelope ataque/decay exponencial."""
    x = np.ones(n)
    na = max(1, int(SR * a))
    x[:na] = np.linspace(0, 1, na)
    tt = np.arange(n) / SR
    return x * np.exp(-tt / max(r, 1e-3))


def tone(f, d, kind="sine", decay=0.25, vib=0.0):
    tt = t(d)
    ph = 2 * np.pi * f * tt + (vib * np.sin(2 * np.pi * 5.5 * tt) if vib else 0)
    if kind == "sine":
        w = np.sin(ph)
    elif kind == "bell":
        w = np.sin(ph) + 0.5 * np.sin(2.76 * ph) + 0.25 * np.sin(5.4 * ph)
    elif kind == "brass":
        w = sum(np.sin(k * ph) / k ** 1.1 for k in range(1, 8))
    elif kind == "square":
        w = np.sign(np.sin(ph)) * 0.6
    return w * env(len(tt), r=decay)


def silence(d):
    return np.zeros(int(SR * d))


def mix(*parts):
    n = max(len(p) for _, p in parts)
    out = np.zeros(n)
    for start, p in parts:
        s = int(SR * start)
        end = min(n, s + len(p))
        if s + len(p) > len(out):
            out = np.pad(out, (0, s + len(p) - len(out)))
        out[s:s + len(p)] += p
    return out


def lowpass(x, alpha=0.2):
    y = np.zeros_like(x)
    acc = 0.0
    for i, v in enumerate(x):
        acc += alpha * (v - acc)
        y[i] = acc
    return y


def save(nome, x, vol=0.8):
    x = x / (np.max(np.abs(x)) + 1e-9) * vol
    fade = int(SR * 0.01)
    x[-fade:] *= np.linspace(1, 0, fade)
    data = (x * 32767).astype(np.int16)
    with wave.open(os.path.join(OUT, f"som_{nome}.wav"), "wb") as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR)
        w.writeframes(data.tobytes())


# Embaralhar cartas (rodada iniciada): rajada de "estalos" + plim
riffle = []
for i in range(14):
    n = int(SR * 0.018)
    burst = lowpass(rng.standard_normal(n), 0.5) * env(n, a=0.001, r=0.006)
    riffle.append((0.02 + i * 0.022 + rng.uniform(0, 0.004), burst * (0.6 + 0.4 * np.sin(i / 3))))
save("rodada", mix(*riffle, (0.36, tone(1318.5, 0.5, "bell", 0.18) * 0.5), (0.42, tone(1760, 0.5, "bell", 0.18) * 0.4)), 0.7)

# Ponto lançado: "ding" de ficha
save("ponto", mix((0, tone(987.8, 0.35, "bell", 0.08)), (0.06, tone(1318.5, 0.45, "bell", 0.12))), 0.6)

# Vitória: fanfarra
notas = [523.25, 659.25, 783.99, 1046.5]
partes = [(i * 0.13, tone(f, 0.25, "brass", 0.15) * 0.6) for i, f in enumerate(notas)]
acorde = sum(tone(f, 1.2, "brass", 0.45) for f in [523.25, 659.25, 783.99, 1046.5]) * 0.35
partes.append((0.58, acorde))
partes += [(0.62 + i * 0.07, tone(2093 * (1 + i * 0.12), 0.3, "bell", 0.08) * 0.25) for i in range(6)]
save("vitoria", mix(*partes), 0.85)

# Derrota: trombone triste descendente
partes = [(0.0, tone(392.0, 0.42, "brass", 0.3, vib=0.0)), (0.45, tone(370.0, 0.42, "brass", 0.3)),
          (0.9, tone(349.2, 0.42, "brass", 0.3)), (1.35, tone(329.6, 1.1, "brass", 0.6, vib=1.8))]
save("derrota", lowpass(mix(*partes), 0.35), 0.75)

# Buraco: assobio descendo + baque
d = 0.7
tt = t(d)
f = 1400 * np.exp(-tt * 2.6) + 180
slide = np.sin(2 * np.pi * np.cumsum(f) / SR) * np.exp(-tt * 0.8)
thud = lowpass(rng.standard_normal(int(SR * 0.25)), 0.05) * env(int(SR * 0.25), r=0.06) * 3
thud += tone(70, 0.25, "sine", 0.1)[:len(thud)] * 0.8
save("buraco", mix((0, slide), (0.68, thud)), 0.8)

# Virada: swoosh subindo + arpejo
d = 0.45
tt = t(d)
noise = rng.standard_normal(len(tt))
sweep = np.zeros_like(noise); acc = 0
alphas = np.linspace(0.02, 0.6, len(tt))
for i, v in enumerate(noise):
    acc += alphas[i] * (v - acc); sweep[i] = acc
sweep *= np.sin(np.pi * tt / d)
arp = [(0.32 + i * 0.07, tone(fq, 0.3, "bell", 0.12) * 0.5) for i, fq in enumerate([659.25, 880, 1174.7, 1568])]
save("virada", mix((0, sweep * 0.6), *arp), 0.75)

# Empate: dois "boops" iguais
save("empate", mix((0, tone(587.3, 0.22, "square", 0.08)), (0.25, tone(587.3, 0.3, "square", 0.1))), 0.5)

# Negativo: buzz grave descendo
save("negativo", lowpass(mix((0, tone(220, 0.25, "square", 0.15)), (0.22, tone(155.6, 0.45, "square", 0.25))), 0.25), 0.7)

# Rodada de ouro: brilho rápido
partes = [(i * 0.045, tone(fq, 0.4, "bell", 0.12) * 0.45)
          for i, fq in enumerate([1046.5, 1318.5, 1568, 2093, 2637, 3136, 2637, 3136])]
save("ouro", mix(*partes), 0.7)

print(sorted(os.listdir(OUT)))
