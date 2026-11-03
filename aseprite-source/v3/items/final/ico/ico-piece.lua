-- ico-piece (Opus single pass, aA8_1). One jigsaw piece, tilted, with real thickness: knobs top and right, sockets
-- left and bottom. The top carries a scrap of the picture (sky, sun, a rolling green hill), the cut side shows the
-- grey board core between two print layers.
-- Material: pillow-lit 6-tone print with a soft rounded bevel at every cut edge, cardboard side in 5 tones with a
-- fibre line, dark ambient row where the top meets the side, glossy varnish streak on the sky.
-- quirk: the print is peeling at the lower-left corner, curling up to show the raw board beneath.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA8_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sqrt, max, min, sin, cos = math.floor, math.abs, math.sqrt, math.max, math.min, math.sin, math.cos
local c = A.new("ico-piece")

local SKY  = { "#2a4f86", "#3a72b4", "#4f95d2", "#73b6e6", "#a2d4f2", "#d4eefa" }
local HILL = { "#1f4a3c", "#2d6a44", "#3f8c4a", "#5daa52", "#86c463", "#b6de82" }
local BOARD = { "#3d3240", "#5f5160", "#857684", "#a99aa4", "#cdbfc3" }
local SUN = { "#d98322", "#f5b82e", "#ffe38a" }
local CX, CY, ANG = 31, 31, -0.18
local ca, sa = cos(ANG), sin(ANG)
local HB = 13.5                                   -- half body
local function inside(u, v)
  local body = abs(u) <= HB and abs(v) <= HB
  -- knobs: circle + neck into the body; sockets: the same bitten out
  local knobT = (u ^ 2 + (v + HB + 3.8) ^ 2 <= 5.0 ^ 2) or (abs(u) <= 2.8 and v < -HB + 1 and v > -HB - 2.5)
  local knobR = ((u - HB - 3.8) ^ 2 + v ^ 2 <= 5.0 ^ 2) or (abs(v) <= 2.8 and u > HB - 1 and u < HB + 2.5)
  local holeL = ((u + HB - 3.4) ^ 2 + v ^ 2 <= 3.9 ^ 2) or (abs(v) <= 2.2 and u < -HB + 2)
  local holeB = (u ^ 2 + (v - HB + 3.4) ^ 2 <= 3.9 ^ 2) or (abs(u) <= 2.2 and v > HB - 2)
  return (body or knobT or knobR) and not holeL and not holeB
end
local function uv(x, y) local dx, dy = x - CX, y - CY return dx * ca + dy * sa, -dx * sa + dy * ca end
local top = A.fmask(0, 0, 63, 63, function(x, y) local u, v = uv(x, y) return inside(u, v) end)
local DX, DY = 1, 3                                -- thickness toward the viewer (down-right)
local side = HP.mask()
for i = 1, DY do top:shift(i >= 2 and DX or 0, i):each(function(x, y) side:set(x, y) end) end
side:cut(top)

-- side: board core with print skins top and bottom
local btok = { r = { name = "board" } }
side:each(function(x, y)
  local t = 3
  if top:has(x, y - 1) then t = 4 end                          -- lit upper skin, just under the edge
  if not side:has(x, y + 1) then t = 2 end                     -- lower skin
  if top:has(x - 1, y) and not top:has(x, y - 1) then t = 2 end -- faces turned right sit in shade
  c:put(x, y, BOARD[t], btok)
end)
-- fibre line through the core
side:each(function(x, y) if side:has(x, y - 1) and side:has(x, y + 1) and X.hash(x, y, 9) > 0.6 then c:put(x, y, BOARD[2], btok) end end)

