import sys
from PIL import Image
b=sys.argv[1]; W,H=(72,56) if b=="frog_pond" else (56,56)
d=f"/tmp/ase/states2/{b}/"
import shutil; shutil.copy(d+f"{b}-ready.png",d+f"{b}-ready-l1.png")
S=2; sh=Image.new("RGBA",(4*W*S+16,3*H*S+16),(196,226,160,255))
for r,l in enumerate(("l1","l2","l3")):
    a=Image.open(d+f"{b}-ready-{l}.png").convert("RGBA")
    assert a.size==(4*W,H)
    assert set(a.getchannel("A").getdata())<={0,255}
    sh.alpha_composite(a.resize((4*W*S,H*S),Image.NEAREST),(8,8+r*H*S))
sh.save(d+f"{b}-ready-sheet.png")
