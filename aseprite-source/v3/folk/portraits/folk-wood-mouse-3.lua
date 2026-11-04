-- folk-wood-mouse-3 portrait (folk F1_2) variant: 3
local VAR = 3
local NAME = "folk-wood-mouse-3"
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local out = app.params.out or (DIR .. "/")
local function R(h, b, s, d) return { hi = h, base = b, shade = s, deep = d } end
local INK = "#2b1c26"
local PINK = R("#f8c0b0", "#e8968e", "#b86a78", "#7e4a62")
local BELLY = R("#fbeed2", "#ecd6b0", "#c8a890", "#94788a")
local FUR = ({ R("#e0a060", "#b8743c", "#8a4f34", "#5e3434"), R("#d8b88a", "#a88a68", "#7a6058", "#4f3e4a"), R("#f0a868", "#c86a3a", "#93453a", "#633040") })[VAR]
local GREEN = R("#a8d468", "#6aa848", "#3f7a4a", "#2c4f48")
local STRAW = R("#f8e09a", "#e0b860", "#b08848", "#7a5a44")
local TEAL = R("#7fd6c8", "#3aa8a0", "#2a7480", "#24485e")
local RUST = R("#d89a62", "#a86440", "#7a4038", "#4e2c3a")
local LEATH = R("#c8945a", "#946038", "#683e34", "#422a32")
local ROLL = R("#eed8b0", "#c8a878", "#967860", "#5e4a52")
local GLOW = R("#fff2a8", "#f8c848", "#d88a30", "#9a5430")
local METAL = R("#d0cad8", "#9a90a8", "#686078", "#443c54")
local PLUM = R("#c890c8", "#9a5a9a", "#6c3c78", "#46284e")
local APRON = R("#fff4dc", "#f0dcb8", "#c8b0a0", "#8a7888")
local RED = R("#ff9a7a", "#e05a48", "#a83a44", "#6e2a3e")
local WOOD = R("#e8c088", "#c08a54", "#8a5a40", "#5a3a38")
local DISC = ({ R("#d8f0b0", "#b8d88a", "#8ab474", "#5f8a62"), R("#b8eee4", "#8ccfc4", "#62a8a6", "#427e86"), R("#f0d0e8", "#d8a8d0", "#b080b0", "#845a8c") })[VAR]
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local CX = 39.5
local function P(m, r, o) c:part(m, r, o or { band = 1, nopop = true, inner = false }) return m end
if VAR == 2 then
  local roll = P(c:rrect(50, 60, 74, 71, 4), ROLL, { band = 2, pop = { x = 53, y = 62 } })
  for _, x in ipairs{ 57, 58, 67, 68 } do for y = 60, 71 do if roll:has(x, y) then c:put(x, y, TEAL.shade) end end end
end
local CL = VAR == 1 and FUR or VAR == 2 and RUST or PLUM
local body = c:ellipse(CX, 102, 30, 30):clip(c:rect(0, 70, 79, 99))
P(body, CL, { band = 3, pop = { x = 16, y = 84 } })
if VAR == 1 then
  P(c:ellipse(CX, 80, 9, 6), BELLY)
  P(c:rrect(27, 82, 52, 99, 3), GREEN, { band = 2, pop = { x = 28, y = 83 } })
  P(c:line({ { 29, 82 }, { 25, 71 } }, 3), GREEN) P(c:line({ { 50, 82 }, { 54, 71 } }, 3), GREEN)
  P(c:ellipse(29.5, 84, 1.5, 1.5), STRAW, { band = 1, pop = { x = 29, y = 83 }, inner = false })
  P(c:ellipse(49.5, 84, 1.5, 1.5), STRAW, { band = 1, pop = { x = 49, y = 83 }, inner = false })
  P(c:rrect(34, 88, 45, 95, 2), GREEN, { band = 1, nopop = true })
  c:stitch{ { 35, 89 }, { 44, 89 } }
