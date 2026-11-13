import sys
from PIL import Image
D="/tmp/claude-0/-home-user-gnome-venture/5ea3a19c-b77b-53be-abcb-7211df396576/scratchpad/cf-ase4/banners/"
im=Image.open(D+"out/banner-%s-pets.png"%sys.argv[1]); 
im.resize((960,240),0).save(D+"v1.png")
