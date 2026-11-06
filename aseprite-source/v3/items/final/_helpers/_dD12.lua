-- _dD12.lua: helper for chunk D12 (rat-pelt .. rock-garden). Thin layer on batch2/_b2.lua (not edited).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local B = dofile(DIR .. "/../../batch2/_b2.lua")
local H, HP, X, K = B.H, B.HP, B.X, B.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local D = { B = B, H = H, HP = HP, X = X, K = K }
D.R = {
  leaf  = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" },
  dleaf = { "#10342c", "#1c4a38", "#2a6440", "#3e8048", "#62a456", "#94c868" },
  pink  = { "#6e1f3a", "#a02a4a", "#d04060", "#ec6280", "#f6a0b0", "#ffd0d8" },
  cream = { "#8a6a58", "#b58d70", "#dcb590", "#f2d4a8", "#fbe7c4", "#fff4d6" },
  gold  = { "#6a4a22", "#a07a34", "#cfa04a", "#ecc86a", "#f8e49a", "#fff4d6" },
  soil  = { "#1e1220", "#34202a", "#4a2e30", "#66423a", "#85574a", "#a87258" },
  seedb = { "#2a1a1a", "#4a2e26", "#6e4a34", "#92683f", "#b88a52", "#dcb27a" },
  stone = { "#35364f", "#4f5170", "#74758c", "#9795a8", "#bdbacb", "#e2e0e6" },
  ink   = { "#1e1a2a", "#2e2a40", "#403c58", "#58546e", "#76728a", "#9a96ac" },
  china = { "#3a4a7a", "#6a7fb0", "#9eb4d8", "#c9d8ea", "#e6eef6", "#f6f9fc" },
  glass = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#8fe0e8", "#c6f2f4", "#f0fcff" },
  red   = { "#4a1020", "#7c1f2e", "#a82e36", "#d04a3c", "#ee7a5a", "#ffb08a" },
  orange= { "#6a2236", "#a2332e", "#d04b25", "#ee6c22", "#fb983a", "#ffc874" },
  wood  = { "#3a2220", "#51302b", "#7a4630", "#a46a40", "#cc9460", "#e8b982" },
  sand  = { "#9a7c52", "#b89a66", "#d0b078", "#e4c88c", "#f0daa0", "#fff0c8" },
}
function D.new(name) return B.new(name) end
function D.fin() B.fin() end
D.lit, D.ell, D.ln, D.poly, D.blade, D.sprout, D.seed = B.lit, B.ell, B.ln, B.polyline, B.blade, B.sprout, B.seed
function D.rng(seed)
  local s = seed or 7
  return function() s = (s * 1103515245 + 12345) % 2147483648 return s / 2147483648 end
end
function D.shadow(c, cx, cy, rx, ry) c:groundShadow(cx, cy, rx, ry) end
-- lit tapered cylinder A->B; ridges: list of S offsets drawn one tone darker (along length)
function D.stalk(c, ax, ay, bx, by, wfn, ramp, ridges)
  local r = H.ramp(ramp)
  local m, n, T, S = X.cyl(ax, ay, bx, by, wfn)
  local idx = X.tone(c, m, X.light(n, { amb = 0.1, wrap = 0.25 }), r, { cuts = { 0.26, 0.44, 0.6, 0.75, 0.88 } })
  for _, rs in ipairs(ridges or {}) do
    m:each(function(x, y) local k = K(x, y)
      if abs(S[k] - rs) < 0.09 and T[k] > 0.03 and T[k] < 0.97 then c:px(x, y, r[max(1, (idx[k] or 3) - 1)]) end end)
  end
  return m, idx, T, S
end
-- swept bezier lit
function D.sw(c, pts, wfn, ramp, R, o)
  local m, T = H.sweep(pts, wfn)
  local idx = B.lit(c, m, ramp, R or 2, o)
  return m, T, idx
end
function D.bez(p, t)
  local u = 1 - t
  return u^3*p[1][1] + 3*u*u*t*p[2][1] + 3*u*t*t*p[3][1] + t^3*p[4][1],
         u^3*p[1][2] + 3*u*u*t*p[2][2] + 3*u*t*t*p[3][2] + t^3*p[4][2]
end
-- recolour pixels of m by tone index into another ramp when pred(x,y) true
function D.recolor(c, m, idx, ramp2, pred)
  m:each(function(x, y) if pred(x, y) then c:px(x, y, ramp2[idx[K(x, y)] or 3]) end end)
end
-- scatter n pixels in mask m via f(x,y); avoid edge px
function D.scatter(m, n, seed, f, inner)
  local rnd = D.rng(seed)
  local pts = {}
  m:each(function(x, y) if not inner or inner:has(x, y) then pts[#pts+1] = {x, y} end end)
  table.sort(pts, function(a, b) if a[2] ~= b[2] then return a[2] < b[2] end return a[1] < b[1] end)
  for i = 1, n do local p = pts[floor(rnd() * #pts) + 1] if p then f(p[1], p[2], i) end end
end
-- rice-like grain: oriented spindle
function D.grain(c, cx, cy, rx, ry, ang, ramp, glint)
  local m = B.ell(cx, cy, rx, ry, ang)
  B.lit(c, m, ramp, min(rx, ry) + .5)
  if glint ~= false then c:px(floor(cx - rx * .3), floor(cy - ry * .4), "#fff4d6") end
  return m
end
-- steam / curl line (list of points)
function D.curl(c, pts, hex) B.polyline(c, pts, hex) end
function D.bubble(c, x, y, hi, lo)
  c:px(x + 1, y, hi) c:px(x, y + 1, hi) c:px(x + 2, y + 1, lo) c:px(x + 1, y + 2, lo)
end
return D
