-- _aC31_5.lua: private helpers for pancakes, pandanus, pandanus-seed, papaya (final, aC31_5, Opus single pass).
-- Read-only use of batch2/_b2g1.lua + _b2g2.lua (-> batch1/_g1.lua -> _h.lua). Shared files are not edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local G2 = dofile(DIR .. "/../../batch2/_b2g2.lua")
G.palm, G.drop, G.path = G2.palm, G2.drop, G2.path
local HP, X, K = G.HP, G.X, G.K
local floor, sqrt, max, min, abs, cos, sin = math.floor, math.sqrt, math.max, math.min, math.abs, math.cos, math.sin
-- paint hand map rows at (x0,y0) with colour table (owner token optional)
function G.map(c, rows, x0, y0, cols, tok)
  for yy, row in ipairs(rows) do for xx = 1, #row do local ch = row:sub(xx, xx)
    if cols[ch] then c:put(x0 + xx - 1, y0 + yy - 1, cols[ch], tok) end end end
end
-- cut all pixels of mask m out of the canvas (to make torn edges / gaps after painting)
function G.erase(c, m) m:each(function(x, y) local i = y * c.w + x c.pix[i] = nil c.own[i] = nil end) end
-- tube along a cubic bezier with round end caps (wider search box than _b2g1's G.tube). returns m, n, T, S, samples
function G.tubeR(p, wfn, N)
  N = N or 160
  local sm = {}
  for i = 0, N do
    local t = i / N
    local x, y = G.bez(p, t)
    local x2, y2 = G.bez(p, min(1, t + 0.002)) local x1, y1 = G.bez(p, max(0, t - 0.002))
    local tx, ty = x2 - x1, y2 - y1 local l = sqrt(tx*tx + ty*ty) tx, ty = tx / l, ty / l
    local px, py = -ty, tx if px + py < 0 then px, py = -px, -py end
    sm[#sm + 1] = { x = x, y = y, t = t, px = px, py = py, tx = tx, ty = ty, w = wfn(t) }
  end
  local m, n, T, S = HP.mask(), {}, {}, {}
  local x0, y0, x1, y1 = 1e9, 1e9, -1e9, -1e9
  for _, s in ipairs(sm) do x0, y0, x1, y1 = min(x0, s.x - s.w), min(y0, s.y - s.w), max(x1, s.x + s.w), max(y1, s.y + s.w) end
  for y = floor(y0) - 1, floor(y1) + 1 do for x = floor(x0) - 1, floor(x1) + 1 do
    local best, bs
    for _, s in ipairs(sm) do local q = (x - s.x)^2 + (y - s.y)^2 - s.w * s.w if not best or q < best then best, bs = q, s end end
    if best <= 0.1 then
      local rx, ry = x - bs.x, y - bs.y
      local sd = rx * bs.px + ry * bs.py
      local sn = max(-0.97, min(0.97, sd / (bs.w + 0.5)))
      local k = K(x, y)
      m:set(x, y) n[k] = { G.norm(rx / (bs.w + 0.5), ry / (bs.w + 0.5), sqrt(max(0.02, 1 - (rx*rx + ry*ry) / (bs.w + 0.5)^2))) }
      T[k], S[k] = bs.t, sn
    end
  end end
  return m, n, T, S, sm
end
return G
