-- Bark Badger (mw-bark-badger), yard sprite 64x64. Opus pass, art-2701-opus.
-- Rootwarden, uncommon. A low, stocky badger trundling right, wearing a slab of tree bark as a
-- coat (fissured plates, ragged hem, a moss tuft), striped face with a cream blaze and an ink
-- nose. quirk: two bracket mushrooms growing out of the bark on its back.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("bark-badger-yard", 64)

local GREY = { "#33303f", "#4d485e", "#6c6880", "#8f8ba2", "#b4b1c4", "#d6d4e0" }
local DARK = { "#241c26", "#2f2633", "#3a3040", "#463b4d" }
local BLAZE= { "#b7a894", "#d3c6ae", "#e9dfc6", "#f8f0da" }
local BARK = { "#2e2226", "#47332e", "#664936", "#866444", "#a5815a", "#c4a077" }
local FUNG = { "#6e2a2a", "#a8432e", "#d4683a", "#ee9150", "#f8b878", "#fde0a8" }
local MOSS = { "#24544a", "#3f9150", "#7cc35a", "#c4e07a" }

c:groundShadow(32, 57, 24, 3)

-- far legs (behind, darker)
for _, x in ipairs({ 22, 49 }) do
  local l = c:rrect(x, 46, x + 5, 56, 2)
  O.shade(c, l, { GREY[1], GREY[1], GREY[2], GREY[2], GREY[3], GREY[3] }, { R = 1.5 })
end
-- stub tail
O.shade(c, c:ellipse(8, 41, 3, 2.5), GREY, { R = 1.5, amb = .3 })

-- torso
local torso = c:ellipse(26, 43, 18, 11)
O.shade(c, torso, GREY, { R = 6, amb = .2, wrap = .3, sep = GREY[2] })
O.mark(c, { {16,53},{19,54},{22,54},{25,54},{28,54},{31,54},{34,53},{18,52},{24,53},{30,53} }, GREY[5]) -- belly fringe

-- near legs, cream claws
for _, x in ipairs({ 12, 37 }) do
  local l = c:rrect(x, 47, x + 6, 56, 2)
  O.shade(c, l, GREY, { R = 2, amb = .2, sep = GREY[1] })
  O.dots(c, { { x + 1, 57 }, { x + 3, 57 }, { x + 5, 57 } }, BLAZE[3])
  O.dots(c, { { x + 2, 57 }, { x + 4, 57 } }, GREY[2])
end

-- bark coat over the back: fissured plates, ragged hem
local head = c:ellipse(46, 36, 12, 11)
local coat = c:ellipse(24, 40, 17, 10)
for x = 0, 63 do
  local cutTo = 45 + ((x * 7) % 5 > 2 and 2 or 0) + ((x % 6 == 0) and 1 or 0)
  coat:cut(c:rect(x, cutTo, x, 63))
end
coat:cut(head:grow(1))
local cb = {}
coat:each(function(x, y)
  local j = math.floor(X.hash(0, y // 3, 7) * 3)
  if (x + j + (y // 4) % 2 * 2) % 5 == 0 and y < 44 then cb[K(x, y)] = -2 end -- vertical fissures
  if y % 4 == 0 and (x + y) % 3 == 0 then cb[K(x, y)] = (cb[K(x, y)] or 0) - 1 end
end)
O.shade(c, coat, BARK, { R = 4, amb = .22, wrap = .35, bias = cb, sep = BARK[1] })

-- quirk: bracket mushrooms (shelf fungi) out of the bark, ringed, pale lip, gills below
local function bracket(cx, cy, rx, ry)
  local m = c:ellipse(cx, cy, rx, ry)
  m:cut(c:rect(0, cy + 1, 63, 63))
  local b = {}
  m:each(function(x, y)
    local d = math.sqrt(((x - cx) / rx) ^ 2 + ((y - cy) / ry) ^ 2)
    if d > .45 and d < .68 then b[K(x, y)] = -1 end
    if d >= .86 then b[K(x, y)] = 2 end
  end)
  O.shade(c, m, FUNG, { R = 2, amb = .4, wrap = .45, bias = b, sep = FUNG[1] })
  for x = cx - rx, cx + rx do O.dot(c, x, cy + 1, FUNG[2]) end -- gill underside
  for x = cx - rx + 1, cx + rx - 1, 2 do O.dot(c, x, cy + 1, FUNG[1]) end
end
bracket(15, 32, 7, 5)
bracket(26, 29, 5, 4)

-- head, turned to the viewer
O.shade(c, head, GREY, { sphere = { 44, 33, 13 }, amb = .3, wrap = .35, sep = GREY[1] })
for _, e in ipairs({ { 36, 26 }, { 56, 26 } }) do -- ears
  local m = c:ellipse(e[1], e[2], 2.5, 2.5)
  O.shade(c, m, DARK, { R = 1, sep = DARK[1] })
  O.dot(c, e[1], e[2], BLAZE[2]) O.dot(c, e[1], e[2] + 1, BLAZE[1])
end
O.shade(c, head, { "#8f8494", BLAZE[1], BLAZE[2], BLAZE[3], BLAZE[4], BLAZE[4] }, { sphere = { 44, 33, 13 }, amb = .3, wrap = .35 }) -- head over ear bases
-- dark eye stripes
for _, sg in ipairs({ -1, 1 }) do -- ear to nose, tapering
  local m = function(x) return 46 + sg * (x - 46) end
  local st, sn = O.tube({ { m(37), 24 }, { m(38), 30 }, { m(41), 36 }, { m(44), 40 } }, function(t) return t < .6 and 3.7 or 3.7 - (t - .6) / .4 * 2.7 end)
  st:clip(head)
  O.shadeN(c, st, sn, DARK, { amb = .45 })
end
-- cream blaze from the forehead down to the muzzle
-- grey cheek fur low on the sides of the face
for _, sx in ipairs({ 37, 55 }) do O.shade(c, c:ellipse(sx, 42, 3, 3):clip(head), GREY, { R = 1.5, amb = .45 }) end
-- nose + mouth
O.dots(c, { {45,39},{46,39},{47,39},{45,40},{46,40},{47,40},{46,41} }, P.ink)
O.dot(c, 45, 39, GREY[5])
O.dots(c, { {45,43},{47,43} }, DARK[3]) O.dot(c, 46, 42, DARK[3])
c:eyeLocked(38, 32)
c:eyeLocked(50, 32)
c:cheek(36, 40) c:cheek(55, 40)

O.done(c, "bark-badger-yard")
