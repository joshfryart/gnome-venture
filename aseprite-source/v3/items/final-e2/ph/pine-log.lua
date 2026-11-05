-- pine-log (lean E2_05)
local NAME = "pine-log"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function P(x, y, col) c:put(x, y, col) end
local function RC(x0, y0, x1, y1, col) for y = y0, y1 do for x = x0, x1 do P(x, y, col) end end end
local function dome(m, ramp, R, name, o) local n = X.pillow(m, R) local t = { tok = { r = { name = name } }, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, amb = 0.1, wrap = 0.2 } if o then for k, v in pairs(o) do t[k] = v end end G.toneN(c, m, n, ramp, t) return n end
local W = { "#4e4e78", "#7c7ca4", "#aeaecb", "#d4d4e6", "#ecebf4", "#fbfaff" }
local D = { "#3a2418", "#5e3a22", "#8a5a30", "#ae7a40", "#cf9c58", "#e8c07c" }
local B = { "#2e1a14", "#52301e", "#7a4a28", "#a2683a", "#c88a4c", "#e8b06c" }
local CR = { "#8a5a30", "#bc8444", "#dca860", "#f0c880", "#fbe3a8" }
local NE = { "#1c4a30", "#2c7040", "#48984c", "#78c060" }
c:groundShadow(34, 52, 26, 3)
-- body (cylinder lit from top)
local body = c:rect(14, 22, 52, 48)
local ys = {}
body:each(function(x, y)
  local t = (y - 22) / 26
  local i = t < 0.12 and 5 or t < 0.3 and 4 or t < 0.52 and 3 or t < 0.78 and 2 or 1
  if t > 0.9 then i = 1 end
  -- bark plates: offset fissures
  local row = floor((y - 22) / 4)
  local px = (x + row * 5 + floor(X.hash(row, 1, 4) * 6)) % 9
  if (y - 22) % 4 == 3 and X.hash(x, y, 2) > 0.2 then i = max(1, i - 1) end
  if px == 0 and (y - 22) % 4 ~= 3 then i = max(1, i - 1) end
  if px == 1 and (y - 22) % 4 == 0 and t < 0.7 then i = min(6, i + 1) end
  P(x, y, B[i])
end)
-- right cut end (round, darker) 
local re = c:ellipse(52, 35, 4, 13)
dome(re, B, 6, "rend", { amb = 0.0, wrap = 0.1 })
re:each(function(x, y) if re:has(x, y) and X.hash(x, y, 5) > 0.8 then P(x, y, B[2]) end end)
-- stub of a lopped branch on top
local stub = c:rect(36, 15, 42, 23)
dome(stub, B, 2.5, "stub", { amb = 0.1, wrap = 0.3 })
local sf = c:ellipse(39, 15, 4, 2)
sf:each(function(x, y) P(x, y, (x + y) % 5 == 0 and CR[2] or CR[4]) end) P(38, 14, CR[5])
RC(36, 22, 42, 23, B[1])
-- end face (left): rings
local face = c:ellipse(15, 35, 7, 13)
face:each(function(x, y)
  local d = sqrt(((x - 15) / 7) ^ 2 + ((y - 35) / 13) ^ 2)
  local ring = floor(d * 6)
  local i = (ring % 2 == 0) and 4 or 3
  if d > 0.9 then i = 2 elseif d < 0.14 then i = 1 end
  local col = CR[min(5, max(1, i))]
  if x + y > 55 then col = CR[max(1, i - 1)] end
  P(x, y, col)
end)
-- bark rim and pith
face:edge():each(function(x, y) end)
face:shrink(1):edge():each(function(x, y) P(x, y, B[3]) end)
P(15, 35, B[2]) P(14, 35, B[3]) P(16, 36, CR[2])
for i = 0, 5 do P(16 + i, 35 + floor(i * 0.5), CR[1]) end   -- radial check crack
P(11, 28, CR[5]) P(10, 30, CR[5]) P(12, 27, CR[5])
-- resin bead + drip (quirk)
local rz = c:ellipse(17, 42, 2, 3)
G.toneN(c, rz, X.pillow(rz, 2), { "#8a3a10", "#c06a14", "#e89a20", "#f8c840", "#fff0a0" }, { tok = { r = { name = "resin" } }, cuts = { .22, .42, .62, .82 } })
P(16, 40, "#fff8c8") P(17, 46, "#c06a14") P(17, 47, "#8a3a10")
-- pine sprig on top right
for _, a in ipairs{ -0.5, -0.1, 0.35 } do
  local ox, oy = 46, 22
  for t = 0, 8 do P(floor(ox + cos(a - 1.3) * t * 0.5 + 0.5 * t * 0.3), floor(oy - t * 0.9 - 1 + a * 2), NE[2 + (t % 2) + (t > 5 and 1 or 0)]) end
end
P(46, 22, NE[1]) P(47, 22, NE[1])
G.save(c, NAME)
