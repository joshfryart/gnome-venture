-- guava-jam (final, Opus single pass). A slim glass jar of coral-pink guava jam: thick glass wall with a bright
-- rim and pale core, jam lit as a cylinder with a glossy meniscus and a scatter of tiny seed specks, a cream paper
-- label with a guava half, and a red gingham cloth cap tied with a twisted twine band.
-- Material: glass (rim, pale core, specular streak), jam (gloss, seeds), cloth (gingham weave, folds, hem stitch),
-- twine (twist). Ground shadow (stands). Draft by Sonnet replaced.
-- quirk: a fat jam drip has escaped from under the cloth and is running down the glass.
local NAME = "guava-jam"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC10_4.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
local c = A.new(NAME)

local JAM   = { "#5a1a34", "#8e2444", "#c23a52", "#e05a62", "#f4867a", "#ffc0a8" }
local GLASS = { "#3a6a8a", "#6aa0b8", "#a6d0dc", "#d4eef0", "#eefaf6" }
local RED   = { "#6e2038", "#9e2c40", "#c8443e", "#e8634e", "#ff8f6c" }
local PINKC = { "#a35a6a", "#d88a8a", "#f2b4a6", "#ffd8c4" }
local CREAMC = { "#8a6c58", "#c4a684", "#e8d4b0", "#f8ecd0", "#fff4d6" }
local TWINE = { "#5b3e2e", "#8a6440", "#b8925a", "#e0c08a" }
local LABEL = { "#a88e70", "#d8c4a0", "#f0e2c0", "#fbf2dc" }

c:groundShadow(32, 56, 13, 1.6)

-- jar: slim straight body with rounded shoulders and a short neck
local X0, X1, Y0, Y1 = 21, 42, 22, 54
local jar = c:rrect(X0, Y0, X1, Y1, 4):add(c:rect(23, 19, 40, 23))
local jtok = { r = { name = "jar" } }
local CXJ = (X0 + X1) / 2
-- per-pixel cylinder light across x
local function cylv(x) local s = (x - CXJ) / ((X1 - X0) / 2 + 0.5) local nz = sqrt(max(0.02, 1 - s * s))
  return max(0, min(1, 0.08 + 0.92 * (s * X.L[1] + nz * X.L[3] - 0.1 * X.L[2]) / 0.85)) end
local function ix(v, cuts) local i = 1 for j, t in ipairs(cuts) do if v >= t then i = j + 1 end end return i end
local inner = jar:shrink(2)
local JTOP = 27
jar:each(function(x, y)
  local v = cylv(x)
  if inner:has(x, y) and y >= JTOP then
    local i = ix(v, { 0.18, 0.36, 0.54, 0.72, 0.9 })
    if y >= Y1 - 4 then i = i - 1 end                     -- deeper colour toward the thick base
    c:put(x, y, JAM[max(1, min(6, i))], jtok)
  elseif inner:has(x, y) then
    c:put(x, y, GLASS[max(3, min(5, ix(v, { 0.3, 0.55, 0.8 }) + 1))], jtok)   -- air gap: pale glass core
  else
    c:put(x, y, GLASS[max(1, min(5, ix(v, { 0.2, 0.42, 0.64, 0.86 })))], jtok)  -- glass wall
  end
end)
-- thick base: bright inner rim line
for x = X0 + 3, X1 - 3 do c:put(x, Y1 - 1, GLASS[(x < CXJ) and 4 or 3], jtok) end
-- jam meniscus: lit lip, curving up at the walls
for x = X0 + 2, X1 - 2 do local y = JTOP if x <= X0 + 2 or x >= X1 - 2 then y = JTOP - 1 end
  c:put(x, y, (x < CXJ + 4) and JAM[6] or JAM[5], jtok) end
-- seed specks + one bubble in the jam
for _, p in ipairs{ {25,31},{29,29},{36,30},{38,36},{26,46},{37,49},{24,39},{33,51} } do
  if inner:has(p[1], p[2]) then c:put(p[1], p[2], "#e8c890", jtok) c:put(p[1] + 1, p[2] + 1, JAM[2], jtok) end end
