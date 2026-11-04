-- npc-nocturna sprite (npc2 P1_24) species: lilac moth
-- Night-gardener moth: fluffy lilac body, violet forewings with gold eyespots, rosy hindwings,
-- straw sun-hat with feathery antennae poking through the crown. Prop: a glowing lantern.
-- Idle: f2 breath (body 1px down, wing tips + hat brim droop, lantern sways), f4 blink. Feet + shadow fixed.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-nocturna"
local R = {
  fur   = { hi = "#ead0ec", base = "#c49ad2", shade = "#8c6aa9", deep = "#5d4581" },
  wing  = { hi = "#b49ae8", base = "#8a6bcb", shade = "#5f4aa0", deep = "#3e3274" },
  rib   = { hi = "#f4b6cc", base = "#d9799e", shade = "#a24f86", deep = "#6c3266" },
  gold  = { hi = "#ffe38c", base = "#f3b53f", shade = "#c97b2c", deep = "#8b4b2c" },
  straw = { hi = "#f8e4a2", base = "#e0bc69", shade = "#b4894b", deep = "#7a5639" },
  ruff  = { hi = "#fff2da", base = "#f1dab6", shade = "#c8a8aa", deep = "#8e7492" },
  leg   = { hi = "#8a6a96", base = "#654a76", shade = "#47355c", deep = "#352745" },
}
local function mir(t) local o = {} for i, q in ipairs(t) do o[i] = { 64 - q[1], q[2] } end return o end
local function sh(t, dy) local o = {} for i, q in ipairs(t) do o[i] = { q[1], q[2] + dy } end return o end

