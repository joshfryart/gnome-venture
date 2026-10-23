-- Guardian of Smokecap Caldera: a legendary fire salamander curled asleep in the
-- mouth of a basalt crater, a smoky toadstool cap for a crown with a little
-- mushroom cloud of smoke rising off it, glowing ember spots and underbelly,
-- tail draped over the crater lip.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local hide  = GV.ramp("#d6322b", { gloss = "#ff9158", dot = "#ffc27a", rim = "#f2793a" }) -- ember red
local lava  = GV.ramp("#f08a24")              -- ember orange pool
local puff  = GV.ramp("#c9c5bc")              -- pale stone smoke
local rock  = GV.ramp("#5b6470")              -- basalt crater

-- mushroom cloud of smoke rising off the cap (behind everything)
local wisp = c:line({ {44, 19}, {45, 15} }, 2)
wisp:add(c:ellipse(42, 11, 3, 2.5)):add(c:ellipse(49, 11, 3, 2.5)):add(c:ellipse(45.5, 9, 4, 3))

-- crater: squat volcano cone with a jagged rim, the sleeper nested in its mouth
local cone = c:poly({ {9, 45}, {10, 36}, {13, 41}, {16, 38}, {47, 39}, {50, 41}, {53, 34}, {55, 44},
                      {57, 55}, {6, 55} })

-- lava pool in the crater mouth
local pool = c:ellipse(32, 45, 20, 3.5)

-- dorsal flame spikes along the curled back
local spikes = c:mask()
local function spike(x, y) spikes:add(c:poly({ {x - 3, y + 4}, {x, y - 3}, {x + 3, y + 4} })) end
spike(16, 30); spike(22, 26); spike(29, 25)

-- curled body: round coiled back sitting in the pool
local body = c:ellipse(24.5, 37, 11, 8.5)

-- tail coiled round the front of the body, tip tucked under the chin
local tail = c:line({ {15, 37}, {13, 42} }, 5)
tail:add(c:line({ {13, 42}, {16, 45}, {24, 46} }, 4))
tail:add(c:line({ {24, 46}, {33, 46} }, 3))
-- glowing underbelly along the underside of the coil
local belly = tail:copy():cut(tail:shift(0, -2))

-- big flat salamander head resting on its tail tip, to the right
local head = c:ellipse(40.5, 35.5, 11, 6.5):add(c:rrect(44, 32, 52, 40, 4))

-- smokecap crown: dark toadstool dome on the head
local cap = c:ellipse(39.5, 26.5, 9, 6):cut(c:rect(0, 28, 63, 63))
cap:add(c:rrect(30, 25, 49, 29, 2))

-- front lip of the crater (over the pool's near edge)
local lip = c:poly({ {8, 49}, {14, 50}, {21, 49}, {29, 50}, {37, 49}, {45, 50}, {53, 49}, {56, 50}, {57, 55}, {6, 55} })

-- front paws hooked over the lip
local paws = c:rrect(34, 47, 39, 50, 1):add(c:rrect(44, 47, 49, 50, 1))

local p = c:build{
  { "wisp",   wisp,   puff,  { gloss = false, pale = true } },
  { "cone",   cone,   rock,  { gloss = false } },
  { "pool",   pool,   lava,  { gloss = false, contour = false } },
  { "spikes", spikes, "gold", { flat = true } },
  { "body",   body,   hide,  { gloss = { 17, 32 } } },
  { "tail",   tail,   hide,  { flat = true } },
  { "belly",  belly,  "gold", { flat = true, contour = false } },
  { "head",   head,   hide,  { gloss = { 33, 32 } } },
  { "cap",    cap,    "dusk", { gloss = { 34, 22 } } },
  { "lip",    lip,    rock,  { gloss = false, contour = false } },
  { "paws",   paws,   hide,  { flat = true } },
}

-- glowing ember beans on the back, head and tail
local mk, mg = "#e8a317", "#f5cf6a"
c:spot(c:ellipse(20.5, 34, 2, 1.5), mk, mg)
c:spot(c:ellipse(27.5, 31, 1.5, 1.5), mk, mg)
c:spot(c:ellipse(14.5, 38, 1.5, 1.5), mk, mg)
c:spot(c:ellipse(28.5, 38, 1.5, 1), mk, mg)
c:spot(c:ellipse(48, 33, 1.5, 1), mk, mg)

-- pale smoke spots on the cap
c:spot(c:ellipse(43, 23, 1.5, 1), "#c9c5bc", "#e9e3d6")
c:spot(c:ellipse(36, 23, 1, 1), "#c9c5bc", "#e9e3d6")

-- brim seam with a button at its head
c:seam({ {31, 28}, {48, 28} })
c:button(38, 26)

-- glowing lava cracks running down the crater
local glow = "#f5cf6a"
c:paint({ "g.", "g.", ".g", ".g" }, 21, 50, { g = glow })
c:paint({ ".g", ".g", "g.", "g." }, 29, 50, { g = glow })
c:paint({ "g.", ".g", ".g" }, 49, 50, { g = glow })
c:paint({ "g", "g", "g" }, 9, 41, { g = glow })
c:paint({ "g", "g", "g" }, 53, 40, { g = glow })

-- face: wide-set eyes, long salamander grin
c:eye(33, 32); c:eye(42, 32)
c:paint({ "m........m", ".mmmmmmmm." }, 35, 38, { m = "#6b1b2c" })

local t = c:save(D .. "final/aseprite/ph/creature-boss-lm-ca-4-lair-smokecap-caldera.aseprite",
                 PNG .. "creature-boss-lm-ca-4-lair-smokecap-caldera.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
