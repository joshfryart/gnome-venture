-- ph/feast-isles-ackee-pot : cast-iron pot, tilted lid, ackee pods spilling, steam, wooden ladle
local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/"
local GV = dofile(D .. "gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local R = GV.R
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"

local iron   = GV.ramp("#4a4458")          -- cast iron (stone family, darkened)
local ironRm = GV.ramp("#5e5870")
local flesh  = GV.ramp("#f5cf6a")          -- ackee aril (gold family)
local steam  = GV.ramp("#e9e2d2")

-- rotated ellipse helper
local function rell(cx, cy, a, b, ux, uy)
  local m = c:mask()
  for y = 0, 63 do for x = 0, 63 do
    local dx, dy = x + 0.5 - cx, y + 0.5 - cy
    local p = dx * ux + dy * uy
    local q = -dx * uy + dy * ux
    if (p * p) / (a * a) + (q * q) / (b * b) <= 1 then m:set(x, y) end
  end end
  return m
end

-- shapes
local body = c:ellipse(31.5, 41, 17, 11):cut(c:rect(0, 0, 63, 32))
body:add(c:rect(17, 50, 20, 53)):add(c:rect(43, 50, 46, 53))           -- stubby feet
local lugs = c:rrect(11, 35, 15, 39, 1):add(c:rrect(48, 35, 52, 39, 1))
local rim  = c:rrect(13, 29, 50, 34, 3)
local food = c:ellipse(30, 30, 13, 5):cut(c:rect(0, 31, 63, 63))
local ladle = c:line({ {13, 10}, {16, 14}, {22, 26} }, 3)
local lid  = rell(43.5, 20.5, 12.5, 3.2, 0.55, -0.83)
local knob = c:rrect(36, 14, 39, 17, 1)
local pod1 = c:ellipse(18.5, 35, 4, 4.5)            -- spilling over the front rim
local pod2 = c:ellipse(24.5, 24, 4, 4)
local pod3 = c:ellipse(32.5, 23, 4, 4)

c:build{
  { "ladle", ladle, "wood", { gloss = false } },
  { "lugs",  lugs,  iron,   { gloss = false } },
  { "body",  body,  iron },
  { "rim",   rim,   ironRm, { gloss = { 16, 30 } } },
  { "food",  food,  flesh,  { gloss = false } },
  { "pod2",  pod2,  "red",  { gloss = false } },
  { "pod3",  pod3,  "red",  { gloss = false } },
  { "lid",   lid,   iron,   { gloss = { 46, 12 } } },
  { "knob",  knob,  iron,   { flat = true } },
  { "pod1",  pod1,  "red",  { gloss = false } },
}

-- steam curls (flat, pale)
c:part(c:line({ {27, 16}, {25, 13}, {27, 10}, {26, 7} }, 2), steam, { flat = true })
c:part(c:line({ {32, 16}, {34, 13}, {32, 10} }, 2), steam, { flat = true })

-- ackee lumps in the pot (yellow arils with black seeds)
local Y = { y = flesh.base, Y = flesh.gloss, s = flesh.shade, k = "#2a2030", g = "#8a8098" }
c:paint({ "kg..yy..kg", "kk.yYyy.kk", "yyyyyyyyys" }, 38, 27, Y)

-- split pods: open top shows arils and seeds
local open = { "kg.kg", "kkykk", "yYyys", ".yys." }
c:paint(open, 22, 21, Y)
c:paint(open, 30, 20, Y)
c:paint(open, 16, 32, Y)

-- iron rim seam & lid knob highlight
c:seam({ { 17, 31 }, { 47, 31 } })
c:px(37, 15, ironRm.gloss)
c:seam({ { 38, 27 }, { 49, 12 } })

c:ground(31.5, 53, 17, 1.5)
local t = c:save(O .. "aseprite/ph/feast-isles-ackee-pot.aseprite", O .. "png/ph/feast-isles-ackee-pot.png")
print(GV.report(t))
