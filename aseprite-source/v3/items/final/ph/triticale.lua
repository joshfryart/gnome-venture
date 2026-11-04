-- triticale (lean W2_37)
-- Slim wheat-rye ear: staggered plump grains on a curved rachis, a fan of long awns, jointed stem, two blue-green flag leaves.
-- quirk: a dewdrop hangs from one awn tip.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "triticale" }
local sin, cos, pi, sqrt, max, min = math.sin, math.cos, math.pi, math.sqrt, math.max, math.min
local GR  = { "#5a2a1c", "#8a4a22", "#b8741f", "#d9a03a", "#efc65c", "#fbe69a" }
local ST  = { "#4d5a2c", "#6f7f3a", "#98a54c", "#c2c96c", "#e0e590", "#f4f4b8" }
local LF  = { "#173e48", "#1f5a52", "#2f7a58", "#4b9a60", "#76b66c", "#a6d084" }
local AW  = "#e6c070"
local AW2 = "#b88a3c"
local tok = { r = { name = "p" } }
local function shade(m, ramp, R, o)
  local n = X.pillow(m, R)
  local v = X.light(n, { amb = 0.1, wrap = 0.25 })
  G.tone(c, m, v, ramp, nil, o, tok)
  return n, v
end
c:groundShadow(32, 57, 9, 2)
-- leaves
local function leaf(p, w)
  local m, n, T, S = G.tube(p, function(t) return w * sin(pi * min(1, t * 1.02)) ^ 0.7 + 0.3 end)
  local v = X.light(n, { amb = 0.12, wrap = 0.25 })
  G.tone(c, m, v, LF, nil, nil, tok)
  m:each(function(x, y) local k = K(x, y)
    if math.abs(S[k]) < 0.22 and T[k] > 0.12 and T[k] < 0.9 then c:put(x, y, S[k] <= 0 and LF[5] or LF[3], tok) end end)
  return m
end
leaf({ {32, 47}, {22, 42}, {14, 42}, {8, 50} }, 2.6)
leaf({ {32, 50}, {40, 46}, {48, 47}, {55, 53} }, 2.2)
-- stem + node
local sm, sn = G.tube({ {31, 58}, {31, 52}, {33, 42}, {33, 33} }, function(t) return 1.6 end)
shade(sm, ST, 1.8)
for x = 29, 34 do if sm:has(x, 48) then c:px(x, 48, ST[2]) end if sm:has(x, 47) then c:px(x, 47, ST[1]) end end
-- ear: grains along curved rachis
local P = { {33, 34}, {32, 26}, {34, 18}, {35, 11} }
local rach = G.tube(P, function(t) return 0.9 end)
c:fillMask(rach, ST[2])
local N = 7
for i = 0, N do
  local t = i / N
  local x, y = G.bez(P, t)
  local x2, y2 = G.bez(P, min(1, t + 0.03))
  local ux, uy = x2 - x, y2 - y
  local l = sqrt(ux * ux + uy * uy) ux, uy = ux / l, uy / l
  local sz = 1 - 0.3 * t
  for _, s in ipairs{ -1, 1 } do
    local off = (i % 2 == 0) and 0 or 1.6
    local cx, cy = x + s * 2.9 * sz, y + (s > 0 and off or 1.6 - off) - 1
    local gx, gy = ux + s * 0.35, uy
    local gl = sqrt(gx * gx + gy * gy)
    local m = G.rell(cx, cy, gx / gl, gy / gl, 3.6 * sz, 2.2 * sz)
    shade(m, GR, 2.2)
    c:px(math.floor(cx), math.floor(cy), GR[3])
    -- crease
    c:px(math.floor(cx + s * 0.4), math.floor(cy + 1), GR[2])
    if i % 2 == 0 and s < 0 or i % 2 == 1 and s > 0 then c:px(math.floor(cx - 1), math.floor(cy - 1), GR[6]) end
  end
end
-- awns: thin straws fanning from the ear tip and flanks
local awns = {
  { 35, 10, 30, 1 }, { 36, 9, 36, 0 }, { 36, 10, 43, 2 }, { 34, 12, 25, 4 },
  { 38, 15, 47, 9 }, { 29, 18, 20, 9 }, { 37, 22, 49, 17 },
}
for _, a in ipairs(awns) do
  G.line(c, { {a[1], a[2]}, { (a[1] + a[3]) / 2 + 0.5, (a[2] + a[4]) / 2 }, {a[3], a[4]} }, AW)
end
c:px(30, 1, AW2) c:px(26, 4, AW2)
-- quirk: dewdrop
c:px(36, 1, "#dff4ff") c:px(36, 2, "#7fb4e0") c:px(35, 2, "#bfe4ff")
G.fin(c, "triticale")
