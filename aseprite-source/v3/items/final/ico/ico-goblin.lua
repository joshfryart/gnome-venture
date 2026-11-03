-- ico-goblin (final, Opus). Front view head: wide-jawed round face, two long swept-back pointed ears, a long
-- hooked nose, slanted yellow eyes under a heavy brow, a sly lopsided grin with two lower tusks, three spiky
-- hair tufts. Light per pixel (6-tone green skin, cool-violet shade).
-- Material: pinkish inner ear with a cartilage vein, skin wart with its own glint, specular on the brow and the
-- nose tip, dark nostril row + cast shadow of the nose, AO where ears tuck behind the head, ivory tusks with a
-- lit edge and a root shadow.
-- quirk: the left tusk is chipped (jagged top, a step shorter).
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA5_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt = math.floor, math.abs, math.max, math.min, math.sqrt
local c = A.new("ico-goblin")
local SKIN = { "#1d3a36", "#2c5940", "#3d7a44", "#5a9c47", "#85bd54", "#b9dd7c" }
local EAR  = { "#5a2e44", "#8a4656", "#b86a6c", "#d8907c" }
local HAIR = { "#1f1830", "#35294f", "#4f3d72", "#6c5a94" }
local TUSK = { "#6e5a52", "#b8a48a", "#e6d8b6", "#fff4d6" }
local EYE  = { "#b8761c", "#f5c838", "#ffe890" }
local stok = { r = { name = "skin" } }

-- ears (behind the head)
local function ear(side)
  local cx = 32
  local function mx(x) return cx + (x - cx) * side end
  local m, n, T, S = A.blade(mx(23), 29, mx(15), 22, mx(9), 12, function(t) return 4.8 * (1 - t) ^ 0.85 + 0.25 end, { fold = 0.35 })
  local idx = A.shade(c, m, n, SKIN, { tok = stok, amb = 0.12, wrap = 0.35 })
  -- inner ear: pink hollow along the middle, cartilage vein down it
  m:each(function(x, y) local k = K(x, y)
    local s = S[k] * side
    if T[k] > 0.08 and T[k] < 0.78 and s > -0.15 and s < 0.6 then
      c:put(x, y, (T[k] < 0.25 or s > 0.4) and EAR[1] or EAR[2], stok)
    end
  end)
  m:each(function(x, y) local k = K(x, y)
    local s = S[k] * side
    if T[k] > 0.15 and T[k] < 0.65 and abs(s - 0.15) < 0.12 then c:put(x, y, EAR[3], stok) end
  end)
  return m, idx
end
local eL, iL = ear(1)
local eR, iR = ear(-1)

-- hair tufts behind the crown
local hairM = c:poly{ { 25, 21 }, { 23, 12 }, { 28, 17 }, { 31, 9 }, { 34, 17 }, { 40, 13 }, { 39, 21 } }
local hn = X.pillow(hairM, 1.6)
local hidx = A.shade(c, hairM, hn, HAIR, { tok = { r = { name = "hair" } }, amb = 0.12, wrap = 0.35, cuts = { 0.3, 0.55, 0.78 } })

-- head: round skull + wide jaw
local head = A.ellM(32, 28.5, 10.6, 9.6)
head:add(A.ellM(32, 35.5, 12, 8.2))
local hnrm = X.sphere(30.8, 31, 13.6, head)
local hb = {}
local hdx = A.shade(c, head, hnrm, SKIN, { tok = stok, bias = hb, amb = 0.16, wrap = 0.42 })
-- AO on the ears right where they tuck behind the head
A.aoRing(c, iL, SKIN, eL, head, -2, stok) A.aoRing(c, iR, SKIN, eR, head, -2, stok)
-- AO on the hair where it meets the scalp
local ring = head:grow(1):cut(head)
ring:each(function(x, y) if hairM:has(x, y) then c:put(x, y, HAIR[1]) end end)
-- scalp line under the tufts: one dark row
for x = 27, 37 do local y = 21 while not head:has(x, y) and y < 26 do y = y + 1 end A.step(c, hdx, SKIN, x, y, -1, stok) end

-- heavy brow: dark furrow under a lit ridge, angled down toward the nose (sly)
local brow = { { 23, 25 }, { 24, 25 }, { 25, 25 }, { 26, 26 }, { 27, 26 }, { 28, 27 }, { 29, 27 },
               { 35, 27 }, { 36, 27 }, { 37, 26 }, { 38, 26 }, { 39, 25 }, { 40, 25 }, { 41, 25 } }
