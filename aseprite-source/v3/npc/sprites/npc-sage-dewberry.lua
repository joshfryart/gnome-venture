-- npc-sage-dewberry sprite (npc2 P1_33) species: butterfly
-- Sage Dewberry, gentle butterfly-folk herbalist: pink spotted wings, lilac fuzz crown, club antennae,
-- gold robe + ember scarf. Prop: a dewberry sprig. 64x96, feet y=90. idle x4: base, breath+settle, base, blink+antenna twitch.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-sage-dewberry"
local FUZZ = { hi = "#e2d2f2", base = "#b9a0da", shade = "#8b72b8", deep = "#5e4a8a" }
local BERRY = { hi = "#9a7cc8", base = "#5d4290", shade = "#40306e", deep = "#2f2452" }
local LEAF = { hi = "#b4d878", base = "#72a84c", shade = "#4b7c4e", deep = "#34564c" }
local CR = { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.base }
local function oval(cx, cy, rx, ry, deg)
  local a = math.rad(deg) local ca, sa, m = math.cos(a), math.sin(a), HP.mask()
  for y = math.floor(cy - rx - 1), math.ceil(cy + rx + 1) do for x = math.floor(cx - rx - 1), math.ceil(cx + rx + 1) do
    local dx, dy = x + .5 - cx, y + .5 - cy
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if (u / (rx + .3)) ^ 2 + (v / (ry + .3)) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end
local function under(c, m, hex) m:each(function(x, y) if not m:has(x, y + 1) then c:put(x, y, hex) end end) end
local function eye(c, x, y)
  c:put(x + 1, y, P.ink) c:put(x + 2, y, P.ink)
  for _, q in ipairs{ {0,1},{3,1},{0,2},{3,2},{1,3},{2,3} } do c:put(x + q[1], y + q[2], P.cream) end
  c:put(x + 1, y + 1, P.cream) c:put(x + 2, y + 1, P.ink) c:put(x + 1, y + 2, P.ink) c:put(x + 2, y + 2, P.ink)
end

