-- _aC11_5.lua: private helpers for chunk aC11_5 (herb-flatbread, heron-plume, hibiscus, hibiscus-cordial).
-- Read-only wrap of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua, hp.lua, hpx.lua). Shared files are not edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, max, min = math.floor, math.abs, math.max, math.min
G.hash = X.hash
-- 1px line
function G.ln(c, x0, y0, x1, y1, hex, clip)
  local n = max(abs(x1 - x0), abs(y1 - y0))
  for i = 0, n do
    local t = n == 0 and 0 or i / n
    local x, y = floor(x0 + (x1 - x0) * t + .5), floor(y0 + (y1 - y0) * t + .5)
    if not clip or clip:has(x, y) then c:put(x, y, hex) end
  end
end
-- pixels of `under` 4-adjacent to `front` (not in front) get hex: part separation line
function G.seam(c, under, front, hex)
  under:each(function(x, y)
    if front:has(x, y) then return end
    if front:has(x+1, y) or front:has(x-1, y) or front:has(x, y+1) or front:has(x, y-1) then c:put(x, y, hex) end
  end)
end
-- paint from pixel-map rows; map char -> hex
function G.stamp(c, x0, y0, rows, map)
  for yy, row in ipairs(rows) do for xx = 1, #row do local ch = row:sub(xx, xx)
    if map[ch] then c:put(x0 + xx - 1, y0 + yy - 1, map[ch]) end end end
end
return G
