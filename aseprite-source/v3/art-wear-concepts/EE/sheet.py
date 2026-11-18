"""Contact sheet for the EE (Birchbramble Steppe) wearable concepts.
4 rows (footwear, backpack, coat, cloak) x 5 columns, icons at 3x NEAREST, name under each.
Run: python3 sheet.py  ->  sheet.png next to this file."""
import glob
import os
from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
CATS = ["footwear", "backpack", "coat", "cloak"]
NAMES = {
    "footwear": ["Birchweave Shoes", "Snowdrift Felt Boots", "Poppy Hide Moccasins", "Rider's Red Boots", "Sunflower Straw Sandals"],
    "backpack": ["Birchbark Pester", "Harvest Wicker Basket", "Beekeeper's Frame", "Flat-weave Satchel", "Fleece Drawsack"],
    "coat": ["Sheepskin Longcoat", "Stitched Felt Vest", "Red-stitch Linen Smock", "Quilted Steppe Coat", "Hedgehog Knit Cardigan"],
    "cloak": ["Shaggy Shepherd Cape", "Poppy Field Shawl", "Birch Hooded Mantle", "Wheatfield Poncho", "Fox-collar Capelet"],
}
S = 3
CW, CH = 64 * S + 24, 64 * S + 34
LW, TH = 96, 40
BG, INK, SUB = (232, 228, 218), (43, 28, 38), (110, 96, 100)


def font(size):
    for p in ["/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", "/usr/share/fonts/dejavu/DejaVuSans.ttf"]:
        if os.path.exists(p):
            return ImageFont.truetype(p, size)
    return ImageFont.load_default()


def main():
    W, H = LW + 5 * CW, TH + 4 * CH
    sheet = Image.new("RGBA", (W, H), BG + (255,))
    d = ImageDraw.Draw(sheet)
    f, fb = font(13), font(16)
    d.text((12, 10), "EE  Birchbramble Steppe  -  wearable concepts", fill=INK, font=fb)
    for r, cat in enumerate(CATS):
        y0 = TH + r * CH
        d.text((12, y0 + 64 * S // 2 - 6), cat, fill=SUB, font=f)
        for n in range(1, 6):
            hits = glob.glob(os.path.join(HERE, f"{cat}-{n}-*.png"))
            if not hits:
                continue
            im = Image.open(hits[0]).convert("RGBA")
            assert im.size == (64, 64), hits[0]
            x0 = LW + (n - 1) * CW
            sheet.alpha_composite(im.resize((64 * S, 64 * S), Image.NEAREST), (x0 + 12, y0 + 4))
            name = NAMES[cat][n - 1]
            tw = d.textlength(name, font=f)
            d.text((x0 + (CW - tw) / 2, y0 + 64 * S + 10), name, fill=INK, font=f)
    sheet.convert("RGB").save(os.path.join(HERE, "sheet.png"))


if __name__ == "__main__":
    main()
