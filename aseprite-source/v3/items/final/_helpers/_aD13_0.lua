-- _aD13_0: helper for rock-pick, rock-rose-seed, rooibos, rooibos-concentrate (Sonnet high, single pass).
-- Wraps batch2/_bbg.lua (read-only) and adds a pixel line + ramp helper.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_bbg.lua")
G.out = app.params.out or "./"
local floor, abs, max = math.floor, math.abs, math.max
-- 1px Bresenham line; fn(x,y,i,n) -> hex or nil
function G.bres(c, x0, y0, x1, y1, hex, tok)
  x0, y0, x1, y1 = floor(x0 + .5), floor(y0 + .5), floor(x1 + .5), floor(y1 + .5)
  local n = max(abs(x1 - x0), abs(y1 - y0))
  for i = 0, n do
    local t = n == 0 and 0 or i / n
    local x, y = floor(x0 + (x1 - x0) * t + .5), floor(y0 + (y1 - y0) * t + .5)
    local h = hex
    if type(hex) == "function" then h = hex(x, y, i, n) end
    if h then c:put(x, y, h, tok) end
  end
end
return G
