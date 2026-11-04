-- _aD12_2.lua: private helper for agent aD12_2 (rhododendron-seed, rhubarb, rhubarb-chutney, rhubarb-cordial).
-- Wraps batch2/_b2g2.lua (tube, palm, drop, blade, oval, cast, toneN) read-only and adds rell/rot/recentre/save2.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g2.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, max, min, cos, sin = math.floor, math.max, math.min, math.cos, math.sin
function G.rell(cx, cy, ux, uy, ra, rb)
  local m = HP.mask()
  local R = math.ceil(max(ra, rb)) + 1
  for y = floor(cy) - R, floor(cy) + R do for x = floor(cx) - R, floor(cx) + R do
    local dx, dy = x - cx, y - cy
    local a, b = dx*ux + dy*uy, -dx*uy + dy*ux
    if (a/ra)^2 + (b/rb)^2 <= 1.0 then m:set(x, y) end
  end end
  return m
end
function G.rot(ux, uy, a) local c, s = cos(a), sin(a) return ux*c - uy*s, ux*s + uy*c end
function G.recentre(c)
  local x0, y0, x1, y1 = 1e9, 1e9, -1e9, -1e9
  for i, _ in pairs(c.pix) do local x, y = i % c.w, i // c.w
    x0, y0, x1, y1 = min(x0, x), min(y0, y), max(x1, x), max(y1, y) end
  local W, Hh = x1 - x0 + 3, y1 - y0 + 3
  local dx = floor((c.w - W) / 2) - (x0 - 1)
  local dy = floor((c.h - Hh) / 2 + 0.5) - (y0 - 1)
  local pix, own = {}, {}
  for i, v in pairs(c.pix) do local x, y = i % c.w + dx, i // c.w + dy pix[y * c.w + x] = v own[y * c.w + x] = c.own[i] end
  c.pix, c.own = pix, own
  print(string.format("recentre dx %d dy %d (outlined size %dx%d)", dx, dy, W, Hh))
end
function G.save2(c, name) G.recentre(c) G.save(c, name) end
-- 1px line into canvas, optional clip mask
function G.ln(c, x0, y0, x1, y1, hex, clip)
  local n = max(math.abs(x1 - x0), math.abs(y1 - y0))
  for i = 0, n do
    local t = n == 0 and 0 or i / n
    local x, y = floor(x0 + (x1 - x0) * t + .5), floor(y0 + (y1 - y0) * t + .5)
    if not clip or clip:has(x, y) then c:put(x, y, hex) end
  end
end
return G
