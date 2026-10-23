-- Grey Wolf King (boss, mountain lair): a blue-grey wolf standing three-quarter on a ridge rock,
-- facing left, wind-swept spiky mane, red royal mantle with gold hem and clasp button, stitched
-- gold crown, stitched scar over the brow. Families: stone (fur), red (mantle), gold (crown).
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local FILE = "creature-boss-lm-ee-4-lair-lair-of-the-grey-wolf-king"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local function tilted(cx, cy, rx, ry, deg)
  local m = c:mask()
  local a = math.rad(deg)
  local ca, sa = math.cos(a), math.sin(a)
  for y = 0, 63 do for x = 0, 63 do
    local dx, dy = x - cx, y - cy
    local u = dx * ca + dy * sa
    local v = -dx * sa + dy * ca
    if (u * u) / (rx * rx) + (v * v) / (ry * ry) <= 1 then m:set(x, y) end
  end end
  return m
end

local fur   = GV.ramp("#7d8796")   -- stone family, cooled toward blue-grey
local furD  = GV.ramp("#5b6470")   -- stone dark (saddle, far legs)
local ruff  = GV.ramp("#c9c5bc")   -- stone pale (mane, muzzle, tail tip)
local rock  = GV.ramp("#8b8f96")   -- stone mid (ridge rock)

-- ridge rock the king stands on
local rockM = c:poly({ {7, 56}, {10, 50}, {18, 48}, {27, 49}, {33, 46}, {41, 48}, {49, 47}, {55, 51}, {57, 56} })

-- bushy tail raised behind, swept by the ridge wind
local tail = tilted(48, 30, 5.5, 11, 30)
local tuft = c:poly({ {51, 14}, {56, 12}, {55, 19} })
tail:add(tuft)
local tailTip = tilted(51, 21, 5.5, 6.5, 30):clip(tail):add(tuft)

-- legs: far pair dark, near pair fur
local legFB = c:rrect(42, 40, 47, 49, 2)
local legFF = c:rrect(21, 40, 26, 49, 2)
local legNB = c:rrect(36, 41, 42, 50, 2)
local legNF = c:rrect(13, 41, 19, 50, 2)

local body = c:ellipse(33, 38, 15, 9)

-- red royal mantle draped over the back, scalloped hem
local mantle = c:ellipse(38, 33, 11, 8):cut(c:rect(0, 36, 63, 63))
mantle:add(c:poly({ {27, 33}, {50, 33}, {49, 42}, {46, 39}, {42, 43}, {38, 39}, {34, 43}, {30, 39} }))

-- wind-swept spiky mane round the neck (tufts flare back and up past the mantle)
local mane = c:ellipse(23, 32, 10, 9)
mane:add(c:poly({ {24, 25}, {37, 16}, {31, 29} }))
mane:add(c:poly({ {27, 25}, {42, 20}, {33, 31} }))
mane:add(c:poly({ {28, 30}, {40, 29}, {32, 35} }))
mane:add(c:poly({ {14, 36}, {18, 45}, {24, 39} }))
mane:add(c:poly({ {22, 38}, {28, 44}, {30, 36} }))

-- head (three-quarter, facing left) with long muzzle
local head = c:ellipse(21, 24, 11.5, 10)
local muzzle = c:ellipse(12, 29, 6, 4.5)
local earB = c:poly({ {9, 20}, {10, 8}, {17, 15} })
local earF = c:poly({ {22, 15}, {28, 6}, {31, 19} })
local inF = c:poly({ {24, 15}, {28, 10}, {29, 17} })

-- stitched felt crown between the ears
local crown = c:poly({ {14, 16}, {13, 8}, {16, 11}, {19, 6}, {22, 11}, {25, 8}, {24, 16} })

local p = c:build{
  { "rock",  rockM, rock },
  { "tail",  tail, fur },
  { "tip",   tailTip, ruff, { gloss = false } },
  { "legFB", legFB, furD, { gloss = false } },
  { "legFF", legFF, furD, { gloss = false } },
  { "body",  body, fur },
  { "legNB", legNB, fur, { gloss = false } },
  { "mantle", mantle, "red" },
  { "mane",  mane, ruff, { gloss = false, light = mane:grow(4):shift(-1, -1) } },
  { "legNF", legNF, fur, { gloss = false } },
  { "earB",  earB, furD, { gloss = false } },
  { "earF",  earF, fur, { gloss = false } },
  { "inF",   inF, furD, { flat = true, contour = false, rim = false } },
  { "head",  head, fur, { stitch = { side = "lit" } } },
  { "muzzle", muzzle, ruff, { gloss = false } },
  { "crown", crown, "gold" },
}

-- crown band seam and ruby
c:seam({ {14, 14}, {24, 14} })
c:paint({ ".r.", "rRr", ".r." }, 18, 10, { r = "#dd3a2a", R = "#ff9158" })

-- mantle hem seam + clasp button where the mantle meets the mane
c:seam({ {31, 40}, {34, 42}, {38, 38}, {42, 42}, {46, 38}, {48, 40} })
c:seam({ {32, 27}, {44, 26} })
c:button(30, 31)

-- nose, mouth, fang
c:paint({ "nnn.", "nnnn", ".nn." }, 6, 26, { n = "#2a1a10" })
c:px(7, 26, "#5e2a3a")
c:paint({ "uuuuu" }, 8, 31, { u = "#4a2c1a" })
c:paint({ "f..f", "f..f" }, 9, 32, { f = "#f2e4c0" })

-- eyes with fierce brows
c:eye(11, 19); c:eye(21, 19)
c:paint({ "bb...", ".bbb." }, 10, 17, { b = "#2a1a10" })
c:paint({ "..bbb", ".bb.." }, 20, 17, { b = "#2a1a10" })


-- toes
for _, x in ipairs({ 15, 17, 38, 40 }) do c:px(x, 49 + (x > 30 and 1 or 0), "#4a2c1a") end

local t = c:save(D .. "final/aseprite/ph/" .. FILE .. ".aseprite", PNG .. FILE .. ".png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
