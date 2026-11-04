-- pickled-asparagus (final, Opus single pass). A slim tall glass jar of pale green-gold brine with five asparagus
-- spears standing in it (tips poking above the brine line), a cork stopper, twisted twine round the neck with a
-- short tail, and a cream paper label with a hand-lettered line and a little spear doodle.
-- Material: per-pixel cylinder light on brine, spears (6-tone tubes, purple-tinged bract chevrons, tinted by the
-- brine where submerged), glass with a bright left rim streak, pale core and cool reflected edge, thick glass base,
-- meniscus line, cork speckle pores, twine twist. Ground shadow.
-- quirk: a single peppercorn on the bottom sends up a little trail of bubbles.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC33_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, abs, max, min = math.floor, math.sqrt, math.abs, math.max, math.min
local c = A.new("pickled-asparagus")
local mix = A.mix

local BRINE = { "#56704e", "#7c955c", "#a0b86c", "#bdd180", "#d4e39a", "#ebf2c2" }
local AIR   = { "#4f7f96", "#7fb0c0", "#a5cfd4", "#c6e6e0", "#e0f3ec", "#f4fbf2" }
local SP    = { "#24452f", "#3a6a3e", "#548a48", "#71a752", "#93c25e", "#c2dc82" }
local TIP   = { "#3a2441", "#5e3658", "#81506f", "#a76e86" }
local CORK  = { "#5a3528", "#7e4f34", "#a26d45", "#c08a56", "#d9aa70", "#efcb92" }
local TW    = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local PAPER = { "#8a7468", "#bfa88e", "#dccaa8", "#eee0c0", "#faf0d6", "#fff8e6" }
local GLASSHI, GLASSRIM = "#f6fcf4", "#5f8ea2"

c:groundShadow(32, 55, 15, 2)

-- jar body mask: body + rounded shoulder + neck
local body = c:rrect(18, 19, 45, 55, 4)
local neck = c:rect(23, 14, 40, 19)
local jar = body:copy():add(neck)
local BR = 24 -- brine line
local x0, x1 = 18, 45
local function cylN(x) local u = (x - (x0 + x1) / 2) / ((x1 - x0) / 2 + 0.6) return { u, 0, sqrt(max(0.04, 1 - u * u)) } end
local n = {}
jar:each(function(x, y) n[K(x, y)] = cylN(x) end)
local v = X.light(n, { amb = 0.1, wrap = 0.35 })
local tokB, tokA = { r = { name = "brine" } }, { r = { name = "air" } }
local inner = jar:copy()
jar:each(function(x, y)
  local k = K(x, y)
  local i = 1
  for j, t in ipairs(A.CUTS) do if v[k] >= t then i = j + 1 end end
  if y > BR then c:put(x, y, BRINE[max(1, min(6, i))], tokB)
  else c:put(x, y, AIR[max(2, min(6, i + 1))], tokA) end
end)
-- meniscus
for x = x0 + 1, x1 - 1 do if jar:has(x, BR + 1) then c:put(x, BR + 1, x < 33 and BRINE[6] or BRINE[5], tokB) end end

-- spears
local tokS = { r = { name = "spear" } }
local spears = {
  { 22.5, 21, -1.2 }, { 26.8, 18, -0.5 }, { 31.2, 17, 0.2 }, { 35.6, 19, 0.8 }, { 40, 22, 1.5 },
}
for si, s in ipairs(spears) do
  local bx, ty, lean = s[1], s[2], s[3]
  local p = { { bx - lean * 0.3, 53 }, { bx - lean * 0.1, 44 }, { bx + lean * 0.3, 30 }, { bx + lean * 0.5, ty } }
  local m, nn, T, S, samp = A.tube(p, function(t)
    if t > 0.9 then return 1.7 * (1 - t) / 0.1 + 0.2 end
    return 1.75
  end)
  m:clip(jar:copy():cut(c:rect(0, 53, 63, 63)))
  local vv = X.light(nn, { amb = 0.1, wrap = 0.3 })
  local L = (53 - ty)
  m:each(function(x, y)
    local k = K(x, y)
    local i = 1
    for j, t in ipairs(A.CUTS) do if vv[k] >= t then i = j + 1 end end
    -- cylinder of the jar dims spears toward the right
    if x >= 40 then i = i - 1 end
    i = max(1, min(6, i))
    local t, sn = T[k], S[k]
    local col = SP[i]
    -- bract chevrons: every ~5 px along the spear, a darker scale on the edge
    local d = (t * L + abs(sn) * 2.2) % 5.2
    if t > 0.12 and t < 0.86 and abs(sn) > 0.35 and d < 1 then col = (i <= 3) and TIP[2] or SP[max(1, i - 2)] end
    if t >= 0.86 then
      local ti = max(1, min(4, floor(i * 4 / 6 + 0.5)))
      col = TIP[ti]
      if (t * L * 1.3 + abs(sn) * 2) % 2.6 < 0.9 and ti > 1 then col = TIP[ti - 1] end
    end
    if y > BR then col = mix(col, BRINE[4], 0.28) end
    c:put(x, y, col, tokS)
  end)
  -- one lit streak on the lit side of the spear
  for _, q in ipairs{ 0.45, 0.5, 0.55 } do
    local s2 = samp[floor(q * 160) + 1]
    local xx, yy = floor(s2.x - 1 + .5), floor(s2.y + .5)
    if jar:has(xx, yy) and xx < 40 then c:put(xx, yy, mix(SP[6], BRINE[4], 0.28), tokS) end
  end
