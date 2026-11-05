-- npc-marigold-tuftwhistle sprite (npc2 P1_21) species: hedgehog
-- Marigold Tuftwhistle: round bristly hedgehog in a red jumper; prop: little brass tin whistle in her paw.
-- 64x96 cell, feet baseline y=90, idle(4): base / breath / base / top quill tuft twitch.
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local P = HP.P
local HH = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hedgehog.lua")
local out = app.params.out or "./"
local NAME = "npc-marigold-tuftwhistle"
local function R(v) return math.floor(v + 0.5) end
local function kp(c, x, y, hex) local o = c.own[y * c.w + x] if o then c:put(x, y, hex, o) end end
local function under(c, m, hex) local l = {} m:each(function(x, y) if not m:has(x, y + 1) then l[#l + 1] = { x, y } end end) for _, q in ipairs(l) do kp(c, q[1], q[2], hex) end end
local FACE = { hi = P.cream, base = P.skinA.hi, shade = P.skinA.base, deep = P.skinA.shade }
local CR = { hi = P.cream, base = P.cream, shade = P.skinA.hi, deep = P.skinA.shade }
local FEET = { hi = P.wood.base, base = P.wood.shade, shade = P.wood.deep, deep = P.wood.deep }

local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b = p.b or 0
  c:groundShadow(31.5, 89.5, 12, 2.5)
  HH.back(c, 31.5, 66 + b, 15, 12, P.wood)
  -- jumper
  local body = c:ellipse(31.5, 79 + b, 11.5, 8.5)
  body:add(c:rrect(21, 80 + b, 42, 87, 2))
  c:part(body, P.ember, { band = 2, pop = { 24, 73 + b } })
  under(c, body, P.ember.deep)
  for x = 22, 41, 2 do kp(c, x, 86, P.ember.shade) end
  c:part(c:poly{ {26, 71 + b}, {37, 71 + b}, {31.5, 76 + b} }, CR, { band = 1, nopop = true })
  for _, sx in ipairs{ 19.5, 43.5 } do
    local s = c:ellipse(sx, 77 + b, 2.5, 4) c:part(s, P.ember, { band = 1, nopop = true }) under(c, s, P.ember.deep)
  end
  HH.head(c, { cx = 32, cy = 58 + b, s = 1, SP = P.wood, FACE = FACE, blink = p.blink })
  -- brass tin whistle in the right paw
  local wh = c:line({ {42, 80 + b}, {48, 72 + b} }, 2)
  c:part(wh, P.gold, { band = 1, pop = { 46, 73 + b } })
  kp(c, 45, 76 + b, P.wood.deep) kp(c, 47, 74 + b, P.wood.deep)
  c:part(c:ellipse(19.5, 81 + b, 2, 2), FACE, { band = 1, nopop = true })
  c:part(c:ellipse(43.5, 79 + b, 2, 2), FACE, { band = 1, nopop = true })
  -- feet (fixed)
  for _, fx in ipairs{ 26, 37 } do local f = c:ellipse(fx, 89, 3, 1.5) c:part(f, FEET, { band = 1, pop = { fx - 2, 88 } }) end
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local fr = {}
for _, p in ipairs{ {}, { b = 1 }, {}, { tw = true } } do fr[#fr + 1] = frame(p) end
HP.report(fr[1])
HP.sheet{ cellw = 64, cellh = 96, frames = fr, tags = { { name = "idle", from = 1, to = 4 } } }
  :save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
