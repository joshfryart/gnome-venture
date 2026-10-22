local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local potR  = GV.ramp("#f4f0e0")
local lidR  = GV.ramp("#f08a24")
local knobR = GV.ramp("#d6322b")
local footR = GV.ramp("#dcb06a")

local body = c:ellipse(32, 36, 17, 14)
local foot = c:rrect(23, 46, 41, 52, 2)
local band = c:rect(14, 26, 50, 27):clip(body)
local lid  = c:rrect(17, 16, 47, 23, 3)
local knob = c:ellipse(32, 13, 3, 2.5)
local leaf = c:ellipse(32, 40, 6.5, 6.5)
leaf:add(c:poly({ {26, 39}, {32, 29}, {39, 39} }))

c:build{
  { "foot", foot, footR },
  { "body", body, potR, { gloss = { 20, 30 } } },
  { "band", band, lidR, { flat = true } },
  { "leaf", leaf, "moss", { gloss = { 29, 36 } } },
  { "lid",  lid,  lidR },
  { "knob", knob, knobR, { gloss = false } },
}

-- leaf veins
local v = "#2e5a2c"
c:fill(c:line({ {32, 32}, {32, 46} }, 1), v)
c:fill(c:line({ {32, 38}, {29, 35} }, 1), v)
c:fill(c:line({ {32, 42}, {35, 39} }, 1), v)

-- lid join seam
c:seam({ {18, 23}, {46, 23} })
c:px(31, 12, knobR.gloss)

local t = c:save(D .. "img-redraw-full/aseprite/ph/broccoflower-seed.aseprite",
                 D .. "img-redraw-full/png/ph/broccoflower-seed.png")
print(GV.report(t))
