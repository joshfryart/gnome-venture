-- yuzu (lean P1b_O19)
local NAME = "yuzu"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan2 = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local function tone(m, n, ramp, o) return G.toneN(c, m, n, ramp, o) end
local function ball(cx, cy, rx, ry, ang, ramp, o) local m, n = G.oval(cx, cy, rx, ry, ang, o and o.flat) tone(m, n, ramp, o) return m, n end
local function leaf(ax, ay, cx, cy, bx, by, w, ramp, vein)
  local m, n, T, S = G.blade(ax, ay, cx, cy, bx, by, function(t) return w * sin(pi * min(1, t)) ^ 0.7 + 0.3 end)
  tone(m, n, ramp)
  if vein then m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.17 and T[k] > 0.08 and T[k] < 0.92 then c:put(x, y, vein) end end) end
  return m
end
local function tube(p, w, ramp) local m, n = G.tube(p, function(t) return type(w) == "function" and w(t) or w end) tone(m, n, ramp) return m end
local function cylrect(x0, y0, x1, y1, ramp)
  local m, n = HP.mask(), {}
  local hw, cx = (x1 - x0 + 1) / 2, (x0 + x1) / 2
  for y = y0, y1 do for x = x0, x1 do m:set(x, y) local nx = max(-0.95, min(0.95, (x - cx) / (hw + 0.3))) n[K(x, y)] = { G.norm(nx, 0, sqrt(1 - nx * nx)) } end end
  tone(m, n, ramp) return m
end

-- yuzu: round bumpy golden rind pitted with pores, a green patch, short stem, a single winged-petiole leaf
local RIND = { "#6b4a0c", "#a47a12", "#d1a31e", "#eecb2e", "#fbe35a", "#fff39a" }
local LF = { "#10382c", "#1c5a36", "#2f7e3e", "#4fa44a", "#7cc65c", "#b0e084" }
local GRN = { "#2e5a22", "#4a7c26", "#6a9c30", "#9ac040" }
local cx, cy, rx, ry = 31, 39, 17, 15
local m = HP.mask()
for y = cy - 20, cy + 20 do for x = cx - 22, cx + 22 do
  local dx, dy = (x - cx) / rx, (y - cy) / ry
  local d = sqrt(dx * dx + dy * dy)
  local a = atan2(dy, dx)
  local bump = 0.05 * sin(a * 9 + 0.5) + 0.035 * sin(a * 15 + 2) + 0.02 * sin(a * 23)
  if d <= 1 + bump then m:set(x, y) end
end end
-- leaf behind stem
local lf = leaf(36, 20, 43, 8, 57, 11, 5.6, LF, LF[6])
local wg, wn = G.oval(39, 17, 2.4, 1.6, -0.6, 1)
tone(wg, wn, LF)
tube({ {33, 24}, {33, 20}, {35, 18}, {36, 19} }, 1.1, { "#3a2a14", "#5a4220", "#7a5c30", "#9a7c48", "#b89c60", "#d4ba80" })
local n = X.pillow(m, 14)
local v = X.light(n, { amb = 0.1, wrap = 0.2 })
local bias = {}
tone(m, n, RIND, { bias = bias })
-- green patch (quirk)
m:each(function(x, y) if v[K(x, y)] > 0.35 and ((x - 44) ^ 2 + (y - 31) ^ 2) < 16 and X.hash(x, y, 2) > 0.2 then
  c:put(x, y, GRN[(v[K(x, y)] > 0.6) and 4 or 3]) end end)
-- pores: dark dimple + pale lit lip up-left
local taken = {}
m:copy():shrink(2):each(function(x, y)
  if X.hash(x, y, 3) > 0.86 and not taken[K(x - 1, y)] and not taken[K(x, y - 1)] and not taken[K(x - 1, y - 1)] and not taken[K(x + 1, y - 1)] then
    taken[K(x, y)] = true
    c:px(x, y, RIND[2]) c:px(x + 1, y + 1, RIND[1])
    if v[K(x, y)] > 0.4 then c:px(x - 1, y - 1, RIND[6]) end
  end
end)
-- calyx + glint
local cal = G.oval(33, 23, 3.4, 1.6, 0, 1)
tone(cal, select(2, G.oval(33, 23, 3.4, 1.6, 0, 1)), GRN.dummy or { "#1e3a18", "#2e5a22", "#4a7c26", "#6a9c30", "#9ac040", "#c8e070" })
c:px(22, 32) c:px(22, 31, "#fffbd0") c:px(23, 31, "#fffbd0") c:px(23, 30, "#fffbd0") c:px(22, 32, "#fffbd0")
-- thorn
c:px(26, 25, "#4a7c26") c:px(25, 24, "#9ac040")

G.save(c, NAME)
