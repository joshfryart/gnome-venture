-- Stag Beetle Patrol: Captain Bracken's old watch, sick with blight, still walking its beat.
-- Big antler mandibles, dented watch helm, frayed gold-stitched sash, grey-green blight on the shell.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local SHELL  = GV.ramp("#7a4a1f")                     -- soil family, chestnut wing cases
local HEAD   = GV.ramp("#3e2f66", { rim = "#7b66b4" }) -- dusk dark head
local JAW    = GV.ramp("#a8582f")                     -- wood bounce, mahogany antlers
local HELM   = GV.ramp("#8b8f96")                     -- stone, tin watch helm
local SASH   = GV.ramp("#b8452f")                     -- faded red sash
local BLIGHT = GV.ramp("#8f9a72")                     -- stone x moss, sickly grey-green

local function mir(pts) local r = {} for i, p in ipairs(pts) do r[i] = { 63 - p[1], p[2] } end return r end

-- legs (behind body), three bent pairs, front pair braced outward
local legs = { { {21,38}, {15,36}, {11,40} }, { {19,44}, {13,46}, {11,51} }, { {22,49}, {18,52}, {16,55} } }
for _, L in ipairs(legs) do c:limb(L); c:limb(mir(L)) end

-- antler mandibles: solid crescents curling inward, a low tooth on the inner edge
local jawL = c:ellipse(21, 17, 8.5, 10):cut(c:ellipse(27.5, 14, 7.5, 9)):cut(c:rect(0, 26, 63, 63))
jawL:add(c:poly({ {19,17}, {24,19}, {19,21} }))   -- tooth
local jawR = c:mask()
jawL:each(function(x, y) jawR:set(63 - x, y) end)

local body = c:ellipse(31.5, 43, 13.5, 10)
local head = c:ellipse(31.5, 27, 11, 8)
local helm = c:ellipse(31.5, 22, 9, 5.5):cut(c:rect(0, 23, 63, 63))
helm:add(c:rrect(20, 20, 43, 24, 2))
helm:cut(c:poly({ {35,16}, {40,16}, {37,20} }))          -- the dent

-- tattered sash end hanging below the right hip, notched tip
local tail = c:poly({ {37,49}, {42,47}, {44,56}, {42,54}, {40,57}, {39,52} })

local p = c:build{
  { "jawL", jawL, JAW, { gloss = { 14, 10 } } },
  { "jawR", jawR, JAW, { gloss = { 41, 9 } } },
  { "body", body, SHELL },
  { "tail", tail, SASH, { flat = true } },
  { "head", head, HEAD, { gloss = false } },
  { "helm", helm, HELM, { gloss = { 25, 18 } } },
}

-- wing split down the back
c:fill(c:rect(31, 36, 32, 52):clip(p.body.m:shrink(1)), SHELL.deep)

-- blight: bean/diamond patches on the shell and one on a mandible
c:spot(c:ellipse(23, 42, 2.5, 2), BLIGHT.base, BLIGHT.gloss)
c:spot(c:ellipse(40, 39, 2, 1.5), BLIGHT.base, BLIGHT.gloss)
c:spot(c:ascii({ ".b.", "bbb", ".b." }, 25, 47), BLIGHT.shade, BLIGHT.base)
c:spot(c:ellipse(49, 12, 1, 1.5), BLIGHT.base, BLIGHT.gloss)

-- sash across the shell: shoulder to hip, with a gold seam and a button pin
local sash = c:line({ {20,36}, {41,49} }, 5):clip(p.body.m:shrink(1))
sash:cut(c:ascii({ "x..x" }, 34, 47)):cut(c:ascii({ "x" }, 27, 40))   -- frayed nicks
c:part(sash, SASH, { flat = true, contact = false })
c:seam({ {22, 38}, {40, 49} })
c:button(19, 35)

-- face
c:eye(22, 25); c:eye(37, 25)
c:paint({ ".uuuu.", "u....u" }, 29, 31, { u = "umber" })

c:ground(31.5, 55, 16, 1.5)
local t = c:save(D .. "final/aseprite/ph/creature-stag-beetle-patrol.aseprite", PNG .. "creature-stag-beetle-patrol.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
