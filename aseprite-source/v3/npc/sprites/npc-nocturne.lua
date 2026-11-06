-- npc-nocturne sprite (npc2 P1_24) species: fruit bat
-- Night musician bat: tall pink-lined ears, tan pug muzzle with a fang, plum wing membranes folded like a cloak,
-- orange knit scarf. Prop: a little wooden flute held across the chest.
-- Idle: f2 breath (body 1px down, scarf tail sways), f4 right-ear twitch. Feet + shadow fixed.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-nocturne"
local R = {
  fur   = { hi = "#a3829a", base = "#765a74", shade = "#523e5c", deep = "#382a44" },
  muz   = { hi = "#f6d2a6", base = "#dca282", shade = "#ab7072", deep = "#764c5c" },
  mem   = { hi = "#cf94b0", base = "#a0628c", shade = "#70426e", deep = "#4a2d52" },
  scarf = { hi = "#ffc674", base = "#f28c3c", shade = "#c25a30", deep = "#883c36" },
  wood  = { hi = "#ecbb7a", base = "#bb8452", shade = "#8b5739", deep = "#5c3b31" },
  ear   = { hi = "#f4b4bc", base = "#d9838f", shade = "#a45a78", deep = "#6e3e5c" },
}
local function mir(t) local o = {} for i, q in ipairs(t) do o[i] = { 64 - q[1], q[2] } end return o end
local function sh(t, dy) local o = {} for i, q in ipairs(t) do o[i] = { q[1], q[2] + dy } end return o end

