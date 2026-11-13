import sys, os, glob, shutil
sys.path.insert(0,'/tmp/claude-0/-home-user-gnome-venture/5ea3a19c-b77b-53be-abcb-7211df396576/scratchpad/cf-ase2')
import mock_ase as m
from PIL import Image
r=m.r; r.ALIAS.clear()
B=m.B; src=B+'final2/'; dd=B+'cmp/final2/'
shutil.rmtree(dd,ignore_errors=True); os.makedirs(dd)
for f in glob.glob(src+'cf-cat-grey-*.png')+glob.glob(src+'overlays/*.png'): shutil.copy(f,dd)
FR=['idleA','idleB','blink','eartwitch','tailflick','yawn','bored','washA','washB','swatA','happy','jump','stalk','wiggle','stretch','swatB','pounce','catch','nap']
for f in glob.glob(m.O+'cf-eyes-*.png'):
    n=os.path.basename(f)
    if not os.path.exists(dd+n): shutil.copy(f,dd)
for c in ['amber','green','blue','hazel','ring']:
    for fr in FR:
        n='cf-eyes-%s-%s.png'%(c,fr)
        if not os.path.exists(dd+n) and os.path.exists(dd+'cf-eyes-%s-idleA.png'%c): shutil.copy(dd+'cf-eyes-%s-idleA.png'%c,dd+n)
COATS=[('orange','tabby','amber',None,None),('black','tuxedo','green',None,None),('cream','calico','blue',None,None),('silver-blue','pointed','blue',None,None)]
ims={}
for coat,pat,eye,ea,ta in COATS:
    for fr in FR:
        img=r.compose(coat,fr,dd,pat,eye,ea,ta,m.CF+'tones.json',m.OVJ)
        e=r.check_compose(img)
        if e: print('COMPOSE',coat,fr,pat,e)
        ims[(coat,fr)]=Image.fromarray(img,'RGBA')
S=2; cw=64*S
W=Image.new('RGBA',(len(FR)*cw, 4*cw+ 64+130*2+40),(205,205,210,255))
dark=Image.new('RGBA',W.size,(52,46,64,255))
for ri,(coat,*_) in enumerate(COATS):
    for ci,fr in enumerate(FR):
        W.alpha_composite(ims[(coat,fr)].resize((cw,cw),0),(ci*cw,ri*cw))
y0=4*cw+8
x=8
for sc in (1,2):
    for fr in FR:
        im=ims[('orange',fr)].resize((64*sc,64*sc),0)
        if x+64*sc>W.width: x=8; y0+=130
        W.alpha_composite(im,(x,y0)); x+=64*sc+2
    x=8; y0+=70
W=W.convert('RGB'); W.save(B+'mockup-final2.png'); print(W.size)
# new-frame sheet with 4 coats on dark, 3x
FR2=FR[:16]
S3=3
D=Image.new('RGBA',(8*64*S3,4*2*64*S3),(52,46,64,255))
for ri,(coat,*_) in enumerate(COATS):
    for ci,fr in enumerate(FR2):
        D.alpha_composite(ims[(coat,fr)].resize((64*S3,64*S3),0),((ci%8)*64*S3,((ci//8)+ri*2)*64*S3))
D.convert('RGB').save(B+'mockup-final2-dark3x.png')
