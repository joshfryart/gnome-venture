-- Rime Crumb (pl-frt-1), perch sprite 36x36. Opus richness pass (c08/opus3), hand-built at this size: a faceted blue ice lump
-- (six flat facets, lit top-left, deep lower-right, pale ridge lines), two ice shards on top, stubby feet joined to
-- the body, 2x3 pill eyes and a wide open croaking toad mouth with a pink tongue.
-- Richness kept bold: hue-shifted ice ramp, rim light on the silhouette, lilac snow bounce, a short crack, one
-- frozen bubble, lit shard ridges.
-- quirk: a small frost puff by the mouth corner.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, P = O.HP, O.P
local c = O.canvas("pl-frt-1-perch", 36)
local ICE = { "#1c2a5e", "#28508e", "#4280c0", "#72b2de", "#aadcf2", "#e0f6fc" }

c:groundShadow(17, 33, 11, 1.5)
for _, fx in ipairs({ 12, 22 }) do
  O.shade(c, c:ellipse(fx, 30.5, 3, 1.5), ICE, { R = 1, amb = .3, sep = ICE[1], rim = true })
end
for _, s in ipairs({ { { 11, 11 }, { 13, 6 }, { 15, 10 }, 5 }, { { 15, 9 }, { 17, 3 }, { 20, 9 }, 6 }, { { 20, 10 }, { 23, 6 }, { 24, 11 }, 4 } }) do
  local m = c:poly{ s[1], s[2], s[3] }
  O.flat(c, m, ICE[s[4]], "shard")
  m:each(function(x, y) if x > s[2][1] then c.pix[y * c.w + x] = ICE[s[4] - 2]:lower() end end)
  m:each(function(x, y) if x == s[2][1] and y > s[2][2] then c.pix[y * c.w + x] = ICE[6]:lower() end end)
end
local V = { A = { 9, 11 }, B = { 17, 8 }, C = { 25, 11 }, D = { 28, 18 }, E = { 25, 28 }, F = { 9, 28 }, G = { 6, 18 },
  J = { 12, 13 }, K = { 22, 13 }, L = { 24, 20 }, M = { 21, 26 }, N = { 13, 26 }, Q = { 10, 20 } }
local facets = { { { "A", "B", "K", "J" }, 6 }, { { "B", "C", "K" }, 5 }, { { "A", "J", "Q", "G" }, 5 }, { { "C", "D", "L", "K" }, 3 },
  { { "D", "E", "M", "L" }, 2 }, { { "E", "F", "N", "M" }, 2 }, { { "F", "G", "Q", "N" }, 4 }, { { "J", "K", "L", "M", "N", "Q" }, 4 } }
local tok = { r = { name = "ice" } }
local body = HP.mask()
for _, f in ipairs(facets) do
  local pts = {} for _, k in ipairs(f[1]) do pts[#pts+1] = V[k] end
  local m = c:poly(pts) body:add(m)
  m:each(function(x, y) c:put(x, y, ICE[f[2]], tok) end)
end
O.mark(c, { { 12, 13 }, { 13, 13 }, { 14, 13 }, { 15, 13 }, { 16, 13 }, { 17, 13 }, { 18, 13 }, { 19, 13 }, { 20, 13 }, { 21, 13 }, { 11, 14 }, { 11, 15 }, { 10, 16 } }, ICE[6])
O.mark(c, { { 14, 26 }, { 15, 26 }, { 16, 26 }, { 17, 26 }, { 18, 26 }, { 19, 26 }, { 20, 26 }, { 23, 22 }, { 22, 24 } }, ICE[2])
O.mark(c, { { 8, 21 }, { 25, 15 } }, "#fff4d6")
-- silhouette rim (upper-left) and lilac bounce (lower-right)
local idx = {} for i, h in ipairs(ICE) do idx[h:lower()] = i end
local rimL = {}
body:each(function(x, y)
  local ul = not body:has(x - 1, y) or not body:has(x, y - 1)
  local lr = not body:has(x + 1, y) or not body:has(x, y + 1)
  local i = idx[c.pix[y * c.w + x]] or 4
  if ul and not lr then rimL[#rimL+1] = { x, y, ICE[math.min(6, i + 1)] }
  elseif lr and not ul and i <= 2 and y > 18 then rimL[#rimL+1] = { x, y, "#7a78c4" } end
end)
for _, q in ipairs(rimL) do c.pix[q[2] * c.w + q[1]] = q[3]:lower() end
O.mark(c, { { 24, 22 }, { 25, 23 }, { 25, 24 } }, ICE[1]) O.mark(c, { { 23, 22 } }, ICE[6]) -- crack
O.mark(c, { { 11, 24 } }, ICE[6]) O.mark(c, { { 12, 25 } }, ICE[3]) -- bubble
c:eyeSmall(13, 15)
c:eyeSmall(20, 15)
O.dots(c, { { 11, 19 }, { 23, 19 } }, "#f5809f")
O.dots(c, { { 13, 19 }, { 14, 19 }, { 15, 19 }, { 16, 19 }, { 17, 19 }, { 18, 19 }, { 19, 19 }, { 20, 19 }, { 21, 19 },
            { 13, 20 }, { 21, 20 }, { 14, 21 }, { 20, 21 }, { 15, 22 }, { 16, 22 }, { 17, 22 }, { 18, 22 }, { 19, 22 } }, P.ink)
O.dots(c, { { 14, 20 }, { 15, 20 }, { 16, 20 }, { 17, 20 }, { 18, 20 }, { 19, 20 }, { 20, 20 }, { 15, 21 }, { 19, 21 } }, "#1c1e48")
O.dots(c, { { 16, 21 }, { 17, 21 }, { 18, 21 } }, "#c4709a")
O.shift(c, 0, -1)
O.done(c, "pl-frt-1-perch", function(c)
  local m = c:ellipse(30.5, 17, 1.5, 1.5)
  local e = m:edge()
  m:each(function(x, y) if not c:get(x, y) then c:put(x, y, e:has(x, y) and "#5f9ad0" or "#e4f6ff") end end)
  c:put(33, 14, "#b9e2f5")
end)
