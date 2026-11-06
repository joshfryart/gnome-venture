-- _aD15_1.lua: private helpers for seed-drill, seed-pearl, seed-scoop, senegal-coral-tree-seed (ph). Wraps batch2/_b2g1.lua (unchanged).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
A.CREAM, A.INK = "#fff4d6", "#2b1c26"
A.R = {  -- 6-tone ramps, dark -> light
  leaf  = { "#163a35", "#1f553f", "#2b7046", "#3f8f4c", "#62ad55", "#93cb68" },
  fresh = { "#1a4238", "#255f43", "#33804b", "#4f9f52", "#78bd5c", "#a8d877" },
  tan   = { "#4a2e22", "#6e4530", "#946440", "#b8864f", "#d8ac6c", "#f0d296" },
  brown = { "#2e1c1c", "#4f2d26", "#74422f", "#9a5d3a", "#bc8250", "#dcb07a" },
  soil  = { "#2a1a1c", "#43281f", "#5f3a28", "#7c4e33", "#9a6842", "#b88a5a" },
  iron  = { "#1a1822", "#2a2832", "#3c3a4a", "#54526a", "#74758c", "#a4a6b8" },
  steel = { "#2a3048", "#3e4868", "#586890", "#7e90b4", "#a8bcd8", "#e0ecf8" },
  gold  = { "#6e3a1c", "#a45a20", "#d98322", "#f5b82e", "#ffd860", "#fff0a8" },
  red   = { "#4a0f1e", "#7e1428", "#b0182c", "#d92b2d", "#f25a3a", "#ff9a72" },
  coral = { "#6a2a3c", "#9a3e4a", "#c85a58", "#e88068", "#f6a888", "#fcd2b0" },
  pearl = { "#5a5a8e", "#8486b4", "#b4b4d4", "#dcd8e6", "#f4ecea", "#fffaf0" },
  mint  = { "#5a9a9c", "#82bcb4", "#aadccc", "#cef0e0" },
  rose  = { "#b88cae", "#d4a8c0", "#ecc8d4", "#f8e0e4" },
}
function A.ell(cx, cy, rx, ry, ang)
  local m = HP.mask() ang = ang or 0
  local ca, sa = cos(ang), sin(ang)
  local Rr = math.ceil(max(rx, ry)) + 1
  for y = floor(cy) - Rr, floor(cy) + Rr do for x = floor(cx) - Rr, floor(cx) + Rr do
    local dx, dy = x - cx + .0, y - cy + .0
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if (u / rx) ^ 2 + (v / ry) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end
function A.lit2(c, m, ramp, Rb, o) o = o or {} o.R = Rb or 3 return A.lit(c, m, ramp, o) end
function A.ln(c, x0, y0, x1, y1, hex, clip)
  local n = max(abs(x1 - x0), abs(y1 - y0))
  for i = 0, n do
    local t = n == 0 and 0 or i / n
    local x, y = floor(x0 + (x1 - x0) * t + .5), floor(y0 + (y1 - y0) * t + .5)
    if not clip or clip:has(x, y) then c:px(x, y, hex) end
  end
end
-- pixels of m 4-adjacent to front (and not in front) get hex
function A.seam(c, m, front, hex)
  m:each(function(x, y)
    if front:has(x, y) then return end
    if front:has(x+1, y) or front:has(x-1, y) or front:has(x, y+1) or front:has(x, y-1) then c:px(x, y, hex) end
  end)
end
function A.rod(c, ax, ay, bx, by, wfn, ramp, o) return A.cyl(c, ax, ay, bx, by, wfn, ramp, o) end
-- small lit leaf (ellipse) with midrib
function A.leafE(c, cx, cy, rx, ry, ang, ramp, rib)
  local m = A.ell(cx, cy, rx, ry, ang)
  A.lit2(c, m, ramp, min(rx, ry) + .4, { cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 } })
  local ca, sa = cos(ang), sin(ang)
  A.ln(c, cx - ca * (rx - .6), cy - sa * (rx - .6), cx + ca * (rx - 1.2), cy + sa * (rx - 1.2), rib or ramp[2], m)
  return m
end
return A
