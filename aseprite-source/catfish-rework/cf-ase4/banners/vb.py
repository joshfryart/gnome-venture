import sys
from PIL import Image
D="/tmp/claude-0/-home-user-gnome-venture/5ea3a19c-b77b-53be-abcb-7211df396576/scratchpad/cf-ase4/banners/"
names=sys.argv[1:]
cols=4; s=3
W=Image.new("RGB",(80*s*cols,100*s*((len(names)+cols-1)//cols)),(90,90,90))
for i,n in enumerate(names):
    im=Image.open(D+"out/npc-%s.png"%n).convert("RGBA").resize((80*s,100*s),0)
    W.paste(im,((i%cols)*80*s,(i//cols)*100*s),im)
W.save(D+"vb.png")
