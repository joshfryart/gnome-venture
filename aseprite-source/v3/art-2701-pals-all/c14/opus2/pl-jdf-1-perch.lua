-- Wing Jot (pl-jdf-1), perch sprite 36x36. Opus second pass (c14/opus2), hand-built at this size.
-- A tilted flake of jade dragonfly wing: dark leading-edge vein, two long veins with cross-veins, amber
-- pterostigma near the tip, jagged root; 2x3 pill eyes in a clear cell.
-- quirk: hum rings over the tip.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-jdf-1-perch", 36)
local floor, rad, cos, sin = math.floor, math.rad, math.cos, math.sin

local JADE = { "#123c3a", "#1c6052", "#2a8a6e", "#4cb489", "#8edcac", "#d0f4d8" }
local VEIN = "#1a4c44"
local STIG = { "#6a3a22", "#a8642a", "#d89a3c" }
local HUM  = "#a8e8c4"

local wing = c:poly{ { 4, 21 }, { 10, 17 }, { 17, 13 }, { 24, 9 }, { 28, 7 }, { 31, 7 }, { 32, 9 }, { 31, 12 },
                     { 27, 17 }, { 22, 22 }, { 16, 25 }, { 10, 27 }, { 5, 27 }, { 6, 25 }, { 3, 24 }, { 5, 22 } }
c:groundShadow(17, 32, 7, 1.5)
local I, T = O.shade(c, wing, JADE, { R = 4, amb = .42, wrap = .55, bounce = "#5a7ab0", bmax = 2 })
local function fd(x, y) return ((x - 16.5) / 6.5) ^ 2 + ((y - 18.5) / 4.6) ^ 2 end
local vp = {}
for _, p in ipairs({ { { 6, 24 }, { 13, 21 }, { 22, 16 }, { 30, 11 } }, { { 7, 26 }, { 14, 24 }, { 22, 20 }, { 29, 14 } } }) do
  for k = 0, 40 do local x, y = O.bez(p, k / 40) vp[#vp+1] = { floor(x + .5), floor(y + .5) } end
end
for _, s in ipairs({ { 8, 22, 9, 26 }, { 25, 13, 26, 17 }, { 28, 10, 28, 14 }, { 23, 11, 23, 13 }, { 9, 19, 9, 21 } }) do
  for k = 0, 4 do vp[#vp+1] = { floor(s[1] + (s[3] - s[1]) * k / 4 + .5), floor(s[2] + (s[4] - s[2]) * k / 4 + .5) } end
end
for _, q in ipairs(vp) do if wing:has(q[1], q[2]) and fd(q[1], q[2]) > 1.1 then O.mark(c, { q }, JADE[3]) end end
local cst = {}
wing:each(function(x, y) if wing:has(x, y - 1) and not wing:has(x, y - 2) and x > 6 then cst[#cst+1] = { x, y } end end)
for _, q in ipairs(cst) do O.mark(c, { q }, VEIN) end
O.mark(c, { { 26, 10 }, { 27, 10 } }, STIG[2]) O.mark(c, { { 27, 9 } }, STIG[3])

-- the face sits in a pale clear cell of the membrane so the small eyes read
wing:each(function(x, y) local d = fd(x, y) if d < .8 then O.mark(c, { { x, y } }, (x + y < 33) and JADE[6] or JADE[5]) elseif d < 1.1 then O.mark(c, { { x, y } }, JADE[4]) end end)
c:eyeSmall(13, 16)
c:eyeSmall(19, 15)
O.dot(c, 11, 20, P.petal.base) O.dot(c, 22, 19, P.petal.base)
O.dots(c, { { 16, 20 }, { 17, 20 }, { 15, 21 }, { 18, 21 }, { 16, 22 }, { 17, 22 } }, P.ink) O.dots(c, { { 16, 21 }, { 17, 21 } }, "#1e5048")

O.done(c, "pl-jdf-1-perch", function(c)
  for _, r in ipairs({ 2.5, 4.5 }) do
    for a = -150, -60, 15 do
      local x, y = floor(29 + r * cos(rad(a)) + .5), floor(6 + r * sin(rad(a)) + .5)
      if not c:get(x, y) and y >= 0 then O.dot(c, x, y, HUM) end
    end
  end
end)
