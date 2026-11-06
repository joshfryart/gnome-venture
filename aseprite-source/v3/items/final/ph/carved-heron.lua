-- carved-heron (final, Opus single pass). A slim hand-carved wooden heron standing on one leg on a round walnut
-- plinth: S-curved neck, small head with a long dagger beak and a two-feather crest, teardrop body tapering to a
-- pointed tail, the second leg tucked up. Material: per-pixel light (6-tone honey wood, cool-violet shade), flowing
-- grain lines along the body and neck, a carved wing groove with a lit lip, chisel-cut feather chevrons, drilled
-- eye, polished glint on the beak; plinth: 6-tone walnut side, pale end grain with growth rings on top, AO where the
-- leg meets the plinth, 2-tone ground shadow.
-- quirk: a curly wood shaving is still lying on the plinth.
local NAME = "carved-heron"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB1r0_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local WD = { "#3b2023", "#5e3326", "#86512f", "#ad7340", "#cf9958", "#ebc27e" }
local BS = { "#2a1820", "#45262a", "#62392e", "#83523a", "#a6714a", "#c8955e" }
local END = { "#9c6a44", "#c08e5c", "#dcae78", "#f0cc94" }
local SHAV = { "#b8834e", "#e2b878", "#f8e0aa" }
local SPEC = "#fff0cc"
local wtok, btok = A.tok("wood"), A.tok("plinth")

c:groundShadow(33, 56, 15, 2)

-- plinth: short cylinder, top ellipse + side band
local BCX, BCY, BRX, BRY, BH = 33, 50, 12, 3.2, 4
local topm, side = HP.mask(), HP.mask()
for y = BCY - 5, BCY + BH + 5 do for x = BCX - BRX - 1, BCX + BRX + 1 do
  local dx = (x - BCX) / (BRX + .5)
  if abs(dx) <= 1 then
    local e = sqrt(1 - dx * dx) * (BRY + .5)
    if y >= BCY - e and y <= BCY + e then topm:set(x, y)
    elseif y > BCY and y <= BCY + e + BH then side:set(x, y) end
  end
end end
side:each(function(x, y)
  local nx = (x - BCX) / (BRX + .5)
  local v = 0.62 - nx * 0.55
  local i = v > 0.95 and 6 or v > 0.75 and 5 or v > 0.55 and 4 or v > 0.35 and 3 or 2
  local dx = (x - BCX) / (BRX + .5)
  local e = sqrt(max(0, 1 - dx * dx)) * (BRY + .5)
  if y >= BCY + e + BH - 0.5 then i = i - 1 end           -- bottom bevel
  if y <= BCY + e + 0.6 then i = min(6, i + 1) end         -- top chamfer catches light
  if X.hash(x, floor(y / 2), 41) > 0.82 then i = i - 1 end -- vertical grain flecks
  c:put(x, y, BS[max(1, i)], btok)
end)
topm:each(function(x, y)
  local dx, dy = (x - BCX + 2) / BRX, (y - BCY) / BRY
  local r = sqrt(dx * dx + dy * dy)
  local ring = floor(r * 4.2 + 0.25 * sin(x * 0.9))
  local col = (ring % 2 == 0) and END[3] or END[2]
  if r > 0.92 then col = END[4] end
  if r > 0.92 and (x > BCX + 4 or y > BCY) then col = END[2] end
  if r < 0.12 then col = END[1] end                        -- pith
  c:put(x, y, col, btok)
end)

-- tucked leg (behind) and standing leg
local leg = HP.mask()
for y = 37, 49 do leg:set(33, y) leg:set(34, y) end
leg:set(32, 43) leg:set(35, 44)                            -- backward knee
for _, q in ipairs{ { 32, 49 }, { 31, 50 }, { 35, 50 }, { 36, 50 } } do leg:set(q[1], q[2]) end -- toes
leg:each(function(x, y)
  local col = (x <= 33) and WD[4] or WD[2]
  if y == 43 or y == 44 then col = (x <= 33) and WD[5] or WD[3] end
  c:put(x, y, col, wtok)
end)
-- AO on the plinth top round the foot
for _, q in ipairs{ { 30, 50 }, { 31, 51 }, { 32, 51 }, { 33, 51 }, { 34, 51 }, { 35, 51 }, { 36, 51 }, { 37, 50 } } do
  if topm:has(q[1], q[2]) then c:put(q[1], q[2], END[1], btok) end end
local tuck = A.poly{ { 37, 36 }, { 40, 40 }, { 37.5, 41.5 }, { 36.5, 40.5 }, { 38, 39.5 }, { 36, 37 } }
tuck:each(function(x, y) c:put(x, y, WD[2], wtok) end)

