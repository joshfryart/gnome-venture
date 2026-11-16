-- Koi Kin (br-koi-kin), yard sprite 64x64. Opus richness pass (c06/opus3), built on c06/opus2.
-- Common, seedkeeper. "Swims round the koi pond with a great many cousins, all orange."
-- An orange koi pal rising out of a round stone-rimmed pond to face us: cream kohaku patches, scale rows, a
-- dorsal fin, side fin, barbels and a round koi mouth, its tail flicking up out of the water behind.
-- Fixes the opus2 weakness (cousins were small dashes at 1x): four cousins are now bold 7x3 fish (lit back,
-- tail fork, dark eye, a shadow on the pond floor) in bright orange against the dark water, swimming round
-- the pond in one direction, one of them with a cream patch.
-- Richness: the rim is separate stones with dark seams and varied tones, light caustic dashes on the water,
-- lit scale crescents along the back, ray streaks in the fins.
-- quirk: one cousin has popped its head up beside the pal and is blowing a bubble.
-- Closer look: a lily pad with a pink lotus bud floats at the left of the pond.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("br-koi-kin-yard", 64)

local KOI  = { "#5a1c1a", "#8e2e1c", "#c4501e", "#ec7a2a", "#f8a44a", "#ffd08a" }
local CRM  = { "#c49a86", "#e6c8b0", "#f8e6d2", "#fff6ea" }
local FIN  = { "#8e2e1c", "#d0602a", "#f49a5a", "#ffc89a", "#ffe6cc" }
local STON = { "#3a3446", "#58526a", "#7c7890", "#a4a2b4", "#c8c8d2" }
local WAT  = { "#14364a", "#1c4e62", "#24687a", "#358a94", "#5aaeac", "#9cd6cc" }
local SUB  = { "#9a4a2a", "#c86a32" } -- cousins seen through water
local BNC  = "#3a7a8a"

-- pond: stone rim, then water
local rim = c:ellipse(32, 50, 29, 10)
local sI, sT = O.shade(c, rim, STON, { R = 2, amb = .28, wrap = .4, rim = true, cuts = { .25, .45, .65, .85 } })
-- separate stones: angular buckets round the ring, a dark seam between neighbours, each stone its own tone
local function stone(x, y)
  local a = math.atan((y - 50) / 10, (x - 32) / 29)
  return math.floor((a / (2 * math.pi) + .5) * 22 + O.H(math.floor(y / 3), 0, 9) * .4)
end
O.tex(c, sI, sT, STON, function(x, y, i)
  local b = stone(x, y)
  if b ~= stone(x + 1, y) or b ~= stone(x, y + 1) then return -2 end
  local h = O.H(b, 1, 4)
  if h > .66 then return 1 elseif h < .3 then return -1 end
end)
local water = c:ellipse(32, 50, 25.5, 7.5)
local wb = {} water:each(function(x, y) wb[K(x, y)] = -1 end)
local wI, wT = O.shade(c, water, WAT, { R = 4, amb = .3, wrap = .4, bias = wb, sep = STON[1] })
-- caustic light dashes on the water
O.tex(c, wI, wT, WAT, function(x, y, i) local q = (x * 5 + y * 13) % 29 if (q == 0 or q == 5) and y % 3 == 0 then return 2 end end)
-- closer look: a lily pad (notched) with a pink lotus bud at the left of the pond
O.pat(c, 8, 49, { ".aaa.", "abbba", "abb.a", ".aaa." }, { a = "#2c6a3a", b = "#5ea24c" }, "lilypad")
O.pat(c, 10, 47, { "pq", "pp" }, { p = "#e0708c", q = "#ffc2d0" }, "lotus")
-- cousins swimming round the pond: bold 7x3 fish (h hi back, b base, t tail, e eye, w cream patch)
local COUS = { a = "#f8b060", b = "#e0782e", t = "#b85a2a", e = "#3a1c20", w = "#f4dcc0" }
local function cousin(x, y, left, patch)
  local rows = { "t..aab.", "ttbbbbe", "t..bbb." }
  if patch then rows[1] = "t..awb." end
  if left then for j, r in ipairs(rows) do rows[j] = r:reverse() end end
  for j, r in ipairs(rows) do for i = 1, #r do
    local ch = r:sub(i, i)
    if COUS[ch] then c:put(x + i - 1, y + j - 1, COUS[ch]) end
  end end
  for i = 1, 6 do c:put(x + i - (left and 0 or 1), y + 3, WAT[1]) end -- shadow on the pond floor
