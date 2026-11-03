-- ico-storm (Opus artist pass): a heavy violet thundercloud of three billows with a flat, dark belly, a bold
-- zig-zag lightning bolt cracking out of it and wind-slanted rain.
-- Material: the cloud is lit per pixel from a height field (max of the billow domes), so creases between billows
-- fall dark on their own; 6-tone cool ramp with a brooding deep belly and a pale lit crown. The bolt is a 6-tone
-- gold pillow with a cream hot core and an ember edge; the cloud gets a warm glow row where the bolt leaves it.
-- Rain: slanted 2 px streaks, sea ramp, lit head. quirk: a lone green leaf is caught tumbling in the gust.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_aA10_2.lua")
local HP, X, K, G = D.HP, D.X, D.K, D.G
local floor, max, min, sqrt, abs = math.floor, math.max, math.min, math.sqrt, math.abs
local c = D.new("ico-storm")
local CL, GOLD = D.CLOUD, D.GOLD
local ctok, btok = { r = { name = "cloud" } }, { r = { name = "bolt" } }

-- cloud: billow domes
local lobes = { { 21, 25, 9, 7.5 }, { 33, 19, 11, 10 }, { 45, 24, 8.5, 7.5 }, { 14.5, 29, 5, 4 }, { 51, 29, 4.5, 3.8 } }
local cm = HP.mask()
for _, l in ipairs(lobes) do cm:add(D.ell(l[1], l[2], l[3], l[4])) end
cm:add(c:rect(15, 27, 51, 32))
local function h(x, y)
  local best = 0
  for _, l in ipairs(lobes) do
    local q = ((x - l[1]) / (l[3] + 0.5)) ^ 2 + ((y - l[2]) / (l[4] + 0.5)) ^ 2
    if q < 1 then best = max(best, l[4] * sqrt(1 - q)) end
  end
  if y >= 27 and y <= 32 and x >= 15 and x <= 51 then best = max(best, 2.5) end
  return best
end
local n = {}
cm:each(function(x, y)
  local gx, gy = (h(x + 1, y) - h(x - 1, y)) / 2, (h(x, y + 1) - h(x, y - 1)) / 2
  local l = sqrt(gx*gx + gy*gy + 1)
  n[K(x, y)] = { -gx / l, -gy / l, 1 / l }
end)
local bias = {}
cm:each(function(x, y) local k = K(x, y)
  if y >= 31 then bias[k] = -2 elseif y >= 29 then bias[k] = -1 end
end)
local v = X.light(n, { amb = 0.08, wrap = 0.35 })
local cidx = X.tone(c, cm, v, CL, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, bias = bias, tok = ctok })
-- creases where one billow tucks behind another: darken the pixel on the far side of the seam
local function arg(x, y)
  local best, bi = 0, 0
  for i, l in ipairs(lobes) do
    local q = ((x - l[1]) / (l[3] + 0.5)) ^ 2 + ((y - l[2]) / (l[4] + 0.5)) ^ 2
    if q < 1 and l[4] * sqrt(1 - q) > best then best, bi = l[4] * sqrt(1 - q), i end
  end
  return bi
end
cm:each(function(x, y) local k = K(x, y)
  local a = arg(x, y)
  if a > 0 and y < 29 and ((cm:has(x - 1, y) and arg(x - 1, y) ~= a and arg(x - 1, y) > 0) or (cm:has(x, y - 1) and arg(x, y - 1) ~= a and arg(x, y - 1) > 0)) then
    c:put(x, y, CL[max(1, (cidx[k] or 3) - 2)], ctok)
  end
end)
-- crown highlight 2x1 pop + one cream on the big billow
c:put(28, 12, CL[6], ctok) c:put(29, 12, CL[6], ctok) c:put(27, 13, D.CREAM, ctok)

-- bolt
local bpts = { { 35, 29 }, { 27, 43 }, { 33, 43 }, { 27, 57 }, { 43, 38 }, { 36.5, 38 }, { 42, 29 } }
local bm = D.poly(bpts)
local bn = X.pillow(bm, 1.6, 1.0)
local bidx = D.tone(c, bm, bn, GOLD, { amb = 0.35, wrap = 0.4, cuts = { 0.15, 0.3, 0.45, 0.6, 0.78 }, tok = btok })
-- hot cream core: a continuous 1 px line down the middle of each stroke
for _, seg in ipairs{ { 38, 31, 32, 41 }, { 31, 45, 28, 53 } } do
  local x0, y0, x1, y1 = seg[1], seg[2], seg[3], seg[4]
  local nst = max(abs(x1 - x0), abs(y1 - y0))
  for i = 0, nst do local x, y = floor(x0 + (x1 - x0) * i / nst + .5), floor(y0 + (y1 - y0) * i / nst + .5)
    if bm:has(x, y) then c:put(x, y, "#fff6c8", btok) end end
end
-- ember edge on the shade side
bm:edge():each(function(x, y) if not bm:has(x + 1, y) and not bm:has(x, y + 1) then c:put(x, y, "#c8502e", btok) end end)
-- warm glow on the cloud belly where the bolt bursts out
for x = 32, 45 do for y = 27, 32 do
  if cm:has(x, y) and not bm:has(x, y) and (bm:has(x, y + 1) or bm:has(x + 1, y) or bm:has(x - 1, y)) then c:put(x, y, "#a8607a", ctok) end
end end

-- rain: slanted streaks (top-right to bottom-left), 2 px wide, lit head
local rtok = { r = { name = "rain" } }
local function drop(x, y)
  local pts = { { 0, 0 }, { 1, 0 }, { 0, 1 }, { -1, 1 }, { -1, 2 }, { -2, 2 }, { -2, 3 }, { -3, 3 } }
  for i, p in ipairs(pts) do
    local col = i <= 2 and D.RAIN[4] or (p[1] - p[2] < -3 and D.RAIN[2] or D.RAIN[3])
    c:put(x + p[1], y + p[2], col, rtok)
  end
end
drop(19, 37) drop(16, 46) drop(24, 50) drop(50, 36) drop(46, 49)

-- quirk: a tumbling leaf in the gust (pointed oval, midrib, darker underside)
local ltok = { r = { name = "leaf" } }
local leaf = {
  "...dGGG..",
  "..dGLLLG.",
  ".dGmmmmLS",
  "dmmGGGLd.",
  ".dddGd...",
}
local LC = { g = D.LEAF[2], G = D.LEAF[3], L = D.LEAF[4], m = D.LEAF[1], d = D.LEAF[2], S = "#8a6a3a" }
for yy, row in ipairs(leaf) do for xx = 1, #row do local ch = row:sub(xx, xx)
  if LC[ch] then c:put(47 + xx - 1, 41 + yy - 1, LC[ch], ltok) end end end
D.save(c, "ico-storm")
