-- hatchet (aC11_2 final, Opus single pass). Intact twin of v3/items/broken-hatchet: slim 3-4 px bellied hickory
-- handle on the diagonal with a flared butt, short bearded steel head at the top.
-- Wood: cylinder light in 6 tones, wavy grain, a small knot, pale end grain + dark wedge in the eye.
-- Steel: polished "horizon" cheek (sky-lit top, ground-dark bottom) with a specular streak, ground bevel + dark ridge,
-- bright cutting edge with one sparkle, cool bounce on the underside, raised eye boss, AO where wood enters steel.
-- Grip: oxblood leather wrap with diagonal twist ridges and dark band ends.
-- quirk: a curl of fresh wood shaving is still caught on the cutting edge.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC11_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sin, pi = math.floor, math.max, math.min, math.abs, math.sin, math.pi
local c = A.new("hatchet")

local WOOD  = { "#4a2a22", "#6a3c2a", "#8b5233", "#ad6d3e", "#c98a50", "#e0aa6e" }
local LEATH = { "#2e1a26", "#4a2232", "#6b2e3a", "#8c3e40", "#ad5a4c", "#cf7e62" }
local STEEL = { "#3c3e57", "#555973", "#72778f", "#9296ab", "#b7bacb", "#dddfe8" }
local SHAV  = { "#c98a50", "#e8c08a", "#f7deb0" }
local SPEC, BOUNCE = "#f5f6fa", "#89a3c8"
local wtok, stok, ltok, qtok = A.tok("wood"), A.tok("steel"), A.tok("leather"), A.tok("shaving")

-- handle: A (top, in the eye) -> B (butt)
local AX, AY, BX, BY = 43, 8, 22, 55
local hm, hn, hT, hS = X.cyl(AX, AY, BX, BY, function(t)
  local w = 1.4 + 0.45 * sin(pi * min(1, t * 1.05))
  if t > 0.93 then w = w + 0.8 end
  if t > 0.985 then w = w - 0.7 end
  return w
end)
local LEN = math.sqrt((BX - AX)^2 + (BY - AY)^2)
local hv = X.light(hn, { amb = 0.12, wrap = 0.3 })
local function grain(k)
  local s, t = hS[k], hT[k]
  for gi, g in ipairs{ -0.42, 0.3 } do
    local gg = g + 0.16 * sin(t * 26 + gi * 2)
    if abs(s - gg) < 0.17 and ((t * 40 + gi * 5) % 9) > 2 then return -1 end
  end
  return 0
end
hm:each(function(x, y)
  local k = K(x, y)
  local t = hT[k]
  local i = floor(hv[k] * 5.99) + 1 + grain(k)
  if t < 0.33 and t > 0.26 then i = i - 1 end                          -- AO just under the boss
  c:put(x, y, WOOD[max(1, min(6, i))], wtok)
end)
-- knot: small dark oval with a lit lip, on the lit side mid-handle
do local t = 0.47 local cx, cy = AX + (BX - AX) * t - 0.6, AY + (BY - AY) * t
  c:put(floor(cx), floor(cy), WOOD[1], wtok) c:put(floor(cx), floor(cy) + 1, WOOD[2], wtok)
  c:put(floor(cx) + 1, floor(cy) - 1, WOOD[6], wtok) end
-- butt end grain: pale cap row at the very bottom
hm:each(function(x, y) local k = K(x, y) if hT[k] > 0.975 and not hm:has(x, y + 1) then c:put(x, y, hS[k] < 0.2 and WOOD[6] or WOOD[4], wtok) end end)

-- leather grip t 0.66..0.9: twist ridges
hm:each(function(x, y)
  local k = K(x, y)
  local t, s = hT[k], hS[k]
  if t > 0.66 and t < 0.9 then
    local i = floor(hv[k] * 5.99) + 1
    local d = (t * LEN + s * 1.6) % 3
    if d < 1 then i = i - 2 elseif d < 1.8 and s < 0.2 then i = i + 1 end
    if t < 0.685 or t > 0.875 then i = 1 end
    c:put(x, y, LEATH[max(1, min(6, i))], ltok)
  end
end)

-- head: slim neck, short bearded blade (same drawing as broken-hatchet, intact)
local head = c:poly{ {46,12},{39,12},{31,13},{24,12},{19,10},{15,9},{12,11},{11,15},{11,20},{12,24},{14,27},{16,29},
  {18,28},{21,24},{26,20},{32,18},{39,19},{46,19} }
local boss = c:rrect(39, 10, 47, 21, 3)
head:add(boss)
local horizon = 15
local bevel = head:copy():cut(head:shift(3, 0)):clip(c:rect(0, 0, 22, 63))
local ridge = bevel:shift(1, 0):cut(bevel):clip(head):clip(c:rect(0, 0, 23, 63))
local edgeL = head:copy():cut(head:shift(1, 0)):clip(c:rect(0, 0, 22, 63))
local bn = X.pillow(boss, 1.5)
local bv = X.light(bn, { amb = 0.15, wrap = 0.2 })
head:each(function(x, y)
  local i
  if boss:has(x, y) then
    i = floor(bv[K(x, y)] * 5.99) + 1 + (y < horizon and 0 or -1)
    if not boss:has(x - 1, y) and head:has(x - 1, y) then i = 2 end
  elseif bevel:has(x, y) then
    i = y < horizon + 1 and 6 or 5
  else
    i = y < horizon and 5 or 3
    if y == horizon - 1 then i = 6 end
    if y == horizon then i = 2 end
  end
  if ridge:has(x, y) then i = y < horizon and 3 or 2 end
  if not head:has(x, y - 1) and not boss:has(x, y) then i = 6 end
  c:put(x, y, STEEL[max(1, min(6, i))], stok)
end)
edgeL:each(function(x, y) if y < horizon + 3 then c:put(x, y, STEEL[6], stok) end end)
c:put(11, 16, SPEC, stok) c:put(11, 17, SPEC, stok)
head:each(function(x, y) if not head:has(x, y + 1) and x > 13 and x < 38 then c:put(x, y, BOUNCE, stok) end end)
for x = 40, 46 do if head:has(x, 21) then c:put(x, 21, STEEL[1], stok) end end
-- eye: handle end grain through the top + dark wedge
for x = 41, 45 do c:put(x, 9, WOOD[4], wtok) c:put(x, 10, WOOD[3], wtok) end
c:put(41, 9, WOOD[6], wtok) c:put(42, 9, WOOD[5], wtok)
c:put(43, 9, WOOD[1], wtok) c:put(43, 10, WOOD[1], wtok)
c:put(40, 10, STEEL[1], stok) c:put(46, 10, STEEL[1], stok)
for x = 40, 46 do c:put(x, 11, (x >= 41 and x <= 45) and STEEL[1] or STEEL[6], stok) end
-- small maker's punch mark on the cheek (two dots)
c:put(30, 15, STEEL[2], stok) c:put(32, 15, STEEL[2], stok)

-- quirk: shaving curl caught on the edge (spiral; the gaps become ink with the outline)
A.map(c, {
  "..bbc.",
  ".b...c",
  "a..ab.",
  "a.b...",
  ".aa...",
}, 5, 18, { a = SHAV[1], b = SHAV[2], c = SHAV[3] }, qtok)
c:put(10, 19, SHAV[2], qtok) c:put(10, 18, SHAV[3], qtok)

A.save(c, "hatchet")
