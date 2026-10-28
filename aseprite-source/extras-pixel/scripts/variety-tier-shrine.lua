-- variety-tier-shrine.lua : stop-tier icons shrine-1..4 (stone lantern path, prayer bell, wishing pool, pilgrims' hall)
-- Stitched Toy, icon mode drawn on a 48 grid and written at out=2 -> 96x96 (readable at 24 px).
-- Families: stone (lantern, steps), wood (frames), red (roofs, ribbons), gold (bell, window glow), water (pool), moss.
-- Run: AppRun -b --script variety-tier-shrine.lua --script-param out=DIR --script-param ase=DIR
local REPO = "/home/user/gnome-venture/"
local GV = dofile(REPO .. "aseprite-source/gvlib/gvlib.lua")
local OUT = app.params.out or (REPO .. "game/assets/img/stoptiers")
local ASE = app.params.ase or (REPO .. "aseprite-source/extras-pixel/aseprite")
local only = app.params.only
local R = GV.R
local STONE = GV.ramp("#8b8f96")
local PATH = GV.ramp("#c9c5bc")
local ROOF = GV.ramp("#d6322b")
local WOOD = GV.ramp("#b07a45")
local DWOOD = GV.ramp("#7a4a1f")
local GLOW = GV.ramp("#f5cf6a")

-- stone lantern (toro): x = centre column, yb = bottom row of the foot. s = scale 1 big, 0 small
local function lantern(c, x, yb, s)
  if s == 1 then
    c:build{
      { "foot", c:rrect(x-4, yb-3, x+4, yb, 1), STONE, { gloss = false } },
      { "post", c:rect(x-2, yb-9, x+2, yb-3), STONE, { gloss = false } },
      { "deck", c:rrect(x-5, yb-11, x+5, yb-8, 1), STONE, { gloss = false } },
      { "box",  c:rect(x-4, yb-18, x+4, yb-11), STONE, { gloss = false } },
      { "roof", c:poly({ {x-7, yb-17}, {x+8, yb-17}, {x+3, yb-23}, {x-2, yb-23} }), STONE },
    }
    c:part(c:rect(x-2, yb-17, x+2, yb-12), GLOW, { flat = true, contour = "#7a3a14" })
    c:px(x, yb-24, R.gold.dot)
  else
    c:build{
      { "foot", c:rect(x-3, yb-2, x+3, yb), STONE, { flat = true } },
      { "post", c:rect(x-1, yb-6, x+1, yb-2), STONE, { flat = true } },
      { "box",  c:rect(x-3, yb-11, x+3, yb-6), STONE, { gloss = false } },
      { "roof", c:poly({ {x-5, yb-10}, {x+6, yb-10}, {x+3, yb-14}, {x-2, yb-14} }), STONE, { gloss = false } },
    }
    c:part(c:rect(x-1, yb-10, x+1, yb-7), GLOW, { flat = true, contour = false })
  end
end

local function stepstone(c, cx, cy, rx, ry)
  c:part(c:ellipse(cx, cy, rx, ry), PATH, { gloss = false, cres = 2, deep = 1 })
end

local function bell(c, x, y)  -- gold bell hanging from y (top of the bell body)
  c:build{
    { "cap",  c:rect(x-1, y-1, x+1, y+1), R.gold, { flat = true } },
    { "bell", c:poly({ {x-4, y+1}, {x+5, y+1}, {x+6, y+9}, {x-5, y+9} }):add(c:ellipse(x+0.5, y+3, 4, 3)), R.gold, { gloss = false } },
    { "lip",  c:rect(x-6, y+8, x+6, y+10), R.gold, { flat = true } },
  }
  c:px(x-2, y+3, R.gold.gloss); c:px(x-2, y+4, R.gold.gloss)
  c:part(c:ellipse(x+0.5, y+12, 1.5, 1.5), GV.ramp("#7a3a14"), { flat = true })
end

local TIERS = {}

TIERS[1] = function(c)  -- stone lantern path
  c:part(c:ellipse(24, 36, 17, 5.5), GV.ramp("#7ab55c"), { gloss = false, cres = 2, deep = 1 })
  stepstone(c, 12, 38, 5, 2.5); stepstone(c, 36, 38, 5, 2.5); stepstone(c, 38, 33, 3, 2)
  stepstone(c, 24, 40, 5, 2.5)
  lantern(c, 24, 37, 1)
  c:seam({ {20, 30}, {28, 30} }, { free = true })
end

TIERS[2] = function(c)  -- prayer bell: wooden frame, gold bell, red beam, small lanterns
  c:part(c:ellipse(24, 38, 18, 4), GV.ramp("#7ab55c"), { gloss = false, cres = 2, deep = 1 })
  c:build{
    { "back",  c:rect(15, 12, 33, 38), GV.ramp("#5e2f1e"), { gloss = false, contour = false } },
    { "postL", c:rect(13, 12, 17, 39), WOOD, { gloss = false } },
    { "postR", c:rect(31, 12, 35, 39), WOOD, { gloss = false } },
    { "beam",  c:rrect(10, 7, 38, 12, 1), ROOF },
  }
  c:seam({ {12, 10}, {36, 10} })
  bell(c, 24, 14)
  c:part(c:rect(23, 25, 25, 31), R.red, { flat = true })
  c:part(c:rect(17, 33, 31, 35), DWOOD, { flat = true, gloss = false })
  lantern(c, 10, 41, 0); lantern(c, 37, 41, 0)
end

TIERS[3] = function(c)  -- wishing pool
  c:part(c:ellipse(24, 37, 17, 5), GV.ramp("#7ab55c"), { gloss = false, cres = 2, deep = 1 })
  lantern(c, 10, 34, 0); lantern(c, 37, 34, 0)
  c:build{
    { "basin", c:ellipse(24, 32, 15, 8):add(c:rect(9, 26, 39, 32)):cut(c:rect(0, 0, 47, 23)), STONE, { gloss = false } },
    { "water", c:ellipse(24, 27.5, 12, 4.5), R.water, { gloss = false, cres = 2, deep = 1 } },
  }
  c:fill(c:rect(15, 25, 18, 25):clip(c:ellipse(24, 27.5, 12, 4.5)), R.water.gloss)
  c:px(29, 28, R.water.rim); c:px(30, 28, R.water.rim); c:px(21, 29, R.water.rim)
  c:paint({ ".g.", "ggg", ".g." }, 30, 26, { g = R.gold.base })
  c:paint({ "gg", "gg" }, 20, 27, { g = R.gold.base })
  c:seam({ {11, 33}, {37, 33} })
end

TIERS[4] = function(c)  -- pilgrims' hall
  c:part(c:ellipse(24, 38, 18, 4), GV.ramp("#7ab55c"), { gloss = false, cres = 2, deep = 1 })
  c:build{
    { "steps", c:rrect(15, 35, 33, 39, 1), PATH, { gloss = false } },
    { "wall",  c:rect(13, 20, 35, 37), WOOD, { gloss = false } },
    { "roof",  c:poly({ {7, 22}, {41, 22}, {35, 11}, {13, 11} }), ROOF },
    { "ridge", c:rrect(16, 6, 32, 11, 2), ROOF, { gloss = false } },
  }
  c:seam({ {9, 21}, {39, 21} })
  c:part(c:rrect(20, 25, 28, 37, 2), GLOW, { gloss = false, contour = "#7a3a14" })
  c:fill(c:rect(24, 26, 24, 36), "#7a3a14")
  c:part(c:rect(15, 25, 18, 30), GLOW, { flat = true, contour = false })
  c:part(c:rect(31, 25, 34, 30), GLOW, { flat = true, contour = false })
  c:button(22, 13)
  lantern(c, 10, 41, 0); lantern(c, 37, 41, 0)
end

for t = 1, 4 do
  if not only or tonumber(only) == t then
    local c = GV.canvas{ w = 48, h = 48, out = 2, mode = "icon" }
    TIERS[t](c)
    local r = c:save(ASE .. "/shrine-" .. t .. ".aseprite", OUT .. "/shrine-" .. t .. ".png")
    print("shrine-" .. t, GV.report(r))
  end
end
