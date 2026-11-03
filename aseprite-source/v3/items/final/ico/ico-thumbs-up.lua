-- ico-thumbs-up (Opus single pass). Side-on fist, arm entering from the left: knitted moss cuff (horizontal rib
-- rows, rolled edge), back of the hand, four curled fingers stacked as round capsules on the right, thumb standing
-- tall with a glossy nail and a joint crease.
-- Material: 6-tone skin per part (pillow light), deep separation rows + AO between fingers and under the thumb,
-- cool bounce on the shade side, knit ribs with a lit lip.
-- quirk: a tiny gold ring on the little finger.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_aR0_2.lua")
local HP, X, K = D.HP, D.X, D.K
local c = D.new("ico-thumbs-up")
local S, M = D.SKIN, D.MOSS

-- back of the hand (palm block)
local back = c:rrect(17, 29, 38, 56, 5)
local bb = {}
local idxB = D.lit(c, back, S, { R = 4 })
-- fingers: 4 capsules, each painted over the last (top first so lower ones overlap upward? no: top last)
local fingers = {}
local fy = { 30, 37, 43, 49 }
local fx1 = { 50, 51, 50, 47 }
for i = 4, 1, -1 do
  local m = c:rrect(29, fy[i], fx1[i], fy[i] + 6, 3)
  fingers[i] = m
end
for i = 4, 1, -1 do
  local m = fingers[i]
  local bias = {}
  -- AO from the finger above (lower part shadows)
  if i > 1 then X.ao(bias, m, fingers[i - 1], 1, -1) end
  X.ao(bias, m, c:rect(0, 0, 29, 63), 1, -1)               -- where finger roots into the hand
  D.lit(c, m, S, { R = 3, bias = bias })
end
-- separation rows between fingers
for i = 2, 4 do D.seam(c, fingers[i], fingers[i - 1], S[2]) end
-- knuckle creases on the fingertips (curl): short dark tick near the right end
for i = 1, 4 do c:put(fx1[i] - 4, fy[i] + 3, S[3]) c:put(fx1[i] - 4, fy[i] + 4, S[2]) end
-- finger roots: dark notch line between back and fingers
for y = 31, 54 do if back:has(29, y) then c:put(29, y, S[3]) end end

-- thumb
local thumb = c:rrect(22, 8, 31, 36, 5)
local tb = {}
X.ao(tb, thumb, c:rect(0, 37, 63, 63), 2, -1)
D.lit(c, thumb, S, { R = 4, bias = tb })
-- contact shadow the thumb casts on the top finger and the back
local cast = thumb:copy():shift(2, 1)
cast:each(function(x, y) if not thumb:has(x, y) and (fingers[1]:has(x, y) or back:has(x, y)) and y > 28 then c:put(x, y, S[2]) end end)
-- thumb joint crease
for _, p in ipairs{ {26, 24}, {27, 24}, {28, 23}, {29, 23} } do c:put(p[1], p[2], S[3]) end
c:put(27, 25, S[5])
-- nail (faces front-right on the tip)
local nail = c:rrect(26, 10, 30, 17, 2)
X.tone(c, nail, X.light(X.pillow(nail, 2), { amb = 0.3, wrap = 0.4 }), { "#b8706a", "#e0a49a", "#f4c8bc", "#ffe0d4", "#ffeee4", "#fff6ea" }, { cuts = D.CUTS })
for x = 26, 30 do c:put(x, 17, "#c9877a") end               -- nail bed edge
c:put(27, 11, D.CREAM) c:put(27, 12, "#fff6ea")               -- gloss

-- cool bounce on lower-right skin edges
for _, p in ipairs{ {46, 54}, {47, 53}, {50, 47}, {51, 41} } do c:put(p[1], p[2], "#b0607a") end

-- knitted cuff (arm from the left): horizontal ribs, rolled lip on the right
local cuff = c:rrect(7, 27, 18, 57, 2)
local cb = {}
X.ao(cb, cuff, back, 1, -1)
local idx = D.lit(c, cuff, M, { R = 3, bias = cb })
cuff:each(function(x, y)
  local k = K(x, y)
  if y % 3 == 0 and x < 17 then c:put(x, y, M[math.max(1, (idx[k] or 3) - 2)])
  elseif y % 3 == 1 and x < 16 and (idx[k] or 3) >= 3 then c:put(x, y, M[math.min(6, idx[k] + 1)]) end
end)
-- rolled lip: a lighter 2 px band at the cuff opening
for y = 28, 56 do c:put(16, y, M[5]) c:put(17, y, M[3]) c:put(18, y, M[2]) end
c:put(16, 28, M[6]) c:put(16, 29, M[6])
-- loose yarn twist at the bottom of the cuff
c:put(10, 58, M[4]) c:put(11, 59, M[2])

-- quirk: tiny gold ring on the little finger
for y = 49, 55 do c:put(39, y, D.GOLD[4]) c:put(40, y, D.GOLD[2]) end
c:put(39, 50, D.GOLD[6]) c:put(39, 49, D.GOLD[5]) c:put(40, 55, D.GOLD[1])
D.save(c)
