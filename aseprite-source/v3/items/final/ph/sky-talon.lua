-- sky-talon (lean E2_07)
local NAME = "sky-talon"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function shade(c, m, ramp, R, name, amb, wrap)
  local n = X.pillow(m, R)
  local tok = { r = { name = name } }
  X.tone(c, m, X.light(n, { amb = amb or 0.08, wrap = wrap or 0.25 }), ramp, { cuts = { 0.2, 0.38, 0.55, 0.72, 0.87 }, tok = tok })
  return n, tok
end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
-- quirk: a small cloud-white feather tied on with a red cord
c:groundShadow(34, 57, 15, 2)
local TAL = { "#3a4e86", "#5774b8", "#82a4dc", "#b0ccf0", "#d8e8fa", "#f2f8ff" }
local tm, tn, TT = G.tube({ {18,12}, {18,32}, {32,52}, {50,53} }, function(t) return 7.4 * (1 - t) ^ 0.9 + 0.5 end)
local ttok = { r = { name = "talon" } }
local v = X.light(tn, { amb = 0.08, wrap = 0.25 })
local idx = X.tone(c, tm, v, TAL, { cuts = { 0.2, 0.38, 0.55, 0.72, 0.87 }, tok = ttok })
-- keratin growth ridges across the claw
tm:each(function(x, y) local k = K(x, y) local t = TT[k]
  if t > 0.2 and abs((t * 40) % 6 - 3) < 0.5 and idx[k] > 1 then c:put(x, y, TAL[math.max(1, idx[k] - 1)], ttok) end end)
-- spec streak along lit edge
tm:each(function(x, y) local k = K(x, y) if TT[k] > 0.25 and TT[k] < 0.7 and idx[k] >= 6 then c:put(x, y, "#fbfdff", ttok) end end)
-- cord wraps at base
local CORD = { "#6e2230", "#a23a40", "#cc5a4c" }
for i = 0, 3 do
  local y = 13 + i * 3
  for x = 10, 26 do if tm:has(x, y) then c:put(x, y, CORD[2], { r = { name = "cord" } }) end if tm:has(x, y + 1) then c:put(x, y + 1, CORD[1], { r = { name = "cord" } }) end end
  if tm:has(13, y) then c:put(13, y, CORD[3]) end
end
-- feather hanging off the cord
local fm, fn, FT, FS, fl = G.blade(22, 20, 32, 28, 36, 42, function(t) if t > 0.985 then return -1 end return max(0.5, 3.6 * sin(pi * min(1, t * 0.95 + 0.05)) ^ 0.7) end, { fold = 0.2 })
fm:cut(tm)
G.toneN(c, fm, fn, { "#9aa4c4", "#b6bedc", "#d0d6ec", "#e6eaf6", "#f2f4fa", "#fbfbf6" }, { tok = { r = { name = "feather" } }, amb = 0.1, wrap = 0.25 })
fm:each(function(x, y) local k = K(x, y) if abs(FS[k]) < 0.12 and FT[k] > 0.05 then c:put(x, y, "#8a94b4") end end)
c:put(21, 19, CORD[3]) c:put(22, 19, CORD[2])
c:sparkle(52, 44)
G.save(c, NAME)