for _, p in ipairs(brow) do
  c:put(p[1], p[2], SKIN[1], stok) c:put(p[1], p[2] + 1, SKIN[2], stok)
  A.step(c, hdx, SKIN, p[1], p[2] - 1, 1, stok)
end
-- eyes: yellow almond, ink pill pupil + glint (looking a touch to the side)
local eyeRows = { ".yyyy", "yYYYy", ".yyy." }
for _, ex in ipairs{ 23, 36 } do
  A.map(c, { ".hhh.", "hEEEe", ".eee." }, ex, 27, { h = EYE[3], E = EYE[2], e = EYE[1] })
  local px = ex + 2
  c:put(px, 27, A.INK) c:put(px + 1, 27, A.INK) c:put(px, 28, A.INK) c:put(px + 1, 28, A.INK) c:put(px, 29, A.INK) c:put(px + 1, 29, A.INK)
  c:put(px, 27, A.CREAM)
end

-- nose: long and hooked, droops over the lip
local nose, nn = A.oval(32.5, 32.2, 2.4, 4.6, 0.12)
nose:add(A.ellM(33.2, 36, 2.9, 1.8))
nn = X.sphere(32.0, 33, 5.4, nose)
local ndx = A.shade(c, nose, nn, SKIN, { tok = stok, amb = 0.14, wrap = 0.35, bias = (function() local b = {} nose:each(function(x, y) b[K(x, y)] = 1 end) return b end)() })
-- cast shadow of the nose on the face (lower-right) + dark nostril row
local nring = nose:grow(1):cut(nose)
nring:each(function(x, y) if head:has(x, y) then c:put(x, y, x >= 33 and SKIN[1] or SKIN[2], stok) end end)
nose:shift(2, 1):each(function(x, y) if head:has(x, y) and not nose:has(x, y) and not nring:has(x, y) then A.step(c, hdx, SKIN, x, y, -1, stok) end end)
c:put(31, 37, SKIN[1], stok) c:put(35, 37, SKIN[1], stok) c:put(32, 37, SKIN[2], stok) c:put(34, 37, SKIN[2], stok)
c:put(31, 30, A.CREAM) c:put(31, 31, SKIN[6], stok) c:put(32, 35, SKIN[6], stok)

-- grin: lopsided (higher on the right), dark mouth with a tongue glimpse
local mouth = HP.mask()
for x = 24, 40 do
  local u = (x - 32) / 8
  local y = floor(40.6 - 1.2 * (1 - u * u) + (x > 32 and -0.7 * u or 0))   -- smile curve, right corner raised
  mouth:set(x, y)
  if x > 25 and x < 39 then mouth:set(x, y - 1) end
  if x > 27 and x < 37 then mouth:set(x, y + 1) end
end
mouth:each(function(x, y) c:put(x, y, "#3a1a2c") end)
for _, x in ipairs{ 30, 31, 32, 33 } do local y = 40 while mouth:has(x, y + 1) do y = y + 1 end c:put(x, y, "#a4446a") end
-- lower lip lit, cheek dimples
mouth:each(function(x, y) if head:has(x, y + 1) and not mouth:has(x, y + 1) then A.step(c, hdx, SKIN, x, y + 1, 1, stok) end end)
c:put(23, 38, SKIN[2], stok) c:put(41, 37, SKIN[2], stok)

-- tusks rising from the lower jaw over the lip; left one chipped (quirk)
local function tusk(x, ytop, chipped)
  local rows = chipped and { "..h", "s.m", "shm", "smd", "dmd" } or { ".h.", "shh", "shm", "shm", "smd", "dmd" }
  local y0 = 43 - #rows
  A.map(c, rows, x, y0, { s = TUSK[4], h = TUSK[3], m = TUSK[2], d = TUSK[1] })
end
tusk(26, 0, true)
tusk(36, 0, false)
c:put(27, 38, TUSK[1])  -- chip notch

-- wart on the right cheek, with its own glint
A.map(c, { ".w.", "wWv", ".v." }, 40, 32, { w = SKIN[5], W = SKIN[4], v = SKIN[3] })
c:put(40, 32, SKIN[6], stok)
-- forehead specular
c:put(27, 20, SKIN[6], stok) c:put(28, 20, SKIN[6], stok)

A.save(c, "ico-goblin")
