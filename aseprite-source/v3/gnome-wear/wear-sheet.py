import sys; sys.path.insert(0,'.')
from wear_comp import *
from PIL import Image
WD='/home/user/gnome-venture/aseprite-source/v3/gnome-wear/'
ALL=['wboots','cape','gloves','brim','pack']  # sorted by code b c g h p
BG=(132,140,124,255)
def cell(strip,f): return strip.crop((f*64,0,f*64+64,80))
# sheet 1: rows = views, cols: base f1, all f1, all f4, plus all 8 frames small? keep 4 per view
cols=[('base',0),('all',0),('all',3),('all',5),('all',1)]
S=Image.new('RGBA',(64*len(cols),80*3),BG)
for i,v in enumerate(['front','back','side']):
    full=compose(v,ALL,WD); base=compose(v)
    for j,(k,f) in enumerate(cols):
        S.alpha_composite(cell(base if k=='base' else full,f),(64*j,80*i))
S.resize((S.width*4,S.height*4),Image.NEAREST).save('wear-avatar-sheet.png')
# sheet 2: each wearable alone on the gnome (frame 1) and the bare layer
S=Image.new('RGBA',(64*10,80*3),BG)
for i,v in enumerate(['front','back','side']):
    for j,w in enumerate(ALL):
        S.alpha_composite(cell(compose(v,[w],WD),0),(128*j,80*i))
        S.alpha_composite(cell(Image.open(WD+f'{v}-{w}.png').convert('RGBA'),0),(128*j+64,80*i))
S.resize((S.width*3,S.height*3),Image.NEAREST).save('wear-alone-sheet.png')
# strip of all 8 frames all worn
S=Image.new('RGBA',(512,240),BG)
for i,v in enumerate(['front','back','side']): S.alpha_composite(compose(v,ALL,WD),(0,80*i))
S.resize((2048,960),Image.NEAREST).save('wear-walk.png')
