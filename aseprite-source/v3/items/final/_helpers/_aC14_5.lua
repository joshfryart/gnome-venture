-- _aC14_5.lua: private helpers for kola, kola-seed, kombucha, kowhai-seed (run3, Opus single pass).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
function G.new5(name) G.out = app.params.out or (DIR .. "/../ph/") return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
-- paint a mask with a per-pixel index function f(x,y,k)->1..#ramp
function G.fillIdx(c, m, ramp, f, tok)
  tok = tok or { r = { name = tostring(ramp) } }
  m:each(function(x, y) local i = f(x, y, K(x, y)) if i then c:put(x, y, ramp[max(1, min(#ramp, i))], tok) end end)
end
-- 1px line (Bresenham-ish), optional clip mask
function G.ln(c, x0, y0, x1, y1, hex, clip)
  local n = max(abs(x1 - x0), abs(y1 - y0))
  for i = 0, n do local t = n == 0 and 0 or i / n
    local x, y = floor(x0 + (x1 - x0) * t + .5), floor(y0 + (y1 - y0) * t + .5)
    if not clip or clip:has(x, y) then c:px(x, y, hex) end end
end
-- torn margin: remove pixels near the edge of m whose hash says so, on the side where pred(x,y) is true
function G.tear(m, pred, seed, depth)
  for d = 1, depth or 2 do
    local e = m:edge()
    e:each(function(x, y) if pred(x, y) and X.hash(x, y, seed + d) > 0.45 then m.s[K(x, y)] = nil end end)
  end
  return m
end
return G
