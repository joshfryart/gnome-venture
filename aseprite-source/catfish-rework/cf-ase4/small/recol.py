import sys, os, json
sys.path.insert(0,'/home/user/gnome-venture/tools')
import catfish_recolor as r
CF='/home/user/gnome-venture/aseprite-source/catfish/'
B=os.path.dirname(os.path.abspath(__file__))+'/'
_orig=r.ramp
def ramp2(base):   # same runtime patch as cf-ase2/mock_ase.py (lift + rim roles)
    o=_orig(base); a,b=r.h2rgb(o['base']),r.h2rgb(o['light'])
    o['lift']=r.hex_([(x+y)//2 for x,y in zip(a,b)])
    h,s,l=r.to_hsl(o['shade']); o['rim']=r.from_hsl(r.toward(h,265,40),min(1,s*0.9),min(0.9,l*1.12))
    return o
r.ramp=ramp2
glob=sys.argv[1]
sys.exit(r.main(['--in',B+'out/','--out',B+'out/','--check','--tones',CF+'tones.json','--overlays',B+'tones_overlays.ase.json','--glob',glob]))
