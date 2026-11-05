-- garden-gate-cross (lean P1b_O2)
local NAME = "garden-gate-cross"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local drawn = HP.mask()
-- lit(mask, normals, ramp, opts): tone with normals; opts.seam = colour for the border where it overlaps earlier art
local function lit(m, n, ramp, o)
  o = o or {}
  local prior = drawn:copy()
  local _, v = G.toneN(c, m, n, ramp, o)
  if o.seam then m:edge():each(function(x, y) if prior:has(x, y) then c:px(x, y, o.seam) end end) end
  drawn:add(m)
  return v
end
local function pil(m, ramp, R, o) return lit(m, X.pillow(m, R), ramp, o) end
local function hx(x, y, s) return X.hash(x, y, s or 1) end
-- two crossed pointed garden-gate planks lashed with twine; quirk: a ladybird hitchhiker on the lower-left plank
local W = { "#2e1d12", "#4d3220", "#6f4a2b", "#946438", "#bd8a50", "#e0b476" }
local ROPE = { "#4a3416", "#6e5226", "#977a3a", "#c0a352", "#e0c878", "#f4e6a0" }
local function plank(a, b, seed, seam)
  local dx, dy = b[1] - a[1], b[2] - a[2]
  local pts = { a, { a[1] + dx / 3, a[2] + dy / 3 }, { a[1] + dx * 2 / 3, a[2] + dy * 2 / 3 }, b }
  local m, n, T, S = G.tube(pts, function(t) return t > 0.86 and max(0.3, 4.8 * (1 - t) / 0.14) or 4.8 end)
  local fl = {}
  for k, v in pairs(n) do fl[k] = { v[1] * 0.55, v[2] * 0.55, v[3] } end   -- flatter, board-like
  lit(m, fl, W, { seam = seam, amb = 0.1 })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    for _, sv in ipairs{ -0.55, -0.05, 0.45 } do
      if abs(s - sv) < 0.09 and hx(x, y, seed) > 0.2 then c:px(x, y, s < 0 and W[3] or W[2]) end
    end
    if s < -0.7 then c:px(x, y, W[6]) end
    if t > 0.84 and t < 0.9 and abs(s) < 3 then c:px(x, y, W[2]) end
    if abs(t - 0.3) < 0.025 and abs(s + 0.2) < 0.12 then c:px(x, y, W[1]) end  -- knot
  end)
  return m
end
plank({ 13, 54 }, { 50, 9 }, 3, nil)
plank({ 51, 54 }, { 14, 9 }, 7, W[1])
-- lashing
local band = G.oval(32, 32, 9, 7.5, 0, 0.9)
local bm, bn = band
lit(bm, select(2, G.oval(32, 32, 9, 7.5, 0, 0.9)), ROPE, { seam = ROPE[1] })
bm:each(function(x, y) if (x + y) % 3 == 0 then c:px(x, y, ROPE[2]) elseif (x + y) % 3 == 1 and hx(x, y, 2) > 0.55 then c:px(x, y, ROPE[6]) end end)
c:fillMask(c:line({ { 24, 36 }, { 32, 40 } }, 1), ROPE[1])
-- hanging tail
local tm, tn = G.tube({ { 38, 36 }, { 41, 42 }, { 37, 47 }, { 41, 53 } }, function(t) return 1.4 - 0.6 * t end)
lit(tm, tn, ROPE, { seam = ROPE[1] })
c:px(41, 54, ROPE[4]) c:px(42, 54, ROPE[5]) c:px(40, 54, ROPE[3])
-- ladybird
for _, p in ipairs{ {18, 47}, {19, 47}, {20, 47}, {18, 48}, {19, 48}, {20, 48}, {19, 49}, {20, 49} } do c:px(p[1], p[2], "#d8302e") end
c:px(19, 47, "#2a1a1e") c:px(19, 48, "#2a1a1e") c:px(20, 48, "#ff7a5a") c:px(17, 48, "#2a1a1e") c:px(18, 49, "#2a1a1e")
G.save(c, NAME)
