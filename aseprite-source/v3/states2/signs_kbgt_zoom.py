import sys
from PIL import Image
b=sys.argv[1]; f=int(sys.argv[2]) if len(sys.argv)>2 else 0; s=int(sys.argv[3]) if len(sys.argv)>3 else 6
im=Image.open(f"/tmp/ase/states2/{b}/{b}-empty.png").convert("RGBA"); W=im.size[0]//4; H=im.size[1]
fr=im.crop((f*W,0,(f+1)*W,H)); bg=Image.new("RGBA",(W,H),(196,226,170,255)); bg.alpha_composite(fr)
bg.resize((W*s,H*s),Image.NEAREST).convert("RGB").save(f"/tmp/claude-0/-home-user-gnome-venture/0379a473-bbc7-5af0-81bd-b41f5db92fbf/scratchpad/z_{b}.png")
