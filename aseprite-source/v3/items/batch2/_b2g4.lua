-- _b2g4.lua: private helpers for coconut + coconut-seed (batch2, Opus). Wraps batch1/_g1.lua (unchanged).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G0 = dofile(DIR .. "/../batch1/_g1.lua")
local G = setmetatable({}, { __index = G0 })
local HP, X, K = G0.HP, G0.X, G0.K
local floor = math.floor
-- 1px hard line
function G.ln(c, x0, y0, x1, y1, hex, tok)
  local n = math.max(math.abs(x1 - x0), math.abs(y1 - y0))
  for i = 0, n do
    local t = n == 0 and 0 or i / n
    c:put(floor(x0 + (x1 - x0) * t + .5), floor(y0 + (y1 - y0) * t + .5), hex, tok)
  end
end
function G.pl(c, pts, hex, tok) for i = 1, #pts - 1 do G.ln(c, pts[i][1], pts[i][2], pts[i+1][1], pts[i+1][2], hex, tok) end end
-- centre the drawing on the canvas (bbox incl. the 1px outline that finish adds)
function G.center(c)
  local x0, y0, x1, y1 = 99, 99, -1, -1
  for i, ow in pairs(c.own) do if ow then
    local x, y = i % c.w, i // c.w
    x0, y0, x1, y1 = math.min(x0, x), math.min(y0, y), math.max(x1, x), math.max(y1, y)
  end end
  local dx = floor((c.w - 1) / 2 - (x0 + x1) / 2 + 0.5)
  local dy = floor((c.h - 1) / 2 - (y0 + y1) / 2 + 0.5)
  local pix, own = {}, {}
  for i, v in pairs(c.pix) do
    local x, y = i % c.w + dx, i // c.w + dy
    if x >= 0 and y >= 0 and x < c.w and y < c.h then pix[y * c.w + x] = v own[y * c.w + x] = c.own[i] end
  end
  c.pix, c.own = pix, own
  print(string.format("center: shift %d,%d (bbox before %d,%d-%d,%d)", dx, dy, x0, y0, x1, y1))
end
function G.save(c, name) G.center(c) G0.save(c, name) end
return G
