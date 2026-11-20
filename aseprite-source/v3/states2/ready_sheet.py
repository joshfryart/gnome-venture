import sys
from PIL import Image
b=sys.argv[1]; d=f"/tmp/ase/states2/{b}/"
import shutil; shutil.copy(d+f"{b}-ready.png", d+f"{b}-ready-l1.png")
rows=[Image.open(d+f"{b}-ready-l{i}.png").convert("RGBA") for i in (1,2,3)]
w,h=rows[0].size
S=Image.new("RGBA",(w*2,h*2*3),(190,226,160,255))
for i,r in enumerate(rows):
    r=r.resize((w*2,h*2),Image.NEAREST); S.alpha_composite(r,(0,i*h*2))
S.save(d+f"{b}-ready-sheet.png")
for i in (2,3):
    im=Image.open(d+f"{b}-ready-l{i}.png"); print(b,i,set(im.getchannel('A').getdata()))
