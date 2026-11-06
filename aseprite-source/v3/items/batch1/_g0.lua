-- _g0.lua: private helpers for cassava / turnip / rambutan (batch1, Opus redraw). Read-only use of _h.lua.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(DIR .. "/_h.lua")
local HP, X, K = H.HP, H.X, H.K
local G = { H = H, HP = HP, X = X, K = K, P = H.P, out = app.params.out or (DIR .. "/") }
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end

function G.bez(p, t)
  local u = 1 - t
  return u^3*p[1][1] + 3*u*u*t*p[2][1] + 3*u*t*t*p[3][1] + t^3*p[4][1],
         u^3*p[1][2] + 3*u*u*t*p[2][2] + 3*u*t*t*p[3][2] + t^3*p[4][2]
end
-- tube along a cubic bezier: half width wfn(t). Returns mask, normals, T, S (S<0 = lit/upper-left side)
function G.tube(p, wfn, o)
  o = o or {}
  local N = o.steps or 200
  local sm = {}
  for i = 0, N do
    local t = i / N
    local x, y = G.bez(p, t)
    local x2, y2 = G.bez(p, min(1, t + 0.002))
    local x1, y1 = G.bez(p, max(0, t - 0.002))
    local tx, ty = x2 - x1, y2 - y1
    local l = sqrt(tx*tx + ty*ty)
    tx, ty = tx / l, ty / l
    local px, py = -ty, tx
    if px + py < 0 then px, py = -px, -py end
    sm[#sm + 1] = { x = x, y = y, t = t, px = px, py = py, w = wfn(t) }
  end
  local m, n, T, S = HP.mask(), {}, {}, {}
  local bx0, by0, bx1, by1 = 1e9, 1e9, -1e9, -1e9
  for _, s in ipairs(sm) do bx0 = min(bx0, s.x) by0 = min(by0, s.y) bx1 = max(bx1, s.x) by1 = max(by1, s.y) end
  for y = floor(by0) - 8, floor(by1) + 8 do for x = floor(bx0) - 8, floor(bx1) + 8 do
    local best, bs
    for _, s in ipairs(sm) do
      local dx, dy = x - s.x, y - s.y
      local q = dx*dx + dy*dy
      if not best or q < best then best, bs = q, s end
    end
    if bs.w > 0 and sqrt(best) <= bs.w + (o.pad or 0) then
      local sd = (x - bs.x) * bs.px + (y - bs.y) * bs.py
      local sn = max(-0.97, min(0.97, sd / (bs.w + 0.5)))
      m:set(x, y)
      local k = K(x, y)
      n[k] = { bs.px * sn, bs.py * sn, sqrt(1 - sn*sn) }
      T[k], S[k] = bs.t, sn
    end
  end end
  return m, n, T, S, sm
end
-- rotated ellipse mask: centre, axis unit (ux,uy), radius along axis ra, across rb
function G.rell(cx, cy, ux, uy, ra, rb)
  local m = HP.mask()
  local R = math.ceil(max(ra, rb)) + 1
  for y = floor(cy) - R, floor(cy) + R do for x = floor(cx) - R, floor(cx) + R do
    local dx, dy = x - cx, y - cy
    local a = dx*ux + dy*uy
    local b = -dx*uy + dy*ux
    if (a/ra)^2 + (b/rb)^2 <= 1.0 then m:set(x, y) end
  end end
  return m
end
-- paint indexed tones with bias
function G.tone(c, m, v, ramp, cuts, bias, tok)
  return X.tone(c, m, v, ramp, { cuts = cuts or { 0.22, 0.4, 0.56, 0.72, 0.86 }, bias = bias, tok = tok })
end
function G.line(c, pts, hex) c:line(pts, 1):each(function(x, y) c:px(x, y, hex) end) end
function G.fin(c, name)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  local ase = G.out .. name .. ".aseprite"
  if name:find("%.p[AB]$") then ase = "/tmp/claude-0/-home-user-gnome-venture/24dbc14e-ae34-540a-ac1a-cc6317049307/scratchpad/b1g0/" .. name .. ".aseprite" end
  c:save{ aseprite = ase, png = G.out .. name .. ".png", scale = 1 }
end
return G