c:put(39, 44, JAM[6], jtok) c:put(39, 45, JAM[4], jtok)

-- label: cream paper wrapped on the cylinder, beveled edges, a guava half in the middle
local lab = c:rect(24, 35, 39, 46)
local ltok = { r = { name = "label" } }
lab:each(function(x, y)
  local i = ix(cylv(x), { 0.25, 0.5, 0.78 })
  if y == 35 then i = i + 1 elseif y == 46 then i = i - 1 end
  c:put(x, y, LABEL[max(1, min(4, i))], ltok)
end)
for x = 25, 38, 2 do c:put(x, 37, "#c8443e", ltok) c:put(x + 1, 44, "#c8443e", ltok) end     -- printed border dashes
local gh = { "..aaa..", ".abbba.", "abcdcba", "abcecba", ".abbba.", "..aaa.." }
A.map(c, gh, 28, 38, { a = "#557a30", b = "#f2eebc", c = "#e05a62", d = "#fff4d6", e = "#b83a52" }, ltok)
c:put(35, 40, "#2e7646", ltok) c:put(36, 39, "#45954c", ltok)                                 -- leaf tick

-- glass specular streaks (left), small one right
for y = 25, 49 do if not lab:has(23, y) then c:put(23, y, CREAMC[5], jtok) end end
for y = 28, 33 do c:put(24, y, GLASS[5], jtok) end
for y = 30, 33 do c:put(40, y, GLASS[4], jtok) end

-- quirk drip: jam escaping from under the cloth, a bead at the end
local dtok = { r = { name = "drip" } }
local dm = A.stem(c, { { 39.5, 20 }, { 40, 23 }, { 40, 26 }, { 40, 29 } }, function(t) return 0.8 + 0.25 * t end, JAM, { tok = dtok })
local bead = c:ellipse(40, 30, 1.5, 1.5)
A.shade(c, bead, X.sphere(40, 30, 2, bead), JAM, { tok = dtok })
c:put(39, 29, JAM[6], dtok)

-- cloth cap: domed top over the lid, skirt with a zig-zag hem, gingham weave
local cap = c:poly{ { 18, 21 }, { 19, 15 }, { 24, 11 }, { 39, 11 }, { 44, 15 }, { 45, 21 } }
for i = 0, 9 do local x = 18 + i * 3 cap:add(c:poly{ { x, 20 }, { x + 3, 20 }, { x + 1.5, 23.5 } }) end
cap:cut(c:rect(0, 0, 63, 10))
local ctok = { r = { name = "cloth" } }
local cn = X.pillow(cap, 4)
local cv = X.light(cn, { amb = 0.08, wrap = 0.3 })
cap:each(function(x, y) local k = K(x, y)
  local i = ix(cv[k], { 0.25, 0.45, 0.65, 0.85 })
  if (x + 1) % 6 == 0 and y > 14 then i = i - 1 end        -- vertical drape folds
  local gx, gy = floor((x - 18) / 2) % 2, floor((y - 11) / 2) % 2
  local col
  if gx == 1 and gy == 1 then col = RED[max(1, min(5, i))]
  elseif gx == 1 or gy == 1 then col = PINKC[max(1, min(4, i - 1))]
  else col = CREAMC[max(1, min(5, i))] end
  c:put(x, y, col, ctok)
end)
-- hem stitch along the skirt (one stitch per asset)
c:stitch{ { 19, 21 }, { 44, 21 } }

-- twine band with twist + a bow on the left
local ttok = { r = { name = "twine" } }
for x = 19, 44 do
  c:put(x, 17, (x % 3 == 0) and TWINE[4] or TWINE[3], ttok)
  c:put(x, 18, (x % 3 == 1) and TWINE[1] or TWINE[2], ttok)
end
for _, p in ipairs{ {17,16,3},{16,15,4},{16,16,2},{17,17,3},{16,19,2},{15,20,3},{17,19,3},{16,21,2},{15,17,1} } do c:put(p[1], p[2], TWINE[p[3]], ttok) end
c:put(18, 17, TWINE[1], ttok) c:put(18, 18, TWINE[1], ttok)                                       -- knot

A.save(c, NAME)
