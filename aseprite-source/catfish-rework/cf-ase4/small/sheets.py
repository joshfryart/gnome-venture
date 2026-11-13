from sheet import sheet
O='/home/user/gnome-venture/game/assets/img/catfish/'; N='out/'
NC='/tmp/claude-0/-home-user-gnome-venture/5ea3a19c-b77b-53be-abcb-7211df396576/scratchpad/cf-ase2/final2/'
yi='balls bio buddy bunting catnip collar hold keepsake scarf season show2 stake titles treat tune'.split()
cols='rose mint sky gold violet red'.split()
from PIL import Image
def comp(dirs,frame,col):
    p='out/_c_%s_%s.png'%(frame,col)
    k=Image.open(NC+'cf-cat-grey-%s.png'%frame).convert('RGBA'); k.alpha_composite(Image.open(N+'cf-collar-%s-%s.png'%(col,frame)).convert('RGBA')); k.save('v/'+p.split('/')[1]); return 'v/'+p.split('/')[1]
G={}
G['yi']=([O+'cf-yi-%s.png'%k for k in yi[:8]],[N+'cf-yi-%s.png'%k for k in yi[:8]],[O+'cf-yi-%s.png'%k for k in yi[8:]],[N+'cf-yi-%s.png'%k for k in yi[8:]])
G['collar']=tuple([O+'cf-collar-%s-%s.png'%(c,f) for c in cols] for f in ('idleA','pounce')) + tuple([comp(0,f,c) for c in cols] for f in ('idleA','pounce','catch','nap'))
sm=[]
G['bits']=([O+'cf-yarn-%d%s.png'%(i,s) for i in (1,2,3,4) for s in ('','-rose','-gold')]+[O+'cf-bird-%d.png'%i for i in (1,2,3)],
 [N+'cf-yarn-%d%s.png'%(i,s) for i in (1,2,3,4) for s in ('','-rose','-gold')]+[N+'cf-bird-%d.png'%i for i in (1,2,3)],
 [O+'cf-yarn-%d-%s.png'%(i,s) for i in (2,) for s in ('mint','violet')]+[O+'cf-season-%s.png'%b for b in 'petal petal-b firefly firefly-b leaf leaf-b flake flake-small'.split()],
 [N+'cf-yarn-%d-%s.png'%(i,s) for i in (2,) for s in ('mint','violet')]+[N+'cf-season-%s.png'%b for b in 'petal petal-b firefly firefly-b leaf leaf-b flake flake-small'.split()])
co='black brown cream grey lilac orange silver-blue white'.split()
G['big']=([O+'cf-tile.png',N+'cf-tile.png']+[O+'cf-bookhead-%s.png'%c for c in co],[N+'cf-bookhead-%s.png'%c for c in co])
for g,rows in G.items():
    for nm,bg in (('light',(236,224,200)),('dark',(40,34,50))):
        sheet([list(r) for r in rows],'out/sheet-%s-%s.png'%(g,nm),4,bg)
sheet([[O+'cf-banner.png'],[N+'cf-banner.png']],'out/sheet-banner-light.png',2,(236,224,200))
sheet([[O+'cf-banner.png'],[N+'cf-banner.png']],'out/sheet-banner-dark.png',2,(40,34,50))