end
cousin(15, 50, true) cousin(27, 53, true, true) cousin(39, 51, true) cousin(48, 54, true)
-- tail fan flicking up out of the water at the right
local tail = c:poly{ { 47, 41 }, { 53, 33 }, { 59, 25 }, { 57, 33 }, { 62, 32 }, { 54, 42 } }
local tb = {} tail:each(function(x, y) if (x - y) % 3 == 0 then tb[K(x, y)] = 1 end end)
O.shade(c, tail, FIN, { R = 2, amb = .3, wrap = .45, bias = tb, sep = FIN[1], cuts = { .25, .45, .65, .85 } })

-- dorsal fin along the back
local dor = c:poly{ { 22, 31 }, { 30, 25 }, { 40, 26 }, { 44, 33 } }
local db = {} dor:each(function(x, y) if x % 3 == 0 then db[K(x, y)] = -1 end end)
O.shade(c, dor, FIN, { R = 1, amb = .35, wrap = .45, bias = db, sep = FIN[1], cuts = { .25, .45, .65, .85 } })

-- body: swimming at the surface, head to the left turned to us, lower body under the waterline
local body = c:ellipse(30, 39, 18, 9)
body:add(c:ellipse(46, 40, 6, 4.5))
body:cut(c:rect(0, 46, 63, 63))
local bI, bT = O.shade(c, body, KOI, { sphere = { 24, 33, 20 }, amb = .26, wrap = .35, sep = KOI[1], rim = true, bounce = BNC, bmax = 2 })
-- scale rows: small arcs on the back half only
O.tex(c, bI, bT, KOI, function(x, y, i)
  if x < 33 or y > 44 then return 0 end
  local ox = (y // 2) % 2 * 2
  if (x + ox) % 4 == 0 and y % 2 == 0 and i >= 3 then return -1 end      -- scale edge
  if (x + ox) % 4 == 3 and y % 2 == 1 and i >= 3 and i <= 5 then return 1 end -- lit crescent above it
end)
-- cream kohaku patches
local patch = c:ellipse(39, 34, 5, 3)
patch:add(c:ellipse(28, 31, 3, 1.5))
patch:clip(body)
O.shade(c, patch, CRM, { sphere = { 36, 32, 8 }, amb = .4, wrap = .45, cuts = { .3, .55, .8 } })
-- side fin
O.shade(c, c:poly{ { 30, 42 }, { 25, 47 }, { 31, 46 }, { 34, 43 } }, FIN, { R = 1, amb = .35, wrap = .45, sep = FIN[1], cuts = { .25, .45, .65, .85 } })
O.mark(c, { { 29, 44 }, { 28, 45 }, { 31, 44 }, { 30, 45 } }, FIN[2]) -- fin rays
-- water line ripples where it breaks the surface
for _, p in ipairs({ { 11, 46 }, { 12, 46 }, { 13, 47 }, { 48, 46 }, { 49, 46 }, { 50, 47 }, { 20, 47 }, { 21, 47 }, { 38, 47 }, { 39, 47 } }) do
  c.pix[p[2] * c.w + p[1]] = WAT[6]
end

-- face on the head, turned to us
c:eyeLocked(14, 34)
c:eyeLocked(24, 34)
-- round koi mouth + barbels at the front
O.dots(c, { { 13, 41 }, { 14, 41 }, { 12, 42 }, { 15, 42 }, { 13, 43 }, { 14, 43 } }, P.ink)
O.dots(c, { { 13, 42 }, { 14, 42 } }, "#7a2a30")
O.dots(c, { { 11, 43 }, { 10, 44 }, { 16, 43 }, { 17, 44 } }, KOI[2])
c:cheek(19, 41) c:cheek(29, 40)

-- quirk: a cousin pops its head up, blowing a bubble
O.shade(c, c:ellipse(53, 47, 2.5, 2), KOI, { sphere = { 52, 46, 3 }, amb = .35, sep = KOI[1] })
O.dot(c, 52, 46, P.ink) O.mark(c, { { 52, 45 }, { 53, 45 } }, KOI[6])

O.shift(c, 0, -11)
O.done(c, "br-koi-kin-yard", function(c)
  for _, p in ipairs({ { 56, 32 }, { 57, 31 }, { 58, 32 }, { 57, 33 }, { 59, 28 } }) do
    if not c.pix[p[2] * c.w + p[1]] then c:put(p[1], p[2], WAT[6]) end
  end
end)
