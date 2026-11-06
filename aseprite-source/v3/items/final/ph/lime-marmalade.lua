-- lime-marmalade (Opus artist pass). A slim upright glass jar of translucent gold-green marmalade with dark and
-- bright shreds of lime peel suspended in it; light glows through the far (lower-right) side. Glass cues: thick pale
-- base, bright left streak, cool reflected edge, empty headspace above the meniscus. A green gingham cloth cap
-- (weave checks lit per pixel, pinked hem) is tied with twisted twine whose ends hang right. Paper label with a lime
-- slice (rind, pith, segments). Ground shadow under the jar.
-- quirk: a single glossy drip of marmalade has escaped from under the cloth and is crawling down the glass.
local NAME = "lime-marmalade"
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC20_4.lua")
local G, HP, X, K = D.G, D.HP, D.X, D.K
local floor, abs, max, min = math.floor, math.abs, math.max, math.min
local c = D.new(NAME)
local MARM  = { "#4a4410", "#6e6a12", "#94921a", "#b8b42a", "#d6d24a", "#f0ee90" }
local GLASS = { "#4e6e74", "#7ea4a6", "#acd0cc", "#d6eee4" }
local PEELD, PEELB = "#3c6418", "#a6e040"
local GA = { "#6a7c3a", "#a8b866", "#d8e2a0", "#f6f8d4" }          -- gingham cream ramp
local GB = { "#2e5a2a", "#4c8a3a", "#78b450", "#a8d870" }          -- gingham mid ramp
local GC = { "#1c3a24", "#2e5a2e", "#467c38", "#6aa048" }          -- gingham crossing ramp
local TW = { "#5e3e24", "#8e6438", "#c09460", "#e6c690" }
local PAPER = { "#a89470", "#d0bc90", "#ece0bc", "#fbf4dc" }
local gt, ct, twt = D.tok("glass"), D.tok("cloth"), D.tok("twine")

