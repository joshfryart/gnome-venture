-- _aD11_4.lua: private helpers for ph/ramson-pesto, ramsons, rangoon-creeper-seed, raphanobrassica (final pass, Sonnet high).
-- Read-only use of _aD11_0.lua (-> _aD10_0.lua -> batch2/_b2g1.lua -> batch1/_g1.lua -> _h.lua -> lib). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/_aD11_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi

-- contact shadow: pixels of `under` that lie 1px (dx,dy) beyond `over` get `hex`
function A.contact(c, under, over, hex, dx, dy, tok)
  over:shift(dx or 1, dy or 1):each(function(x, y)
    if under:has(x, y) and not over:has(x, y) then c:put(x, y, hex, tok) end
  end)
end

-- rope / twine band along a line a->b, thickness th, twist tones tw (table, 4), lit side upper-left
function A.rope(c, a, b, th, tw, tok)
  local m = c:line({ a, b }, th)
  local vx, vy = b[1] - a[1], b[2] - a[2]
  local l = sqrt(vx * vx + vy * vy) vx, vy = vx / l, vy / l
  local px, py = -vy, vx
  if px + py > 0 then px, py = -px, -py end   -- p points toward the lit upper-left
  m:each(function(x, y)
    local u = (x - a[1]) * vx + (y - a[2]) * vy
    local v = (x - a[1]) * px + (y - a[2]) * py   -- >0 lit side
    local i = 3
    if floor(u * 0.9 + v * 0.7 + 100) % 3 == 0 then i = 2 end
    if v > th * 0.25 then i = i + 1 elseif v < -th * 0.25 then i = i - 1 end
    c:put(x, y, tw[max(1, min(#tw, i))], tok)
  end)
  return m
end
return A