elseif VAR == 2 then
  P(c:line({ { 25, 71 }, { 21, 99 } }, 4), LEATH) P(c:line({ { 54, 71 }, { 58, 99 } }, 4), LEATH)
  P(c:rrect(20, 82, 25, 86, 1), METAL, { band = 1, pop = { x = 21, y = 83 }, inner = false })
  P(c:ellipse(CX, 72, 18, 5), TEAL, { band = 2, pop = { x = 26, y = 70 } })
  P(c:rrect(43, 74, 50, 92, 2), TEAL, { band = 2, nopop = true })
  for _, y in ipairs{ 79, 80, 86, 87 } do for x = 44, 49 do c:put(x, y, TEAL.deep) end end
  for x = 43, 50, 2 do c:put(x, 93, TEAL.shade) end
else
  P(c:rrect(27, 79, 52, 99, 3), APRON, { band = 2, pop = { x = 28, y = 80 } })
  P(c:line({ { 30, 80 }, { 31, 71 } }, 2), APRON) P(c:line({ { 49, 80 }, { 48, 71 } }, 2), APRON)
  P(c:rrect(33, 88, 46, 95, 2), APRON, { band = 1, nopop = true })
  c:stitch{ { 34, 89 }, { 45, 89 } }
  P(c:line({ { 62, 99 }, { 66, 63 } }, 3), WOOD)
  P(c:ellipse(67, 58, 5.5, 4.5), WOOD, { band = 2, pop = { x = 64, y = 55 } })
  P(c:ellipse(67, 57, 3.5, 2), WOOD, { band = 1, nopop = true, inner = false })
  for x = 65, 69 do c:put(x, 57, WOOD.deep) end
  P(c:ellipse(62.5, 88, 3.5, 3), FUR, { band = 1, pop = { x = 61, y = 86 }, inner = false })
end
-- big round ears behind the head
for _, e in ipairs{ { 19, 20 }, { 60, 59 } } do
  P(c:ellipse(e[1], 28, 10, 10), FUR, { band = 2, pop = { x = e[1] - 6, y = 21 } })
  P(c:ellipse(e[2], 29, 6.5, 7), PINK, { band = 2, pop = { x = e[2] - 3, y = 24 } })
end
local head = c:ellipse(CX, 48, 20.5, 17)
head:add(c:ellipse(19.5, 56, 2.5, 2.5)):add(c:ellipse(59.5, 56, 2.5, 2.5))
P(head, FUR, { band = 3, pop = { x = 27, y = 36 } })
P(c:ellipse(CX, 58, 10, 6.5), BELLY, { band = 1, pop = { x = 33, y = 54 }, inner = false })
P(c:ellipse(CX, 53, 3, 2), PINK, { band = 1, pop = { x = 38, y = 52 }, inner = false })
c:put(39, 56, INK) c:put(40, 56, INK)
for _, q in ipairs{ { 36, 58 }, { 37, 59 }, { 38, 59 }, { 39, 58 }, { 40, 58 }, { 41, 59 }, { 42, 59 }, { 43, 58 } } do c:put(q[1], q[2], INK) end
c:put(39, 57, PINK.deep) c:put(40, 57, PINK.deep)
for _, q in ipairs{ { 33, 57 }, { 32, 59 }, { 34, 60 }, { 46, 57 }, { 47, 59 }, { 45, 60 } } do c:put(q[1], q[2], FUR.shade) end
for _, x in ipairs{ 22, 55 } do for dx = 0, 2 do c:put(x + dx, 55, PINK.base) c:put(x + dx, 56, PINK.base) end end
c:put(22, 55, PINK.hi) c:put(55, 55, PINK.hi)
for _, e in ipairs{ { 29.5, 46.5 }, { 50, 46.5 } } do P(c:ellipse(e[1], e[2], 4.5, 4.5), FUR, { band = 1, nopop = true, inner = false }) end
for _, e in ipairs{ { 29.5, 46.5 }, { 50, 46.5 } } do c:ellipse(e[1], e[2], 4.5, 4.5):each(function(x, y) c:put(x, y, FUR.deep) end) end
c:eyeLocked(27, 44) c:eyeLocked(48, 44)
if VAR == 1 then
  local hm = c:ellipse(CX, 33, 25, 5.5):add(c:rrect(28, 18, 51, 33, 6))
  P(hm, STRAW, { band = 2, pop = { x = 30, y = 20 } })
  for _, y in ipairs{ 22, 26 } do for x = 29, 50 do if (x + y) % 2 == 0 then c:put(x, y, STRAW.shade) end end end
  for x = 15, 64 do if x % 3 == 0 and hm:has(x, 36) then c:put(x, 36, STRAW.shade) end end
  P(c:rect(28, 29, 51, 31), GREEN, { band = 1, nopop = true })
  P(c:line({ { 46, 30 }, { 49, 22 } }, 1), GREEN)
  for _, l in ipairs{ { 47, 25 }, { 51, 23 }, { 48, 20 } } do P(c:ellipse(l[1], l[2], 2, 1.5), GREEN, { band = 1, pop = { x = l[1] - 1, y = l[2] - 1 }, inner = false }) end
  P(c:poly{ { 11, 82 }, { 20, 82 }, { 15.5, 68 } }, METAL, { band = 1, pop = { x = 14, y = 74 } })
  P(c:rrect(13, 83, 17, 96, 1), WOOD, { band = 1, nopop = true })
  P(c:ellipse(15.5, 88, 3.5, 3), FUR, { band = 1, pop = { x = 14, y = 86 }, inner = false })
