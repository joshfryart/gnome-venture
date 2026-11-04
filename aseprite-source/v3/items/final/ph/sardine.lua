-- sardine (first draft, Sonnet). A slim silver sardine in side view, slightly arched: blue-green back, bright silver
-- flank with a row of dark spots, pale belly, forked tail, ringed eye, gill arc and a small dorsal fin.
-- quirk: a bubble rises from its mouth and one loose scale floats off the flank.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD14.lua")
local c = A.new("sardine")
local floor, sin, sqrt, pi = math.floor, math.sin, math.sqrt, math.pi
local body = A.HP.mask()
local topY, botY = {}, {}
for x = 5, 46 do
  local t = (x - 5) / 41
  local h = 10.5 * sin(pi * (t ^ .8)) ^ .8 + 1.2
  local cy = 31 - 2 * sin(pi * t) + (t - .5) * 3
  topY[x], botY[x] = cy - h * .9, cy + h * .75
  for y = floor(topY[x] + .5), floor(botY[x] + .5) do body:set(x, y) end
end
-- tail
local tail = c:poly{ { 44, 30 }, { 59, 17 }, { 55, 31 }, { 59, 45 }, { 44, 33 } }
A.lit(c, tail, A.R("#6a8ab0"), 2, { amb = .1 })
for i = 0, 3 do A.ln(c, 46, 31, 58, 19 + i * 8, "#445f8a") end
-- body: silver bands
local bk, sv = A.R("#2f6f8f"), A.R("#cfd8e4")
body:each(function(x, y)
  local v = (y - topY[x]) / (botY[x] - topY[x] + .01)
  local hex
  if v < .22 then hex = bk[3] elseif v < .34 then hex = bk[4] elseif v < .46 then hex = "#7ab0c8" elseif v < .66 then hex = sv[5] elseif v < .8 then hex = sv[4] else hex = sv[3] end
  if v < .1 then hex = bk[2] end
  if ((x + floor(y / 2)) % 4 == 0) and v > .3 and v < .8 then hex = sv[6] end
  c:px(x, y, hex)
end)
-- spots, gill arc, eye, fins
for x = 14, 36, 4 do c:px(x, floor(topY[x] + (botY[x] - topY[x]) * .36), "#1f4a6a") end
for y = 25, 37 do c:px(13 + floor((y - 31) ^ 2 / 14), y, "#7aa0b8") end
c:fillMask(c:ellipse(9, 29, 2.5, 2.5), "#fff4d6") c:fillMask(c:ellipse(9, 29, 1.2, 1.2), "#2b1c26") c:px(8, 28, "#fff4d6")
local dor = c:poly{ { 26, floor(topY[26]) }, { 31, floor(topY[31]) - 5 }, { 36, floor(topY[36]) } }
A.lit(c, dor, A.R("#2f6f8f"), 1.5, {})
local pel = c:poly{ { 22, floor(botY[22]) }, { 24, floor(botY[24]) + 4 }, { 28, floor(botY[28]) } }
A.lit(c, pel, A.R("#8aa8c8"), 1.5, {})
-- mouth
c:px(5, 31, "#2b1c26") c:px(6, 32, "#2b1c26")
-- bubble + loose scale
A.sph(c, 2, 24, 2.2, "#b6f0e0", { nospec = true }) c:px(1, 23, "#fff4d6")
A.sph(c, 8, 20, 1.2, "#b6f0e0", { nospec = true })
A.sph(c, 30, 45, 1.8, "#cfd8e4", { nospec = true }) c:px(29, 44, "#fff4d6")
A.fin()