local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b, w, lx, hd = p.b or 0, p.w or 0, p.lx or 0, p.hd or 0
  c:groundShadow(32, 89.5, 13, 3)
  -- legs + feet (never move)
  local legs = c:rect(27, 84, 29, 88) legs:add(c:rect(35, 84, 37, 88))
  c:part(legs, R.leg, { band = 1, nopop = true })
  c:part(c:ellipse(27.5, 88.5, 3, 1.5), R.leg, { band = 1, nopop = true })
  c:part(c:ellipse(36.5, 88.5, 3, 1.5), R.leg, { band = 1, nopop = true })
  -- rosy hindwings
  for _, s in ipairs{ -1, 1 } do
    c:part(c:ellipse(32 + s * 17, 77 + b + w, 6, 4.5), R.rib, { band = 1, pop = { x = 32 + s * 17 - 3, y = 75 + b + w } })
  end
  -- violet forewings with veins + gold eyespots
  for _, s in ipairs{ -1, 1 } do
    local pts = { { 27, 65 }, { 14, 51 + w }, { 7, 56 + w }, { 8, 66 + w }, { 13, 72 }, { 25, 72 } }
    local v1, v2 = { { 26, 67 }, { 11, 56 } }, { { 26, 70 }, { 10, 66 } }
    if s > 0 then pts, v1, v2 = mir(pts), mir(v1), mir(v2) end
    local m = c:poly(sh(pts, b))
    c:part(m, R.wing, { band = 2, pop = { x = s < 0 and 12 or 50, y = 55 + b + w } })
    c:fillMask(c:line(sh(v1, b), 1):clip(m:shrink(1)), R.wing.shade)
    c:fillMask(c:line(sh(v2, b), 1):clip(m:shrink(1)), R.wing.shade)
    local ex = s < 0 and 13 or 51
    c:part(c:ellipse(ex + 0.5, 61.5 + b, 2.5, 2.5), R.gold, { band = 1, nopop = true })
    c:put(ex, 61 + b, R.wing.deep) c:put(ex - 1, 60 + b, R.gold.hi)
  end
  -- fluffy body with rosy stripes
  local body = c:ellipse(32, 75 + b, 10, 11)
  c:part(body, R.fur, { band = 2, pop = { x = 26, y = 69 + b } })
  for _, y in ipairs{ 77, 82 } do
    c:rect(22, y + b, 42, y + 1 + b):clip(body):each(function(x, yy)
      local v = c:get(x, yy)
      c:put(x, yy, (v == R.fur.shade or v == R.fur.deep) and R.rib.shade or R.rib.base)
    end)
  end
  for _, q in ipairs{ { 27, 72 }, { 30, 74 }, { 25, 75 }, { 35, 71 }, { 29, 80 } } do
    if body:has(q[1], q[2] + b) then c:put(q[1], q[2] + b, R.fur.hi) end
  end
  -- tiny arms; right paw holds the lantern
  c:part(c:ellipse(21.5, 72 + b, 2.5, 3.5), R.fur, { band = 1, nopop = true })
  c:part(c:ellipse(42.5, 73 + b, 3, 3), R.fur, { band = 1, nopop = true })
  local Lx = 46 + lx
  c:part(c:rect(Lx - 1, 74 + b, Lx + 1, 75 + b), R.leg, { band = 1, nopop = true })
  c:part(c:rect(Lx - 3, 76 + b, Lx + 3, 77 + b), R.leg, { band = 1, nopop = true })
  c:part(c:rrect(Lx - 3, 78 + b, Lx + 3, 84 + b, 1), R.gold, { band = 1, nopop = true })
  for y = 78, 84 do c:put(Lx + 1, y + b, R.gold.shade) end
  c:put(Lx - 1, 80 + b, R.ruff.hi) c:put(Lx - 1, 81 + b, R.gold.hi) c:put(Lx - 2, 79 + b, R.gold.hi)
  c:part(c:rect(Lx - 2, 85 + b, Lx + 2, 86 + b), R.leg, { band = 1, nopop = true })
  -- cream neck ruff
  local ruff = c:ellipse(32, 63 + b, 10, 2.5)
  for _, q in ipairs{ { 23, 64.5 }, { 27, 65.5 }, { 32, 66 }, { 37, 65.5 }, { 41, 64.5 } } do ruff:add(c:ellipse(q[1], q[2] + b, 1.5, 1.5)) end
  c:part(ruff, R.ruff, { band = 1, pop = { x = 25, y = 62 + b } })
  -- fuzzy round head
  local head = c:ellipse(32, 48 + b, 12.5, 9.5)
  for _, q in ipairs{ { 19.5, 50 }, { 20, 54 }, { 44.5, 50 }, { 44, 54 } } do head:add(c:ellipse(q[1], q[2] + b, 1.5, 1.5)) end
  c:part(head, R.fur, { band = 2, pop = { x = 23, y = 44 + b } })
  if p.blink then
    for _, x0 in ipairs{ 24, 36 } do
      for i = 1, 3 do c:put(x0 + i, 48 + b, P.ink) end
      c:put(x0, 47 + b, P.ink) c:put(x0 + 4, 47 + b, P.ink)
    end
  else c:eyeLocked(24, 46 + b) c:eyeLocked(36, 46 + b) end
  c:put(31, 52 + b, R.rib.shade) c:put(32, 52 + b, R.rib.deep) c:put(31, 51 + b, R.rib.hi)
  for _, q in ipairs{ { 30, 54 }, { 31, 55 }, { 32, 55 }, { 33, 54 } } do c:put(q[1], q[2] + b, P.ink) end
  for _, x in ipairs{ 21, 22, 41, 42 } do c:put(x, 52 + b, R.rib.hi) end
  -- straw sun-hat: wide floppy brim, round crown, violet ribbon + rosy bow
  local brim = c:ellipse(32, 38 + b, 16, 3.5)
  brim:add(c:ellipse(17.5, 39.5 + b + hd, 2.5, 1.5)) brim:add(c:ellipse(46.5, 39.5 + b + hd, 2.5, 1.5))
  c:part(brim, R.straw, { band = 1, pop = { x = 19, y = 37 + b } })
  for x = 18, 46, 3 do if brim:has(x, 40 + b) then c:put(x, 40 + b, R.straw.shade) end end
  local crown = c:rrect(24, 28 + b, 40, 37 + b, 4)
  c:part(crown, R.straw, { band = 2, pop = { x = 27, y = 30 + b } })
  crown:each(function(x, y) if (x + y) % 3 == 0 and y < 34 + b and c:get(x, y) == R.straw.base:lower() then c:put(x, y, R.straw.shade) end end)
  c:part(c:rect(24, 34 + b, 40, 36 + b):clip(crown), R.wing, { band = 1, nopop = true })
  local bow = c:ellipse(22, 35 + b, 2, 1.5) bow:add(c:ellipse(19.5, 36 + b, 1.5, 1.5))
  c:part(bow, R.rib, { band = 1, nopop = true })
  -- feathery antennae poking through the crown
  for _, s in ipairs{ -1, 1 } do
    local a = { { 29, 29 }, { 24, 21 }, { 19, 13 }, { 21, 11 }, { 26, 19 }, { 31, 28 } }
    if s > 0 then a = mir(a) end
    local m = c:poly(sh(a, b))
    c:part(m, R.leg, { band = 1, nopop = true, inner = false })
    m:each(function(x, y) if (x + y) % 2 == 0 and c:get(x, y) == R.leg.base:lower() then c:put(x, y, R.leg.hi) end end)
  end
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local FR = { { b = 0 }, { b = 1, w = 1, lx = 1, hd = 1 }, { b = 0 }, { b = 0, blink = true } }
local DUR = { 0.45, 0.4, 0.45, 0.16 }
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
