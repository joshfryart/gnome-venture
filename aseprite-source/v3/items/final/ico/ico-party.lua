-- ico-party (final, Opus). A slim party popper (paper cone) on the diagonal, tip lower-left, firing three curling
-- ribbon streamers and a spray of confetti up and to the right.
-- Material: cone = rolled card with spiral stripes (cylinder light, 6 tones per stripe colour), a gold foil rim with
-- a bright bevel and a dark mouth; streamers = ribbons with twist (pinched, darker where they turn edge-on);
-- confetti = flat chips each with a lit edge; one glossy bead.
-- quirk: a tiny red gnome hat got fired out with the confetti.
local A = dofile("/home/user/gnome-venture/aseprite-source/v3/items/final/_helpers/_aA7_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, sqrt, abs, sin, cos, pi = math.floor, math.max, math.min, math.sqrt, math.abs, math.sin, math.cos, math.pi
local c = A.new("ico-party")
local DU = { "#251c4a", "#35295f", "#5a459e", "#7a60c6", "#a088e2", "#cbb8f6" }
local GO = { "#7a3e1c", "#b5651f", "#d98322", "#f5b82e", "#ffd65e", "#fff0a8" }
local PE = { "#5e2048", "#9a3466", "#c94f84", "#f5809f", "#ffaac4", "#ffd6e4" }
local SE = { "#24406e", "#2f6a9e", "#3a96b8", "#5fc4c8", "#96e0d8", "#cdf6ec" }
local MO = { "#1e4a40", "#2f7a4a", "#4f9e50", "#7cc35a", "#a8da70", "#d4f09a" }
local PA = { "#5e4a6e", "#8a789c", "#b8a8c4", "#ddd0dc", "#f2e8e6", "#fff8ee" }
local EM = { "#5e1c34", "#8f2638", "#b52e3f", "#e8493b", "#ff7a52", "#ffb08a" }

-- streamers first (the cone paints over their roots)
local function ribbon(p, ramp, hw, turns, name)
  local tk = A.tok(name)
  local m, n, T, S, samp = A.tube(p, function(t) return hw end)
  -- twist: width pinches where the ribbon turns edge-on
  local cut = HP.mask()
  m:each(function(x, y) local k = K(x, y)
    local tw = abs(cos(T[k] * turns * pi))
    local w = 0.35 + 0.65 * tw
    if abs(S[k]) > w + 0.05 and T[k] > 0.04 then cut:set(x, y) end
  end)
  m:cut(cut)
  local v = X.light(n, { amb = 0.1, wrap = 0.3 })
  local bias = {}
  m:each(function(x, y) local k = K(x, y)
    local tw = abs(cos(T[k] * turns * pi))
    -- the back face shows on alternate half-turns: one tone darker
    if floor(T[k] * turns + 0.5) % 2 == 1 then bias[k] = -1 end
    if tw < 0.35 then bias[k] = (bias[k] or 0) - 1 end
  end)
  local idx = X.tone(c, m, v, ramp, { cuts = { 0.12, 0.28, 0.46, 0.64, 0.84 }, bias = bias, tok = tk })
  return m, idx, tk
end
local s1 = ribbon({ { 31, 33 }, { 29, 20 }, { 38, 13 }, { 44, 19 } }, PE, 1.6, 3, "rib1")
local s2 = ribbon({ { 33, 35 }, { 41, 27 }, { 52, 31 }, { 56, 21 } }, SE, 1.6, 3.5, "rib2")
local s3 = ribbon({ { 34, 38 }, { 44, 42 }, { 49, 49 }, { 57, 44 } }, MO, 1.5, 3, "rib3")
-- curl end on the pink streamer
do local tk = A.tok("curl")
  for _, q in ipairs{ { 45, 21 }, { 45, 22 }, { 44, 23 }, { 43, 23 }, { 42, 22 } } do c:put(q[1], q[2], PE[3], tk) end
  c:put(46, 21, PE[2], tk) c:put(46, 22, PE[2], tk) end

-- confetti chips: {cx, cy, kind, ramp}
local function chip(cx, cy, kind, ramp, rot)
  local tk = A.tok("chip")
  local m
  if kind == "sq" then m = c:rect(cx - 1, cy - 1, cx + 1, cy + 1)
  elseif kind == "dia" then m = c:poly{ { cx + .5, cy - 2 }, { cx + 3, cy + .5 }, { cx + .5, cy + 3 }, { cx - 2, cy + .5 } }
  elseif kind == "dot" then m = c:ellipse(cx, cy, 1.5, 1.5)
  elseif kind == "bar" then m = rot and c:rect(cx - 1, cy - 2, cx + 1, cy + 2) or c:rect(cx - 2, cy - 1, cx + 2, cy + 1) end
  local x0, y0, x1, y1 = m:bbox()
  m:each(function(x, y)
    local i = 4
    if x == x0 or y == y0 then i = 5 end
    if x == x1 or y == y1 then i = 3 end
    c:put(x, y, ramp[i], tk)
  end)
  if kind == "dot" then c:put(cx - 1, cy - 1, ramp[6], tk) end
  return m
end
chip(22, 26, "sq", GO)
chip(14, 14, "dia", SE)
chip(37, 6, "dot", EM)
chip(52, 12, "bar", GO, true)
chip(56, 34, "sq", PE)
chip(23, 35, "dot", MO)
chip(45, 30, "dia", DU)
chip(40, 50, "bar", SE)
chip(29, 9, "sq", MO)
c:sparkle(50, 6)

-- the cone (rolled card with spiral stripes)
local p = { { 11, 54 }, { 16, 49 }, { 22, 43 }, { 28, 37 } }
local ctk = A.tok("cone")
local cm, cn, CT, CS, samp = A.tube(p, function(t) return 1.2 + 6.2 * t end)
local cv = X.light(cn, { amb = 0.06, wrap = 0.22 })
local LEN = sqrt(17 ^ 2 + 17 ^ 2)
local cidx = {}
cm:each(function(x, y) local k = K(x, y)
  local v = cv[k]
  local i = 1 for j, t in ipairs{ 0.14, 0.3, 0.48, 0.66, 0.86 } do if v >= t then i = j + 1 end end
  if CT[k] > 0.9 then i = max(1, i - 1) end -- the lip shades the throat
  local band = floor((CT[k] * LEN + CS[k] * 3.2) / 4) % 2
  local r = band == 0 and DU or PA
  c:put(x, y, r[i], ctk) cidx[k] = { i, band }
end)
-- spiral seam: a dark edge where each cream band meets the next violet band
cm:each(function(x, y) local k = K(x, y)
  local d = (CT[k] * LEN + CS[k] * 3.2) / 4
  if d - floor(d) < 0.14 and cidx[k][2] == 0 then c:put(x, y, DU[max(1, cidx[k][1] - 1)], ctk) end
end)
-- specular streak along the lit side of the card
for _, t in ipairs{ 0.42, 0.5, 0.58 } do
  local s = samp[floor(t * 160) + 1]
  local x, y = floor(s.x + s.px * s.w * -0.55 + .5), floor(s.y + s.py * s.w * -0.55 + .5)
  if cm:has(x, y) then local i = cidx[K(x, y)] c:put(x, y, (i[2] == 0 and DU or PA)[6], ctk) end
end
-- foil rim and dark mouth at the open end
local ex, ey = 28, 37
local ux, uy = 1 / sqrt(2), -1 / sqrt(2)
local rim = A.rell(ex + ux * 0.8, ey + uy * 0.8, ux, uy, 2.8, 8.4)
local mouth = A.rell(ex + ux * 1.4, ey + uy * 1.4, ux, uy, 1.6, 6.0)
local rtk = A.tok("rim")
rim:each(function(x, y)
  local s = (x - ex) + (y - ey) -- <0 upper-left
  c:put(x, y, s < -5 and GO[6] or s < -1 and GO[5] or s < 4 and GO[4] or GO[3], rtk)
end)
mouth:each(function(x, y) local s = (x - ex) + (y - ey)
  local q = (x - ex) - (y - ey) c:put(x, y, (q < -1 and "#3a1630") or (s > 2 and EM[3]) or "#6e2038", rtk) end)
-- confetti still leaving the mouth
c:put(30, 34, GO[5], rtk) c:put(31, 34, GO[5], rtk) c:put(30, 35, GO[3], rtk) c:put(31, 35, GO[3], rtk)
-- tiny tip cap
local tip = A.tok("tip")
c:put(11, 54, GO[3], tip) c:put(10, 55, GO[2], tip) c:put(11, 55, GO[2], tip) c:put(10, 54, GO[4], tip)

-- quirk: a tiny red gnome hat sailing out with the confetti
local hx, hy = 18, 18
A.map(c, {
  "...ab..",
  "..aBb..",
  "..aBBb.",
  ".aBBBb.",
  ".aBBBdb",
  "ccccccd",
  "ceeeeed",
}, hx - 3, hy - 3, { a = EM[5], b = EM[3], B = EM[4], d = EM[2], c = "#fff4d6", e = "#e2d0b0" }, A.tok("hat"))
A.save(c, "ico-party")
