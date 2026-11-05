-- scorpion-plate (lean E2_06)
local NAME = "scorpion-plate"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function R(v) return floor(v + 0.5) end
local function paint(m, ramp, rad, name, opt) opt = opt or {}
  local n = X.pillow(m, rad or 4); local tok = { r = { name = name } }
  local idx = X.tone(c, m, X.light(n, { amb = opt.amb or 0.08, wrap = opt.wrap or 0.25 }), ramp, { cuts = { 0.22, 0.4, 0.56, 0.72, 0.86 }, tok = tok })
  return n, idx, tok end
local function sel(m, fn) local o = HP.mask() m:each(function(x, y) if fn(x, y) then o:set(x, y) end end) return o end
local function spec(m, n, col, tok) local x, y = G.specAt(m, n, 30) if x then c:put(x, y, col, tok) end end
local PLATE = { "#4a5a7e", "#6a82aa", "#8eaad0", "#b4cce6", "#d8e6f4", "#f4f8fc" }
local SCOR = { "#4a1a10", "#7a2c14", "#a8481c", "#cc6a24", "#ec9438", "#fcc468" }
local LEM = { "#c8860c", "#e8aa14", "#f8cc2c", "#fce458" }
c:groundShadow(32, 58, 26, 3)
local pl = c:ellipse(32, 42, 27, 15)
local pn, _, pt = paint(pl, PLATE, 10, "plate")
local well = c:ellipse(32, 43, 20, 10)
paint(well, { PLATE[3], PLATE[4], PLATE[5], PLATE[5], PLATE[6], PLATE[6] }, 6, "well", { amb = 0.3 })
-- tail first (behind): beaded segments curling up on the right
local pts = { { 33, 46 }, { 42, 52 }, { 54, 46 }, { 50, 28 } }
local tm, tn, TT = G.tube(pts, function(t) return 3.2 - 1.2 * t end)
local tt = { r = { name = "tail" } }
G.toneN(c, tm, tn, SCOR, { tok = tt, amb = 0.1, wrap = 0.3 })
tm:each(function(x, y) local t = TT[K(x, y)] if t * 7 - floor(t * 7) < 0.2 then c:put(x, y, SCOR[1], tt) end end)
-- stinger
local st = c:poly{ { 48, 29 }, { 52, 29 }, { 50, 21 } }
paint(st, { SCOR[1], SCOR[2], SCOR[3], SCOR[4], SCOR[5], SCOR[6] }, 2, "sting")
c:put(50, 21, "#d8ffa0", { r = { name = "venom" } }); c:put(50, 22, "#8ae04c", { r = { name = "venom" } })
-- legs
local lg = { r = { name = "leg" } }
for i, y in ipairs{ 36, 40, 44 } do
  for sd = -1, 1, 2 do
    c:line({ { 32 + sd * 7, y }, { 32 + sd * 12, y + 2 }, { 32 + sd * 14, y + 6 } }, 1):each(function(x, yy) c:put(x, yy, SCOR[2], lg) end) end end
-- body (mesosoma plates)
local body = c:ellipse(32, 37, 9, 11)
local bn, bidx, bt = paint(body, SCOR, 6, "body")
for _, y in ipairs{ 33, 37, 41, 45 } do c:rect(24, y, 40, y):each(function(x, yy) if body:has(x, yy) then c:put(x, yy, SCOR[1], bt) end end) end
for _, p in ipairs{ {29,31},{30,31},{29,35},{30,35} } do c:put(p[1], p[2], SCOR[6], bt) end
c:put(28, 28, SCOR[6], bt); c:put(36, 28, "#101010", bt); c:put(28, 27, "#101010", bt)
-- claws: arm + pincer
local function claw(sd)
  local am = c:line({ { 32 + sd * 7, 31 }, { 32 + sd * 11, 26 }, { 32 + sd * 14, 22 } }, 2)
  paint(am, SCOR, 2, "arm" .. sd)
  local pin = c:poly{ { 32 + sd * 11, 22 }, { 32 + sd * 17, 20 }, { 32 + sd * 17, 14 }, { 32 + sd * 15, 13 }, { 32 + sd * 11, 17 } }
  local n, _, t = paint(pin, SCOR, 4, "pin" .. sd)
  c:line({ { 32 + sd * 14, 18 }, { 32 + sd * 17, 18 } }, 1):each(function(x, y) c:put(x, y, SCOR[1], t) end)
  c:put(32 + sd * 16, 14, SCOR[6], t) end
claw(-1); claw(1)
-- quirk: a sprig of parsley garnish
local pr = { r = { name = "pars" } }
for _, p in ipairs{ {14,50},{15,49},{16,50},{15,51},{17,49},{13,49},{14,48} } do c:put(p[1], p[2], (p[1] + p[2]) % 2 == 0 and "#4aa048" or "#78c85c", pr) end
G.save(c, NAME)