-- body: teardrop on a slant, pointed tail lower-right
local ang = 0.42
local body = select(1, A.oval(37, 31, 9.5, 5.4, ang, 0.9))
local tail = A.poly{ { 41, 31.5 }, { 51.5, 40.5 }, { 43.5, 37.5 } }
body:add(tail)
local bn = A.body(body, 35, 29, 9, 4, 0.5)
local ca, sa = cos(ang), sin(ang)
local bias = {}
body:each(function(x, y) local k = K(x, y)
  local dx, dy = x - 37, y - 31
  local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
  -- wing groove: an arc from the shoulder to the tail, lit lip above it
  local gv = -1.2 + 0.018 * (u + 6)^2
  if u > -6 and u < 11 then
    if abs(v - gv) < 0.5 then bias[k] = -2 elseif v - gv < -0.5 and v - gv > -1.5 then bias[k] = 1 end
  end
  -- grain lines along the body
  local g = (v * 0.75 + 0.5 * sin(u * 0.35)) % 2.6
  if not bias[k] and g < 0.32 and X.hash(x, y, 3) > 0.3 then bias[k] = -1 end
end)
local bidx = A.shade(c, body, bn, WD, { tok = wtok, bias = bias, amb = 0.08, wrap = 0.25 })
-- chisel feather chevrons on the wing's rear
for _, q in ipairs{ { 42, 35 }, { 45, 36 }, { 44, 33 } } do
  for _, d in ipairs{ { 0, 0 }, { 1, 1 }, { 2, 1 } } do local x, y = q[1] + d[1], q[2] + d[2]
    if body:has(x, y) then c:put(x, y, WD[max(1, (bidx[K(x, y)] or 3) - 2)], wtok) end end
  if body:has(q[1], q[2] - 1) then c:put(q[1], q[2] - 1, WD[min(6, (bidx[K(q[1], q[2] - 1)] or 3) + 1)], wtok) end
end
-- AO on the body above the leg
for _, q in ipairs{ { 33, 36 }, { 34, 36 }, { 35, 36 } } do if body:has(q[1], q[2]) then c:put(q[1], q[2], WD[1], wtok) end end

-- neck: S-curve tube out of the breast
local np = { { 31, 29 }, { 24, 24 }, { 31, 17 }, { 26, 12 } }
local nm, nn, NT, NS = A.tube(np, function(t) return 2.2 - t * 0.7 end)
local nb = {}
nm:each(function(x, y) local k = K(x, y)
  if body:has(x, y) then nb[k] = -1 end
  if abs(NS[k] - 0.15) < 0.12 and X.hash(x, y, 9) > 0.35 then nb[k] = (nb[k] or 0) - 1 end   -- grain
end)
nm:cut(body:shrink(1))
local nidx = A.shade(c, nm, nn, WD, { tok = wtok, bias = nb, amb = 0.1, wrap = 0.25 })
-- AO where the neck meets the breast
body:each(function(x, y) if nm:has(x - 1, y) and not nm:has(x, y) and y < 31 then c:put(x, y, WD[2], wtok) end end)

-- head
local hm, hn = A.oval(25.5, 11, 3.3, 2.6, -0.2, 0.9)
A.shade(c, hm, hn, WD, { tok = wtok, amb = 0.1, wrap = 0.25 })
-- crest: two carved plumes swept back
for _, q in ipairs{ { 28, 9, 5 }, { 29, 9, 4 }, { 30, 8, 5 }, { 31, 8, 4 }, { 32, 8, 3 }, { 33, 7, 3 }, { 29, 10, 3 }, { 30, 10, 3 }, { 31, 10, 2 } } do
  c:put(q[1], q[2], WD[q[3]], wtok) end
-- beak: long dagger, upper mandible lit, lower in shade, polished glint
local beak = A.poly{ { 23.2, 9.6 }, { 9.5, 12.6 }, { 23.2, 13.4 } }
beak:cut(hm)
beak:each(function(x, y)
  local mid = 9.6 + (x - 23.2) * (12.6 - 9.6) / (9.5 - 23.2)
  local col = (y < mid + 0.9) and WD[5] or WD[3]
  if y >= mid + 1.9 then col = WD[2] end
  if x > 20 and y >= mid + 0.9 then col = WD[2] end
  c:put(x, y, col, wtok)
end)
c:put(17, 11, SPEC, wtok) c:put(18, 11, WD[6], wtok)
-- drilled eye: dark pit with a lit lower lip
c:put(24, 10, A.INK, wtok) c:put(24, 11, WD[5], wtok)
c:put(23, 10, WD[2], wtok)

-- quirk: a curly wood shaving lying on the plinth, curling over the front edge
local stok = A.tok("shaving")
local shav = {
  ".bcc..",
  "bc..cb",
  "a.bc.b",
  ".a..ba",
  "..aa..",
}
local SM = { a = SHAV[1], b = SHAV[2], c = SHAV[3] }
for yy, row in ipairs(shav) do for xx = 1, #row do local ch = row:sub(xx, xx)
  if SM[ch] then c:put(39 + xx - 1, 46 + yy - 1, SM[ch], stok) end end end
A.save(c, NAME)