elseif VAR == 2 then
  c:put(22, 75, METAL.shade) c:put(21, 76, METAL.shade)
  P(c:poly{ { 13, 80 }, { 23, 80 }, { 18, 76 } }, METAL)
  P(c:rect(13, 81, 23, 91), GLOW, { band = 2, pop = { x = 15, y = 82 } })
  for y = 81, 91 do c:put(13, y, METAL.base) c:put(23, y, METAL.shade) c:put(18, y, METAL.shade) end
  P(c:ellipse(16, 87, 1, 2), GLOW.hi and R(GLOW.hi, GLOW.hi, GLOW.base, GLOW.shade))
  P(c:rect(12, 92, 24, 94), METAL)
else
  local k = c:ellipse(CX, 48, 21.5, 18):clip(c:rect(0, 0, 79, 37))
  P(k, RED, { band = 2, pop = { x = 26, y = 33 } })
  for x = 19, 60 do if k:has(x, 37) then c:put(x, 37, RED.deep) end end
  P(c:ellipse(61, 34, 3, 2.5), RED, { band = 1, pop = { x = 60, y = 33 }, inner = false })
  P(c:poly{ { 62, 33 }, { 71, 27 }, { 69, 34 } }, RED) P(c:poly{ { 62, 35 }, { 70, 38 }, { 66, 41 } }, RED)
  for _, q in ipairs{ { 28, 34 }, { 33, 32 }, { 38, 34 }, { 44, 32 }, { 50, 34 }, { 55, 35 }, { 36, 31 }, { 25, 36 } } do if k:has(q[1], q[2]) then c:put(q[1], q[2], APRON.hi) end end
end
c:finish{ outline = true }
for _, w in ipairs{ { { 22, 57 }, { 9, 53 } }, { { 22, 59 }, { 10, 62 } }, { { 57, 57 }, { 70, 53 } }, { { 57, 59 }, { 69, 62 } } } do
  c:line(w, 1):each(function(x, y) if not c:get(x, y) then c:put(x, y, FUR.deep, "wh") end end)
end
local disc = c:ellipse(39.5, 44.5, 30.5, 30.5)
disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and DISC.base or DISC.shade, "bg") end end)
disc:grow(1):cut(disc):each(function(x, y) if not c:get(x, y) then c:put(x, y, DISC.deep, "bg") end end)
HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " ok")
