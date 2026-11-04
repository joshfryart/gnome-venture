-- wood-chips (lean D3o_14)
-- loose heap of seven tilted pale chips (pine cream and orange-red cedar) with grain lines, one curled shaving on top. Quirk: a tiny knot-hole in one chip.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CUTS = { 0.22, 0.4, 0.56, 0.72, 0.86 }
local function T(c, m, ramp, R, bias) G.tone(c, m, X.light(X.pillow(m, R or 4), { amb = 0.1, wrap = 0.25 }), ramp, CUTS, bias) end
local function ell(c, cx, cy, rx, ry, a)
  local p = {}
  for i = 0, 15 do local t = i / 16 * 2 * pi
    local x, y = rx * cos(t), ry * sin(t)
    p[#p + 1] = { cx + x * cos(a) - y * sin(a), cy + x * sin(a) + y * cos(a) } end
  return c:poly(p)
end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "wood-chips" }
local PINE = { "#8a5a3a", "#b07a48", "#d09e60", "#e8c280", "#f6dc9e", "#fff0c4" }
local CED = { "#6a2e2c", "#8e4430", "#b4623a", "#d28450", "#e8a468", "#f8c88c" }
c:groundShadow(32, 53, 22, 4)
local chips = {
  { 22,48, 9,4.5, 0.15, PINE }, { 42,48, 9,4.5, -0.2, CED }, { 32,50, 8,4, 0.05, PINE },
  { 17,40, 8,4, -0.5, CED }, { 46,40, 8,4, 0.55, PINE }, { 30,41, 9,4.5, 0.25, CED },
  { 38,33, 8,4, -0.35, PINE },
}
for i, ch in ipairs(chips) do
  local m = ell(c, ch[1], ch[2], ch[3], ch[4], ch[5])
  local bias = {}
  m:each(function(x, y)
    local u = (x - ch[1]) * cos(-ch[5]) - (y - ch[2]) * sin(-ch[5])
    local v = (x - ch[1]) * sin(-ch[5]) + (y - ch[2]) * cos(-ch[5])
    if abs(v) < 3.3 and floor(v + 8) % 2 == 0 and abs(u) < ch[3] - 2 and X.hash(x, y, i) > 0.25 then bias[K(x, y)] = -1 end
  end)
  G.tone(c, m, X.light(X.pillow(m, 4), { amb = 0.1, wrap = 0.3 }), ch[6], CUTS, bias)
  -- shaded torn end
  c:px(floor(ch[1] + ch[3] * cos(ch[5]) * 0.8), floor(ch[2] + ch[3] * sin(ch[5]) * 0.8), ch[6][1])
end
-- knot hole
c:px(28, 41, CED[1]) c:px(29, 41, CED[1]) c:px(28, 40, CED[2])
-- curled shaving on top
local sh = c:line({ {24,31},{29,26},{36,24},{42,26},{43,30},{39,31},{37,28} }, 3)
G.tone(c, sh, X.light(X.pillow(sh, 2), { amb = 0.15, wrap = 0.3 }), PINE, CUTS)
G.line(c, { {26,30},{30,26},{36,24} }, PINE[6])
c:px(37, 28, PINE[1]) c:px(38, 29, PINE[2])
c:sparkle(20, 35)
G.fin(c, "wood-chips")
