-- ico-thumbs-down (Opus single pass). Front-on fist hanging from a sleeve at the top (different build from
-- thumbs-up): ember knitted cuff with vertical ribs and a rolled lip, back of the hand, four curled fingers side by
-- side with middle-knuckle creases and tucked tips, thumb pointing straight down with the nail facing us.
-- Material: 6-tone skin per part, deep seams + AO between fingers and under the cuff, contact shadow from the
-- thumb, knit rib texture, nail gloss.
-- quirk: a sticking plaster wrapped round the thumb.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_aR0_2.lua")
local HP, X, K = D.HP, D.X, D.K
local max, min = math.max, math.min
local c = D.new("ico-thumbs-down")
local S, E = D.SKIN, D.EMBER

-- back of the hand
local back = c:rrect(21, 13, 47, 36, 5)
local bb = {}
X.ao(bb, back, c:rect(0, 0, 63, 14), 2, -1)               -- under the cuff
D.lit(c, back, S, { R = 4, bias = bb })
-- knuckle bumps row (lit tops)
for _, x in ipairs{ 26, 32, 38, 43 } do c:put(x, 25, S[6]) c:put(x + 1, 25, S[5]) c:put(x + 2, 26, S[3]) end

-- fingers: vertical capsules left -> right, each overlapping the previous by 1 px
local fx = { 24, 30, 36, 42 }
local fy1 = { 44, 45, 44, 41 }
local fingers = {}
for i = 1, 4 do
  local m = c:rrect(fx[i], 28, fx[i] + 6, fy1[i], 3)
  local bias = {}
  if i > 1 then X.ao(bias, m, fingers[i - 1], 1, -1) end
  X.ao(bias, m, c:rect(0, 0, 63, 28), 1, -1)
  D.lit(c, m, S, { R = 3, bias = bias })
  fingers[i] = m
end
for i = 2, 4 do D.seam(c, fingers[i], fingers[i - 1], S[2]) end
-- middle-knuckle creases + tucked tip shadow
for i = 1, 4 do
  local y = 36
  c:put(fx[i] + 2, y, S[3]) c:put(fx[i] + 3, y, S[3]) c:put(fx[i] + 2, y + 1, S[5])
  for x = fx[i] + 2, fx[i] + 4 do c:put(x, fy1[i] - 1, S[2]) end
end
-- cool bounce on the right edge
for _, p in ipairs{ {48, 33}, {47, 37}, {47, 38} } do if fingers[4]:has(p[1], p[2]) or back:has(p[1], p[2]) then c:put(p[1], p[2], "#b0607a") end end

-- thumb pointing down
local thumb = c:rrect(15, 26, 24, 57, 4)
local tb = {}
X.ao(tb, thumb, c:rect(0, 0, 63, 25), 2, -1)
D.lit(c, thumb, S, { R = 4, bias = tb })
-- contact shadow on the first finger
fingers[1]:each(function(x, y) if x == 25 and not thumb:has(x, y) and y > 29 then c:put(x, y, S[2]) end end)
-- nail at the tip, facing the viewer
local nail = c:rrect(17, 48, 22, 55, 2)
X.tone(c, nail, X.light(X.pillow(nail, 2), { amb = 0.3, wrap = 0.4 }), { "#b8706a", "#e0a49a", "#f4c8bc", "#ffe0d4", "#ffeee4", "#fff6ea" }, { cuts = D.CUTS })
for x = 17, 22 do c:put(x, 48, "#c9877a") end
c:put(18, 50, D.CREAM) c:put(18, 51, "#fff6ea")
-- joint crease above the nail
c:put(17, 44, S[3]) c:put(18, 44, S[3]) c:put(19, 45, S[3]) c:put(18, 45, S[5])

-- quirk: sticking plaster wrapped round the thumb (1 px proud each side, pad + air holes)
local pl = c:rect(14, 33, 25, 38)
local PL = { "#8a5a3c", "#b98258", "#dcae7c", "#f0cc98", "#fbe3b6", "#fff0d0" }
local pn = {}
pl:each(function(x, y) local t = max(-0.95, min(0.95, (x - 18.5) / 6.5)) pn[K(x, y)] = { t, (y - 35.5) / 8, math.sqrt(1 - t * t) } end)
X.tone(c, pl, X.light(pn, { amb = 0.12, wrap = 0.3 }), PL, { cuts = D.CUTS })
c:fillMask(c:rect(17, 34, 21, 37), PL[5])                   -- gauze pad
c:fillMask(c:rect(17, 37, 21, 37), PL[4])
for _, p in ipairs{ {15, 35}, {23, 35}, {24, 36} } do c:put(p[1], p[2], PL[2]) end   -- air holes
for x = 14, 25 do c:put(x, 38, PL[1]) end                    -- shadow row under the strip
for x = 15, 24 do c:put(x, 39, S[2]) end                     -- contact shadow on the thumb

-- knitted cuff at the top: vertical ribs, rolled lip at the bottom
local cuff = c:rrect(20, 6, 48, 15, 2)
local idx = D.lit(c, cuff, E, { R = 3 })
cuff:each(function(x, y)
  local k = K(x, y)
  if x % 3 == 0 and y < 13 then c:put(x, y, E[max(1, (idx[k] or 3) - 2)])
  elseif x % 3 == 1 and y < 12 and (idx[k] or 3) >= 3 then c:put(x, y, E[min(6, idx[k] + 1)]) end
end)
for x = 21, 47 do c:put(x, 13, E[5]) c:put(x, 14, E[3]) c:put(x, 15, E[1]) end
c:put(21, 13, E[6]) c:put(22, 13, E[6])
D.save(c)
