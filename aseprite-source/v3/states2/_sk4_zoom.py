import sys
from PIL import Image
b,W,H,k=sys.argv[1],int(sys.argv[2]),int(sys.argv[3]),int(sys.argv[4])
im=Image.open(f"/tmp/ase/states2/{b}/{b}-empty.png").convert("RGBA").crop((k*W,0,k*W+W,H))
bg=Image.new("RGBA",im.size,(178,214,150,255)); bg.alpha_composite(im)
bg.resize((W*9,H*9),Image.NEAREST).save(f"/tmp/claude-0/-home-user-gnome-venture/0379a473-bbc7-5af0-81bd-b41f5db92fbf/scratchpad/z_{b}.png")
