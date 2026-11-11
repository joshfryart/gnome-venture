import re
SRC='/home/user/gnome-venture/aseprite-source/v3/finish/b/door.lua'
L=open(SRC).read().split('\n')
def seg(a,b): return '\n'.join(L[a-1:b])
head=seg(1,261)
head=head.replace('local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$")\nlocal V3 = d .. "/../.."','local V3 = "/home/user/gnome-venture/aseprite-source/v3"')
assert 'V3 = "/home' in head
head=head.replace('local NAME = app.params.name or "cottage"','local NAME = app.params.name or "clementine-moss"\nlocal OUT = app.params.out or "./"')
# ---------- COTTAGE (snail) from lines 266-310
cot=seg(266,310)
cot=cot.replace('local function cottage()','local function clementine()')
cot=cot.replace('P(x, y, THATCH[GX.idx(v)])','P(x, y, MOSSR[GX.idx(v)])')
cot=cot.replace('  window(130, 116, 166, 152, TEAL, true, { "#f0809c", "#ffd24a", "#e8493b", "#c8b8ec" })\n  window(372, 116, 408, 152, TEAL, true, { "#ffd24a", "#f5a0c0", "#fff2dc", "#e8493b" })\n','  headband()\n  goggle(148, 128); goggle(388, 128)\n')
cot=cot.replace('door{ shape = "arch", x0 = DX0, y0 = DY0, x1 = DX1, y1 = DY1, frame = TIMB, wood = BARN, seed = 3, pw = 7, straps = { 150, 186 } }','door{ shape = "arch", x0 = DX0, y0 = DY0, x1 = DX1, y1 = DY1, frame = TIMB, wood = BLUEW, seed = 3, pw = 7, kx = 254, ky = 180 }\n  spiral(240, 166, 11)')
cot=cot.replace('  snail(207, 204)\n','  trail()\n  can(176, 205); cabbages()\n')
cot=cot.replace('plate(240, 84, TIMB)','plate(240, 84, BLUEW)')
cot=cot.replace('{ "#f0809c", "#ffd24a", "#fff2dc" }, function(x) return x > 190 and x < 290 end)','{ "#8fc0f0", "#ffd24a", "#fff2dc" }, function(x) return x > 190 and x < 290 end)')
assert 'goggle(148' in cot and 'trail()' in cot and 'spiral(' in cot and 'MOSSR' in cot
# ---------- BURROW from 313-353
bur=seg(313,353).replace('local function burrow()','local function bracken()')
old='door{ shape = "round", x0 = 207, y0 = 135, x1 = 272, y1 = 203, f = 5, frame = STONE, wood = GOLD, seed = 6, pw = 8, blocks = true, straps = { 150, 183 }, kx = 240, ky = 170 }'
assert old in bur
bur=bur.replace(old,'door{ shape = "round", x0 = 207, y0 = 135, x1 = 272, y1 = 203, f = 5, frame = STONE, wood = REDW, seed = 6, pw = 8, blocks = true, kx = 256, ky = 186 }\n  elytra()')
i=bur.index('  mushroom(192'); j=bur.index('  lantern(300')
bur=bur[:i]+'  trellis(168); acorn(286, 206); antennae()\n'+bur[j:]
# ---------- HUT from 402-480
hut=seg(402,480).replace('local function hut()','local function twigg()')
old='door{ shape = "rect", x0 = DX0, y0 = DY0, x1 = DX1, y1 = DY1, f = 4, frame = TIMB, wood = DIRT, woven = true, seed = 2, kx = 255, ky = 178 }'
assert old in hut
hut=hut.replace(old,'door{ shape = "rect", x0 = DX0, y0 = DY0, x1 = DX1, y1 = DY1, f = 4, frame = TIMB, wood = VIO, woven = true, seed = 2, kx = 255, ky = 186 }\n  moonstars()')
hut=hut.replace('plate(240, 84, DIRT, { w = 44 })','plate(240, 84, VIO, { w = 44 })')
i=hut.index('  -- chili string'); j=hut.index('  for i = 1, 16 do tuft')
hut=hut[:i]+'  herbs(172); herbs(192); chimes(206); staff(196)\n'+hut[j:]
new=open('new.lua').read()
foot='''

local F = { ["clementine-moss"] = clementine, ["bracken-spurwing"] = bracken, ["old-twigg"] = twigg }
F[name]()
c:save{ aseprite = OUT .. "door-" .. name .. ".aseprite", png = OUT .. "door-" .. name .. ".png", scale = 1 }
end

for _, n in ipairs(NAME == "all" and { "clementine-moss", "bracken-spurwing", "old-twigg" } or { NAME }) do build(n) end
'''
# the head ends inside build(); helpers 'new' live after head and before builders
open('door-gen.lua','w').write(head+'\n'+new+'\n'+cot+'\n'+bur+'\n'+hut+'\n'+foot)
