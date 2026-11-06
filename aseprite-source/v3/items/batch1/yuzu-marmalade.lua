-- yuzu-marmalade (pass B, final). Slim straight-sided glass jar (22 px) with rounded glass shoulders, green gingham
-- cap pinched by twisted twine (bow + frayed ends), pinked skirt with folds. Translucent amber marmalade:
-- glow on the shade side, darker where the glass is thickest, curling peel shreds, bubbles, bright meniscus.
-- Glass: pale headspace, bright left rim streak, thick base with a caustic, cool rim on the right.
-- History: yuzu-marmalade.pA (pass A).
-- quirk: a glossy drip of marmalade escaping from under the cloth and running down the glass.
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_h.lua")
local HP, X, c, P = H.new("yuzu-marmalade")
local K, floor, max, min = H.K, math.floor, math.max, math.min
local DY = -2
local function put(x, y, h) c:put(x, y + DY, h) end

local GLASS = { "#35607c", "#5287a2", "#7fb3c4", "#aad8dc", "#d2f0ea", "#f2fff9" }
local MARM  = { "#6e2412", "#a03c16", "#cc621a", "#ec8a1e", "#ffb22e", "#ffda66" }
local GLOW  = "#ffc94a"
local PAPER = { "#a8946e", "#cbb68c", "#e4d3aa", "#f4e8c8", "#fff6e0" }
local CLOTH = { "#9c9078", "#c2b698", "#ddd2b4", "#efe6c8", "#faf3dc", "#fffbee" }
local GING  = { "#1f4a42", "#2a6448", "#3a874c", "#54a352", "#77bd58", "#a6d872" }
local TWINE = { "#4e2c20", "#7d4c2c", "#a87240", "#d0a262", "#ecc88e" }
local YUZU  = { "#b57418", "#e0a020", "#f8cc3a", "#ffe880" }

c:groundShadow(32, 58 + DY, 13, 2)
-- glass jar: neck, rounded shoulder, straight body, rounded foot
local jar = c:rrect(21, 27, 42, 57, 3):add(c:rect(25, 22, 38, 27)):add(c:rrect(22, 24, 41, 31, 4))
local function tx(x, x0, x1) return ((x - x0) / (x1 - x0)) * 2 - 1 end
jar:each(function(x, y)
  local t = tx(x, 21, 42)
  local i = (t < -0.8) and 5 or (t < -0.3) and 4 or (t < 0.5) and 4 or (t < 0.85) and 3 or 2
  if y >= 24 and y <= 26 and t < 0.6 then i = 5 end                         -- shoulder catches the light
  put(x, y, GLASS[i])
end)
-- marmalade (inset 2, top at y33, meniscus curls up at the walls)
local fill = c:rrect(23, 35, 40, 55, 2):add(c:rect(23, 34, 23, 35)):add(c:rect(40, 34, 40, 35))
fill:each(function(x, y)
  local t = tx(x, 23, 40)
  local i = (t < -0.75) and 3 or (t < -0.2) and 4 or (t < 0.25) and 4 or (t < 0.7) and 5 or (t < 0.88) and 3 or 2
  if y >= 52 then i = max(1, i - 1) end
  if y >= 54 then i = max(1, i - 1) end
  if y <= 36 then i = 6 end
  if y == 37 then i = max(2, i - 2) end
  local col = MARM[min(6, i)]
  if i == 5 and t > 0.3 and t < 0.65 and y > 38 and y < 50 then col = GLOW end   -- light glowing through
  put(x, y, col)
end)
-- peel shreds: curling strips, pale top edge, dark underside
local shreds = { { {25,39},{26,39},{27,40},{28,40} }, { {33,40},{34,40},{35,39} }, { {29,44},{30,45},{31,45},{32,44} },
  { {36,47},{37,47},{38,48} }, { {25,49},{26,50},{27,50} }, { {32,51},{33,51},{34,52},{35,52} }, { {37,42},{38,41} } }
for _, s in ipairs(shreds) do
  for _, p in ipairs(s) do put(p[1], p[2], MARM[6]) if fill:has(p[1], p[2] + 1) then put(p[1], p[2] + 1, MARM[2]) end end
