-- npc-juniper-kettleby sprite (npc2 P1_17) species: hedgehog
-- Brisk tea-brewing hedgehog: spine dome over a cream face, long snout + dark nose, mustard tunic,
-- holds a copper kettle (prop). Idle: breath dip with spines flattening, lid rattle + blink on f4.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local HH = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hedgehog.lua")
local out = app.params.out or (DIR .. "/")
local NAME = "npc-juniper-kettleby"
local SPINE = { hi = "#b98a5e", base = "#7a4f36", shade = "#57364a", deep = "#3a2638" }
local FACE = { hi = "#fff0d4", base = "#f3d6aa", shade = "#c99e8c", deep = "#8a6470" }
local SNOUT = { hi = FACE.hi, base = FACE.base, shade = FACE.shade, deep = FACE.deep }
local PAW = { hi = "#b07c5c", base = "#865640", shade = "#5c3a48", deep = "#3a2638" }
local COP = { hi = "#ffc48e", base = "#dc7c46", shade = "#a64c4c", deep = "#5e2c40" }
local NOSE = { hi = "#8a6470", base = "#4a2f3c", shade = "#3a2638", deep = "#3a2638" }
local function keep(c, x, y, hex) local o = c.own[y * c.w + x] if o then c:put(x, y, hex, o) end end
local function spikes(m, cx, cy, rx, ry, a0, a1, n, len, w)
  for i = 0, n - 1 do
    local a = math.rad(a0 + (a1 - a0) * i / math.max(1, n - 1))
    local ex, ey = cx + math.cos(a) * (rx - 1), cy + math.sin(a) * (ry - 1)
    local tx, ty = cx + math.cos(a) * (rx + len), cy + math.sin(a) * (ry + len)
    local px, py = -math.sin(a) * w, math.cos(a) * w
    m:add(HP.poly{ { ex + px, ey + py }, { tx, ty }, { ex - px, ey - py } })
  end
  return m
end
local function streaks(c, cx, cy, rx, ry, a0, a1, n)
  for i = 0, n - 1 do
    local a = math.rad(a0 + (a1 - a0) * i / (n - 1))
    for f = 0.55, 0.95, 0.12 do
      local x, y = math.floor(cx + math.cos(a) * rx * f + .5), math.floor(cy + math.sin(a) * ry * f + .5)
      if c:get(x, y) == SPINE.base or c:get(x, y) == SPINE.hi:lower() then keep(c, x, y, SPINE.shade) end
    end
  end
end
local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b, set, lid = p.b or 0, p.set or 0, p.lid or 0
  c:groundShadow(32, 89.5, 13, 2.5)
  HH.back(c, 32, 70 + b, 13, 9, SPINE)
  for _, x in ipairs{ 27, 37 } do c:part(c:ellipse(x, 88, 3.5, 2), PAW, { band = 1 }) end
  local tun = c:ellipse(32, 78 + b, 11, 9)
  c:part(tun, P.gold, { band = 2 })
  for _, y in ipairs{ 73, 77, 81 } do c:put(32, y + b, P.gold.deep) end
  c:part(c:ellipse(21, 75 + b, 2.5, 3.5), P.gold, { band = 1, nopop = true })
  c:part(c:ellipse(21, 79 + b, 2, 1.5), PAW, { band = 1 })
  -- copper kettle held in the right paw
  local ring = c:ellipse(45, 74 + b, 4, 3.5):cut(c:ellipse(45, 74 + b, 2.5, 2)):clip(c:rect(0, 0, 63, 75 + b))
  c:part(ring, COP, { band = 1, nopop = true })
  c:part(c:ellipse(45, 80 + b, 5.5, 4.5), COP, { band = 2, pop = { x = 42, y = 78 + b } })
  c:part(c:line({ { 50, 80 + b }, { 53, 77 + b }, { 54, 75 + b } }, 2), COP, { band = 1, nopop = true })
  c:part(c:ellipse(45, 76.5 + b - lid, 3, 1), COP, { band = 1, nopop = true, inner = true })
  c:put(45, 75 + b - lid, COP.hi)
  c:part(c:ellipse(43, 73 + b, 2, 1.5), PAW, { band = 1, nopop = true })
  HH.head(c, { cx = 32, cy = 50 + b, s = 1, SP = SPINE, FACE = FACE, blink = p.blink, chin = 8 })
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local frames = {}
for _, p in ipairs{ {}, { b = 1, set = 1 }, {}, { blink = true, lid = 1 } } do frames[#frames + 1] = frame(p) end
HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }
  :save{ png = out .. NAME .. ".png", aseprite = out .. NAME .. ".aseprite", scale = 1 }
print(NAME .. " ok")