local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b, tip, at = p.b or 0, p.tip or 0, p.at or 0
  c:groundShadow(32, 88.5, 12, 3)
  for _, fx in ipairs{ 27, 38 } do c:part(c:ellipse(fx, 87.5, 3.5, 2), P.dusk, { band = 1, pop = { x = fx - 2, y = 86 } }) end
  -- wings behind the shoulders
  for _, s in ipairs{ -1, 1 } do
    local up = oval(32.5 + s * 15, 52 + b, 10, 6.5, s * -45)
    local lo = oval(32.5 + s * 12, 67 + b, 6, 4.5, s * 35)
    c:part(lo, P.petal, { band = 2, nopop = true })
    c:part(up, P.petal, { band = 2, pop = { x = s < 0 and 13 or 47, y = 49 + b } })
    c:part(c:ellipse(32.5 + s * 20, 49 + b, 2.2, 2.2):clip(up:copy():shrink(1)), CR, { band = 1, nopop = true, inner = false })
    c:fillMask(c:line({ { 32.5 + s * 6, 58 + b }, { 32.5 + s * 18, 49 + b } }, 1):clip(up:copy():shrink(1)), P.petal.shade)
    c:part(c:ellipse(32.5 + s * 14, 68 + b, 1.2, 1.2):clip(lo:copy():shrink(1)), CR, { band = 1, nopop = true, inner = false })
  end
  -- robe
  local robe = c:ellipse(32.5, 66 + b, 9.5, 8)
  robe:add(c:poly{ { 24, 66 + b }, { 41, 66 + b }, { 44, 85 + b }, { 21, 85 + b } })
  c:part(robe, P.gold, { band = 2, pop = { x = 27, y = 61 + b } })
  under(c, robe, P.gold.deep)
  for _, fx in ipairs{ 28, 37 } do c:fillMask(c:line({ { fx, 74 + b }, { fx + (fx < 32 and -1 or 1), 84 + b } }, 1):clip(robe), P.gold.shade) end
  for _, s in ipairs{ -1, 1 } do
    local sl = c:ellipse(32.5 + s * 11, 66 + b, 3, 4.5)
    c:part(sl, P.gold, { band = 1, nopop = true }) under(c, sl, P.gold.deep)
  end
  c:part(c:ellipse(21.5, 71 + b, 2.2, 1.8), P.skinA, { band = 1, nopop = true })
  local sc = c:rrect(24, 56 + b, 41, 60 + b, 2)
  sc:add(c:poly{ { 26, 59 + b }, { 29, 59 + b }, { 28, 67 + b }, { 25, 67 + b } })
  c:part(sc, P.ember, { band = 1, pop = { x = 25, y = 57 + b } })
  -- prop: dewberry sprig in the right hand
  local tw = c:line({ { 44, 71 + b }, { 47, 63 + b }, { 48, 58 + b } }, 2)
  c:fillMask(tw:copy():grow(1), P.ink) c:part(tw, P.wood, { band = 1, nopop = true })
  local lf = c:poly{ { 47, 64 + b }, { 51, 60 + b }, { 54, 60 + b }, { 51, 64 + b } }
  c:fillMask(lf:copy():grow(1), P.ink) c:part(lf, LEAF, { band = 1, pop = { x = 50, y = 61 + b } })
  c:put(49, 63 + b, LEAF.shade) c:put(51, 62 + b, LEAF.shade)
  local be = HP.mask()
  for _, q in ipairs{ { 46.5, 56 }, { 49.5, 56 }, { 48, 54 }, { 48, 58 } } do be:add(HP.ellipse(q[1], q[2] + b, 1.6, 1.6)) end
  c:fillMask(be:copy():grow(1), P.ink) c:part(be, BERRY, { band = 1, pop = { x = 46, y = 55 + b } })
  c:put(48, 53 + b, BERRY.hi) c:put(49, 57 + b, BERRY.shade)
  c:part(c:ellipse(43.5, 71 + b, 2.2, 1.8), P.skinA, { band = 1, nopop = true })
  -- head + lilac fuzz crown
  local hcx, hcy = 32.5, 43 + b
  local head = c:ellipse(hcx, hcy, 12, 10)
  c:part(head, P.skinA, { band = 2, pop = { x = 26, y = 45 + b } })
  local fz = head:copy():clip(c:rect(0, 0, 63, 39 + b))
  for i = 0, 8 do local a = math.rad(195 + i * 18.75) fz:add(HP.ellipse(hcx + math.cos(a) * 11.5, hcy + math.sin(a) * 9.5, 1.8, 1.8)) end
  local DR = { 1, 0, 2, 1, 0, 1, 2, 0, 1, 1, 0, 2 }
  for x = 21, 44 do local d = DR[(x * 5) % #DR + 1] for y = 40 + b, 39 + b + d do if head:has(x, y + 1) then fz:set(x, y) end end end
  fz:add(c:poly{ { 31, 33 + b }, { 32, 29 + b }, { 33, 31 + b }, { 34, 29 + b }, { 35, 33 + b } })
  c:part(fz, FUZZ, { band = 2, inner = false, pop = { x = 25, y = 36 + b } })
  for _, q in ipairs{ { 27, 35 }, { 31, 34 }, { 37, 35 }, { 24, 38 }, { 40, 37 } } do c:put(q[1], q[2] + b, FUZZ.hi) c:put(q[1] + 1, q[2] + 1 + b, FUZZ.shade) end
  -- face
  if p.blink then for _, x in ipairs{ 25, 37 } do for i = 0, 3 do c:put(x + i, 46 + b, P.ink) end end
  else eye(c, 25, 44 + b) eye(c, 37, 44 + b) end
  c:put(32, 48 + b, P.skinA.shade) c:put(33, 48 + b, P.skinA.shade)
  c:paint({ "i..i", ".ii." }, 31, 49 + b, { i = "ink" })
  c:cheek(23, 48 + b) c:cheek(41, 48 + b)
  -- antenna clubs
  c:part(c:ellipse(25, 24 + b + tip, 2, 2), BERRY, { band = 1, pop = { x = 24, y = 23 + b + tip } })
  c:part(c:ellipse(40 + at, 24 + b + tip, 2, 2), BERRY, { band = 1, pop = { x = 39 + at, y = 23 + b + tip } })
  c:finish{ outline = true }
  c:fillMask(c:line({ { 28, 32 + b }, { 26, 29 + b }, { 25, 27 + b + tip } }, 1), P.ink)
  c:fillMask(c:line({ { 37, 32 + b }, { 39, 29 + b }, { 40 + at, 27 + b + tip } }, 1), P.ink)
  HP.assertClean(c)
  return c
end

local F = { { b = 0 }, { b = 1, tip = 1 }, { b = 0 }, { b = 0, blink = true, at = 1 } }
local frames = {}
for _, p in ipairs(F) do frames[#frames + 1] = frame(p) end
local s = HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }
s:save{ png = out .. NAME .. ".png", scale = 1 }
local pc = app.pixelColor
local function rgba(h) return pc.rgba(tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16), 255) end
local spr = Sprite(64, 96, ColorMode.RGB)
for _ = 2, 4 do spr:newEmptyFrame() end
for f, c in ipairs(frames) do
  local im = Image(64, 96, ColorMode.RGB) im:clear(pc.rgba(0, 0, 0, 0))
  for i, hex in pairs(c.pix) do im:putPixel(i % 64, i // 64, rgba(hex)) end
  spr:newCel(spr.layers[1], spr.frames[f], im, Point(0, 0))
end
local tg = spr:newTag(1, 4) tg.name = "idle"
spr:saveAs(out .. NAME .. ".aseprite") spr:close()
print(NAME .. " ok")
