-- Clownfish Peek (pl-bjq-2), yard sprite 64x64. Opus second pass (c15/opus2), built on the Haiku idea.
-- Rootwarden, common, Reef of the Box-Jelly Queen. "A little striped fish that peeks out of the coral, then
-- hides again."
-- A round orange clownfish faces us, peeking up over a low ridge of lavender brain coral (maze grooves), its two
-- little pectoral fins hooked over the coral edge like hands on a wall. Cream stripes with ink borders wrap
-- behind its cheeks, an ink-tipped dorsal fin stands up. Two teal staghorn coral branches rise behind.
-- Haiku weakness fixed: a huge blobby pink mound with the fish a small side-view lump on top; now the fish is the
-- hero, the coral a slim ridge plus branches (clear reef silhouette).
-- quirk: it has only its eyes and fins over the edge, ready to duck back down (one bubble rising).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-bjq-2-yard", 64)

local FISH = { "#7a2418", "#b8401a", "#e8661e", "#ff8f2e", "#ffb45a", "#ffd890" }
local STR  = { "#b8a0a8", "#e4d6d0", "#fff4e6" }
local BRN  = { "#3c2a62", "#5a4490", "#8068c0", "#a690de", "#c8b6f0", "#e6dcfa" }
local STAG = { "#1f4a5a", "#2a6a78", "#3a9298", "#5fc4c8", "#94e0d8", "#c8f4e8" }

c:groundShadow(32, 56, 22, 2)

-- staghorn branches behind (left and right)
for _, br in ipairs({
  { { 15, 46 }, { 12, 36 }, { 9, 30 }, { 8, 24 }, 2.6 }, { { 14, 38 }, { 17, 32 }, { 18, 28 }, { 18, 23 }, 1.8 },
  { { 49, 46 }, { 52, 36 }, { 55, 30 }, { 56, 22 }, 2.6 }, { { 51, 37 }, { 48, 31 }, { 47, 28 }, { 47, 24 }, 1.8 },
}) do
  local m, n = O.tube({ br[1], br[2], br[3], br[4] }, function(t) return br[5] * (1 - t * .35) end)
  local I, Tk = O.shadeN(c, m, n, STAG, { amb = .3, wrap = .45, rim = true, sep = STAG[1] })
  O.tex(c, I, Tk, STAG, function(x, y, i) if H(x, y, 7) > .8 then return 1 end end) -- polyp dots
  O.mark(c, { { br[4][1], br[4][2] } }, STAG[6]) -- pale growing tip
end

-- dorsal fin
local dor = c:poly{ { 26, 17 }, { 30, 9 }, { 35, 8 }, { 38, 12 }, { 38, 17 } }
local dI, dT = O.shade(c, dor, FISH, { R = 2, amb = .35, wrap = .45, sep = FISH[1] })
O.tex(c, dI, dT, FISH, function(x, y, i) if (x - y) % 3 == 0 and y > 10 then return -1 end end) -- fin rays
-- head/body
local head = c:ellipse(32, 27, 14, 11)
local hI, hT = O.shade(c, head, FISH, { sphere = { 27, 21, 18 }, amb = .3, wrap = .45, rim = true, bounce = "#9a6ad0", bmax = 2 })
-- cream collar stripes behind the cheeks, with ink borders
head:each(function(x, y)
  local u = math.abs(x + .5 - 32) / 14
  local v = (y + .5 - 27) / 11
  local d = u / math.sqrt(math.max(.05, 1 - v * v))
  local p = y * c.w + x
  if d > .62 and d < .8 then
    c.pix[p] = (x < 32 and y < 26) and STR[3] or (y > 31 and STR[1] or STR[2])
  elseif (d >= .55 and d <= .62) or (d >= .8 and d <= .86) then
    c.pix[p] = P.ink
  end
end)
-- dorsal ink tip
O.mark(c, { { 31, 9 }, { 32, 8 }, { 33, 8 }, { 34, 8 }, { 35, 9 } }, P.ink)
-- glossy head glint
O.mark(c, { { 26, 19 }, { 27, 18 }, { 28, 18 } }, FISH[6])

-- face
c:eyeLocked(25, 23)
c:eyeLocked(34, 23)
c:cheek(24, 29) c:cheek(38, 29)
O.flat(c, c:rect(30, 30, 33, 31), P.ink, "mouth") O.dots(c, { { 31, 31 }, { 32, 31 } }, "#c94f84")

-- brain coral ridge in front, low and wide, maze grooves
local ridge = c:ellipse(32, 44, 21, 8)
ridge:add(c:rect(12, 44, 52, 51))
ridge:cut(c:rect(0, 52, 63, 63))
local bI, bT = O.shade(c, ridge, BRN, { R = 5, amb = .3, wrap = .45, rim = true, bounce = "#4a7aa0", bmax = 2, sep = BRN[1] })
O.tex(c, bI, bT, BRN, function(x, y, i)
  local w = math.sin(x * .55 + math.sin(y * .7) * 2.2) + math.sin(y * .9 + x * .12)
  if math.abs(w) < .28 then return -1 end
end)
O.mark(c, { { 20, 38 }, { 21, 37 }, { 22, 37 } }, BRN[6])
-- pectoral fins hooked over the coral edge
for _, f in ipairs({ { 18, 36, 1 }, { 46, 36, -1 } }) do
  local fx, fy, s = f[1], f[2], f[3]
  local fin = c:poly{ { fx - 3 * s, fy - 1 }, { fx + 3 * s, fy - 2 }, { fx + 4 * s, fy + 3 }, { fx, fy + 4 } }
  O.shade(c, fin, FISH, { R = 1, amb = .35, wrap = .45, sep = FISH[1] })
  O.mark(c, { { fx - 2 * s, fy }, { fx - 1 * s, fy + 2 } }, P.ink) -- ink fin edge marks
end

O.done(c, "pl-bjq-2-yard", function(c)
  local function put(x, y, h) if not c:get(x, y) then c:put(x, y, h) end end
  -- one bubble rising
  for _, p in ipairs({ { 44, 6 }, { 45, 6 }, { 43, 7 }, { 46, 7 }, { 43, 8 }, { 46, 8 }, { 44, 9 }, { 45, 9 } }) do put(p[1], p[2], "#b9e2f5") end
  put(44, 7, "#e4f6ff")
  for _, p in ipairs({ { 41, 12 }, { 42, 12 }, { 41, 13 }, { 42, 13 } }) do put(p[1], p[2], "#b9e2f5") end
end)
