-- Bark Badger (mw-bark-badger), perch sprite 36x36. Opus pass, drawn at this size by hand:
-- stocky grey badger, cream face with two ear-to-nose stripes, bark coat with fissures.
-- quirk: two bracket mushrooms on the bark, 2-3 px tall, pale lip and dark gill line.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("bark-badger-perch", 36)

local GREY = { "#33303f", "#4d485e", "#6c6880", "#8f8ba2", "#b4b1c4", "#d6d4e0" }
local DARK = { "#241c26", "#2f2633", "#3a3040", "#463b4d" }
local BLAZE= { "#b7a894", "#d3c6ae", "#e9dfc6", "#f8f0da" }
local BARK = { "#2e2226", "#47332e", "#664936", "#866444", "#a5815a", "#c4a077" }
local FUNG = { "#6e2a2a", "#a8432e", "#d4683a", "#ee9150", "#f8b878", "#fde0a8" }

c:groundShadow(18, 33, 14, 2)
for _, x in ipairs({ 12, 27 }) do
  O.shade(c, c:rrect(x, 26, x + 3, 32, 1), { GREY[1], GREY[1], GREY[2], GREY[2], GREY[3], GREY[3] }, { R = 1 })
end
O.shade(c, c:ellipse(4, 24, 2, 1.5), GREY, { R = 1, amb = .3 })
local torso = c:ellipse(15, 25, 10, 6.5)
O.shade(c, torso, GREY, { R = 3, amb = .2, wrap = .3, sep = GREY[2] })
O.mark(c, { {10,30},{13,31},{16,31},{19,30} }, GREY[5])
for _, x in ipairs({ 7, 21 }) do
  O.shade(c, c:rrect(x, 27, x + 3, 32, 1), GREY, { R = 1, amb = .25, sep = GREY[1] })
  O.dots(c, { { x, 33 }, { x + 2, 33 } }, BLAZE[3]) O.dots(c, { { x + 1, 33 }, { x + 3, 33 } }, GREY[2])
end

local head = c:ellipse(26, 20, 7.5, 7)
-- bark coat
local coat = c:ellipse(13, 23, 10, 6.5)
for x = 0, 35 do coat:cut(c:rect(x, 26 + ((x * 7) % 5 > 2 and 1 or 0), x, 35)) end
coat:cut(head:grow(1))
local cb = {}
coat:each(function(x, y) if (x + (y // 3) % 2) % 3 == 0 and y < 25 then cb[K(x, y)] = -2 end end)
O.shade(c, coat, BARK, { R = 2.5, amb = .25, wrap = .35, bias = cb, sep = BARK[1] })

-- quirk: bracket mushrooms
local function bracket(cx, cy, rx, ry)
  local m = c:ellipse(cx, cy, rx, ry)
  m:cut(c:rect(0, cy + 1, 35, 35))
  local b = {}
  m:each(function(x, y) if math.sqrt(((x - cx) / rx) ^ 2 + ((y - cy) / ry) ^ 2) >= .8 then b[K(x, y)] = 2 end end)
  O.shade(c, m, FUNG, { R = 1, amb = .45, wrap = .45, bias = b, sep = FUNG[1] })
  for x = cx - rx, cx + rx do O.dot(c, x, cy + 1, FUNG[2]) end
end
bracket(8, 18, 4, 3)
bracket(15, 16, 3, 2)

-- head
O.shade(c, head, { "#8f8494", BLAZE[1], BLAZE[2], BLAZE[3], BLAZE[4], BLAZE[4] }, { sphere = { 25, 19, 8 }, amb = .3, wrap = .35, sep = GREY[1] })
for _, ex in ipairs({ 20, 32 }) do
  O.dots(c, { { ex, 15 }, { ex + 1, 15 }, { ex, 14 }, { ex + 1, 14 } }, DARK[2])
end
O.shade(c, head, { "#8f8494", BLAZE[1], BLAZE[2], BLAZE[3], BLAZE[4], BLAZE[4] }, { sphere = { 25, 19, 8 }, amb = .3, wrap = .35 })
for _, sg in ipairs({ -1, 1 }) do
  local m = function(x) return 26 + sg * (x - 26) end
  local st, sn = O.tube({ { m(21), 15 }, { m(22), 18 }, { m(23.5), 21 }, { m(25), 23 } }, function(t) return t < .6 and 2 or 2 - (t - .6) / .4 * 1.4 end)
  st:clip(head)
  O.shadeN(c, st, sn, DARK, { amb = .45 })
end
O.mark(c, { {20,24},{20,25},{32,24},{32,25},{21,26},{31,26} }, GREY[4]) -- grey cheeks
-- pale eye patches so the pill eyes read inside the dark stripes
for _, ex in ipairs({ 21, 28 }) do O.dots(c, { { ex, 19 }, { ex + 3, 19 }, { ex, 20 }, { ex + 3, 20 }, { ex + 1, 21 }, { ex + 2, 21 } }, BLAZE[3]) end
c:eyeSmall(22, 18)
c:eyeSmall(29, 18)
O.dots(c, { {25,23},{26,23},{27,23},{26,24} }, P.ink) O.dot(c, 25, 23, GREY[5])
O.dots(c, { {25,25},{27,25} }, DARK[3])
O.dot(c, 21, 23, "#f5809f") O.dot(c, 31, 23, "#f5809f")

O.shift(c, 0, -1)
O.done(c, "bark-badger-perch")
