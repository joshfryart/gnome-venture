-- variety-tier-tower.lua : stoptiers/tower-1..4 (96x96). Drawn on a 48 grid, written at 2x nearest (out=2).
-- 1 sturdy ladder, 2 signal beacon, 3 map room, 4 watchers' hall.
-- Family: stone footing + wood frame + red roofs + gold trim. Ramps: wood/stone/red/gold/flame presets,
-- light-wood "#c98f50" and dusk-dark "#3d2a1c" borrowed from soil/wood via GV.ramp.
-- Run: AppRun -b --script variety-tier-tower.lua --script-param out=<dir>
local ROOT = "/home/user/gnome-venture/"
local GV = dofile(ROOT .. "aseprite-source/gvlib/gvlib.lua")
local OUT = app.params.out or (ROOT .. "aseprite-source/extras-pixel/png/")
local ASE = ROOT .. "aseprite-source/extras-pixel/aseprite/"
local lwood = GV.ramp("#c98f50")
local dark  = GV.ramp("#3d2a1c")

local function base(c)  -- stone footing shared by the family
  c:part(c:rrect(7, 38, 41, 43, 2), "stone")
  c:seam({ {10, 40}, {38, 40} }, { free = true })
end

local T = {}

T[1] = function(c)
  for _, y in ipairs({ 10, 17, 24, 31 }) do
    c:part(c:rect(15, y, 32, y + 2), lwood, { gloss = false })
  end
  c:part(c:rect(10, 7, 15, 38), "wood")
  c:part(c:rect(32, 7, 37, 38), "wood")
  c:part(c:rect(11, 5, 14, 7), "gold", { flat = true })
  c:part(c:rect(33, 5, 36, 7), "gold", { flat = true })
  c:part(c:rrect(8, 37, 40, 41, 2), "stone")
end

T[2] = function(c)
  c:part(c:line({ {15, 37}, {19, 22} }, 5), "wood")
  c:part(c:line({ {33, 37}, {29, 22} }, 5), "wood")
  c:part(c:line({ {17, 35}, {31, 26} }, 3), lwood, { gloss = false })
  c:part(c:line({ {31, 35}, {17, 26} }, 3), lwood, { gloss = false })
  c:part(c:rrect(11, 20, 37, 23, 1), "wood")
  c:part(c:rrect(8, 37, 40, 41, 2), "stone")
  c:part(c:poly({ {26,5},{27,9},{30,12},{31,16},{17,16},{18,11},{21,9},{22,7} }), "flame")
  c:fill(c:ellipse(24, 13, 2, 3), "#ffd86a")
  c:part(c:rrect(15, 16, 33, 20, 2), "gold")
end

T[3] = function(c)
  c:part(c:rect(11, 27, 16, 36), "wood")
  c:part(c:rect(32, 27, 37, 36), "wood")
  c:part(c:line({ {14, 35}, {34, 28} }, 3), lwood, { gloss = false })
  c:part(c:rect(9, 16, 39, 27), "wood")
  c:part(c:rect(13, 18, 35, 26), "cream")
  -- the map: pond, red route, X
  c:paint({
    "...www.............",
    "..wwwww...rr.......",
    "...www...r..r..r.r.",
    ".........r...rr..x.",
    "..................."
  }, 15, 19, { w = "#8fcbd8", r = "#b8452f", x = "#dd3a2a" })
  c:part(c:poly({ {5, 17}, {24, 5}, {43, 17} }), "red")
  c:seam({ {8, 16}, {40, 16} }, { free = true })
  c:part(c:rrect(8, 37, 40, 41, 2), "stone")
end

T[4] = function(c)
  c:part(c:rect(6, 29, 40, 39), "stone")
  c:part(c:poly({ {5, 31}, {11, 23}, {35, 23}, {41, 31} }), "red")
  c:part(c:rect(16, 16, 32, 38), "stone")
  c:paint({
    "..ccccccc..",
    ".cgguuuggc.",
    ".cgguuuggc.",
    "..ccccccc.."
  }, 19, 19, { c = "#f1ece0", g = "#e8a317", u = "#2a1a10" })
  c:part(c:rrect(20, 29, 28, 38, 3), dark)
  c:part(c:poly({ {14, 17}, {24, 8}, {34, 17} }), "red")
  c:part(c:rect(8, 32, 12, 36), "gold", { flat = true })
  c:part(c:rect(34, 32, 38, 36), "gold", { flat = true })
  c:part(c:rect(23, 5, 24, 8), "gold", { flat = true })
end

local k = tonumber(app.params.tier)
for _, i in ipairs(k and { k } or { 1, 2, 3, 4 }) do
  local c = GV.canvas{ w = 48, h = 48, mode = "icon", out = 2 }
  T[i](c)
  local t = c:save(ASE .. "variety-tier-tower-" .. i .. ".aseprite", OUT .. "tower-" .. i .. ".png")
  print("tower-" .. i .. " " .. GV.report(t))
end
