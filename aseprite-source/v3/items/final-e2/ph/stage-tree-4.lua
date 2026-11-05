-- stage-tree-4 (lean E2_13)
local NAME = "stage-tree-4"
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
local BARK = { "#2a1814", "#4a2c22", "#6d4430", "#8e5f3d", "#ae7c4e", "#cf9d6a" }
local FOL = { "#143a30", "#1d5a38", "#2b7a3e", "#43984a", "#68b552", "#9bd066" }
local ORG = { "#8a2a10", "#b8481a", "#e06a1e", "#f78f2a", "#ffb445", "#ffe08a" }
soil(32, 51, 20, 6)
tb({ { 29, 53 }, { 25, 54 } }, 1.0, BARK, "root1")
tb({ { 35, 53 }, { 39, 54 } }, 1.0, BARK, "root2")
tb({ { 32, 52 }, { 31, 44 }, { 33, 36 }, { 32, 29 } }, function(t) return 2.3 - 0.8 * t end, BARK, "trunk")
tb({ { 32, 36 }, { 27, 33 }, { 23, 28 } }, 0.9, BARK, "brL")
tb({ { 33, 35 }, { 38, 32 }, { 42, 27 } }, 0.9, BARK, "brR")
local can = HP.mask()
for _, e in ipairs{ { 32, 17, 11, 8 }, { 21, 23, 9, 7 }, { 43, 23, 9, 7 }, { 32, 26, 14, 6 }, { 24, 15, 6, 5 }, { 40, 15, 6, 5 } } do
  can:add((G.oval(e[1], e[2], e[3], e[4], 0, 1)))
end
local n = X.pillow(can, 13)
local idx = tn(can, n, FOL, "canopy", { amb = .08, wrap = .2 })
can:each(function(x, y) local k = K(x, y) local h = X.hash(x, y, 11) local i = idx[k]
  if i and h > 0.86 and i >= 2 then c:put(x, y, FOL[i - 1], { r = { name = "canopy" } })
  elseif i and h < 0.1 and i >= 2 and i < 6 then c:put(x, y, FOL[i + 1], { r = { name = "canopy" } }) end end)
-- scalloped leaf clumps along the bottom: dark undershade
can:shrink(1):each(function(x, y) if y > 27 and not can:has(x, y + 1) then c:put(x, y, FOL[1], { r = { name = "canopy" } }) end end)
-- blossoms
for _, p in ipairs{ { 27, 12 }, { 39, 10 }, { 46, 20 }, { 20, 20 } } do c:put(p[1], p[2], "#fff4f0", { r = { name = "blos" } }) c:put(p[1] + 1, p[2], "#ffc8d0", { r = { name = "blos" } }) end
-- oranges
for i, p in ipairs{ { 23, 19 }, { 33, 13 }, { 42, 21 }, { 30, 24 }, { 38, 28 } } do
  local m, nn = G.oval(p[1], p[2], 3.2, 3.2, 0, 1)
  tn(m, nn, ORG, "or" .. i, { amb = .06, wrap = .2 })
  local bx, by = G.specAt(m, nn, 30) if bx then c:put(bx, by, ORG[6], { r = { name = "or" .. i } }) end
  c:put(p[1], p[2] - 3, FOL[1], { r = { name = "or" .. i } }) c:put(p[1] + 1, p[2] - 3, FOL[5], { r = { name = "or" .. i } })
end
-- quirk: fallen orange with a bite
local fm = ov(44, 53, 3, 2.6, 0, ORG, "fall")
c:put(46, 52, "#ffe9a8", { r = { name = "fall" } }) c:put(47, 53, "#ffd070", { r = { name = "fall" } }) c:put(46, 53, "#ffe9a8", { r = { name = "fall" } })
c:put(42, 51, ORG[6], { r = { name = "fall" } })
G.save(c, NAME)
