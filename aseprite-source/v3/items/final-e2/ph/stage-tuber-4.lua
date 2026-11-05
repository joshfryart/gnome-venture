-- stage-tuber-4 (lean E2_13)
local NAME = "stage-tuber-4"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CUTS = { .22, .4, .56, .72, .86 }
local SOIL = { "#2e1d1a", "#4a2e25", "#6a4430", "#8a5e3e", "#a97a50", "#c79a68" }
local PL   = { "#12302e", "#1c4a3a", "#2a6a42", "#3d8a4a", "#5fa856", "#8cc668" }
local PST  = { "#3a2a3a", "#5a3a4a", "#7a5a52", "#5f8a48", "#86ae5a", "#b0cf7a" }
local SPUD = { "#4a2c26", "#6e4234", "#946048", "#b98462", "#d6a67c", "#efc9a0" }
local PURP = { "#3a2250", "#5a3a82", "#7d5cab", "#9f84cc", "#c3ade6", "#e8dcf7" }
local function tn(m, n, ramp, tag, o)
  o = o or {}
  return G.toneN(c, m, n, ramp, { tok = { r = { name = tag } }, cuts = CUTS, amb = o.amb or .1, wrap = o.wrap or .22, bias = o.bias })
end
local function ov(cx, cy, rx, ry, ang, ramp, tag, rib)
  local m, n = G.oval(cx, cy, rx, ry, ang, 1.0)
  tn(m, n, ramp, tag)
  if rib then
    local ca, sa = cos(ang), sin(ang)
    for i = -rx + 1, rx - 1, 0.5 do
      local x, y = floor(cx + ca * i + .5), floor(cy + sa * i + .5)
      if m:has(x, y) then c:put(x, y, ramp[5], { r = { name = tag .. "rib" } }) end
    end
  end
  return m
end
local function bl(ax, ay, cx, cy, bx, by, w, ramp, tag, o)
  o = o or {}
  local m, n, T, S, len = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    local u = min(1, t * 0.92 + 0.08)
    return max(0.5, w * sin(pi * u ^ 1.1) ^ 0.7)
  end, { fold = o.fold or 0.45 })
  tn(m, n, ramp, tag, { amb = .12, wrap = .22 })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if abs(s) < 0.12 and t > 0.03 and t < 0.9 then c:put(x, y, s <= 0 and ramp[6] or ramp[2], { r = { name = tag } }) return end
    if o.veins then for _, vt in ipairs(o.veins) do
      local d = t * len - (vt + abs(s) * 4)
      if d > -0.5 and d < 0.5 and abs(s) > 0.2 and abs(s) < 0.75 then c:put(x, y, s < 0 and ramp[5] or ramp[2], { r = { name = tag } }) return end
    end end
  end)
  if o.serr then m:edge():each(function(x, y) local k = K(x, y)
    if T[k] > 0.25 and T[k] < 0.95 and X.hash(x, y, 7) > 0.55 and (x + y) % 3 == 0 then c.pix[y * c.w + x] = nil c.own[y * c.w + x] = nil end end) end
  return m, n, T, S
end
local function tb(pts, w, ramp, tag)
  local m, n, T = G.tube(pts, function(t) return type(w) == "function" and w(t) or w end)
  tn(m, n, ramp, tag, { amb = .15, wrap = .3 })
  return m
end
local function soil(cx, cy, rx, ry)
  c:groundShadow(cx, cy + ry - 1, rx + 1, 3)
  local m, n = G.oval(cx, cy, rx, ry, 0, 0.7)
  local idx = tn(m, n, SOIL, "soil")
  m:each(function(x, y) local k = K(x, y) local h = X.hash(x, y, 5)
    if h > 0.9 and idx[k] and idx[k] >= 2 then c:put(x, y, SOIL[max(1, idx[k] - 2)], { r = { name = "soil" } })
    elseif h < 0.05 and idx[k] and idx[k] >= 3 then c:put(x, y, SOIL[min(6, idx[k] + 2)], { r = { name = "soil" } }) end end)
  return m
end
local function compound(bx, by, ang, len, np, ramp, tag, ls)
  ls = ls or 3
  local ex, ey = bx + cos(ang) * len, by + sin(ang) * len
  c:line({ { bx, by }, { ex, ey } }, 1):each(function(x, y) c:put(x, y, ramp[3], { r = { name = tag .. "r" } }) end)
  ov(ex + cos(ang) * ls * .5, ey + sin(ang) * ls * .5, ls * 1.15, ls * .72, ang, ramp, tag .. "t", true)
  for i = np, 1, -1 do
    local t = i / (np + .5)
    local px, py = bx + (ex - bx) * t, by + (ey - by) * t
    local s = ls * (1.1 - 0.4 * t)
    for _, sg in ipairs{ -1, 1 } do
      local a = ang + sg * 1.05
      ov(px + cos(a) * s * .85, py + sin(a) * s * .85, s, s * .64, a, ramp, tag .. i .. sg, true)
    end
  end
end
local function eyes(m, pts, tag)
  for _, p in ipairs(pts) do if m:has(p[1], p[2]) then c:put(p[1], p[2], SPUD[1], { r = { name = tag } }) if m:has(p[1] - 1, p[2] - 1) then c:put(p[1] - 1, p[2] - 1, SPUD[5], { r = { name = tag } }) end end end
end
soil(32, 51, 21, 6)
tb({ { 29, 50 }, { 29, 40 }, { 30, 30 }, { 29, 20 } }, 1.3, PST, "stalk")
compound(29, 44, -2.9, 12, 2, PL, "a1", 3.0)
compound(29, 42, -0.2, 12, 2, PL, "a2", 3.0)
compound(29, 34, -2.4, 10, 2, PL, "b1", 2.8)
compound(29, 33, -0.8, 10, 2, PL, "b2", 2.8)
-- star flowers
local function flower(cx, cy, r, tag)
  for k = 0, 4 do
    local a = -pi / 2 + k * 2 * pi / 5
    ov(cx + cos(a) * r * 1.05, cy + sin(a) * r * 1.05, r * 1.0, r * .72, a, PURP, tag .. k)
  end
  ov(cx, cy, r * .55, r * .55, 0, { "#a06a10", "#c8901a", "#e8b028", "#f8cc3c", "#ffe070", "#fff4a8" }, tag .. "c")
end
c:line({ { 29, 22 }, { 36, 14 } }, 1):each(function(x, y) c:put(x, y, PL[3], { r = { name = "fs1" } }) end)
c:line({ { 29, 22 }, { 22, 14 } }, 1):each(function(x, y) c:put(x, y, PL[3], { r = { name = "fs2" } }) end)
flower(29, 14, 3.3, "f1")
flower(37, 11, 2.7, "f2")
flower(21, 12, 2.7, "f3")
-- unearthed big potatoes in front
local p1 = ov(45, 47, 8, 5.6, -0.2, SPUD, "spud1")
eyes(p1, { { 42, 45 }, { 47, 49 }, { 49, 45 }, { 41, 49 } }, "spud1")
local p2 = ov(40, 53, 4, 2.8, 0.2, SPUD, "spud2")
eyes(p2, { { 39, 53 } }, "spud2")
-- quirk: a bee visiting the flower
ov(44, 15, 2.2, 1.5, 0, { "#2b1c26", "#6a4a10", "#c89018", "#f2c030", "#ffe070", "#fff0a0" }, "bee")
c:put(44, 15, "#2b1c26", { r = { name = "bee" } }) c:put(43, 12, "#dff4ff", { r = { name = "bee" } }) c:put(45, 12, "#dff4ff", { r = { name = "bee" } })
G.save(c, NAME)