end
put(35, 41, MARM[6]) put(28, 47, "#ffe9a8") put(36, 52, "#ffe9a8")                -- bubbles
-- glass base: thick, pale, with a caustic
for x = 22, 41 do put(x, 56, GLASS[(x < 27) and 6 or (x < 37) and 4 or 3]) end
for x = 23, 40 do put(x, 57, GLASS[(x < 26) and 4 or 2]) end
put(33, 56, "#ffd27a") put(34, 56, "#ffbe55")
-- glass rims: bright left streak (broken by the label), cool right edge
for y = 27, 54 do if y < 42 or y > 51 then put(22, y, GLASS[6]) end end
for y = 30, 37 do put(23, y, GLASS[5]) end
for y = 29, 53 do put(41, y, GLASS[3]) end
for y = 44, 50 do put(39, y, "#ffe2a0") end
-- label: kraft tag with a yuzu
local lab = c:rrect(26, 42, 37, 51, 2)
lab:each(function(x, y)
  local i = 4
  if x == 26 or y == 42 then i = 5 end
  if x == 37 or y == 51 then i = 2 end
  if (x == 36 or y == 50) and i == 4 then i = 3 end
  put(x, y, PAPER[i])
end)
local yu = c:ellipse(31, 47, 2.5, 2.5)
yu:each(function(x, y) local d = (x - 30) + (y - 46) put(x, y, YUZU[d <= 0 and 3 or d <= 2 and 2 or 1]) end)
put(30, 46, YUZU[4]) put(32, 47, YUZU[2]) put(29, 48, YUZU[2])               -- pitted rind
put(33, 44, GING[5]) put(34, 44, GING[4]) put(34, 43, GING[5]) put(35, 43, GING[3]) put(32, 44, TWINE[2])
-- cloth cap: puff above the twine, flared skirt with pinked edge below
local puff = c:rrect(23, 12, 40, 22, 4)
local skirt = c:poly{ {25,22},{38,22},{43,29},{20,29} }
for x = 20, 43 do if (x - 20) % 5 < 3 then skirt:set(x, 30) end if (x - 20) % 5 == 1 then skirt:set(x, 31) end end
local cap = puff:copy():add(skirt)
local cn = X.pillow(cap, 3)
local cv = X.light(cn, { amb = 0.12, wrap = 0.3 })
local folds = { {28,23,-2}, {35,23,2} }
cap:each(function(x, y)
  local i = floor(cv[K(x, y)] * 5.99) + 1
  if y >= 23 then
    for _, f in ipairs(folds) do
      local fx = f[1] + f[3] * (y - f[2]) / 3
      if math.abs(x - fx) < 0.5 then i = i - 1 end
    end
  end
  if y == 12 + 0 and x > 26 and x < 37 then i = i + 1 end
  i = max(1, min(6, i))
  local sx, sy = floor((x - 20) / 3) % 2 == 0, floor((y - 12) / 3) % 2 == 0
  local col
  if sx and sy then col = GING[max(1, i - 1)] elseif sx or sy then col = GING[min(6, i)] else col = CLOTH[min(6, i)] end
  put(x, y, col)
end)
-- twisted twine pinching the neck
for x = 23, 40 do
  local a = (x % 3)
  put(x, 21, TWINE[a == 0 and 5 or a == 1 and 4 or 3]) put(x, 22, TWINE[a == 0 and 2 or a == 1 and 3 or 2])
end
-- bow knot + two dangling frayed ends
c:paint({ ".ab..", "abcba", ".bdb.", "..b.." }, 34 - 1, 19 + DY, { a = TWINE[5], b = TWINE[3], c = TWINE[1], d = TWINE[2] })
for _, p in ipairs{ {37,23},{38,24},{38,25},{39,26},{39,27},{40,28},{40,29} } do put(p[1], p[2], TWINE[4]) put(p[1] + 1, p[2], TWINE[2]) end
for _, p in ipairs{ {34,23},{34,24},{33,25},{33,26},{33,27} } do put(p[1], p[2], TWINE[3]) end
put(40, 30, TWINE[5]) put(42, 30, TWINE[4]) put(32, 28, TWINE[4])
-- quirk: drip running down the glass from under the skirt, glossy bead at the end
for y = 31, 35 do put(28, y, MARM[4]) put(29, y, MARM[2]) end
put(28, 31, MARM[6]) put(28, 32, MARM[5])
put(27, 35, MARM[4]) put(27, 36, MARM[5]) put(28, 36, MARM[4]) put(29, 36, MARM[2]) put(28, 37, MARM[2]) put(27, 37, MARM[3])
put(27, 36, "#fff0c0")
H.fin(c)
