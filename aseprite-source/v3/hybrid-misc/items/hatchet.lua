-- hatchet (sonnet-medium test)
local LIB = "/home/user/gnome-venture/aseprite-source/v3/lib/"
local HP = dofile(LIB .. "hp.lua")
local X = dofile(LIB .. "hpx.lua").init(HP)
local K = X.K
local OUT = app.params.out or "./"
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CUTS = { 0.22, 0.4, 0.56, 0.72, 0.86 }
local function ell(cx, cy, rx, ry)
  local m = HP.mask()
  for y = floor(cy - ry) - 1, floor(cy + ry) + 1 do for x = floor(cx - rx) - 1, floor(cx + rx) + 1 do
    if ((x + 0.5 - cx) / rx) ^ 2 + ((y + 0.5 - cy) / ry) ^ 2 <= 1 then m:set(x, y) end end end
  return m
end
local function tn(c, m, ramp, R, o)
  o = o or {}
  local n = X.pillow(m, R)
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.25 })
  X.tone(c, m, v, ramp, { cuts = o.cuts or CUTS, bias = o.bias })
  return n, v
end
local function tnN(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.25 })
  X.tone(c, m, v, ramp, { cuts = o.cuts or CUTS, bias = o.bias })
  return v
end
local function fin(c, name)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = OUT .. name .. ".aseprite", png = OUT .. name .. ".png", scale = 1 }
end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "hatchet" }
local WD = { "#3e2a30", "#5e3e3a", "#80583e", "#a47646", "#c89a58", "#e8c070" }
local ST = { "#2f3a56", "#4a566e", "#6f7c98", "#98a4bc", "#c4cddf", "#eef2f8" }
local LE = { "#4a2430", "#7a3a3e", "#a85a4a", "#d08a5a" }
c:groundShadow(30, 58, 14, 1.5)
-- handle
local len = sqrt(24 ^ 2 + 36 ^ 2)
local hm, hn, T, S = X.cyl(14, 55, 38, 17, function(t) return 2.2 + (t < 0.12 and 0.9 or 0) + t * 0.4 end)
local bias = {}
hm:each(function(x, y) local k = K(x, y)
  if abs(S[k] - 0.2) < 0.12 and X.hash(floor(T[k] * 20), 1, 3) > 0.3 then bias[k] = -1 end
  if abs(S[k] + 0.35) < 0.1 and X.hash(floor(T[k] * 14), 2, 3) > 0.4 then bias[k] = 1 end
end)
tnN(c, hm, hn, WD, { bias = bias })
-- leather grip wrap
hm:each(function(x, y) local k = K(x, y)
  if T[k] > 0.1 and T[k] < 0.42 then
    local band = floor((T[k] * len + S[k] * 1.2) / 2.0) % 2
    local s = S[k]
    local idx = (s > 0.35) and 1 or (s < -0.35 and 4 or 3)
    if band == 0 then idx = max(1, idx - 1) end
    c:px(x, y, LE[idx])
  end
end)
-- red cloth knot (quirk)
for _, p in ipairs{ {28,34},{29,34},{28,35},{29,35},{27,36},{30,36},{27,37},{31,37},{26,38} } do c:px(p[1], p[2], "#c8404a") end
c:px(28, 34, "#f07068") c:px(29, 35, "#8a2a40") c:px(31, 37, "#8a2a40") c:px(26, 38, "#8a2a40") c:px(30, 36, "#a83448")
-- head
local head = c:poly{ {32,14},{37,10},{47,9},{54,5},{58,16},{54,29},{46,23},{38,22},{32,20} }
local n = X.pillow(head, 4)
local v = X.light(n, { amb = 0.12, wrap = 0.25 })
local hb = {}
head:each(function(x, y) local k = K(x, y)
  if x < 36 and X.hash(x, y, 4) > 0.5 then hb[k] = -1 end
  if X.hash(x * 3, y, 2) > 0.94 then hb[k] = 1 end
end)
X.tone(c, head, v, ST, { cuts = CUTS, bias = hb })
-- ground cutting edge bevel
local strip = head:copy():cut(head:shift(-2, 0))
strip:each(function(x, y) if x > 50 then c:px(x, y, ST[6]) end end)
local strip2 = head:copy():cut(head:shift(-1, 0))
strip2:each(function(x, y) if x > 50 then c:px(x, y, ST[5]) end end)
-- bevel line, eye region shade, poll
for i = 0, 8 do c:px(38 + i, 16 + floor(i * 0.5), ST[2]) end
for y = 12, 19 do c:px(33, y, ST[2]) end
c:px(34, 12, ST[5]) c:px(35, 11, ST[5]) c:px(36, 11, ST[6])
c:px(44, 12, ST[6]) c:px(45, 12, ST[6]) c:px(46, 13, ST[5])
-- nick in edge
c:px(56, 20, ST[1]) c:px(55, 21, ST[1]) c:px(56, 21, ST[2])
-- AO under head on handle
for _, p in ipairs{ {36,23},{37,23},{38,23},{35,22} } do c:px(p[1], p[2], WD[1]) end
-- pommel knob
c:px(12, 56, WD[2]) c:px(13, 57, WD[1])
fin(c, "hatchet")
