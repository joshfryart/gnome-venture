import sys
from PIL import Image
slot=sys.argv[1]
R="/home/user/gnome-venture/game/assets/img/catfish/"
rows=[l.strip().split('|') for l in open("items.txt")]
its=[r[1] for r in rows if r[0]==slot]
S=4
def build(bg):
    ims=[]
    for k in its:
        o=Image.open(R+f"cf-pet-{k}.png").convert("RGBA"); n=Image.open(f"out/cf-pet-{k}.png").convert("RGBA")
        ims.append((o,n))
    w,h=ims[0][0].size
    cols=min(len(its),5)
    nr=(len(its)+cols-1)//cols
    sh=Image.new("RGBA",(cols*(w+3),nr*2*(h+3)),bg)
    for i,(o,n) in enumerate(ims):
        cx=(i%cols)*(w+3)+1; cy=(i//cols)*2*(h+3)+1
        sh.paste(o,(cx,cy),o); sh.paste(n,(cx,cy+h+3),n)
    return sh.resize((sh.width*S,sh.height*S),0)
a=build((222,200,160,255)); b=build((52,40,70,255))
o=Image.new("RGBA",(a.width*2+8,a.height),(0,0,0,255)); o.paste(a,(0,0)); o.paste(b,(a.width+8,0))
o.save(f"sheet-{slot}.png"); print(o.size)
