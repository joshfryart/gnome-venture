-- stage-vegetable-4 (lean P1b_O13)
local NAME = "stage-vegetable-4"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt, atan2 = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local function T(nm) return { r = { name = nm } } end
local function ball(m, R, ramp, nm, o) local n = X.pillow(m, R) o = o or {} o.tok = T(nm) if not o.cuts then o.cuts = {0.2,0.38,0.55,0.72,0.86} end G.toneN(c, m, n, ramp, o) return n end
local SOIL = { "#1e1218", "#3a2420", "#5e3a2a", "#86583a", "#ae7e4a" }
local LF = { "#12362e", "#1f5e3c", "#34864a", "#58ac4e", "#8ccc62", "#c2ec8c" }
local CAB = { "#1d4a50", "#2f6f64", "#4e9a76", "#7ac48a", "#aae2a2", "#e0f8c4" }
c:groundShadow(32, 57, 24, 3)
local soil = c:ellipse(32, 52, 22, 6) soil:add(c:ellipse(32, 50, 15, 5))
ball(soil, 8, SOIL, "soil", { amb = 0.1, wrap = 0.2 })
soil:each(function(x, y) local h = X.hash(x, y, 5) if h > 0.9 then c:put(x, y, SOIL[5], T("soil")) elseif h < 0.07 then c:put(x, y, SOIL[1], T("soil")) end end)
local function leaf(ax, ay, cx, cy, bx, by, w, nm)
  local m, n, Tt, S, L = G.blade(ax, ay, cx, cy, bx, by, function(t) if t > 0.985 then return -1 end return max(0.8, w * sin(pi * min(1, t * 1.04)) ^ 0.6) end, { fold = 0.4 })
  local tok = T(nm)
  G.toneN(c, m, n, LF, { tok = tok, cuts = {0.18,0.34,0.5,0.66,0.82}, amb = 0.1, wrap = 0.2 })
  m:each(function(x, y) local k = K(x, y)
    local s, t = S[k], Tt[k]
    if abs(s) < 0.13 and t > 0.08 and t < 0.92 then c:put(x, y, s <= 0 and LF[6] or LF[2], tok) end
    if t > 0.3 and t < 0.9 then for _, vt in ipairs{ 0.4, 0.55, 0.7 } do
      local d = (t - vt) * L - abs(s) * 3
      if d > -0.5 and d < 0.5 and abs(s) > 0.28 and abs(s) < 0.85 then c:put(x, y, s < 0 and LF[5] or LF[2], tok) end end end
  end)
  return m
end
-- back wrapper leaves
leaf(30, 50, 8, 48, 7, 26, 5.4, "bl")
leaf(34, 50, 56, 48, 57, 26, 5.4, "br")
-- head
local hd, hn = G.oval(32, 33, 15, 15, 0, 1)
local hdm = hd
G.toneN(c, hd, hn, CAB, { tok = T("head"), cuts = {0.2,0.38,0.55,0.72,0.88}, amb = 0.08, wrap = 0.25 })
local function seam(p, hex, dx)
  for i = 0, 40 do local x, y = G.bez(p, i / 40) local px, py = floor(x + 0.5) + (dx or 0), floor(y + 0.5)
    if hd:has(px, py) then c:put(px, py, hex, T("head")) end end
end
local sl = { {32,48}, {21,42}, {20,28}, {28,19} }
local sr = { {33,48}, {45,41}, {45,28}, {38,19} }
local sm = { {32,47}, {28,38}, {29,28}, {33,20} }
for _, s in ipairs{ sl, sr, sm } do seam(s, CAB[2]) seam(s, CAB[5], 1) end
seam(sl, CAB[1], -1) seam(sr, CAB[1], 1)
-- wrapper crinkle bumps
hd:each(function(x, y) if X.hash(x, y, 8) > 0.93 and (x + y) % 2 == 0 then c:put(x, y, CAB[2], T("head")) end end)
-- waxy bloom + spec
c:px(24, 25, CAB[6]) c:px(25, 25, CAB[6]) c:px(24, 26, CAB[5]) c:px(26, 24, CAB[5]) c:px(23, 27, CAB[5])
-- front wrapper leaves
leaf(31, 52, 14, 54, 8, 38, 5.0, "fl")
leaf(33, 52, 50, 54, 56, 38, 5.0, "fr")
-- quirk: caterpillar crossing the top
local B, BD = "#b0e640", "#5a9a20"
for _, p in ipairs{ {33,16},{34,16},{33,17},{34,17} } do c:put(p[1], p[2], B, T("cat")) end
for _, p in ipairs{ {36,14},{37,14},{36,15},{37,15},{39,15},{40,15},{39,16},{40,16} } do c:put(p[1], p[2], B, T("cat")) end
for _, p in ipairs{ {34,17},{37,15},{40,16} } do c:put(p[1], p[2], BD, T("cat")) end
for _, p in ipairs{ {42,16},{43,16},{42,17},{43,17} } do c:put(p[1], p[2], "#f0a030", T("cat")) end
c:put(43, 16, "#2b1c26", T("cat")) c:put(36, 14, "#e8ff90", T("cat"))
G.save(c, NAME)
