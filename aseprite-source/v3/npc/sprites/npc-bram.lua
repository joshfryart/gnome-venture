-- npc-bram sprite (npc2 P1_2) species: hedgehog
-- Bram: round hedgehog hedge-wizard, spiky brown-violet quills, cream face + pointed snout, tall purple
-- wizard hat bent left with a gold star tip, pink robe; prop/quirk: tiny star wand. idle(4), feet fixed.
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local P = HP.P
local HH = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hedgehog.lua")
local out = app.params.out or "./"
local NAME = "npc-bram"
local SP = { hi = "#c39a78", base = "#86604e", shade = "#58405a", deep = "#36263e" }
local FACE = { hi = "#ffe8c8", base = "#ecc49a", shade = "#c08a78", deep = "#80525a" }
local CR = { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.base }
local HAT, ROBE = P.dusk, P.petal
local function under(c, m, hex) m:each(function(x, y) if not m:has(x, y + 1) then c:put(x, y, hex) end end) end
local NO = { band = 1, nopop = true, inner = false }

local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b = p.bob or 0
  c:groundShadow(32, 89.5, 13, 2.5)
  -- star wand (behind paw)
  local ws = p.ws or 0
  c:part(c:line({ { 46, 82 + b }, { 49, 65 + b + ws } }, 1), P.wood, NO)
  c:paint({ "..X..", "XXXXX", ".XXX.", ".X.X." }, 47, 61 + b + ws, { X = "gold.base" })
  c:put(48, 62 + b + ws, P.gold.hi) c:put(49, 61 + b + ws, P.gold.hi) c:put(50, 63 + b + ws, P.gold.shade)
  HH.back(c, 32, 68 + b, 15, 10, SP)
  -- robe (hem fixed at the ground, top breathes)
  local robe = c:poly{ { 24, 68 + b }, { 40, 68 + b }, { 45, 87 }, { 19, 87 } }
  robe:add(c:ellipse(32, 70 + b, 8, 3))
  c:part(robe, ROBE, { band = 2, inner = false, pop = { x = 24, y = 70 + b } })
  under(c, robe, ROBE.deep)
  for _, l in ipairs{ { { 28, 76 + b }, { 26, 85 } }, { { 36, 77 + b }, { 38, 85 } } } do
    c:line(l, 1):clip(robe):each(function(x, y) c:put(x, y, ROBE.shade) end) end
  c:hem(85, 21, 43)
  c:part(c:poly{ { 28, 67 + b }, { 37, 67 + b }, { 32.5, 73 + b } }, CR, NO)
  c:button(32, 73 + b)
  -- sleeves + paws
  for _, s in ipairs{ { 21, -1 }, { 43, 1 } } do
    local m = c:ellipse(s[1], 75 + b, 3, 4.5) c:part(m, ROBE, NO) under(c, m, ROBE.deep)
  end
  for _, x in ipairs{ 21, 45 } do local m = c:ellipse(x, 80 + b, 2, 1.5) c:part(m, FACE, NO) under(c, m, FACE.shade) end
  -- feet (fixed)
  for _, x in ipairs{ 26.5, 37.5 } do local m = c:ellipse(x, 88, 3, 1.5) c:part(m, FACE, NO) under(c, m, FACE.deep) end
  HH.head(c, { cx = 32, cy = 56 + b, s = 1, SP = SP, FACE = FACE, blink = p.blink })
  -- wizard hat, bent tip with star
  local hb = p.hb or 0
  local cone = c:poly{ { 24, 49 + b }, { 40, 49 + b }, { 36, 32 + b }, { 29, 31 + b } }
  cone:add(c:line({ { 32, 32 + b }, { 30, 27 + b }, { 27, 23 + b + hb }, { 24, 21 + b + hb } }, 4))
  local brim = c:ellipse(32, 49 + b, 14, 2.5)
  local hat = cone:copy():add(brim)
  c:part(hat, HAT, { band = 2, inner = false, pop = { x = 29, y = 35 + b } })
  under(c, hat, HAT.deep)
  cone:each(function(x, y) if (y == 44 + b or y == 45 + b) and not brim:has(x, y) then c:put(x, y, x > 35 and P.gold.shade or P.gold.base) end end)
  c:put(33, 38 + b, P.gold.hi) c:put(30, 41 + b, P.gold.hi) c:put(34, 35 + b, P.cream)
  c:paint({ ".X.", "XXX", ".X." }, 21, 19 + b + hb, { X = "gold.base" })
  c:put(22, 19 + b + hb, P.gold.hi)
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local frames = {}
for _, p in ipairs{ {}, { bob = 1, hb = 1, ws = 1 }, {}, { blink = true } } do frames[#frames + 1] = frame(p) end
HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }
  :save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " ok")
