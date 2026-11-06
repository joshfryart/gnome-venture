-- grand-healing-elixir (final pass, Opus aB35_4). A slim round-bellied flask with a tall thin neck: pale blue glass
-- (bright curved rim streak on the lit side, pale core, cool deep edge), glowing rose-ruby potion filling the belly
-- (pale glowing core, bright meniscus), a bevelled gold lip, a gold collar with three studs, and a little gold crown
-- stopper with a ruby set in its middle point. Ground shadow.
-- quirk: a heart-shaped bubble is rising through the potion, chased by two tiny round ones.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB35_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("grand-healing-elixir")
local GL   = { "#34507e", "#557eae", "#86b2da", "#b4daf0", "#d6eef8", "#eef8fc" }
local LIQ  = { "#5e1a3a", "#982448", "#cc3854", "#ee5862", "#ff8a7a", "#ffc4a4" }
local GOLD = { "#5a2a1e", "#8f4a1f", "#c06e22", "#e89a2a", "#f5c84a", "#ffe9a0" }
local RUBY = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }
local CREAM = "#fff4d6"

c:groundShadow(32, 57, 12, 2)
-- glass: belly + neck
local BX, BY, BR = 32, 44, 11
local belly = c:ellipse(BX, BY, BR, BR)
local neck = c:rect(29, 20, 35, 35)
local glass = belly:copy():add(neck)
local gn = {}
glass:each(function(x, y) local k = K(x, y)
  if y >= 34 or belly:has(x, y) and not neck:has(x, y) then
    local nx, ny = (x - BX) / (BR + 0.5), (y - BY) / (BR + 0.5)
    gn[k] = { nx, ny, sqrt(max(0.03, 1 - nx * nx - ny * ny)) }
  else
    local t = max(-0.95, min(0.95, (x - 32) / 3.6))
    gn[k] = { t, 0, sqrt(1 - t * t) }
  end
end)
local gtok = A.tok("glass")
local gidx = A.shade(c, glass, gn, GL, { tok = gtok, amb = 0.25, wrap = 0.4 })
-- shoulder AO where the neck meets the belly
for _, p in ipairs{ { 28, 34 }, { 36, 34 }, { 28, 35 }, { 36, 35 } } do if glass:has(p[1], p[2]) then c:put(p[1], p[2], GL[2], gtok) end end

-- potion inside the belly (one glass pixel wall all round), surface at y = 37
local liq = belly:shrink(1)
liq:each(function(x, y) if y < 37 then liq.s[K(x, y)] = nil end end)
local ltok = A.tok("liquid")
local ln = X.sphere(BX, BY, BR - 1, liq)
local lv = X.light(ln, { amb = 0.05, wrap = 0.2 })
liq:each(function(x, y) local k = K(x, y)
  local d = sqrt((x - BX + 1.5) ^ 2 + (y - BY - 1) ^ 2) / (BR - 1)
  lv[k] = min(1, lv[k] * 0.55 + max(0, 1 - d) * 0.6)   -- glowing pale core
end)
local lidx = X.tone(c, liq, lv, LIQ, { cuts = A.CUTS, tok = ltok })
for x = BX - 10, BX + 10 do if liq:has(x, 37) then c:put(x, 37, x < BX + 4 and LIQ[6] or LIQ[5], ltok) end end   -- meniscus
-- glass bright rim streak on the lit side + pale core and cool deep edge lower-right
for _, p in ipairs{ { 24, 39 }, { 23, 40 }, { 23, 41 }, { 23, 42 }, { 23, 43 }, { 23, 44 }, { 24, 47 }, { 24, 48 } } do c:put(p[1], p[2], CREAM, gtok) end
for _, p in ipairs{ { 26, 38 }, { 25, 39 } } do c:put(p[1], p[2], GL[6], gtok) end
for y = 22, 31 do c:put(30, y, y % 5 == 0 and GL[5] or GL[6], gtok) end
glass:edge():each(function(x, y) local k = K(x, y) local n = gn[k]
  if n[1] + n[2] > 0.95 and y > 40 then c:put(x, y, GL[1], gtok) end end)

-- quirk: heart bubble + two small bubbles
local htok = A.tok("heart")
A.rows(c, 33, 41, { "ab.ab", "bbbbc", ".bbc.", "..c.." }, { a = CREAM, b = LIQ[6], c = LIQ[5] }, htok)
c:put(31, 39, LIQ[6], htok) c:put(37, 38, LIQ[6], htok)
c:put(36, 49, LIQ[5], htok)

-- gold lip ring at the mouth
local gtk = A.tok("gold")
local lip = c:rrect(27, 18, 37, 21, 1)
local lipn = X.pillow(lip, 1.6)
A.shade(c, lip, lipn, GOLD, { tok = gtk, amb = 0.1, wrap = 0.3 })
for x = 28, 36 do c:put(x, 21, x < 33 and GOLD[3] or GOLD[2], gtk) end
-- gold collar at the neck base with three studs
local col = c:rect(28, 31, 36, 33)
local coln = {} col:each(function(x, y) local t = max(-0.95, min(0.95, (x - 32) / 5)) coln[K(x, y)] = { t, (y - 32) * 0.5, sqrt(1 - t * t) } end)
local ctk = A.tok("collar")
A.shade(c, col, coln, GOLD, { tok = ctk, amb = 0.1, wrap = 0.3 })
for _, x in ipairs{ 29, 32, 35 } do c:put(x, 32, GOLD[6], ctk) c:put(x + 1, 33, GOLD[2], ctk) end
-- crown stopper (sits in the neck, band + three points, ruby in the middle point)
local crown = c:rect(28, 14, 36, 17)
crown:add(c:poly{ { 28, 14 }, { 28, 10 }, { 30, 13 } }):add(c:poly{ { 30, 14 }, { 32, 8 }, { 34, 14 } }):add(c:poly{ { 36, 14 }, { 36, 10 }, { 34, 13 } })
local crn = X.pillow(crown, 1.8)
local crk = A.tok("crown")
A.shade(c, crown, crn, GOLD, { tok = crk, amb = 0.1, wrap = 0.3 })
for x = 28, 36 do c:put(x, 17, GOLD[2], crk) end          -- dark row where crown meets the lip
for x = 29, 35 do c:put(x, 15, (x % 2 == 1) and GOLD[6] or GOLD[3], crk) end   -- beaded band
c:put(28, 10, GOLD[6], crk) c:put(36, 10, GOLD[5], crk)   -- tip balls
A.rows(c, 31, 11, { ".a.", "abc", ".cd" }, { a = RUBY[4], b = RUBY[3], c = RUBY[2], d = RUBY[1] }, crk)
c:put(32, 8, GOLD[6], crk)
A.save(c, "grand-healing-elixir")
