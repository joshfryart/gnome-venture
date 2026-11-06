-- _aB35_1.lua: private helpers for golden-carp, golden-carp-feast, golden-shower-seed, golden-talon (Opus single pass).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua). Adds a few small utilities.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, max, min, abs = math.floor, math.max, math.min, math.abs
G.out = app.params.out or (DIR .. "/../ph/")
-- set a pixel only if inside mask
function G.pin(c, m, x, y, hex, tok) if m:has(x, y) then c:put(x, y, hex, tok) end end
-- mask from a bezier point at t with offset s (in half-widths) using tube samples
function G.at(samp, t, s)
  local q = samp[floor(t * (#samp - 1)) + 1]
  return floor(q.x + q.px * q.w * s + .5), floor(q.y + q.py * q.w * s + .5)
end
-- re-tone a pixel index by delta, using a stored idx table
function G.step(c, idx, ramp, x, y, d, tok)
  local i = idx[K(x, y)] if not i then return end
  c:put(x, y, ramp[max(1, min(#ramp, i + d))], tok)
end
-- jagged torn cut: removes pixels of m beyond line (nx,ny).(p - p0) > jag(x,y)
function G.tear(m, x0, y0, nx, ny, amp, seed)
  local cut = {}
  m:each(function(x, y)
    local d = (x - x0) * nx + (y - y0) * ny
    local along = -(x - x0) * ny + (y - y0) * nx
    local j = (X.hash(floor(along / 2), 0, seed or 3) - 0.5) * 2 * amp
    if d > j then cut[#cut + 1] = { x, y } end
  end)
  for _, p in ipairs(cut) do m.s[K(p[1], p[2])] = nil end
  return m
end
return G
