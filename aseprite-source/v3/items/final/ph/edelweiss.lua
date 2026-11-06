-- edelweiss (final, Opus single pass). An alpine star: seven slim woolly bracts with green-grey tips around a
-- cluster of tiny gold florets, on a thin felted stem with two narrow upturned leaves.
-- Material: per-pixel folded-blade light (6-tone cool wool white), felt flecks, dark midrib groove, AO where
-- the bracts gather under the florets; florets as little lit domes with dark gaps; leaves 6-tone with a pale midrib.
-- quirk: a single snowflake has landed on the lower leaf.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB25_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, sqrt, abs, sin, cos, pi = math.floor, math.max, math.min, math.sqrt, math.abs, math.sin, math.cos, math.pi
local NAME = "edelweiss"
local c = A.new(NAME)
local WO = { "#5b6176", "#858ca2", "#adb3c4", "#cdd2dc", "#e6e8ec", "#f7f4ea" }
local TIP = { "#3a5048", "#5a7464", "#7d9682", "#a3b8a0", "#c4d2bc", "#dde6d2" }
local LF = { "#1f3a33", "#2f5446", "#4b7460", "#6c9476", "#93b592", "#bfd4b4" }
local GO = { "#5a3d1e", "#8f6428", "#c0922e", "#dcba48", "#f0dc80", "#fff2b8" }
local wtok = { r = { name = "wool" } }
local ltok = { r = { name = "leaf" } }
local ftok = { r = { name = "floret" } }
local CX, CY = 32, 24

-- stem (thin, felted), drawn first
do
  local m, n = A.tube({ { CX, CY + 4 }, { 33, 38 }, { 30, 48 }, { 31, 58 } }, function(t) return 1.3 end, 80)
  A.shade(c, m, n, LF, { tok = ltok })
end
-- two narrow leaves rising off the stem
local function leaf(ax, ay, cx, cy, bx, by)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t) return 1.9 * sin(pi * min(1, t * 1.05)) ^ 0.7 end, { fold = 0.5 })
  local bias = {}
  m:each(function(x, y) local k = K(x, y) if T[k] < 0.12 then bias[k] = -1 end end)
  local idx = A.shade(c, m, n, LF, { tok = ltok, bias = bias })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.18 and T[k] > 0.12 and T[k] < 0.85 then c:put(x, y, LF[5], ltok) end end)
  return m
end
leaf(31, 47, 22, 46, 18, 38)
local lm = leaf(31, 41, 40, 40, 44, 32)

-- bracts: seven slim lanceolate wool blades, back ones first
local bracts = {}
local angs = { -90, -38, 14, 64, 116, 166, 218 }
for i, ad in ipairs(angs) do
  local a = math.rad(ad + 4)
  local L = (i == 4 or i == 5) and 12 or 14
  local ux, uy = cos(a), sin(a)
  bracts[#bracts + 1] = { ux, uy, L, i }
end
table.sort(bracts, function(p, q) return p[2] < q[2] end) -- upper ones behind
local allB = HP.mask()
for _, b in ipairs(bracts) do
  local ux, uy, L = b[1], b[2], b[3]
  local vx, vy = -uy, ux
  local ax, ay = CX + ux * 1.5, CY + uy * 1.5
  local qx, qy = CX + ux * L * 0.55 + vx * 0.8, CY + uy * L * 0.55 + vy * 0.8
  local bx, by = CX + ux * L, CY + uy * L
  local function wf(t)
    if t < 0.38 then return 1.2 + 1.5 * (t / 0.38) end
    return 2.7 * ((1 - t) / 0.62) ^ 0.85
  end
  local m, n, T, S = A.blade(ax, ay, qx, qy, bx, by, wf, { fold = 0.45 })
  local bias = {}
  m:each(function(x, y) local k = K(x, y) if T[k] < 0.24 then bias[k] = -1 end end)
  local wm, tm = HP.mask(), HP.mask()
  m:each(function(x, y) if T[K(x, y)] > 0.8 then tm:set(x, y) else wm:set(x, y) end end)
  local v = X.light(n, { amb = 0.08, wrap = 0.28 })
  local idx = X.tone(c, wm, v, WO, { cuts = A.CUTS, bias = bias, tok = wtok })
  local tidx = X.tone(c, tm, v, TIP, { cuts = A.CUTS, bias = bias, tok = wtok })
  -- midrib groove and felt flecks
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.14 and T[k] > 0.25 and T[k] < 0.75 then A.step(c, idx, WO, x, y, -1, wtok)
    elseif idx[k] and X.hash(x, y, 3) > 0.9 and idx[k] >= 3 then A.step(c, idx, WO, x, y, 1, wtok) end
  end)
  allB:add(m)
end
-- shadowed disc under the florets
local disc = HP.ellipse(CX, CY, 4, 4)
disc:each(function(x, y) c:put(x, y, (x + y < CX + CY) and WO[2] or WO[1], wtok) end)
-- florets: little lit domes with dark gaps
local fl = { { 0, 0 }, { -3, -1 }, { 3, -1 }, { -2, 2 }, { 2, 2 }, { 0, -3 }, { 0, 3 } }
table.sort(fl, function(p, q) return p[2] < q[2] end)
for _, f in ipairs(fl) do
  local fx, fy = CX + f[1], CY + f[2]
  local m, n = A.oval(fx, fy, 1.3, 1.3, 0, 1)
  local v = X.light(n, { amb = 0.1, wrap = 0.3 })
  X.tone(c, m, v, GO, { cuts = A.CUTS, tok = ftok })
  c:put(fx + 1, fy + 1, GO[2], ftok)
end
c:put(CX - 1, CY - 1, "#fff8dc", ftok)
-- quirk: a snowflake resting on the right leaf
local sx, sy = 39, 36
local SF = { { 0, 0, "#f4fbff" }, { -1, 0, "#cfe8f6" }, { 1, 0, "#cfe8f6" }, { 0, -1, "#cfe8f6" }, { 0, 1, "#cfe8f6" },
  { -1, -1, "#8bc4ea" }, { 1, 1, "#8bc4ea" }, { 1, -1, "#8bc4ea" }, { -1, 1, "#8bc4ea" } }
for _, s in ipairs(SF) do c:put(sx + s[1], sy + s[2], s[3]) end
A.save(c, NAME)
