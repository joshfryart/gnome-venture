import sys; from PIL import Image; import numpy as np
M={'#2b1c26':'#','#3d3654':'D','#57516f':'s','#6e6684':'b','#8a859b':'m','#aca7b9':'l','#cdc9d3':'L','#f1ebe3':'g','#646691':'r','#2a1a10':'u','#4a2c1a':'U','#74462a':'W','#f2e4c0':'c','#e8909e':'p','#c66a80':'P'}
a=np.array(Image.open(sys.argv[1]).convert('RGBA'))
y0,y1=(int(sys.argv[2]),int(sys.argv[3])) if len(sys.argv)>3 else (0,a.shape[0])
for y in range(y0,y1): print('%2d '%y+''.join(M.get('#%02x%02x%02x'%tuple(a[y,x,:3]),'?') if a[y,x,3] else '.' for x in range(a.shape[1])))
