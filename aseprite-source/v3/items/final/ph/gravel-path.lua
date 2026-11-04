-- gravel-path (dC10 first draft): an S-curve of pebble path between grass edges, pebbles in grey, tan and rust.
-- quirk: one tiny yellow flower pokes up between the stones.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC10.lua")
local B, H, HP, X, K = D.B, D.H, D.HP, D.X, D.K
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local c = D.new('gravel-path')
local pts = { {18,50}, {10,36}, {42,36}, {40,10} }
local m = H.sweep(pts, function(t) return 10 - 7 * t end, 80)
c:fillMask(m, '#6a5a50')
local ramps = { 'stone', 'wood', 'stone' }
local SAND = { '#6a5a50', '#9a8670', '#c4aa86', '#dcc49c', '#efdcb8', '#fff0d0' }
local R = { H.ramp('stone'), H.ramp('wood'), SAND }
for gy = 4, 60, 4 do for gx = 4, 62, 4 do
  local cx = gx + floor(X.hash(gx, gy, 3) * 3) - 1 + ((gy // 4) % 2) * 2
  local cy = gy + floor(X.hash(gx, gy, 5) * 3) - 1
  if m:has(cx, cy) and m:has(cx - 2, cy) and m:has(cx + 2, cy) then
    local p = B.ell(cx, cy, 2.8, 2.1, 0):clip(m)
    B.lit(c, p, R[1 + floor(X.hash(gx, gy, 9) * 3)], 1.6)
  end
end end
-- grass edging
m:edge():each(function(x, y) if X.hash(x, y, 2) > 0.5 then c:px(x, y, '#3f9150') end end)
for _, p in ipairs{ {12,48},{8,40} } do
  B.ln(c, p[1], p[2], p[1]-1, p[2]-3, '#7cc35a') B.ln(c, p[1]+1, p[2], p[1]+2, p[2]-3, '#c4e07a')
end
-- quirk flower
local fx0, fx1 = 99, 0
for x = 0, 63 do if m:has(x, 42) then fx0 = min(fx0, x) fx1 = max(fx1, x) end end
local fx = (fx0 + fx1) // 2
c:px(fx, 41, '#3f9150') c:px(fx, 40, '#3f9150')
for _, d in ipairs{ {-1,0},{1,0},{0,-1},{0,1} } do c:px(fx + d[1], 38 + d[2], '#fff4d6') end
c:px(fx, 38, '#f5b82e')
D.fin()
