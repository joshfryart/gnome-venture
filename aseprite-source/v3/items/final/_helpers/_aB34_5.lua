-- _aB34_5.lua: private helpers for gnome-bandstand, gnome-statue, goat-cheese, goat-cheese-salad (B3, Opus single pass).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua). Adds a tone store for contact shadows.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local floor, sqrt, max, min = math.floor, math.sqrt, math.max, math.min
A.store = {}
function A.new(name) A.store = {} return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function A.norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return { x/l, y/l, z/l } end
-- tone a mask from normals, remember ramp+index per pixel
function A.tone(c, m, n, ramp, o)
  o = o or {}
  local idx = G.toneN(c, m, n, ramp, { bias = o.bias, cuts = o.cuts, amb = o.amb, wrap = o.wrap, tok = o.tok })
  for k, i in pairs(idx) do A.store[k] = { ramp, i } end
  return idx
end
function A.pil(c, m, ramp, R, o) local n = X.pillow(m, R or 2) return A.tone(c, m, n, ramp, o), n end
function A.setp(c, x, y, ramp, i) i = max(1, min(#ramp, i)) c:put(x, y, ramp[i]) A.store[K(x, y)] = { ramp, i } end
function A.shift(c, x, y, amt) local s = A.store[K(x, y)] if s then A.setp(c, x, y, s[1], s[2] + amt) end end
-- contact shadow: pixels just below-right of mask m (not in m) go amt tones darker
function A.contact(c, m, dx, dy, amt)
  m:shift(dx, dy):each(function(x, y) if not m:has(x, y) then A.shift(c, x, y, -(amt or 1)) end end)
end
-- vertical cylinder normals between x0..x1 (ny tilt)
-- inner separation: edge pixels of m touching an earlier-stored pixel outside m drop to tone <= lvl
function A.sep(c, m, lvl, prev)
  local hit = {}
  m:edge():each(function(x, y)
    for _, d in ipairs{ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do
      local q = K(x + d[1], y + d[2])
      if not m:has(x + d[1], y + d[2]) and A.store[q] and (not prev or prev[q]) then hit[#hit + 1] = { x, y } break end
    end
  end)
  for _, p in ipairs(hit) do local s = A.store[K(p[1], p[2])] if s then A.setp(c, p[1], p[2], s[1], min(s[2], lvl or 2)) end end
end
function A.vnorm(m, x0, x1, ny)
  local n, cx, hw = {}, (x0 + x1) / 2, (x1 - x0) / 2 + 0.5
  m:each(function(x, y) local u = max(-0.97, min(0.97, (x - cx) / hw)) n[K(x, y)] = A.norm(u, ny or 0, sqrt(1 - u*u)) end)
  return n
end
function A.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  local out = app.params.out
  c:save{ aseprite = out .. name .. ".aseprite", png = out .. name .. ".png", scale = 1 }
end
return A
