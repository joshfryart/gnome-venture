-- variety-tier-jetty.lua : stop-tier icons jetty-1..4 (plank pier, net racks, smokehouse, fish supper hall)
-- Stitched Toy, icon mode drawn on a 48 grid and written at out=2 -> 96x96 (readable at 24 px).
-- Families: water (sea band), wood (planks, posts, huts), dwood (dark pile), thatch/cream (nets), red (hall roof), gold (glow), stone (chimney).
local REPO = "/home/user/gnome-venture/"
local GV = dofile(REPO .. "aseprite-source/gvlib/gvlib.lua")
local OUT = app.params.out or (REPO .. "game/assets/img/stoptiers")
local ASE = app.params.ase or (REPO .. "aseprite-source/extras-pixel/aseprite")
local only = app.params.only
local R = GV.R
local WOOD = GV.ramp("#b07a45")
local DWOOD = GV.ramp("#7a4a1f")
local PLANK = GV.ramp("#c9a96e")
local ROOF = GV.ramp("#d6322b")
local GLOW = GV.ramp("#f5cf6a")
local STONE = GV.ramp("#8b8f96")
local NET = GV.ramp("#a4b86a")

-- sea band along the bottom with a couple of wave glints
local function sea(c, y0)
  c:part(c:rrect(5, y0, 42, 42, 3), R.water, { gloss = false, cres = 2, deep = 1 })
  for _, p in ipairs({ {10, y0+3}, {26, y0+5}, {35, y0+2}, {16, y0+7} }) do
    c:paint({ "www" }, p[1], p[2], { w = R.water.gloss })
  end
end

-- plank deck: rectangle of planks (light/dark rows) with a gold seam along the edge
local function deck(c, x0, y0, x1, y1)
  c:part(c:rect(x0, y0, x1, y1), PLANK, { gloss = false })
  for x = x0 + 4, x1 - 2, 5 do c:fill(c:rect(x, y0 + 1, x, y1 - 1), "#9a6b3f") end
end

local function pile(c, x, y0, y1)
  c:part(c:rect(x, y0, x + 2, y1), DWOOD, { flat = true, rim = false })
end

local TIERS = {}

TIERS[1] = function(c)  -- plank pier
  sea(c, 30)
  pile(c, 10, 25, 38); pile(c, 22, 25, 38); pile(c, 34, 25, 38)
  deck(c, 6, 20, 41, 26)
  -- end posts (mooring), and a fish crate with two silver tails
  c:part(c:rect(6, 11, 9, 20), DWOOD, { gloss = false })
  c:part(c:rect(38, 11, 41, 20), DWOOD, { gloss = false })
  c:part(c:rect(5, 10, 10, 12), WOOD, { flat = true })
  c:part(c:rect(37, 10, 42, 12), WOOD, { flat = true })
  c:paint({ "s.s", "sss", ".s." }, 19, 10, { s = "#c9c5bc" })
  c:paint({ ".s", "ss" }, 26, 12, { s = "#c9c5bc" })
  c:part(c:rect(17, 14, 28, 21), WOOD, { gloss = false })
  c:fill(c:rect(18, 17, 27, 17), DWOOD.base)
  c:seam({ {7, 22}, {40, 22} })
end

TIERS[2] = function(c)  -- net racks
  sea(c, 34)
  pile(c, 8, 30, 41); pile(c, 38, 30, 41)
  deck(c, 5, 28, 42, 33)
  c:part(c:rect(8, 8, 11, 28), WOOD, { gloss = false })
  c:part(c:rect(36, 8, 39, 28), WOOD, { gloss = false })
  c:part(c:rect(22, 8, 25, 28), WOOD, { gloss = false })
  c:part(c:rect(7, 7, 40, 10), DWOOD, { flat = true })
  for _, r in ipairs({ { 12, 21, 24 }, { 26, 35, 24 } }) do
    c:part(c:rect(r[1], 10, r[2], r[3]), NET, { gloss = false, contour = false })
    for y = 11, r[3] do for x = r[1], r[2] do
      if (x + y) % 3 == 0 or (x - y) % 3 == 0 then c:px(x, y, NET.deep) end
    end end
    c:paint({ "gg", "gg" }, r[1] + 3, 11, { g = R.gold.base })
    c:paint({ "gg", "gg" }, r[2] - 4, 11, { g = R.gold.base })
  end
  c:seam({ {6, 30}, {41, 30} })
end

TIERS[3] = function(c)  -- smokehouse
  sea(c, 36)
  pile(c, 8, 32, 41); pile(c, 38, 32, 41)
  deck(c, 5, 30, 42, 35)
  c:build{
    { "wall", c:rect(8, 20, 38, 31), WOOD, { gloss = false } },
    { "chim", c:rect(30, 9, 35, 18), STONE, { gloss = false } },
    { "roof", c:poly({ {5, 22}, {41, 22}, {34, 12}, {12, 12} }), DWOOD },
  }
  c:part(c:rect(29, 8, 36, 10), STONE, { flat = true })
  c:seam({ {7, 21}, {39, 21} })
  c:part(c:rrect(14, 24, 22, 31, 1), GLOW, { gloss = false, contour = "#7a3a14" })
  c:fill(c:rect(18, 25, 18, 30), "#7a3a14")
  c:part(c:rect(27, 25, 34, 28), GV.ramp("#5e2f1e"), { flat = true, contour = false })
  c:part(c:ellipse(33, 5.5, 2.5, 1.5), GV.ramp("#c9c5bc"), { flat = true })
end

TIERS[4] = function(c)  -- fish supper hall
  sea(c, 36)
  pile(c, 7, 32, 42); pile(c, 38, 32, 42)
  deck(c, 5, 30, 42, 35)
  c:build{
    { "wall",  c:rect(9, 19, 38, 31), WOOD, { gloss = false } },
    { "roof",  c:poly({ {5, 21}, {42, 21}, {36, 9}, {11, 9} }), ROOF },
    { "ridge", c:rrect(15, 5, 32, 9, 2), ROOF, { gloss = false } },
  }
  c:seam({ {7, 20}, {40, 20} })
  c:part(c:rrect(18, 24, 28, 31, 2), GLOW, { gloss = false, contour = "#7a3a14" })
  c:fill(c:rect(23, 25, 23, 30), "#7a3a14")
  c:part(c:rect(11, 24, 15, 28), GLOW, { flat = true, contour = false })
  c:part(c:rect(31, 24, 36, 28), GLOW, { flat = true, contour = false })
  -- fish sign on the roof: blue fish on gold plaque
  c:part(c:rrect(18, 11, 29, 17, 2), GLOW, { flat = true })
  c:paint({ "..ff...", ".ffffff", "ffffff.f", ".ffffff", "..ff..." }, 19, 11, { f = R.water.shade })
  c:button(32, 10)
end

for t = 1, 4 do
  if not only or tonumber(only) == t then
    local c = GV.canvas{ w = 48, h = 48, out = 2, mode = "icon" }
    TIERS[t](c)
    local r = c:save(ASE .. "/jetty-" .. t .. ".aseprite", OUT .. "/jetty-" .. t .. ".png")
    print("jetty-" .. t, GV.report(r))
  end
end
