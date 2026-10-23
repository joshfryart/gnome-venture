-- creature-blight-mother: trek boss (lv 19). A swollen grey aphid queen, glistening,
-- with a thorn crown, dripping cornicle horns and blighted young spilling from her rear.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local grey  = GV.R.stone                 -- swollen abdomen (stone family)
local slate = GV.ramp("#5b6470")         -- dark head (stone dark base)
local young = GV.ramp("#8f9c7a")         -- blighted young: sickly grey-green (moss/stone borrow)
local ooze  = "#4f5a3a"                  -- blight markings

-- legs (behind everything)
c:limb({ {13, 45}, {10, 50}, {9, 53} })
c:limb({ {22, 46}, {22, 53} })
c:limb({ {31, 43}, {33, 50} })

-- cornicle horns (aphid siphunculi) rising off the back
local horn1 = c:line({ {42, 20}, {45, 13}, {46, 9} }, 3)
local horn2 = c:line({ {50, 24}, {53, 18}, {54, 15} }, 3)

-- swollen abdomen
local abd = c:ellipse(38.5, 31, 17.5, 15)

-- head with antennae and crown
local head = c:ellipse(20.5, 37, 12, 10.5)
local antL = c:line({ {12, 30}, {9, 23}, {9, 20} }, 2):add(c:rect(7, 16, 10, 19))
local antR = c:line({ {27, 29}, {31, 21}, {32, 18} }, 2):add(c:rect(31, 14, 34, 17))
local crown = c:poly({ {10, 31}, {10, 20}, {14, 25}, {17, 18}, {20.5, 24}, {24, 18}, {27, 25}, {31, 20}, {31, 31} })

local p = c:build{
  { "horn1", horn1, grey,  { flat = true } },
  { "horn2", horn2, grey,  { flat = true } },
  { "abd",   abd,   grey,  { stitch = { side = "lit" } } },
  { "antL",  antL,  grey,  { flat = true } },
  { "antR",  antR,  grey,  { flat = true } },
  { "crown", crown, "gold" },
  { "head",  head,  slate },
}

-- horn tips ooze blight
c:fill(c:rect(45, 8, 47, 9), ooze)
c:fill(c:rect(53, 14, 55, 15), ooze)

-- blight markings on the abdomen (diamonds and beans)
local dia  = { "..d..", ".ddd.", "ddddd", ".ddd.", "..d.." }
local bean = { ".dd.", "dddd", ".dd." }
local gl = "#7a8a52"
c:spot(c:ascii(dia, 40, 22), ooze, gl)
c:spot(c:ascii(bean, 47, 30), ooze, gl)
c:spot(c:ascii(dia, 39, 34), ooze, gl)
-- wet glisten: 1 px glints on the lit side of the swollen back
for _, q in ipairs({ {27, 24}, {29, 21}, {44, 18} }) do c:px(q[1], q[2], grey.gloss) end

-- segment seam across the swollen back, button at its head
c:button(34, 18)
c:seam({ {36, 23}, {37, 31}, {37, 39} })

-- blighted young spilling from the rear
local yb = {
  { 51.5, 45, 5, 4.5 },
  { 41.5, 51, 5.5, 4.5 },
}
for _, b in ipairs(yb) do
  c:part(c:ellipse(b[1], b[2], b[3], b[4]), young, {})
end
c:eye(47, 44, true); c:eye(52, 44, true)
c:eye(37, 50, true); c:eye(42, 50, true)
c:spot(c:ascii({ ".d", "dd" }, 50, 41), ooze, gl)   -- each young already carries the blight
c:spot(c:ascii({ ".d", "dd" }, 40, 47), ooze, gl)

-- face: locked eyes set wide, grim mouth
c:eye(12, 35); c:eye(23, 35)
c:paint({ "bb.......bb", "..b.....b.." }, 11, 32, { b = "#2a1a10" })
c:paint({ "mmmmm", "m...m" }, 17, 43, { m = "#2a1a10" })

local t = c:save(D .. "final/aseprite/ph/creature-blight-mother.aseprite", PNG .. "creature-blight-mother.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
