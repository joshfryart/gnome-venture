-- npc-fern-sunpatch sprite (npc2 P1_11) species: tree frog
-- Sunny tree frog in a plum rain-hood (droopy tip to the LEFT, sun-yellow lining); eyes bulge out of the hood. Prop: a sunflower she carries.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local out = app.params.out or (DIR .. "/")
local INK, CREAM = "#2b1c26", "#fbf1d4"
local function F(c, m, r, band, pop)
  c:part(m, r, { band = band or 2, nopop = not pop, pop = pop and { x = math.floor(pop[1]), y = math.floor(pop[2]) } or nil })
  return m
end
local function under(c, m, hex)
  local l = {} m:each(function(x, y) if not m:has(x, y + 1) then l[#l + 1] = { x, y } end end)
  for _, q in ipairs(l) do c:put(q[1], q[2], hex) end
end
local function fuzz(m, list) for _, b in ipairs(list) do m:add(HP.ellipse(b[1], b[2], b[3] or 1.5, b[3] or 1.5)) end return m end
local function ring(cx, cy, rx, ry, a0, a1, st, r) local t = {} for a = a0, a1, st do local q = math.rad(a) t[#t + 1] = { cx + math.cos(q) * rx, cy + math.sin(q) * ry, r } end return t end
local function overlay(c, mask, r, from)
  local L = {}
  mask:each(function(x, y) local v = c:get(x, y)
    if v == from.base or v == from.hi then L[#L + 1] = { x, y, r.base } elseif v == from.shade then L[#L + 1] = { x, y, r.shade } elseif v == from.deep then L[#L + 1] = { x, y, r.deep } end end)
  for _, q in ipairs(L) do c:put(q[1], q[2], q[3]) end
end
local function lineOn(c, pts, hex, clipm) c:line(pts, 1):clip(clipm):each(function(x, y) c:put(x, y, hex) end) end
local function eye(c, x, y, blink)
  if blink then for i = 0, 3 do c:put(x + i, y + 2, INK) end c:put(x, y + 1, INK) c:put(x + 3, y + 1, INK) return end
  c:put(x + 1, y, INK) c:put(x + 2, y, INK)
  for _, q in ipairs{ {0,1},{3,1},{0,2},{3,2},{1,3},{2,3} } do c:put(x + q[1], y + q[2], CREAM) end
  c:put(x + 1, y + 1, CREAM) c:put(x + 2, y + 1, INK) c:put(x + 1, y + 2, INK) c:put(x + 2, y + 2, INK)
end
local NAME = "npc-fern-sunpatch"
local SKIN  = { hi = "#b8e06a", base = "#6fb84a", shade = "#3f7f4c", deep = "#2c4f4a" }
local BELLY = { hi = "#f8efc4", base = "#e8d898", shade = "#b9a47e", deep = "#7d6a6e" }
local HOOD  = { hi = "#b07ad0", base = "#7d4fa8", shade = "#563a86", deep = "#3a2862" }
local SUN   = { hi = "#ffeaa0", base = "#f5c64a", shade = "#cd8a3a", deep = "#8a563a" }
local SEED  = { hi = "#b0743e", base = "#7a4a32", shade = "#523248", deep = "#3a2433" }
local LEAF  = { hi = "#9fd35a", base = "#5a9a3c", shade = "#366b45", deep = "#24463f" }
local function sunflower(c, fx, fy)
  local m = HP.mask()
  for i = 0, 9 do local a = math.rad(i * 36) m:add(c:ellipse(fx + math.cos(a) * 4, fy + math.sin(a) * 4, 1.8, 1.8)) end
  F(c, m, SUN, 1, { fx - 4, fy - 3 })
  F(c, c:ellipse(fx, fy, 2.6, 2.6), SEED, 1, { fx - 1, fy - 1 })
end
function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b = p.b or 0
  c:groundShadow(32, 89, 15, 3)
  -- thighs + webbed feet (never move)
  F(c, c:ellipse(25, 84, 4.5, 3), SKIN, 1) F(c, c:ellipse(39, 84, 4.5, 3), SKIN, 1)
  for _, x in ipairs{ 24, 40 } do
    local m = c:ellipse(x, 88.5, 5, 2) F(c, m, SKIN, 1, { x - 3, 87 })
    c:put(x - 2, 90, SKIN.deep) c:put(x + 1, 90, SKIN.deep)
  end
  -- poncho with scalloped hem, open front showing pale belly
  local pm = c:poly{ { 22, 53 + b }, { 42, 53 + b }, { 48, 81 + b }, { 16, 81 + b } }
  for _, x in ipairs{ 18, 24, 30, 36, 42, 46 } do pm:add(c:ellipse(x, 81 + b, 2.5, 1.5)) end
  F(c, pm, HOOD, 2)
  lineOn(c, { { 25, 60 + b }, { 21, 79 + b } }, HOOD.shade, pm)
  lineOn(c, { { 40, 60 + b }, { 44, 79 + b } }, HOOD.deep, pm)
  under(c, pm, HOOD.deep)
  F(c, c:ellipse(32, 71 + b, 7, 8.5), BELLY, 1, { 28, 65 + b })
  -- left hand on belly; right hand holds the sunflower
  F(c, c:ellipse(24, 67 + b, 3, 2.5), SKIN, 1, { 23, 66 + b })
  local fx, fy = 48 + (p.tw or 0), 32 + b + (p.fd or 0)
  local stem = c:line({ { 43, 67 + b }, { 46, 52 + b }, { fx, fy + 3 } }, 2)
  F(c, stem, LEAF, 1)
  F(c, c:ellipse(49, 50 + b + (p.fd or 0), 3, 1.5), LEAF, 1, { 47, 49 + b })
  F(c, c:ellipse(43, 64 + b, 3, 2.5), SKIN, 1, { 42, 63 + b })
  -- hood: round cowl, tip flops LEFT
  local hm = c:ellipse(32, 40 + b, 19, 14)
  hm:add(c:line({ { 18, 32 + b }, { 12, 27 + b }, { 8, 31 + b + (p.tip or 0) } }, 4))
  F(c, hm, HOOD, 2, { 20, 30 + b })
  for _, q in ipairs{ { 21, 29 }, { 22, 29 }, { 23, 28 } } do c:put(q[1], q[2] + b, HOOD.hi) end
  under(c, hm, HOOD.deep)
  F(c, c:ellipse(32, 46 + b, 15.5, 10), SUN, 1)
  -- frog face in the opening
  F(c, c:ellipse(32, 47 + b, 13.5, 8.5), SKIN, 2, { 24, 43 + b })
  for _, ex in ipairs{ 25, 39 } do F(c, c:ellipse(ex, 39 + b, 5, 4.5), SKIN, 1, { ex - 3, 36 + b }) end
  eye(c, 23, 37 + b, p.blink) eye(c, 37, 37 + b, p.blink)
  c:put(30, 45 + b, SKIN.deep) c:put(34, 45 + b, SKIN.deep)
  for x = 25, 39 do local y = (x <= 26 or x >= 38) and 49 or 50 c:put(x, y + b, "#4a2a3a") end
  for _, q in ipairs{ { 22, 48 }, { 23, 48 }, { 41, 48 }, { 42, 48 } } do c:put(q[1], q[2] + b, "#e88a8a") end
  sunflower(c, fx, fy)
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
IDLE = { { b = 0 }, { b = 1, tip = 1, fd = 1 }, { b = 0 }, { b = 0, blink = true, tw = 1 } }
local W, H = 64, 96
local frames = {}
for _, p in ipairs(IDLE) do frames[#frames + 1] = frame(p) end
local s = HP.sheet{ cellw = W, cellh = H, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }
s:save{ png = out .. NAME .. ".png", scale = 1 }
local pc = app.pixelColor
local function rgba(h) return pc.rgba(tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16), 255) end
local spr = Sprite(W, H, ColorMode.RGB)
for _ = 2, #frames do spr:newEmptyFrame() end
spr.layers[1].name = "npc"
for f, c in ipairs(frames) do
  local im = Image(W, H, ColorMode.RGB) im:clear(pc.rgba(0, 0, 0, 0))
  for i, hex in pairs(c.pix) do im:putPixel(i % W, i // W, rgba(hex)) end
  spr:newCel(spr.layers[1], spr.frames[f], im, Point(0, 0))
  spr.frames[f].duration = (f == 2) and 0.5 or 0.35
end
local tg = spr:newTag(1, #frames) tg.name = "idle"
spr:saveAs(out .. NAME .. ".aseprite") spr:close()
print(NAME .. " ok")
