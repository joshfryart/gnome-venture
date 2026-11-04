-- npc-ginger-thornwhistle sprite (npc2 P1_11) species: common carder bee
-- Round ginger-furred carder bee, bramble-leaf neckerchief, frosted wings. Prop: a thorny bramble whistle-staff topped with a pink bramble flower.
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
local NAME = "npc-ginger-thornwhistle"
local GING = { hi = "#ffd08a", base = "#f2a24a", shade = "#c4693e", deep = "#7e3f48" }
local BAND = { hi = "#c4693e", base = "#9a4e3e", shade = "#6e3646", deep = "#4a2a3e" }
local MUZ  = { hi = "#fff0c8", base = "#ffdca0", shade = "#e8b070", deep = "#c4693e" }
local LEGS = { hi = "#7a5a78", base = "#54405e", shade = "#3c2c48", deep = "#31222f" }
local WING = { hi = "#f6f0dc", base = "#d3e6ee", shade = "#a3bcd8", deep = "#7480aa" }
local WOOD = { hi = "#c99a6a", base = "#8f6045", shade = "#5e3d45", deep = "#3e2a38" }
local LEAF = { hi = "#a6d36a", base = "#5f9e48", shade = "#3a6e4c", deep = "#274a44" }
local ROSE = { hi = "#ffd6dc", base = "#f096a8", shade = "#c0607e", deep = "#80406a" }
function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b = p.b or 0
  c:groundShadow(32, 89, 15, 3)
  -- stubby legs + boots (fixed)
  F(c, c:rrect(26, 82, 29, 88, 1), LEGS, 1) F(c, c:rrect(35, 82, 38, 88, 1), LEGS, 1)
  F(c, c:ellipse(27, 89, 3.5, 1.5), LEGS, 1, { 25, 88 }) F(c, c:ellipse(37.5, 89, 3.5, 1.5), LEGS, 1, { 35, 88 })
  -- wings behind
  local wy = 50 + b + (p.wd or 0)
  for _, s in ipairs{ -1, 1 } do
    local m = c:ellipse(32 + s * 16, wy, 6.5, 4) F(c, m, WING, 1, { 32 + s * 16 - 4, wy - 2 })
    lineOn(c, { { 32 + s * 11, wy + 1 }, { 32 + s * 20, wy - 1 } }, WING.shade, m)
  end
  -- round fuzzy body with one dark band
  local bm = c:ellipse(32, 70 + b, 15, 13.5)
  fuzz(bm, ring(32, 70 + b, 14.5, 13, 20, 160, 20, 1.5))
  F(c, bm, GING, 2, { 22, 62 + b })
  local band = HP.mask()
  for x = 0, 63 do for y = 75 + b + (x % 2), 78 + b do band:set(x, y) end end
  overlay(c, band:clip(bm), BAND, GING)
  for _, q in ipairs{ { 24, 66 }, { 30, 64 }, { 38, 67 }, { 27, 71 }, { 35, 72 }, { 41, 71 }, { 31, 81 }, { 37, 80 } } do
    if bm:has(q[1], q[2] + b) and c:get(q[1], q[2] + b) == GING.base then c:put(q[1], q[2] + b, GING.shade) end
  end
  -- bramble-leaf neckerchief
  local nk = c:ellipse(32, 57 + b, 11, 2.5)
  nk:add(c:poly{ { 29, 58 + b }, { 36, 58 + b }, { 32.5, 64 + b } })
  F(c, nk, LEAF, 1, { 24, 56 + b })
  lineOn(c, { { 32, 59 + b }, { 32, 63 + b } }, LEAF.shade, nk)
  -- bramble staff (planted, never moves), thorns poke out
  local st = c:line({ { 16, 89 }, { 17, 72 }, { 15, 50 } }, 2)
  for _, q in ipairs{ { 14, 82 }, { 19, 76 }, { 14, 66 }, { 18, 59 } } do st:set(q[1], q[2]) end
  F(c, st, WOOD, 1, { 15, 52 })
  local lf = p.lf or 0
  F(c, c:poly{ { 16, 51 }, { 11, 47 + lf }, { 8, 49 + lf }, { 12, 52 } }, LEAF, 1)
  local fl = HP.mask()
  for _, d in ipairs{ { 0, -2 }, { 2, 0 }, { 0, 2 }, { -2, 0 } } do fl:add(c:ellipse(17 + d[1], 47 + d[2], 1.3, 1.3)) end
  F(c, fl, ROSE, 1, { 16, 45 })
  c:put(17, 47, "#f5c64a")
  -- arms (dark bee legs) : one grips staff, one on tummy
  F(c, c:ellipse(18.5, 67 + b, 3, 2.5), LEGS, 1, { 17, 66 + b })
  F(c, c:ellipse(43, 68 + b, 2.5, 2.5), LEGS, 1, { 42, 67 + b })
  -- big fuzzy head
  local hm = c:ellipse(32, 42 + b, 17, 14.5)
  fuzz(hm, ring(32, 42 + b, 16.5, 14, 190, 350, 16, 1.6))
  hm:add(c:poly{ { 29, 30 + b }, { 31, 25 + b }, { 33, 29 + b }, { 36, 26 + b }, { 36, 30 + b } })
  F(c, hm, GING, 2, { 21, 35 + b })
  for _, q in ipairs{ { 25, 31 }, { 28, 30 }, { 38, 31 }, { 41, 33 } } do c:put(q[1], q[2] + b, GING.hi) end
  F(c, c:ellipse(32, 48 + b, 6.5, 4.5), MUZ, 1, { 28, 45 + b })
  eye(c, 23, 40 + b, p.blink) eye(c, 37, 40 + b, p.blink)
  c:put(31, 46 + b, BAND.base) c:put(32, 46 + b, BAND.base) c:put(31, 45 + b, BAND.hi) c:put(32, 45 + b, BAND.shade)
  c:put(30, 49 + b, "#4a2a3a") c:put(31, 50 + b, "#4a2a3a") c:put(32, 50 + b, "#4a2a3a") c:put(33, 49 + b, "#4a2a3a")
  for _, q in ipairs{ { 21, 46 }, { 22, 46 }, { 42, 46 }, { 43, 46 } } do c:put(q[1], q[2] + b, "#e88a8a") end
  -- antenna tips
  local tw = p.tw or 0
  F(c, c:ellipse(22, 20 + b, 1.6, 1.6), BAND, 1, { 21, 19 + b })
  F(c, c:ellipse(43 + tw, 20 + b - tw, 1.6, 1.6), BAND, 1, { 42 + tw, 19 + b - tw })
  c:finish{ outline = true }
  c:fillMask(c:line({ { 27, 29 + b }, { 25, 25 + b }, { 22, 22 + b } }, 1), INK)
  c:fillMask(c:line({ { 37, 29 + b }, { 39, 25 + b }, { 43 + tw, 22 + b - tw } }, 1), INK)
  HP.assertClean(c)
  return c
end
IDLE = { { b = 0 }, { b = 1, wd = 1, lf = 1 }, { b = 0 }, { b = 0, blink = true, tw = 1, lf = -1 } }
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