end

-- peppercorn + bubble trail (quirk)
A.map(c, { ".pp.", "pPqp", ".pp." }, 35, 50, { p = "#3a2420", P = "#7a5040", q = "#5e3a2e" })
for _, b in ipairs{ { 37, 47 }, { 36, 45 }, { 37, 43 } } do c:put(b[1], b[2], AIR[6]) c:put(b[1], b[2] + 1, BRINE[2]) end
A.map(c, { ".a.", "aHa", ".a." }, 35, 39, { a = AIR[5], H = GLASSHI })

-- thick glass base
for x = 19, 44 do if jar:has(x, 53) then
  c:put(x, 53, x < 30 and AIR[5] or AIR[4]) c:put(x, 54, x < 30 and AIR[4] or AIR[3]) c:put(x, 55, AIR[2]) end end
c:put(21, 54, GLASSHI) c:put(22, 54, GLASSHI)

-- glass wall: bright rim + pale core + cool edge
jar:edge():each(function(x, y)
  if y >= 55 then return end
  if x <= 20 or (y <= 20 and x <= 26) then c:put(x, y, AIR[5])
  elseif x >= 43 or y <= 15 then c:put(x, y, GLASSRIM) end
end)
for y = 23, 50 do if y < 30 or y > 40 then c:put(20, y, GLASSHI) end end
for y = 25, 28 do c:put(21, y, AIR[6]) end
for y = 21, 50 do if y % 7 ~= 3 then c:put(43, y, "#8fc4cf") end end
c:put(24, 17, GLASSHI) c:put(25, 17, GLASSHI) c:put(19, 22, GLASSHI)

-- label (on the glass, front)
local lab = c:rect(21, 29, 42, 39)
lab:cut(c:rect(21, 29, 21, 29)):cut(c:rect(42, 39, 42, 39))
A.cast(c, lab, 1, 1, -1)
local ln = X.pillow(lab, 1.2)
for k, nn in pairs(ln) do local x = k % 1024 - 256 local cn = cylN(x) ln[k] = { (nn[1] + cn[1]) * 0.6, nn[2], nn[3] } end
local lv = X.light(ln, { amb = 0.15, wrap = 0.4 })
local tokL = { r = { name = "label" } }
X.tone(c, lab, lv, PAPER, { cuts = { 0.15, 0.3, 0.46, 0.62, 0.8 }, tok = tokL })
for x = 23, 40 do c:put(x, 31, PAPER[2], tokL) c:put(x, 37, PAPER[2], tokL) end
-- lettering + little spear doodle
A.map(c, {
  "gg.ggg.gg.g",
  "...........",
  "ggg.gg.ggg.",
}, 28, 33, { g = "#3f7a46" }, tokL)
A.map(c, { ".t", "tg", "g.", "g." }, 24, 32, { t = TIP[3], g = "#3f7a46" }, tokL)
c:put(41, 30, PAPER[6], tokL)

-- twine round the neck (twist) + tail
for x = 22, 41 do
  c:put(x, 15, ((x % 3) == 0) and TW[1] or ((x < 31) and TW[3] or TW[2]))
  c:put(x, 16, ((x % 3) == 1) and TW[1] or ((x < 31) and TW[2] or TW[1]))
end
c:put(25, 15, TW[4]) c:put(26, 15, TW[4])
A.map(c, { "ab", "ba", "ab", ".b", ".a" }, 42, 15, { a = TW[2], b = TW[1] })

-- cork stopper
local cork = c:rrect(22, 7, 41, 13, 2)
A.cast(c, cork, 0, 1, -1)
local cidx = A.toneN(c, cork, X.pillow(cork, 2.2), CORK, { cuts = A.CUTS, tok = { r = { name = "cork" } } })
cork:each(function(x, y)
  if X.hash(x, y, 77) < 0.16 and y > 7 and x > 22 and x < 41 then
    local i = cidx[K(x, y)] or 3 c:put(x, y, CORK[max(1, i - 2)]) end end)
for x = 24, 39 do c:put(x, 7, (x < 31) and CORK[6] or CORK[5]) end
c:put(25, 8, A.CREAM)
A.save(c, "pickled-asparagus")
