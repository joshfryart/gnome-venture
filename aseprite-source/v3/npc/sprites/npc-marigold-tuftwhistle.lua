-- npc-marigold-tuftwhistle sprite (npc2 P1_21) species: hedgehog
-- Marigold Tuftwhistle: round bristly hedgehog in a red jumper; prop: little brass tin whistle in her paw.
-- 64x96 cell, feet baseline y=90, idle(4): base / breath / base / top quill tuft twitch.
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local P = HP.P
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
  -- quill ball (seen from above: the back of the head and body are all spines)
  local cy = 62 + b
  local Q = c:ellipse(31.5, cy, 16.5, 15.5)
  local tips = {}
  for a = 150, 390, 15 do
    local r = math.rad(a)
    local ux, uy = math.cos(r), math.sin(r)
    local tx, ty = -uy, ux
    local len = 5 + ((a // 15) % 2) + ((p.tw and a >= 255 and a <= 285) and 2 or 0)
    local bx, by = 31.5 + ux * 14, cy + uy * 13
    local ex, ey = 31.5 + ux * (16.5 + len), cy + uy * (15.5 + len)
    if p.tw and a >= 255 and a <= 285 then ex = ex + 1 end
    Q:add(c:poly{ { R(bx + tx * 3), R(by + ty * 3) }, { R(bx - tx * 3), R(by - ty * 3) }, { R(ex), R(ey) } })
    tips[#tips + 1] = { bx, by, ex, ey }
  end
  c:part(Q, P.wood, { band = 3, pop = { 20, 52 + b } })
  for _, t in ipairs(tips) do
    c:line({ { R(t[1]), R(t[2]) }, { R(t[3] - (t[3] - t[1]) * 0.2), R(t[4] - (t[4] - t[2]) * 0.2) } }, 1)
      :each(function(x, y) if Q:has(x, y) then kp(c, x, y, P.wood.deep) end end)
  end
  for y = 48 + b, 76 + b, 4 do for x = 17 + (y % 8 == 0 and 2 or 0), 46, 5 do
    if Q:has(x, y) and Q:has(x + 1, y - 1) then kp(c, x, y, P.wood.shade) kp(c, x + 1, y - 1, P.wood.shade)
      if x < 30 and y < 62 + b then kp(c, x + 1, y, P.wood.hi) end end
  end end
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
  -- ears
  for _, ex in ipairs{ 22.5, 40.5 } do c:part(c:ellipse(ex, 58 + b, 2, 2), P.wood, { band = 1, nopop = true }) kp(c, R(ex), 58 + b, P.petal.shade) end
  -- face with pointed snout
  local face = c:ellipse(31.5, 64 + b, 9.5, 7)
  c:part(face, FACE, { band = 2, pop = { 25, 59 + b } })
  for x = 23, 40, 3 do
    for y = 56 + b, 62 + b do if face:has(x, y) then kp(c, x, y, P.wood.base) kp(c, x + 1, y, P.wood.base) if (x % 2 == 0) then kp(c, x, y + 1, P.wood.shade) end break end end
  end
  c:part(c:ellipse(31.5, 70 + b, 3.5, 2.5), FACE, { band = 1, sep = true, pop = { 29, 69 + b } })
  for x = 30, 33 do for y = 71 + b, 72 + b do c:put(x, y, P.wood.deep) end end
  c:put(31, 71 + b, P.stone.hi)
  c:eyeSmall(26, 62 + b) c:eyeSmall(36, 62 + b)
  c:cheek(23, 67 + b) c:cheek(39, 67 + b)
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
