"""Angelic Voice App Icon - halo + voice waveform on celestial night."""
from PIL import Image, ImageDraw
import math, random, os

SIZE = 1024
img = Image.new('RGB', (SIZE, SIZE), (5, 5, 20))
draw = ImageDraw.Draw(img)

# Deep space gradient
for y in range(SIZE):
    ratio = y / SIZE
    r = int(5 + 22 * math.sin(ratio * math.pi))
    g = int(5 + 12 * math.sin(ratio * math.pi))
    b = int(20 + 45 * math.sin(ratio * math.pi))
    draw.line([(0, y), (SIZE, y)], fill=(r, g, b))

# Stars
random.seed(7)
for _ in range(90):
    x = random.randint(0, SIZE)
    y = random.randint(0, SIZE)
    s = random.randint(1, 3)
    bright = random.randint(110, 230)
    draw.ellipse([x, y, x+s, y+s], fill=(bright, bright, int(bright*1.1)))

center = SIZE // 2
gold = (230, 205, 128)
rune = (140, 178, 255)
cyan = (60, 190, 230)

# Halo — glowing golden ring high in the frame
halo_cy = center - 150
halo_r = 210
for w in range(18, 0, -1):
    a = int(90 * (w / 18))
    col = (min(255, gold[0]), min(255, gold[1]), min(255, gold[2] + a))
    draw.ellipse([center - halo_r - w, halo_cy - halo_r*0.45 - w,
                  center + halo_r + w, halo_cy + halo_r*0.45 + w],
                 outline=(gold[0]//2 + a//4, gold[1]//2 + a//5, gold[2]//3), width=2)
# Bright halo core ellipse
draw.ellipse([center - halo_r, halo_cy - halo_r*0.45,
              center + halo_r, halo_cy + halo_r*0.45],
             outline=gold, width=8)

# Voice waveform — concentric arcs emanating downward (the angel speaking)
wave_cy = center + 120
for i, rad in enumerate(range(90, 360, 60)):
    fade = 1 - i / 6
    col = (int(rune[0]*fade + 20), int(rune[1]*fade + 20), int(rune[2]*fade + 30))
    box = [center - rad, wave_cy - rad, center + rad, wave_cy + rad]
    draw.arc(box, start=210, end=330, fill=col, width=max(2, int(7*fade)))

# Central star / speaking point
for r in range(70, 0, -1):
    a = int(18 * (1 - r/70))
    draw.ellipse([center-r, wave_cy-r, center+r, wave_cy+r],
                 fill=(30+a*3, 45+a*3, 90+a*5))

# Four-point sparkle at the voice origin
spark = 46
for ang in (0, 90, 180, 270):
    a = math.radians(ang)
    draw.line([(center, wave_cy),
               (center + spark*math.cos(a), wave_cy + spark*math.sin(a))],
              fill=(235, 240, 255), width=4)
for ang in (45, 135, 225, 315):
    a = math.radians(ang)
    draw.line([(center, wave_cy),
               (center + spark*0.5*math.cos(a), wave_cy + spark*0.5*math.sin(a))],
              fill=cyan, width=2)
draw.ellipse([center-7, wave_cy-7, center+7, wave_cy+7], fill=(255, 255, 255))

out_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                       "AngelicVoice", "Assets.xcassets", "AppIcon.appiconset")
os.makedirs(out_dir, exist_ok=True)
img.save(os.path.join(out_dir, "icon_1024.png"), "PNG")
print("Icon saved:", os.path.join(out_dir, "icon_1024.png"))
