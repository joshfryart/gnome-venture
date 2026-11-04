-- npc-oakley-mossfoot sprite (npc2 P1_26) species: dragonfly
-- Oakley Mossfoot: easy-going dragonfly drifter, straw sun hat with moss growing on the brim (quirk), purple scarf, brown poncho, 4 glassy wings.
local NAME = "npc-oakley-mossfoot"
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local function oval(cx, cy, rx, ry, deg)
  local a = math.rad(deg)
  local ca, sa, m = math.cos(a), math.sin(a), HP.mask()
  for y = math.floor(cy - rx - 1), math.ceil(cy + rx + 1) do for x = math.floor(cx - rx - 1), math.ceil(cx + rx + 1) do
    local dx, dy = x + .5 - cx, y + .5 - cy
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if (u / (rx + .3)) ^ 2 + (v / (ry + .3)) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end
local INK, CREAM = "#2b1c26", "#f4ead0"
local function eye4(c, x, y, blink)
  if blink then for i = 0, 3 do c:put(x + i, y + 2, INK) end return end
  c:put(x + 1, y, INK) c:put(x + 2, y, INK)
  for _, q in ipairs({ { 0, 1 }, { 3, 1 }, { 0, 2 }, { 3, 2 }, { 1, 3 }, { 2, 3 }, { 1, 1 } }) do c:put(x + q[1], y + q[2], CREAM) end
  c:put(x + 2, y + 1, INK) c:put(x + 1, y + 2, INK) c:put(x + 2, y + 2, INK)
end
local function recol(c, m, from, to) m:each(function(x, y) if c:get(x, y) == from then c:put(x, y, to) end end) end
local BLUE  = { hi = "#7fc8e0", base = "#3f8fc0", shade = "#2f5f9a", deep = "#2c3c72" }
local EYEG  = { hi = "#b8e070", base = "#6fae3a", shade = "#3f7a3a", deep = "#2c4c3a" }
local WING  = { hi = "#eef4ea", base = "#cfe6ee", shade = "#9cc0d8", deep = "#6f8cb8" }
local STRAW = { hi = "#f6d47a", base = "#e0a83c", shade = "#b0702e", deep = "#7a4630" }
local PURP  = { hi = "#a882d8", base = "#7650b0", shade = "#523a8a", deep = "#3a2a62" }
local CLOAK = { hi = "#b88a5a", base = "#8a5e3c", shade = "#5e3c34", deep = "#3e2830" }
local MOSS  = { hi = "#b6d65a", base = "#6e9e38", shade = "#44702e", deep = "#2e4a2c" }
local function F(p)
  local c = HP.canvas{ w = 64, h = 96, scale = 1, name = NAME }
  local b, w, t = p.b or 0, p.wing or 0, p.tail or 0
  c:groundShadow(32.5, 89.5, 13, 3)
  -- wings (behind), two pairs
  for _, s in ipairs{ -1, 1 } do
    local lo = oval(32.5 + s * 13, 66 + b + w, 9, 2.2, s * 14)
    local up = oval(32.5 + s * 14, 60 + b + w, 10.5, 2.6, s * -14)
    c:part(lo, WING, { band = 1, nopop = true })
    c:part(up, WING, { band = 1, nopop = true })
    c:put(32 + s * 20, 58 + b + w - (s > 0 and 1 or 0), WING.hi)
  end
  -- segmented tail curling out behind, right
  local tl = c:line({ { 38, 80 + b }, { 46, 83 + b }, { 51, 80 + b + t }, { 52, 76 + b + t } }, 3)
  c:part(tl, BLUE, { band = 1, nopop = true })
  for _, q in ipairs{ { 42, 81 }, { 46, 82 }, { 50, 81 } } do c:put(q[1], q[2] + b, BLUE.deep) end
  c:put(52, 75 + b + t, BLUE.hi)
  -- legs + feet (fixed)
  c:part(c:rect(27, 82, 28, 87), BLUE, { band = 1, nopop = true })
  c:part(c:rect(36, 82, 37, 87), BLUE, { band = 1, nopop = true })
  c:part(c:ellipse(27.5, 88.5, 3, 1.6), BLUE, { band = 1, nopop = true })
  c:part(c:ellipse(37.5, 88.5, 3, 1.6), BLUE, { band = 1, nopop = true })
  -- poncho
  local cl = c:ellipse(32.5, 73 + b, 11, 9)
  cl:add(c:poly{ { 22, 75 + b }, { 43, 75 + b }, { 45, 84 + b }, { 20, 84 + b } })
  c:part(cl, CLOAK, { band = 2, pop = { x = 25, y = 67 + b } })
  cl:each(function(x, y) if not cl:has(x, y + 1) then c:put(x, y, CLOAK.deep) end end)
  for _, x in ipairs{ 26, 32, 38 } do c:put(x, 82 + b, CLOAK.shade) c:put(x, 83 + b, CLOAK.shade) end
  -- tiny arms
  c:part(c:ellipse(21.5, 74 + b, 2.5, 3), BLUE, { band = 1, nopop = true })
  c:part(c:ellipse(43.5, 74 + b, 2.5, 3), BLUE, { band = 1, nopop = true })
  -- scarf + hanging end
  c:part(c:rrect(23, 61 + b, 42, 64 + b, 1), PURP, { band = 1, pop = { x = 24, y = 61 + b } })
  c:part(c:rect(26, 65 + b, 28, 70 + b), PURP, { band = 1, nopop = true })
  c:put(26, 71 + b, PURP.shade) c:put(28, 71 + b, PURP.shade)
  -- head
  local hd = c:ellipse(32.5, 53 + b, 11, 8)
  c:part(hd, BLUE, { band = 2, pop = { x = 25, y = 52 + b } })
  -- snout plate + mandible smile
  c:part(c:ellipse(32.5, 57.5 + b, 3, 1.5), { hi = BLUE.hi, base = BLUE.hi, shade = BLUE.base, deep = BLUE.shade }, { band = 1, nopop = true })
  c:put(30, 59 + b, INK) c:put(31, 60 + b, INK) c:put(32, 60 + b, INK) c:put(33, 60 + b, INK) c:put(34, 59 + b, INK)
  -- compound-eye domes with facets
  for _, ex in ipairs{ 25, 40 } do
    local d = c:ellipse(ex, 48 + b, 6, 5)
    c:part(d, EYEG, { band = 2, pop = { x = ex - 3, y = 45 + b } })
    d:each(function(x, y) if (x + 2 * y) % 4 == 0 and y % 2 == 0 and c:get(x, y) == EYEG.base then c:put(x, y, EYEG.shade) end end)
  end
  eye4(c, 23, 47 + b, p.blink) eye4(c, 38, 47 + b, p.blink)
  -- straw hat (wide brim, low crown, purple band)
  local hb = c:ellipse(32.5, 42 + b, 16, 3.5)
  c:part(hb, STRAW, { band = 2, nopop = true })
  hb:each(function(x, y) if not hb:has(x, y + 1) then c:put(x, y, STRAW.deep) end end)
  local cr = c:rrect(26, 34 + b, 39, 41 + b, 3)
  c:part(cr, STRAW, { band = 2, pop = { x = 28, y = 35 + b } })
  for x = 27, 38, 3 do c:put(x, 37 + b, STRAW.shade) end
  for x = 26, 39 do c:put(x, 40 + b, x > 35 and PURP.shade or PURP.base) c:put(x, 41 + b, PURP.deep) end
  -- quirk: moss growing on the brim, with a two-leaf sprout
  local ms = c:ellipse(20.5, 42 + b, 4, 1.6)
  ms:add(c:ellipse(24, 43 + b, 2, 1))
  c:part(ms, MOSS, { band = 1, pop = { x = 18, y = 41 + b } })
  local sw = p.sprout or 0
  c:put(21, 40 + b, MOSS.shade) c:put(21, 39 + b, MOSS.shade)
  c:put(20 + sw, 38 + b, MOSS.hi) c:put(22 + sw, 38 + b, MOSS.base) c:put(19 + sw, 37 + b, MOSS.hi)
  return c