-- top: pillow bevel, regions of the picture
local n = X.pillow(top, 2.6)
local v = X.light(n, { amb = 0.1, wrap = 0.28 })
for k, val in pairs(v) do local x, y = k % 1024 - 256, k // 1024 - 256 v[k] = val - 0.007 * ((x - CX) + (y - CY)) end
local sky, hill, sun = HP.mask(), HP.mask(), HP.mask()
top:each(function(x, y)
  local u, vv = uv(x, y)
  local hy = 1.0 + 3.0 * sin(u * 0.17 + 0.4) - 0.1 * u
  if vv > hy then hill:set(x, y) else sky:set(x, y) end
end)
local skyTok, hillTok = { r = { name = "sky" } }, { r = { name = "hill" } }
local bias = {}
-- AO along the hill line under the sky (hill top lit, sky just above slightly darker = haze)
A.paintV(sky, v, SKY, { 0.28, 0.46, 0.64, 0.8, 0.93 }, bias, skyTok)
local hb = {}
-- grass texture: short darker tufts in rows
hill:each(function(x, y) if X.hash(x, y, 3) > 0.82 then hb[K(x, y)] = -1 end end)
X.ao(hb, hill, sky, 1, 1)                  -- sunlit crest
local hidx = A.paintV(hill, v, HILL, { 0.2, 0.36, 0.52, 0.68, 0.86 }, hb, hillTok)
-- a second, farther hill line (darker band) for depth
hill:each(function(x, y) local u, vv = uv(x, y)
  local hy2 = 6.5 + 2.2 * sin(u * 0.22 - 1.4)
  if abs(vv - hy2) < 0.55 and inside(u, vv + 1.5) then c:put(x, y, HILL[2], hillTok) end end)
-- sun: disc upper-left on the sky, with a pale core
do local su, sv = -3.5, -5.5
  local sx, sy = CX + su * ca - sv * sa, CY + su * sa + sv * ca
  local m = c:ellipse(floor(sx + .5), floor(sy + .5), 3, 3):clip(sky)
  local sn = X.sphere(sx - 0.5, sy - 0.5, 3.5, m)
  A.litN(m, sn, { SUN[1], SUN[2], SUN[2], SUN[3], SUN[3], SUN[3] }, { tok = { r = { name = "sun" } } })
end
-- a small cloud on the right knob
do
  local cl = c:ellipse(34, 21, 3, 1.5):add(c:ellipse(37, 20, 2, 2)):add(c:ellipse(39, 21.5, 2, 1)):clip(sky):clip(top:shrink(2))
  cl:each(function(x, y) c:put(x, y, (cl:has(x, y + 1) and y < 22) and SKY[6] or SKY[5], skyTok) end)
end
-- varnish streak across the sky (glossy print)
for _, q in ipairs{ { 20, 22 }, { 21, 21 }, { 22, 20 }, { 23, 19 } } do if sky:has(q[1], q[2]) then c:put(q[1], q[2], SKY[6], skyTok) end end
c:put(22, 21, "#f2fbff", skyTok)
-- dark ambient row where the top meets the side
top:each(function(x, y) if side:has(x, y + 1) and (hill:has(x, y)) then c:put(x, y, HILL[2], hillTok) end
  if side:has(x, y + 1) and sky:has(x, y) then c:put(x, y, SKY[2], skyTok) end end)

-- quirk: print peeling at the lower-left corner: a curled flap (back side = pale board) over raw grey board
do
  -- corner of body at u=-HB, v=+HB
  local cu, cv = -HB + 1.5, HB - 1.5
  local function P(u, v) return floor(CX + u * ca - v * sa + .5), floor(CY + u * sa + v * ca + .5) end
  -- raw board under the peeled print
  for du = 0, 4 do for dv = 0, 4 do if du + dv <= 4 then
    local x, y = P(cu + du, cv - dv) if top:has(x, y) then c:put(x, y, BOARD[4], btok) end end end end
  local x, y = P(cu, cv) c:put(x, y, BOARD[3], btok)
  -- curl: flap standing up off the corner, its back pale
  local fx, fy = P(cu + 3.2, cv - 3.2)
  A.bmp({ "..ab", ".abc", "abcd", "bcd." }, fx - 2, fy - 2, { a = "#fbf2ea", b = "#e6d8d0", c = BOARD[4], d = BOARD[2] })
end
A.done()
