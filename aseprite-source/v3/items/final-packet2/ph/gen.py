import subprocess, glob, os
from PIL import Image
D = "/home/user/gnome-venture/aseprite-source/v3/items/final-packet2/ph/"
L1 = '"#1c4a38","#286a3c","#3a8a3a","#5aa840","#84c450","#b0dc6c"'
S1 = '"#2a7c46","#42a448","#66c250","#92da5e","#bcec7c","#dcf89a"'
T1 = '"#5c6a3c","#7e8e48","#9ab454","#a8d060","#c4e87e"'
L2 = '"#2a3c4a","#385a52","#4a7c5a","#68a468","#8cc47a","#b4dc98"'
S2 = '"#2c6a58","#3e8e62","#58aa72","#7cc486","#a4dc9c","#ccf0b8"'
L3 = '"#3a3a4c","#4c5a6a","#648a7c","#80a890","#a4c4a8","#c8dcc0"'
S3 = '"#3a6a64","#4e8a7c","#6ca890","#90c4a8","#b4dcc0","#d8f0d8"'
L4 = '"#4a2c3c","#6a3c3c","#8a5a3a","#a8803c","#c4a450","#dcc470"'
S4 = '"#7a3c3c","#a8524a","#c8725a","#e49a6a","#f4bc84","#fcd8a4"'
T4 = '"#6a3c34","#8a5440","#a8704c","#c09060","#d4b078"'
items = [
 ("papaya-seed",'"#14100e","#2a1c18","#44302a","#5e4638","#7a5e4a","#98785c"',L1,S1,T1,1.0,1.0,"pits","#8a6a50","#d8862c",None),
 ("parsley-seed",'"#3c3a24","#58563a","#74724c","#908e60","#aaa878","#c4c294"',L2,S2,'"#4c6a3c","#68884a","#84a456","#9cc464","#b8dc80"',0.9,0.9,"stripes","#d8d4a0","#4a9a4a",None),
 ("pasque-flower-seed",'"#4a3a30","#6a5444","#8a6e58","#a8886c","#c4a484","#dcc0a0"',L3,S3,'"#7a6a8a","#9484a0","#a8b490","#b8d09c","#d0e8b4"',1.2,0.9,"none","#c8b0d8","#9a7cc0",'"#ece4f0","#dcd0e8","#c8b8dc","#b4a0c8","#8c78a8","#6c5888"'),
 ("passion-fruit-seed",'"#1c1412","#322420","#4a3830","#645048","#806a5c","#9c8672"',L1,S2,'"#6a5a3c","#887646","#a4944f","#b0c45a","#ccdc7a"',0.9,1.0,"pits","#5a4638","#e8a020",'"#fff0d0","#f8e0a8","#f0cc84","#e0b468","#b88a4c","#8a6438"'),
 ("passionflower-seed",'"#2c1c30","#443048","#5e4660","#7a6078","#96809c","#b4a0b8"',L2,S1,'"#5a5a4c","#78785a","#949c64","#a8c070","#c4dc90"',1.0,1.1,"stripes","#a890b8","#8a54a8",None),
 ("peach-seed",'"#3c1c14","#5c2c1c","#7c4228","#9c5c38","#bc7a4c","#d89a68"',L1,S4,T4,1.3,1.2,"stripes","#5c2c1c","#e8806a",'"#fff0e0","#fce0cc","#f8ccb0","#ecb494","#c88c70","#9c6450"'),
 ("peachcot-seed",'"#4a2418","#6c3822","#8c5030","#a8683c","#c48450","#dca468"',L4,S4,'"#7a3c2c","#9a5438","#b87444","#c8a050","#dcc070"',1.2,1.1,"pits","#8c5030","#f09a50",None),
 ("peanut-seed",'"#7c3a24","#a04c30","#c06a40","#d88c58","#ecac74","#f8c898"',L1,S1,T1,1.2,0.95,"spots","#8c3c28","#d8a038",None),
 ("pear-seed",'"#0c0a0a","#1c1412","#302220","#4a3430","#664a42","#84645a"',L1,S2,T1,1.0,0.9,"none","#6a4a40","#9ac040",None),
 ("pecan-seed",'"#4a2c1c","#6a4228","#8a5c34","#a87a44","#c49a5c","#dcb878"',L4,S1,'"#5a4a34","#7a6a44","#9a8c50","#a8c460","#c4dc80"',1.3,1.0,"stripes","#3c2418","#b87a3c",None),
 ("pentas-seed",'"#3a2418","#583824","#745034","#926a44","#b08658","#cca474"',L1,S3,'"#6a4a4c","#8a5a58","#a86a64","#a8c470","#c4dc90"',0.9,0.9,"spots","#2c1c14","#d8506a",'"#fff0ec","#fcdcdc","#f4c4c8","#e4a8b0","#b88490","#8a6070"'),
 ("peregrina-seed",'"#2c3a2c","#44563a","#5c7448","#789058","#96ac6c","#b4c888"',L2,S2,T1,1.0,1.0,"spots","#c4d890","#c43c3c",None),
]
for n,seed,leaf,sleaf,stem,sl,sw,m,mc,band,paper in items:
    p = f',\npaper={{{paper}}}' if paper else ''
    open(D+n+".lua","w").write(f'''-- {n} (packet P2_{n})
dofile([[/home/user/gnome-venture/aseprite-source/v3/items/seedgen/seedpacket.lua]])({{
name="{n}", dir=[[/home/user/gnome-venture/aseprite-source/v3/items]],
seed={{{seed}}}, leaf={{{leaf}}}, sleaf={{{sleaf}}}, stem={{{stem}}},
sl={sl}, sw={sw}, marks="{m}", markc="{mc}", band="{band}"{p}
}})
''')
    r = subprocess.run(["/tmp/aseq/squashfs-root/AppRun","-b","--script-param","out="+D,"--script",D+n+".lua"],capture_output=True,text=True)
    if r.returncode or r.stderr.strip(): print(n, r.stderr[-300:])
fs = [D+i[0]+".png" for i in items]
s = Image.new("RGBA",(4*192,3*192),(90,90,90,255))
for i,x in enumerate(fs):
    im = Image.open(x).convert("RGBA").resize((192,192),0)
    s.paste(im,((i%4)*192,(i//4)*192),im)
s.save("/tmp/new_sheet.png")
print("ok")
