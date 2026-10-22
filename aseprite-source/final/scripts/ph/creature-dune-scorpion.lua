local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- legs (behind body)
c:limb({ {17, 49}, {13, 52}, {12, 55} })
c:limb({ {21, 51}, {19, 55} })
c:limb({ {29, 51}, {31, 55} })
c:limb({ {32, 49}, {36, 52}, {37, 55} })

local claw = {
  ".##....##.",
  "###...###.",
  "####.####.",
  "#########.",
  "##########",
  "##########",
  ".########.",
  "..######..",
}
local clawR = {}
for i, r in ipairs(claw) do clawR[i] = r:reverse() end

local p = c:build{
  { "sting", c:poly({ {32, 15}, {38, 10}, {42, 12}, {41, 17}, {36, 17} }), "dusk" },
  { "t6", c:ellipse(43, 16, 3.5, 3), "gold" },
  { "t5", c:ellipse(47, 22, 3.5, 3.5), "gold" },
  { "t4", c:ellipse(49, 30, 4, 4), "gold" },
  { "t3", c:ellipse(48, 38, 4, 4), "gold" },
  { "t2", c:ellipse(43, 45, 4.5, 4), "gold" },
  { "body", c:ellipse(25, 45, 11, 7.5), "gold" },
  { "armL", c:line({ {18, 40}, {14, 31} }, 3), "gold", { flat = true } },
  { "armR", c:line({ {31, 39}, {33, 30} }, 3), "gold", { flat = true } },
  { "clawL", c:ascii(claw, 9, 22), "gold" },
  { "clawR", c:ascii(clawR, 28, 22), "gold" },
  { "head", c:ellipse(24.5, 39, 7, 6.5), "gold" },
}
c:eye(20, 37, true); c:eye(26, 37, true)
c:paint({ "u..u", ".uu." }, 23, 42, { u = "umber" })
c:ground(25, 55, 15, 1.5)
local t = c:save(D .. "test100/aseprite/ph/creature-dune-scorpion.aseprite",
                 D .. "test100/png/ph/creature-dune-scorpion.png")
print(GV.report(t))
