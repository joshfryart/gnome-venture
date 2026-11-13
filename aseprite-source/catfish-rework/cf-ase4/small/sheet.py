import sys,os
from PIL import Image,ImageDraw
def sheet(rows,out,s=4,bg=(70,60,80)):
    # rows: list of list of paths
    ims=[[Image.open(p).convert('RGBA') if p and os.path.exists(p) else None for p in r] for r in rows]
    W=max(sum((i.width*s+6 if i else 6) for i in r)+6 for r in ims); H=sum(max([i.height*s for i in r if i]+[1])+6 for r in ims)+6
    im=Image.new('RGBA',(W,H),bg+(255,)); y=6
    for r in ims:
        x=6;h=1
        for i in r:
            if i:
                im.alpha_composite(i.resize((i.width*s,i.height*s),Image.NEAREST),(x,y)); x+=i.width*s+6; h=max(h,i.height*s)
            else: x+=6
        y+=h+6
    im.convert('RGB').save(out)
if __name__=='__main__':
    s=int(sys.argv[1]); out=sys.argv[2]; bg=tuple(int(v) for v in sys.argv[3].split(','))
    sheet([[p for p in a.split(',')] for a in sys.argv[4:]],out,s,bg)
