-- masterwork-secateurs (final, Opus single pass). Bypass pruners, jaws up and slightly open: a curved polished
-- steel blade (honed bright edge, bevel band, specular) sweeping past a darker hooked anvil jaw; brass pivot bolt with
-- a screw slot; slim handles with bare steel necks and ribbed red grips (dark collar where they meet); a brass coil
-- spring between them (twist). quirk: a snipped rose petal drifts away from the blade tip.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC22_5.lua")
local K, X = A.K, A.X
local floor, sin, pi, max = math.floor, math.sin, math.pi, math.max
local c = A.new("masterwork-secateurs")

-- hooked anvil jaw (behind)
local hm, hn, hT, hS = A.blade(31, 30, 41, 20, 36, 7, function(t)
  if t > 0.985 then return -1 end return 2.3 * (1 - t * 0.55) end, { fold = 0.2 })
local hb = {} hm:each(function(x, y) hb[K(x, y)] = -1 end)
local hidx = A.tone(c, hm, hn, A.STEEL, { bias = hb, amb = 0.12 })
-- sap groove along the hook
hm:each(function(x, y) local k = K(x, y)
  if math.abs(hS[k]) < 0.15 and hT[k] > 0.2 and hT[k] < 0.75 then c:put(x, y, A.STEEL[1]) end end)

-- handles: steel neck then ribbed red grip
local function handle(pts)
  local m, n, T, S, samp = A.tube(pts, function(t)
    if t < 0.3 then return 1.3 end
    return 1.75 + 0.35 * sin(pi * (t - 0.3) / 0.7) end)
  local len = 28
  local idx = A.toneSel(c, m, n, function(k) return T[k] < 0.3 and A.STEEL or A.RED end, { amb = 0.1, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    local t = T[k]
    if t >= 0.3 and t < 0.335 then c:put(x, y, A.RED[1])
    elseif t > 0.42 and t < 0.93 and (t * len) % 3 < 0.9 then A.step(c, idx, A.RED, x, y, -1) end
  end)
  return m
end
local lm = handle({ { 31, 29 }, { 27, 37 }, { 22, 46 }, { 21, 56 } })
A.contact(c, lm, 1)
local rm = handle({ { 33, 29 }, { 38, 37 }, { 43, 46 }, { 43, 56 } })

-- cutting blade (on top), curved
local bm, bn, bT, bS = A.blade(34, 30, 23, 21, 27, 5, function(t)
  if t > 0.985 then return -1 end return 2.6 * (1 - t) ^ 0.75 + 0.25 end, { fold = 0.15 })
local bidx = A.tone(c, bm, bn, A.STEEL, { amb = 0.16, wrap = 0.35 })
-- honed edge (right side, facing the hook) + bevel band beside it
bm:each(function(x, y) local k = K(x, y)
  if bT[k] > 0.18 and not bm:has(x + 1, y) then
    c:put(x, y, A.STEEL[6])
    if bm:has(x - 1, y) then A.step(c, bidx, A.STEEL, x - 1, y, 1) end
  end end)
c:put(26, 13, A.CREAM) c:put(26, 14, A.STEEL[6])
A.contact(c, bm, 1)

-- coil spring between the grips (brass, twist)
for y = 37, 39 do for x = 28, 36 do
  if not lm:has(x, y) and not rm:has(x, y) and (x + y) % 3 == 0 then
    c:put(x, y, y == 37 and A.BRASS[6] or (y == 38 and A.BRASS[4] or A.BRASS[3])) end end end

-- pivot bolt with slot
local pm = A.ball(c, 32.5, 28.5, 2.4, A.BRASS)
A.contact(c, pm, 1)
c:put(33, 28, A.BRASS[1]) c:put(32, 29, A.BRASS[1]) c:put(31, 27, A.CREAM)

-- quirk: a rose petal drifting off the blade tip
local om, on = A.oval(19.5, 9.5, 2.6, 1.5, -0.5, 0.8)
local oidx = A.tone(c, om, on, A.PINK, { amb = 0.2, wrap = 0.35 })
c:put(19, 10, A.PINK[3]) c:put(20, 10, A.PINK[3])
A.save(c, "masterwork-secateurs")
