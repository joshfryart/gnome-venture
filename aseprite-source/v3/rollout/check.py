#!/usr/bin/env python3
"""Check which items of a run exist in v3/items/final and are 64x64. Usage: python3 check.py run1.json"""
import json,sys,os
from PIL import Image
R=os.path.dirname(os.path.abspath(__file__));F=os.path.join(R,'..','items','final')
items=json.load(open(os.path.join(R,sys.argv[1])))
miss=[];bad=[]
for it in items:
    p=os.path.join(F,it['folder'],it['name']+'.png')
    if not os.path.exists(p): miss.append(it['folder']+'/'+it['name']);continue
    im=Image.open(p)
    if im.size!=(64,64): bad.append((it['name'],im.size))
    px=im.convert('RGBA').getdata()
    if any(0<a<255 for *_,a in px): bad.append((it['name'],'semi-transparent'))
print(len(items),'items;',len(miss),'missing;',len(bad),'bad');print('missing:',miss);print('bad:',bad)
