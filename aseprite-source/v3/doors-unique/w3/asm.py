import re,json
W='/tmp/claude-0/-home-user-gnome-venture/9c742976-d6c0-5f98-947e-a8c24c975813/scratchpad/doors/w3/'
SRC='/home/user/gnome-venture/aseprite-source/v3/finish/b/door.lua'
L=open(SRC).read().split('\n')
head='\n'.join(L[:261])
head=head.replace('local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$")\nlocal V3 = d .. "/../.."','local V3 = "/home/user/gnome-venture/aseprite-source/v3"')
assert 'V3 = "/home' in head
head=head.replace('local NAME = app.params.name or "cottage"','local NAME = app.params.name or "auntie-saffira"\nlocal OUT = app.params.out or "./"')
old='  c:fillMask(rect(cx - 2, cy - 11, cx + 2, cy - 9), INK)   -- ring/cap'
assert old in head
head=head.replace(old,'  if o.body then o.body(cx, cy); return end\n'+old)
lst=[d['slug'] for d in json.load(open(W+'../list3.json'))]
lua_list='local LIST = {'+','.join('"%s"'%s for s in lst)+'}\n'
foot='''
local v = V[name]
H[v.home](v)
c:save{ aseprite = OUT .. "door-" .. name .. ".aseprite", png = OUT .. "door-" .. name .. ".png", scale = 1 }
end
for _, n in ipairs(NAME == "all" and LIST or { NAME }) do build(n) end
'''
body=open(W+'new.lua').read()+'\n'+open(W+'props.lua').read()+'\n'+open(W+'homes.lua').read()+'\n'+open(W+'table.lua').read()
open(W+'gen.lua','w').write(lua_list+head+'\n'+body+foot)
