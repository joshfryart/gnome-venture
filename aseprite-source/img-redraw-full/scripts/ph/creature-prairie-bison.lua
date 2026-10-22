local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local dark  = GV.ramp("#44281c")
local brown = GV.ramp("#8c4a1a")
local tan   = GV.ramp("#a5663a")
local horn  = GV.ramp("#f8eed2")

-- tail with tuft
local tail = c:line({ {46, 45}, {50, 43}, {52, 40} }, 3)
local tuft = c:ellipse(52.5, 37.5, 2.5, 3)

-- body + belly
local body = c:ellipse(31.5, 43, 18, 10)
local belly = c:ellipse(31.5, 47, 10, 5)

-- feet (front hooves)
local feetL = c:rrect(17, 48, 24, 55, 2)
local feetR = c:rrect(39, 48, 46, 55, 2)

-- mane: ring of shaggy blobs around the head
local hx, hy = 31.5, 26
local mane = c:mask()
for i = 0, 11 do
  local a = i * math.pi / 6 + math.pi / 12
  mane:add(c:ellipse(hx + math.cos(a) * 12, hy + math.sin(a) * 11.5, 4.5, 4.5))
end
mane:add(c:ellipse(hx, hy, 13, 12))

-- horns: upturned cream hooks
local hornL = c:poly({ {23, 14}, {18, 13}, {15, 10}, {14, 7}, {16, 7}, {18, 9}, {21, 10}, {24, 11} })
local hornR = c:poly({ {41, 14}, {46, 13}, {49, 10}, {50, 7}, {48, 7}, {46, 9}, {43, 10}, {40, 11} })

-- ears poking out sideways
local earL = c:ellipse(12.5, 25, 3, 2.5)
local earR = c:ellipse(50.5, 25, 3, 2.5)

local head = c:ellipse(hx, hy + 1, 11, 10.5)
local muzzle = c:ellipse(31.5, 32, 7, 4.5)

local p = c:build{
  { "tail",  tail,  dark, { flat = true } },
  { "tuft",  tuft,  dark },
  { "body",  body,  brown, { stitch = { side = "lit" } } },
  { "belly", belly, tan, { gloss = false } },
  { "feetL", feetL, dark, { gloss = false } },
  { "feetR", feetR, dark, { gloss = false } },
  { "mane",  mane,  dark },
  { "hornL", hornL, horn, { flat = true } },
  { "hornR", hornR, horn, { flat = true } },
  { "earL",  earL,  brown, { gloss = false } },
  { "earR",  earR,  brown, { gloss = false } },
  { "head",  head,  brown },
  { "muzzle", muzzle, tan, { gloss = false } },
}

-- inner ears
c:px(12, 25, tan.base); c:px(13, 25, tan.base)
c:px(50, 25, tan.base); c:px(51, 25, tan.base)

-- nose
c:paint({ ".nnnnnn.", "nnnnnnnn", ".n.nn.n." }, 28, 28, { n = "#2a1a10" })
-- mouth
c:paint({ "m.....m", ".mmmmm." }, 28, 33, { m = "#4a2c1a" })

-- shaggy brow tuft
c:paint({ ".d.d.d.", "ddddddd" }, 28, 16, { d = dark.base })

c:eye(22, 20); c:eye(37, 20)

c:ground(31.5, 55, 16, 1.5)
local t = c:save(O .. "aseprite/ph/creature-prairie-bison.aseprite", O .. "png/ph/creature-prairie-bison.png")
print(GV.report(t))
