-- _aR21_3.lua: private helpers for ph/bok-choy-seed, ph/borer-plate (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min = math.sqrt, math.floor, math.max, math.min
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ph/")
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
A.norm = norm
function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
-- light + quantise a normal field
function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok })
  return idx, v
end
-- normals of a cylinder with a vertical axis (x0..x1 span); tilt > 0 faces down, < 0 faces up
function A.vnorm(m, x0, x1, tilt)
  local n = {}
  m:each(function(x, y)
    local t = max(-0.97, min(0.97, ((x + 0.5 - x0) / (x1 + 1 - x0)) * 2 - 1))
    local ty = type(tilt) == "function" and tilt(x, y) or (tilt or 0)
    n[K(x, y)] = { norm(t, ty, sqrt(1 - t*t)) }
  end)
  return n
end
-- re-tone one pixel by d steps (uses an idx table from X.tone)
function A.step(c, idx, ramp, x, y, d, tok)
  local k = K(x, y) local i = idx[k]
  if not i then return end
  i = max(1, min(#ramp, i + d)) idx[k] = i
  c:put(x, y, ramp[i], tok)
end
function A.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end
-- 1px separation line: pixels of m 4-adjacent to pixels of `prev` (not in m) get hex
function A.sep(c, m, prev, hex, tok)
  m:each(function(x, y)
    for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do
      local a, b = x + d[1], y + d[2]
      if prev:has(a, b) and not m:has(a, b) then c:put(x, y, hex, tok) return end
    end
  end)
end
-- local frame helper: u along A->B (0..1), v across (px) with +v toward lower-right
function A.frame(ax, ay, bx, by)
  local vx, vy = bx - ax, by - ay
  local L = sqrt(vx*vx + vy*vy)
  local ux, uy = vx / L, vy / L
  local px, py = -uy, ux
  if px + py < 0 then px, py = -px, -py end
  return function(x, y) local rx, ry = x - ax, y - ay return (rx*ux + ry*uy) / L, rx*px + ry*py end, L, ux, uy, px, py
end
-- normals from a height field hfn(x,y) (sampled by central difference), z scale zs
function A.hnorm(m, hfn, zs)
  local n = {}
  m:each(function(x, y)
    local gx = (hfn(x + 0.5, y) - hfn(x - 0.5, y)) * (zs or 1)
    local gy = (hfn(x, y + 0.5) - hfn(x, y - 0.5)) * (zs or 1)
    n[K(x, y)] = { norm(-gx, -gy, 1) }
  end)
  return n
end
return A
