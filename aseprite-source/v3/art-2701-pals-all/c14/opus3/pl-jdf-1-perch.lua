-- Wing Jot (pl-jdf-1), perch sprite 36x36. Opus third pass (c14/opus3), hand-built at this size.
-- opus3: a broader wing so the face has room, clean two-tone glass, a thick costa, two long parallel veins
-- and a few regular ladder rungs (wing, not crackle), amber pterostigma, a lit glass edge.
-- A tilted flake of jade dragonfly wing: dark leading-edge vein, two long veins with cross-veins, amber
-- pterostigma near the tip, jagged root; 2x3 pill eyes in a clear cell.
-- quirk: hum rings over the tip.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_c14.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-jdf-1-perch", 36)
local floor, rad, cos, sin = math.floor, math.rad, math.cos, math.sin

local JADE = { "#123c3a", "#1c6052", "#2a8a6e", "#4cb489", "#8edcac", "#d0f4d8" }
local VEIN = "#1a4c44"
local STIG = { "#6a3a22", "#a8642a", "#d89a3c" }
local HUM  = "#a8e8c4"

local wing = c:poly{ { 4, 21 }, { 10, 17 }, { 17, 13 }, { 24, 9 }, { 28, 7 }, { 31, 7 }, { 32, 9 }, { 31, 13 },
                     { 27, 19 }, { 22, 24 }, { 16, 27 }, { 10, 29 }, { 5, 29 }, { 6, 27 }, { 3, 25 }, { 5, 23 } }
c:groundShadow(17, 33, 7, 1.5)
local I, T = O.shade(c, wing, JADE, { R = 4, amb = .42, wrap = .55, bounce = "#5a7ab0", bmax = 2 })
local DX, DY = .89, -.455
local function UV(x, y) return (x - 4) * DX + (y - 21) * DY, (x - 4) * -DY + (y - 21) * DX end
local vmin, vmax = {}, {}
wing:each(function(x, y) local u, v = UV(x, y) local k = floor(u + .5)
  vmin[k] = math.min(vmin[k] or 99, v) vmax[k] = math.max(vmax[k] or -99, v) end)
local function fd(x, y) return ((x - 16.5) / 6.5) ^ 2 + ((y - 19.5) / 5) ^ 2 end
local lit, drk, long, rung, costa, cl = {}, {}, {}, {}, {}, {}
wing:each(function(x, y)
  local u, v = UV(x, y) local k = floor(u + .5)
  local w = math.max(1, vmax[k] - vmin[k]) local dv = v - vmin[k] local f = dv / w
  if dv < 1.2 and u > 2 then costa[#costa+1] = { x, y } return end
  if dv < 2.2 and u > 2 then cl[#cl+1] = { x, y } return end
  if f < .5 then lit[#lit+1] = { x, y } else drk[#drk+1] = { x, y } end
  if fd(x, y) < 1.15 then return end
  for _, lf in ipairs({ .36, .7 }) do if math.abs(f - lf) * w < .5 then long[#long+1] = { x, y } return end end
  if (u + (f < .36 and 0 or f < .7 and 2 or 1)) % 4 < .9 and u > 3 then rung[#rung+1] = { x, y } end
end)
O.mark(c, lit, JADE[6]) O.mark(c, drk, JADE[5])
O.mark(c, rung, JADE[3]) O.mark(c, long, JADE[2])
O.mark(c, costa, VEIN) O.mark(c, cl, JADE[6])
O.mark(c, { { 26, 10 }, { 27, 10 }, { 28, 9 } }, STIG[1]) O.mark(c, { { 27, 11 }, { 28, 10 } }, STIG[3])
wing:each(function(x, y) local d = fd(x, y) if d >= 1 and d < 1.15 then O.mark(c, { { x, y } }, JADE[3]) end end)
c:eyeSmall(13, 17)
c:eyeSmall(19, 16)
O.dot(c, 11, 21, P.petal.base) O.dot(c, 22, 20, P.petal.base)
O.dots(c, { { 16, 21 }, { 17, 21 }, { 15, 22 }, { 18, 22 }, { 16, 23 }, { 17, 23 } }, P.ink) O.dots(c, { { 16, 22 }, { 17, 22 } }, "#1e5048")

O.done(c, "pl-jdf-1-perch", function(c)
  for _, r in ipairs({ 2.5, 4.5 }) do
    for a = -150, -60, 15 do
      local x, y = floor(29 + r * cos(rad(a)) + .5), floor(6 + r * sin(rad(a)) + .5)
      if not c:get(x, y) and y >= 0 then O.dot(c, x, y, HUM) end
    end
  end
end)
