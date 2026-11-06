-- lemon-cordial (final pass, Opus). A tall slim glass bottle (long neck, sloped shoulder, straight body) full of
-- sunny lemon cordial up to the shoulder, a cork stopper with a paler end-grain top, twisted twine round the neck
-- with a small paper tag, and a cream paper label with a lemon on it.
-- Material: glass = 1 px lit wall ring, pale empty core above the liquid, a long cream specular streak on the left
-- and a cool reflected edge on the right. Liquid: per-pixel cylinder light on a 6-tone lemon ramp, a bright
-- meniscus line, deep amber at the foot. Cork: grain flecks. Twine: 2-tone twist. 2-tone ground shadow.
-- History: Sonnet draft (_dC20) replaced.
-- quirk: a single lemon pip has sunk to the bottom of the bottle.
local NAME = "lemon-cordial"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC20_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min = math.floor, math.abs, math.max, math.min
local c = A.new(NAME)

local GLASS = { "#2a4a7a", "#3a6f96", "#5b9fbe", "#8fcfd8", "#c4eee8", "#eafff6" }
local LIQ = { "#8f3f1c", "#c06a1e", "#e39a24", "#f5c232", "#ffdf62", "#fff2a6" }
local CORK = { "#51302b", "#7a4a32", "#a06a42", "#c08d5a", "#ddb47e", "#f0d3a0" }
local PAPER = { "#a68a6a", "#d8c29a", "#f3e6c4", "#fff6de" }
local LEM = { "#b07a14", "#e6b818", "#fbe050", "#fff4a0" }
local TW = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local LF = { "#24544a", "#3f9150", "#7cc35a" }

local cx = 31.5
c:groundShadow(32, 56, 12, 2)

local function w(y)
  if y < 13 then return nil end
  if y <= 14 then return 3.5 end            -- lip
  if y <= 22 then return 2.5 end            -- neck
  if y <= 30 then return 2.5 + (y - 22) * 0.82 end  -- shoulder
  if y <= 52 then return 9.0 end
  if y <= 54 then return 9.0 - (y - 52) * 0.9 end
  return nil
end
local bm, bn, BS = A.lathe(cx, 13, 54, w)
local inner = bm:shrink(1)
local LEVEL = 27
local gtok, ltok = { r = { name = "glass" } }, { r = { name = "liquid" } }

-- glass everywhere first
local v = X.light(bn, { amb = 0.2, wrap = 0.4 })
bm:each(function(x, y) local k = K(x, y)
  local i
  if inner:has(x, y) then i = (v[k] > 0.5) and 5 or 4 else i = (v[k] > 0.55) and 4 or ((v[k] > 0.3) and 3 or 2) end
  if y <= 14 then i = (BS[k] < -0.2) and 5 or ((BS[k] > 0.5) and 2 or 4) end
  c:put(x, y, GLASS[i], gtok)
end)
-- lip underside dark row
for x = floor(cx - 3), floor(cx + 4) do if bm:has(x, 15) then c:put(x, 15, GLASS[2], gtok) end end

-- liquid
local lm = HP.mask()
inner:each(function(x, y) if y >= LEVEL then lm:set(x, y) end end)
local bias = {}
lm:each(function(x, y) if y >= 51 then bias[K(x, y)] = -1 end end)
local lidx = X.tone(c, lm, X.light(bn, { amb = 0.15, wrap = 0.35 }), LIQ, { cuts = A.CUTS, bias = bias, tok = ltok })
-- meniscus
lm:each(function(x, y) if y == LEVEL then c:put(x, y, (x < cx + 3) and LIQ[6] or LIQ[5], ltok) end end)
-- reflected cool-ish light on the right inside edge
lm:each(function(x, y) if not lm:has(x + 1, y) and y > LEVEL + 2 and y < 51 then c:put(x, y, "#e9b65a", ltok) end end)

-- label (cream paper, lemon motif)
local L0, L1, T0, T1 = floor(cx - 6), floor(cx + 7), 36, 45
for y = T0, T1 do for x = L0, L1 do
  local i = 3
  if x >= L1 - 1 then i = 2 end
  if y == T0 then i = 4 end
  if y == T1 then i = 2 end
  if x == L0 or x == L1 or y == T0 or y == T1 then if i ~= 4 then i = 1 end end
  if y == T0 and (x == L0 or x == L1) then i = 1 end
  c:put(x, y, PAPER[i], { r = { name = "label" } })
