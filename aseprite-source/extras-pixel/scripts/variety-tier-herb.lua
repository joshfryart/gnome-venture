-- variety-tier-herb.lua : stop-tier icons herb-1..4 (drying rack, seed shed, hive row, tea house)
-- Stitched Toy, icon mode drawn on a 48 grid and written at out=2 -> 96x96 (readable at 24 px).
-- Families: moss (grass, herb bundles, tea roof), wood (frames, walls), thatch #c9a96e (shed roof), gold (hives, glow), petal (flowers), cream (sacks).
local REPO = "/home/user/gnome-venture/"
local GV = dofile(REPO .. "aseprite-source/gvlib/gvlib.lua")
local OUT = app.params.out or (REPO .. "game/assets/img/stoptiers")
local ASE = app.params.ase or (REPO .. "aseprite-source/extras-pixel/aseprite")
local only = app.params.only
local R = GV.R
local WOOD = GV.ramp("#b07a45")
local DWOOD = GV.ramp("#7a4a1f")
local THATCH = GV.ramp("#c9a96e")
local GRASS = GV.ramp("#7ab55c")
local LEAF = GV.ramp("#4a8a3e")
local MOSS = GV.ramp("#6a9a3a")
local PETAL = GV.ramp("#e46a9b")
local LILAC = GV.ramp("#7a5cc0")
local GLOW = GV.ramp("#f5cf6a")
local CREAM = GV.ramp("#f1ece0")

local function lawn(c, cx, cy, rx, ry)
  c:part(c:ellipse(cx, cy, rx, ry), GRASS, { gloss = false, cres = 2, deep = 1 })
end

-- hanging herb bundle: tied head at (x, y), leaves hang down len px
local function bundle(c, x, y, len, flower)
  c:part(c:poly({ {x-3, y+2}, {x+4, y+2}, {x+3, y+len}, {x-2, y+len} }), LEAF, { flat = true })
  c:px(x, y+4, LEAF.rim); c:px(x-1, y+3, LEAF.rim)
  c:part(c:rect(x-1, y, x+1, y+2), R.red, { flat = true, contour = false })
  if flower then c:part(c:rect(x-1, y+len-1, x+1, y+len+1), flower, { flat = true, contour = false }) end
end

local TIERS = {}

TIERS[1] = function(c)  -- drying rack
  lawn(c, 24, 38, 17, 4.5)
  c:part(c:rect(12, 13, 35, 38), GV.ramp("#8a5a35"), { gloss = false, contour = false })
  c:build{
    { "postL", c:rect(8, 8, 11, 40), WOOD, { gloss = false } },
    { "postR", c:rect(36, 8, 39, 40), WOOD, { gloss = false } },
    { "bar",   c:rrect(6, 9, 41, 13, 1), DWOOD, { gloss = false } },
    { "bar2",  c:rrect(8, 20, 39, 23, 1), DWOOD, { gloss = false } },
  }
  c:seam({ {7, 11}, {40, 11} })
  bundle(c, 16, 13, 14, PETAL.base)
  bundle(c, 23, 13, 12, LILAC.base)
  bundle(c, 30, 13, 14, GLOW.base)
end

TIERS[2] = function(c)  -- seed shed
  lawn(c, 24, 38, 18, 4.5)
  c:build{
    { "wall", c:rect(8, 20, 34, 38), WOOD, { gloss = false } },
    { "roof", c:poly({ {5, 22}, {37, 22}, {32, 10}, {10, 10} }), THATCH },
  }
  c:seam({ {7, 21}, {35, 21} })
  for x = 12, 33, 4 do c:fill(c:rect(x, 14, x, 20), THATCH.shade) end  -- thatch ribs
  c:part(c:rrect(14, 26, 22, 38, 1), GV.ramp("#5e2f1e"), { gloss = false, contour = false })
  c:button(23, 12)
  bundle(c, 28, 24, 8, PETAL.base)
  -- seed sacks
  c:build{
    { "sack1", c:rrect(33, 31, 41, 40, 3), CREAM },
    { "sack2", c:rrect(29, 34, 36, 41, 2), CREAM, { gloss = false } },
  }
  c:part(c:rect(35, 32, 39, 33), R.red, { flat = true, contour = false })
  c:paint({ "ss", "ss" }, 36, 36, { s = "#e8a317" })
end

TIERS[3] = function(c)  -- hive row
  lawn(c, 24, 38, 18, 4.5)
  c:part(c:rect(6, 33, 41, 37), WOOD, { gloss = false })
  c:part(c:rect(9, 37, 12, 41), DWOOD, { flat = true })
  c:part(c:rect(35, 37, 38, 41), DWOOD, { flat = true })
  for _, x in ipairs({ 14, 24, 34 }) do
    local g = R.gold
    c:build{
      { "b3", c:ellipse(x, 29, 6, 4):add(c:rect(x-6, 29, x+6, 33)), GV.ramp("#e8a317") },
      { "b2", c:ellipse(x, 24, 5, 3.5), GV.ramp("#e8a317"), { gloss = false } },
      { "b1", c:ellipse(x, 19.5, 3.5, 3), GV.ramp("#e8a317"), { gloss = false } },
    }
    c:fill(c:rect(x-5, 28, x+5, 28), "#b8661a")
    c:part(c:ellipse(x, 31, 2, 1.5), GV.ramp("#5e2f1e"), { flat = true, contour = false })
  end
  c:seam({ {7, 35}, {40, 35} })
  -- one bee
  c:paint({ "bkb.", ".kkw" }, 19, 11, { b = "#f5cf6a", k = "#2a1a10", w = "#c8ecdc" })
  -- flowers
  c:paint({ ".p.", "ppp", ".p." }, 5, 31, { p = PETAL.base })
  c:paint({ ".p.", "ppp", ".p." }, 39, 30, { p = LILAC.base })
end

TIERS[4] = function(c)  -- tea house
  lawn(c, 24, 38, 18, 4)
  c:build{
    { "steps", c:rrect(15, 35, 33, 39, 1), THATCH, { gloss = false } },
    { "wall",  c:rect(11, 21, 36, 37), WOOD, { gloss = false } },
    { "roof",  c:poly({ {6, 23}, {41, 23}, {35, 12}, {12, 12} }), MOSS },
    { "ridge", c:rrect(17, 8, 30, 12, 2), MOSS, { gloss = false } },
  }
  c:seam({ {8, 22}, {39, 22} })
  c:part(c:rrect(20, 26, 28, 37, 2), GLOW, { gloss = false, contour = "#7a3a14" })
  c:fill(c:rect(24, 27, 24, 36), "#7a3a14")
  c:part(c:rect(13, 26, 17, 30), GLOW, { flat = true, contour = false })
  c:part(c:rect(31, 26, 34, 30), GLOW, { flat = true, contour = false })
  -- teacup sign on the roof: cream cup with a red rim and steam
  c:part(c:rrect(18, 14, 29, 20, 2), CREAM, { flat = true })
  c:paint({ "rrrrrr", "wwwwwr", ".www.r", "..w..." }, 20, 15, { r = R.red.base, w = "#c8d77a" })
  c:button(31, 14)
end

for t = 1, 4 do
  if not only or tonumber(only) == t then
    local c = GV.canvas{ w = 48, h = 48, out = 2, mode = "icon" }
    TIERS[t](c)
    local r = c:save(ASE .. "/herb-" .. t .. ".aseprite", OUT .. "/herb-" .. t .. ".png")
    print("herb-" .. t, GV.report(r))
  end
end