end
local FR = { { b = 0 }, { b = 1, wing = 1, sprout = 1 }, { b = 0 }, { b = 0, blink = true, tail = -1, wing = -1 } }
local frames = {}
for _, p in ipairs(FR) do local c = F(p) c:finish{ outline = true } HP.assertClean(c) frames[#frames + 1] = c end
local pc = app.pixelColor
local function rgba(h) return pc.rgba(tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16), 255) end
local strip = Sprite(256, 96, ColorMode.RGB)
local sim = Image(256, 96, ColorMode.RGB) sim:clear(pc.rgba(0, 0, 0, 0))
local spr = Sprite(64, 96, ColorMode.RGB)
for _ = 2, 4 do spr:newEmptyFrame() end
local L = spr.layers[1] L.name = NAME
for f, c in ipairs(frames) do
  local im = Image(64, 96, ColorMode.RGB) im:clear(pc.rgba(0, 0, 0, 0))
  for i, hex in pairs(c.pix) do im:putPixel(i % 64, i // 64, rgba(hex)) sim:putPixel((f - 1) * 64 + i % 64, i // 64, rgba(hex)) end
  spr:newCel(L, spr.frames[f], im, Point(0, 0))
  spr.frames[f].duration = (f % 2 == 1) and 0.45 or 0.3
end
local tg = spr:newTag(1, 4) tg.name = "idle"
spr:saveAs(out .. NAME .. ".aseprite") spr:close()
strip.cels[1].image = sim strip:saveCopyAs(out .. NAME .. ".png") strip:close()
print(NAME .. " ok")