end end
-- lemon on label: 5x3 oval with nubs, leaf
local lemon = { "  bbb  ", " bcccb ", "abccdcba", " abbbb ", "  aaa  " }
local lemon2 = {
  ".bbbb.",
  "bccdcb",
  "abccbba",
  ".aaaa.",
}
local map = { a = LEM[1], b = LEM[2], c = LEM[3], d = LEM[4] }
for r, row in ipairs(lemon2) do for i = 1, #row do local ch = row:sub(i, i)
  if map[ch] then c:put(L0 + 3 + i, T0 + 2 + r, map[ch], { r = { name = "label" } }) end end end
c:put(L0 + 3, T0 + 5, LEM[1]) -- tip nub
c:put(L0 + 10, T0 + 5, LEM[1])
c:put(L0 + 8, T0 + 2, LF[2]) c:put(L0 + 9, T0 + 2, LF[3]) c:put(L0 + 9, T0 + 1, LF[3])
-- tiny text lines
for x = L0 + 3, L1 - 4 do if x % 2 == 0 then c:put(x, T1 - 2, PAPER[1]) end end

-- glass specular streak + cool edge (over everything glassy)
for y = 17, 52 do
  local x = floor(cx - 6)
  if y < 31 then x = floor(cx - 1 - (y > 22 and (y - 22) * 0.62 or 0)) end
  if bm:has(x, y) and not (x >= L0 and x <= L1 and y >= T0 and y <= T1) and y ~= 30 and y ~= 49 then
    c:put(x, y, (y > 34 and y < 46) and A.CREAM or GLASS[6], gtok)
  end
end
c:put(floor(cx - 5), 33, GLASS[6], gtok) c:put(floor(cx - 5), 34, GLASS[6], gtok)
for y = 32, 52 do local x = floor(cx + 8) if bm:has(x, y) and not (y >= T0 and y <= T1) then c:put(x, y, "#9fd8dc", gtok) end end

-- quirk: the sunk pip at the bottom (pale teardrop on its side)
c:put(floor(cx + 3), 52, "#fff0c8") c:put(floor(cx + 4), 52, "#e8d29a") c:put(floor(cx + 5), 52, "#b89a5e")
c:put(floor(cx + 4), 51, "#f6e4b0")

-- cork stopper above the lip
local km, kn = A.lathe(cx, 6, 12, function(y) if y <= 7 then return 3.0 end return 2.6 - (y - 8) * 0.12 end)
local ktok = { r = { name = "cork" } }
local kidx = A.shade(c, km, kn, CORK, { tok = ktok, amb = 0.12, wrap = 0.3 })
-- end grain top
for x = floor(cx - 2), floor(cx + 2) do c:put(x, 6, (x < cx) and CORK[6] or CORK[5], ktok) end
c:put(floor(cx), 6, CORK[4], ktok)
-- grain flecks
for _, p in ipairs{ { -1, 9 }, { 1, 10 }, { 0, 8 }, { 2, 11 }, { -2, 11 } } do
  local x, y = floor(cx + p[1]), p[2]
  if km:has(x, y) then A.step(c, kidx, CORK, x, y, -2, ktok) end
end
-- dark row where cork enters the lip
for x = floor(cx - 2), floor(cx + 3) do if bm:has(x, 13) then c:put(x, 13, GLASS[2], gtok) end end

-- twine twisted round the neck (y 19-20) + tag hanging to the right
local ttok = { r = { name = "twine" } }
for x = floor(cx - 3), floor(cx + 3) do
  c:put(x, 19, ((x + 19) % 2 == 0) and TW[3] or TW[2], ttok)
  c:put(x, 20, ((x + 20) % 2 == 0) and TW[2] or TW[1], ttok)
end
c:put(floor(cx - 3), 19, TW[4], ttok)
-- tail to the tag
for _, p in ipairs{ { 4, 21, 2 }, { 5, 22, 3 }, { 5, 23, 2 }, { 6, 24, 3 } } do c:put(floor(cx + p[1]), p[2], TW[p[3]], ttok) end
-- tag: small card, punched hole, tilted
local tag = {
  "..aa..",
  ".abba.",
  "abcdcb",
  "abcccb",
  "abcccb",
  "abccbb",
  "aabbba",
}
local tm = { a = PAPER[1], b = PAPER[2], c = PAPER[3], d = "#6e4a3a" }
for r, row in ipairs(tag) do for i = 1, #row do local ch = row:sub(i, i)
  if tm[ch] then c:put(floor(cx + 4 + i), 23 + r, tm[ch], { r = { name = "tag" } }) end end end
c:put(floor(cx + 8), 28, LEM[2]) c:put(floor(cx + 7), 28, LEM[3])

A.save(c, "ph", NAME)
