-- stage-vegetable-2 (lean P1b_O13)
local NAME = "stage-vegetable-2"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt, atan2 = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local function T(nm) return { r = { name = nm } } end
local function ball(m, R, ramp, nm, o) local n = X.pillow(m, R) o = o or {} o.tok = T(nm) if not o.cuts then o.cuts = {0.2,0.38,0.55,0.72,0.86} end G.toneN(c, m, n, ramp, o) return n end
local SOIL = { "#1e1218", "#3a2420", "#5e3a2a", "#86583a", "#ae7e4a" }
local LF = { "#12362e", "#1f5e3c", "#34864a", "#58ac4e", "#8ccc62", "#c2ec8c" }
c:groundShadow(32, 56, 24, 3)
local soil = c:ellipse(32, 50, 22, 7) soil:add(c:ellipse(32, 47, 15, 6))
ball(soil, 9, SOIL, "soil", { amb = 0.1, wrap = 0.2 })
soil:each(function(x, y) local h = X.hash(x, y, 5) if h > 0.9 then c:put(x, y, SOIL[5], T("soil")) elseif h < 0.07 then c:put(x, y, SOIL[1], T("soil")) end end)
for _, p in ipairs{ {16,52},{17,52},{48,52},{49,52},{47,53} } do c:put(p[1], p[2], "#b8a898", T("pb")) end
for _, p in ipairs{ {18,53},{50,53} } do c:put(p[1], p[2], "#6a5a60", T("pb")) end
local function leaf(ax, ay, cx, cy, bx, by, w, nm)
  local m, n, Tt, S, L = G.blade(ax, ay, cx, cy, bx, by, function(t) if t > 0.985 then return -1 end return max(0.6, w * sin(pi * min(1, t * 1.04)) ^ 0.7) end, { fold = 0.4 })
  local tok = T(nm)
  G.toneN(c, m, n, LF, { tok = tok, cuts = {0.18,0.34,0.5,0.66,0.82}, amb = 0.1, wrap = 0.2 })
  m:each(function(x, y) local k = K(x, y)
    local s, t = S[k], Tt[k]
    if abs(s) < 0.13 and t > 0.08 and t < 0.92 then c:put(x, y, s <= 0 and LF[6] or LF[2], tok) end
    if t > 0.25 and t < 0.9 then for _, vt in ipairs{ 0.35, 0.5, 0.65, 0.8 } do
      local d = (t - vt) * L - abs(s) * 3
      if d > -0.5 and d < 0.5 and abs(s) > 0.28 and abs(s) < 0.85 then c:put(x, y, s < 0 and LF[5] or LF[2], tok) end end end
    if abs(s) > 0.9 and X.hash(x, y, 3) > 0.6 then c:put(x, y, LF[1], tok) end
  end)
end
leaf(31, 46, 16, 40, 8, 30, 4.6, "l1")
leaf(33, 46, 48, 40, 57, 30, 4.6, "l2")
leaf(31, 46, 20, 30, 18, 12, 5.2, "l3")
leaf(33, 46, 46, 28, 48, 12, 5.2, "l4")
leaf(32, 46, 29, 28, 32, 6, 5.8, "l5")
-- rosy stalk
local st = c:rect(30, 42, 34, 48)
ball(st, 3, { "#6a2040", "#a43a62", "#d46486", "#f8a2b8" }, "stalk", { cuts = {0.3,0.6,0.85} })
c:put(31, 43, "#ffd8e0", T("stalk"))
-- quirk: ladybug on right leaf
local R, D = "#e83a24", "#7a1018"
for _, p in ipairs{ {45,32},{46,32},{47,32},{44,33},{45,33},{46,33},{47,33},{45,34},{46,34} } do c:put(p[1], p[2], R, T("bug")) end
for _, p in ipairs{ {46,34},{47,33} } do c:put(p[1], p[2], D, T("bug")) end
c:put(46, 32, D, T("bug")) c:put(44, 33, "#2b1c26", T("bug")) c:put(45, 32, "#ff9a80", T("bug"))
-- dew
c:put(20, 21, "#f0fdff", T("dew")) c:put(21, 21, "#a8dcea", T("dew")) c:put(20, 22, "#6aa8c8", T("dew"))
G.save(c, NAME)
