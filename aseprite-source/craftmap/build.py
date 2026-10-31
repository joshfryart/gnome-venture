import json, base64, os
R='/home/user/gnome-venture/aseprite-source/craftmap/scenes/'
OUT='/tmp/claude-0/-home-user-gnome-venture/7ac7affd-f84b-5ac0-9631-db667c6f0949/scratchpad/art/crafting-area-map.html'
AREAS=[
 ('cooking','Cooking','imp/kitchen','Meals from your harvests and the wild.',8,85,'3 ready',None),
 ('pantry','Pantry','med/pantry','Jam, pickles and cordials in real days.',4,40,'2 jars done',None),
 ('tools','Tools','imp/tools','Upgrade your tools with gathered things.',2,30,'Needs a Tool Shed','lock'),
 ('garden','Garden supplies','imp/garden','Compost, loam and mulch.',6,12,'1 ready',None),
 ('potions','Potions','imp/alchemy','Healing Potions for Pals on jobs.',3,9,None,None),
 ('building','Building','imp/building','Stone, timber and rope for repairs.',5,18,'2 ready',None),
 ('decor','Yard & decor','imp/decor','Paths, fences and ornaments.',9,40,None,None),
]
EX={
'oven':[('Honey Loaf','2/2 flour, 1/1 honey',1),('Mushroom Pie','1/2 mushroom, 2/2 flour',0)],
'produce':[('Root Stew','3/3 carrot, 2/2 beet',1),('Garden Salad','1/2 cabbage',0)],
'stove':[('Berry Porridge','2/2 oats, 4/4 berries',1),('Pepper Soup','0/3 pepper',0)],
'rack':[('Skillet Eggs','1/1 egg, 1/1 butter',1)],
'table':[('Cheese Sandwich','1/1 loaf, 1/1 cheese',1),('Herb Butter','1/2 herbs',0)],
'jams':[('Plum Jam','4/4 plums, 2/2 sugar',1),('Gooseberry Jam','0/4 gooseberry',0)],
'cheese':[('Cloth Cheese','2/2 milk',1)],
'cordials':[('Elderflower Cordial','3/3 flowers, 1/1 sugar',1),('Mint Cordial','1/3 mint',0)],
'crock':[('Dill Pickles','5/5 cucumber, 1/1 dill',1)],
'kraut':[('Sauerkraut','2/2 cabbage, 1/1 salt',1)],
'rack_t':[],
'bench':[('Sturdy Handle','2/2 oak, 1/1 twine',1)],
'anvil':[('Masterwork Hammer','1/3 iron, 1/1 coal',0),('Iron Trowel','3/3 iron',1)],
'toolbox':[('Mending Kit','2/2 twine, 1/1 nails',1)],
'grindstone':[('Sharp Edge','1/1 flint',1)],
'can':[('Copper Can','0/2 copper',0)],
'sacks':[('Rich Loam','3/3 leaf mould, 2/2 soil',1)],
'compost':[('Compost','4/4 scraps, 2/2 leaves',1)],
'seeds':[('Seed Tray','2/2 plank, 1/1 soil',1)],
'barrow':[('Bark Mulch','3/3 bark',1)],
'flasks':[('Healing Potion','2/2 herb, 1/1 flask',1),('Strong Healing','1/3 herb',0)],
'mortar':[('Ground Herbs','4/4 herb',1)],
'cauldron':[('Brew Base','1/1 spring water, 2/2 moss',1)],
'book':[('Recipe Notes','Read what you know',1)],
'still':[('Spirit of Mint','0/3 mint',0)],
'pulley':[('Rope Pulley','1/1 rope, 2/2 iron',1)],
'sawhorse':[('Timber Beam','3/3 log',1)],
'stones':[('Dressed Stone','4/4 rough stone',1),('Arch Keystone','1/2 dressed stone',0)],
'rope':[('Stout Rope','6/6 fibre',1)],
'timber':[('Plank Bundle','4/4 log',1)],
'lantern':[('Iron Lantern','1/1 iron, 1/1 glass',1)],
'planter':[('Clay Planter','2/2 clay',1)],
'birdbath':[('Stone Birdbath','0/3 dressed stone',0)],
'fence':[('Picket Fence','4/4 plank',1),('Gate','1/2 plank',0)],
'path':[('Stepping Stones','6/6 pebble',1)],
}
EX['rack']=[('Skillet Eggs','1/1 egg, 1/1 butter',1)]
def b64(p): return 'data:image/png;base64,'+base64.b64encode(open(p,'rb').read()).decode()
data=[]
for k,l,s,bl,h,t,badge,lock in AREAS:
    j=json.load(open(R+s+'.json'))
    hs=[]
    for hp in j['hotspots']:
        hid=hp['id']; key=hid
        if k=='tools' and hid=='rack': ex=[('Tool Hangers','2/2 plank, 1/1 nails',1)]
        else: ex=EX.get(hid,[])
        hs.append(dict(id=hid,label=hp['label'],x=hp['x']/300*100,y=hp['y']/200*100,w=hp['w']/300*100,h=hp['h']/200*100,rec=[dict(n=a,i=b,ok=c) for a,b,c in ex]))
    data.append(dict(key=k,label=l,img=b64(R+s+'.png'),blurb=bl,have=h,total=t,badge=badge,lock=lock,hs=hs))
tpl=open(os.path.join(os.path.dirname(OUT),'tpl.html')).read()
open(OUT,'w').write(tpl.replace('/*DATA*/null',json.dumps(data)))
print(os.path.getsize(OUT)//1024,'KB')