local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b, st, et = p.b or 0, p.st or 0, p.et or 0
  c:groundShadow(32, 89.5, 12, 3)
  c:part(c:ellipse(28, 88.5, 2.5, 1.5), R.fur, { band = 1, nopop = true })
  c:part(c:ellipse(36, 88.5, 2.5, 1.5), R.fur, { band = 1, nopop = true })
  -- folded wing-cloak with scalloped hem + finger ribs
  local cloak = c:poly{ { 23, 60 + b }, { 41, 60 + b }, { 47, 86 + b }, { 17, 86 + b } }
  for _, x in ipairs{ 22, 32, 42 } do cloak:cut(c:ellipse(x, 87.5 + b, 3, 1.5)) end
  c:part(cloak, R.mem, { band = 2, pop = { x = 24, y = 64 + b } })
  local inn = cloak:shrink(1)
  for _, l in ipairs{ { { 25, 61 }, { 18, 86 } }, { { 29, 62 }, { 27, 86 } }, { { 35, 62 }, { 37, 86 } }, { { 39, 61 }, { 46, 86 } } } do
    c:fillMask(c:line(sh(l, b), 1):clip(inn), R.mem.shade)
  end
  c:fillMask(c:line(sh({ { 32, 64 }, { 32, 85 } }, b), 1):clip(inn), R.mem.deep)
  -- knit scarf + hanging tail
  local sc = c:rrect(21, 58 + b, 43, 63 + b, 2)
  c:part(sc, R.scarf, { band = 1, pop = { x = 23, y = 59 + b } })
  for x = 24, 41, 3 do c:put(x, 61 + b, R.scarf.shade) end
  local tail = c:poly{ { 24, 61 + b }, { 29, 62 + b }, { 26 + st, 74 + b }, { 21 + st, 73 + b } }
  c:part(tail, R.scarf, { band = 1, nopop = true })
  for i = 0, 4, 2 do c:put(21 + st + i, 73 + b, R.scarf.deep) end
  for x = 22, 28 do if tail:has(x + st, 68 + b) then c:put(x + st, 68 + b, R.scarf.hi) end end
  -- flute across the chest + paws
  local fl = c:line(sh({ { 19, 70 }, { 45, 79 } }, b), 2)
  c:part(fl, R.wood, { band = 1, pop = { x = 21, y = 70 + b } })
  for _, x in ipairs{ 31, 34, 40 } do local y = math.floor(70 + (x - 19) * 9 / 26 + 0.5) + b if fl:has(x, y) then c:put(x, y, R.wood.deep) end end
  c:part(c:ellipse(26, 72.5 + b, 2, 2), R.fur, { band = 1, nopop = true })
  c:part(c:ellipse(37, 76.5 + b, 2, 2), R.fur, { band = 1, nopop = true })
  -- tall ears (inner pink), right one twitches
  local L = { { 21, 45 }, { 16, 18 }, { 19, 17 }, { 30, 39 } }
  local Li = { { 22, 40 }, { 18, 22 }, { 19.5, 21 }, { 27, 38 } }
  local Rr, Ri = mir(L), mir(Li)
  Rr[2] = { Rr[2][1] + et, Rr[2][2] + et } Rr[3] = { Rr[3][1] + et, Rr[3][2] + et }
  Ri[2] = { Ri[2][1] + et, Ri[2][2] + et } Ri[3] = { Ri[3][1] + et, Ri[3][2] + et }
  c:part(c:poly(sh(L, b)), R.fur, { band = 1, pop = { x = 18, y = 20 + b } })
  c:part(c:poly(sh(Rr, b)), R.fur, { band = 1, nopop = true })
  c:part(c:poly(sh(Li, b)), R.ear, { band = 1, nopop = true, inner = false })
  c:part(c:poly(sh(Ri, b)), R.ear, { band = 1, nopop = true, inner = false })
  -- tuft + head
  c:part(c:poly(sh({ { 29, 40 }, { 30, 35 }, { 32, 38 }, { 34, 35 }, { 35, 40 } }, b)), R.fur, { band = 1, nopop = true })
  local head = c:ellipse(32, 48 + b, 13, 10.5)
  c:part(head, R.fur, { band = 2, pop = { x = 24, y = 42 + b } })
  local muz = c:ellipse(32, 54 + b, 6.5, 3.5)
  c:part(muz, R.muz, { band = 1, pop = { x = 28, y = 52 + b } })
  c:eyeLocked(24, 45 + b) c:eyeLocked(36, 45 + b)
  c:put(31, 51 + b, R.ear.base) c:put(32, 51 + b, R.ear.base)
  c:put(30, 52 + b, R.ear.shade) c:put(31, 52 + b, R.muz.deep) c:put(32, 52 + b, R.muz.deep) c:put(33, 52 + b, R.ear.shade)
  for _, q in ipairs{ { 29, 55 }, { 30, 56 }, { 31, 56 }, { 32, 56 }, { 33, 56 }, { 34, 55 } } do c:put(q[1], q[2] + b, P.ink) end
  c:put(33, 57 + b, P.cream)
  for _, x in ipairs{ 21, 22, 41, 42 } do c:put(x, 52 + b, R.ear.base) end
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local FR = { { b = 0 }, { b = 1, st = 1 }, { b = 0 }, { b = 0, et = 1 } }
local DUR = { 0.45, 0.4, 0.45, 0.2 }
local frames = {}
for _, p in ipairs(FR) do frames[#frames + 1] = frame(p) end
local W, H, N = 64, 96, #frames
local pc = app.pixelColor
local function rgba(h) return pc.rgba(tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16), 255) end
local strip = Image(W * N, H, ColorMode.RGB) strip:clear(pc.rgba(0, 0, 0, 0))
local spr = Sprite(W, H, ColorMode.RGB)
for _ = 2, N do spr:newEmptyFrame() end
for f, c in ipairs(frames) do
  local im = Image(W, H, ColorMode.RGB) im:clear(pc.rgba(0, 0, 0, 0))
  for i, hex in pairs(c.pix) do im:putPixel(i % W, i // W, rgba(hex)) strip:putPixel((f - 1) * W + i % W, i // W, rgba(hex)) end
  spr:newCel(spr.layers[1], spr.frames[f], im, Point(0, 0))
  spr.frames[f].duration = DUR[f]
end
spr.layers[1].name = NAME
local tg = spr:newTag(1, N) tg.name = "idle"
spr:saveAs(out .. NAME .. ".aseprite") spr:close()
local s2 = Sprite(W * N, H, ColorMode.RGB) s2.cels[1].image = strip
s2:saveCopyAs(out .. NAME .. ".png") s2:close()
print(NAME .. " ok")