c:groundShadow(32, 57, 12, 1.4)
-- jar body
local body = c:rrect(21, 23, 42, 56, 4)
body:add(c:rect(23, 21, 40, 23))
local gn = D.vcylN(body, 21, 42)
D.tone(c, body, gn, GLASS, { amb = 0.2, wrap = 0.35, tok = gt })
-- marmalade fill
local fill = body:copy():shrink(1)
do local cut = {} fill:each(function(x, y) if y < 28 or y > 53 then cut[#cut + 1] = K(x, y) end end) for _, k in ipairs(cut) do fill.s[k] = nil end end
local fb = {}
c:ellipse(36.5, 46, 3, 5.5):each(function(x, y) if fill:has(x, y) then fb[K(x, y)] = 1 end end)   -- glow through the far side
fill:each(function(x, y) if y >= 52 then fb[K(x, y)] = (fb[K(x, y)] or 0) - 1 end end)            -- denser at the bottom
local fidx = D.tone(c, fill, D.vcylN(fill, 22, 41), MARM, { amb = 0.2, wrap = 0.4, bias = fb, tok = gt })
for x = 22, 41 do if fill:has(x, 28) then c:put(x, 28, x < 30 and MARM[6] or MARM[5], gt) end end  -- meniscus
-- peel shreds
local shreds = { { 25, 31, 1 }, { 33, 30, 0 }, { 38, 33, 1 }, { 27, 51, 0 }, { 35, 50, 1 }, { 39, 41, 0 }, { 24, 45, 1 }, { 30, 53, 0 }, { 37, 37, 0 }, { 24, 37, 0 } }
for _, s in ipairs(shreds) do
  local col = s[3] == 1 and PEELB or PEELD
  for i = 0, 2 do local x, y = s[1] + i, s[2] + (s[3] == 1 and -floor(i / 2) or floor(i / 2)) if fill:has(x, y) then c:put(x, y, col, gt) end end
end
-- thick glass base + bright rim
for x = 22, 41 do if body:has(x, 55) then c:put(x, 55, x < 28 and GLASS[4] or GLASS[3], gt) c:put(x, 54, GLASS[2], gt) end end
-- label with a lime slice
local lab = c:rect(25, 36, 36, 47)
D.tone(c, lab, D.vcylN(lab, 21, 42), PAPER, { amb = 0.3, wrap = 0.4, tok = D.tok("label") })
for x = 25, 36 do c:put(x, 48, MARM[1], gt) end                                                     -- label shadow on fill
local SL = { "#2e6a26", "#5aa63a", "#d8ee9a", "#a6d64a", "#7cbc34" }
local lt = D.tok("slice")
c:ellipse(30.5, 41.5, 4, 4):each(function(x, y)
  local dx, dy = x - 30.5, y - 41.5 local r = math.sqrt(dx * dx + dy * dy)
  local col
  if r > 3.6 then col = SL[1] elseif r > 2.8 then col = SL[3]
  else local a = math.atan(dy, dx) local seg = abs(((a / (math.pi / 3.5)) % 1) - 0.5) < 0.12
    col = (seg or r < 0.8) and SL[3] or (dx + dy < 0 and SL[4] or SL[5]) end
  c:put(x, y, col, lt)
end)
c:put(36, 37, PAPER[1], lt) c:put(35, 36, PAPER[1], lt)                                            -- dog-eared corner
-- glass streaks
for y = 29, 51 do if y < 35 or y > 48 then c:put(22, y, D.CREAM, gt) end end
for y = 30, 33 do c:put(23, y, GLASS[4], gt) end
for y = 33, 51 do c:put(41, y, "#c4ead8", gt) end
-- cloth cap
local cap = c:poly{ { 23, 15 }, { 26, 12 }, { 37, 12 }, { 40, 15 }, { 41, 20 }, { 44, 25 }, { 19, 25 }, { 22, 20 } }
do local cut = {} cap:each(function(x, y) if y == 25 and x % 2 == 0 then cut[#cut + 1] = K(x, y) end end) for _, k in ipairs(cut) do cap.s[k] = nil end end
local cn = X.pillow(cap, 3)
local cv = X.light(cn, { amb = 0.15, wrap = 0.3 })
cap:each(function(x, y) local k = K(x, y)
  local v = cv[k] or 0
  if y >= 22 then v = v - 0.12 end                      -- skirt hangs in shade under the twine
  if y == 22 then v = v - 0.2 end                       -- AO just under the tie
  local i = v > 0.78 and 4 or (v > 0.55 and 3 or (v > 0.3 and 2 or 1))
  local hx, hy = (x // 2) % 2 == 0, (y // 2) % 2 == 0
  local R = (hx and hy) and GC or ((hx or hy) and GB or GA)
  c:put(x, y, R[i], ct)
end)
-- fold lines on the skirt
for _, p in ipairs{ { 24, 23 }, { 24, 24 }, { 31, 23 }, { 31, 24 }, { 38, 23 }, { 39, 24 } } do c:put(p[1], p[2], GC[1], ct) end
-- twine with twist
for x = 21, 42 do c:put(x, 21, (x % 3 == 0) and TW[1] or ((x % 3 == 1) and TW[3] or TW[2]), twt) end
for x = 22, 41 do c:put(x, 20, (x % 3 == 2) and TW[4] or GC[1], x % 3 == 2 and twt or ct) end
-- twine ends hanging right
local e1 = { { 43, 21 }, { 44, 23 }, { 45, 25 }, { 45, 27 }, { 46, 29 } }
local e2 = { { 43, 22 }, { 43, 24 }, { 42, 26 }, { 42, 28 } }
for i, p in ipairs(e1) do c:put(p[1], p[2], TW[(i % 2) + 2], twt) end
D.line(c, { { 43, 21 }, { 44, 23 } }, TW[2], twt) D.line(c, { { 44, 23 }, { 45, 25 } }, TW[3], twt) D.line(c, { { 45, 26 }, { 46, 29 } }, TW[2], twt)
D.line(c, { { 43, 22 }, { 43, 24 } }, TW[1], twt) D.line(c, { { 42, 25 }, { 42, 28 } }, TW[2], twt)
c:put(46, 30, TW[4], twt) c:put(42, 29, TW[3], twt)                                                -- frayed tips
c:put(42, 21, TW[1], twt) c:put(43, 20, TW[2], twt)                                                -- knot
-- quirk: marmalade drip down the glass from under the hem
local dt = D.tok("drip")
for y = 26, 31 do c:put(26, y, y < 29 and MARM[5] or MARM[4], dt) c:put(27, y, MARM[3], dt) end
c:put(26, 32, MARM[4], dt) c:put(27, 32, MARM[3], dt) c:put(25, 32, MARM[5], dt) c:put(28, 32, MARM[2], dt)
c:put(26, 33, MARM[3], dt) c:put(27, 33, MARM[2], dt)
c:put(26, 27, D.CREAM, dt)                                                                          -- glint
D.save(c, NAME)
