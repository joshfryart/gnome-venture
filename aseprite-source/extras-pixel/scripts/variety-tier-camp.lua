-- variety-tier-camp.lua : stoptiers/camp-1..4 (96x96). Drawn on a 48 grid, written at 2x nearest (out=2).
-- 1 log seats, 2 cookfire ring, 3 storytelling stage, 4 great lodge.
-- Family: wood logs + stone + ember flame + red cloth. Shapes kept inside grid 5..41.
-- Run: AppRun -b --script-param out=<dir> --script variety-tier-camp.lua   (script-param goes BEFORE --script)
local ROOT = "/home/user/gnome-venture/"
local GV = dofile(ROOT .. "aseprite-source/gvlib/gvlib.lua")
local OUT = app.params.out or (ROOT .. "aseprite-source/extras-pixel/png/")
local ASE = ROOT .. "aseprite-source/extras-pixel/aseprite/"
local lwood = GV.ramp("#d9a660")
local dark  = GV.ramp("#3d2a1c")
local smoke = GV.ramp("#d8d2cc", { shade = "#aaa4a4", deep = "#7c7680", pale = false })

-- stump: bark body + pale cut top with growth rings
local bark = GV.ramp("#8a5a35")
local cut  = GV.ramp("#e8c48a")
local function stump(c, x0, y0, w, h)
  local cx = x0 + (w - 1) / 2
  c:part(c:rrect(x0, y0 + 4, x0 + w - 1, y0 + h - 1, 3), bark)
  for _, dx in ipairs({ 3, 7, w - 5 }) do
    c:fill(c:rect(x0 + dx, y0 + 9, x0 + dx, y0 + h - 4), "#5e2f1e")
  end
  local top = c:ellipse(cx, y0 + 4, w / 2, 4)
  c:part(top, cut, { gloss = false })
  c:fill(top:copy():shrink(2):edge(), "#b07a45")
  c:fill(c:ellipse(cx, y0 + 4, 1, 1), "#b07a45")
end

local T = {}

T[1] = function(c)
  stump(c, 6, 9, 15, 17)
  stump(c, 27, 9, 15, 17)
  stump(c, 15, 23, 17, 16)
end

T[2] = function(c)
  local cx, cy = 24, 31
  local stones = {}
  for i = 0, 9 do
    local a = i * 2 * math.pi / 10
    stones[#stones + 1] = { cx + 14 * math.cos(a), cy + 6 * math.sin(a) }
  end
  table.sort(stones, function(p, q) return p[2] < q[2] end)
  local function stone(p) c:part(c:ellipse(math.floor(p[1] + 0.5), math.floor(p[2] + 0.5), 3, 3), "stone") end
  for i = 1, 5 do stone(stones[i]) end
  c:part(c:line({ {12, 31}, {24, 8} }, 2), "wood", { flat = true })
  c:part(c:line({ {36, 31}, {24, 8} }, 2), "wood", { flat = true })
  c:part(c:rrect(16, 12, 32, 24, 5), dark)
  c:part(c:rect(15, 12, 33, 14), "gold", { flat = true })
  c:part(c:poly({ {24,16},{27,21},{31,25},{33,32},{15,32},{17,25},{21,21} }), "flame")
  c:fill(c:ellipse(24, 28, 3, 3), "#ffd86a")
  c:part(c:line({ {14, 33}, {34, 33} }, 3), "wood")
  for i = 6, 10 do stone(stones[i]) end
end

T[3] = function(c)
  c:part(c:rect(9, 11, 37, 34), "dusk")
  c:paint({ "..g..", ".ggg.", "ggggg", ".ggg.", ".g.g." }, 21, 17, { g = "#f5cf6a" })
  c:part(c:rect(7, 8, 16, 35), "red")
  c:part(c:rect(31, 8, 40, 35), "red")
  c:part(c:rect(7, 6, 40, 11), "red")
  c:seam({ {8, 9}, {39, 9} }, { free = true })
  c:part(c:rect(6, 33, 41, 40), "wood")
  c:seam({ {8, 36}, {39, 36} }, { free = true })
  c:part(c:rrect(18, 28, 28, 33, 2), "wood")
end

T[4] = function(c)
  c:part(c:rect(29, 8, 34, 19), "stone")
  c:part(c:ellipse(32, 7, 3, 2), smoke, { flat = true, solid = false })
  c:part(c:rect(8, 21, 39, 38), "wood")
  for _, y in ipairs({ 25, 29, 33 }) do c:fill(c:rect(9, y, 38, y), "#8a4f2a") end
  c:part(c:rect(6, 38, 41, 41), "stone")
  c:part(c:poly({ {5, 22}, {23, 8}, {42, 22} }), "red")
  c:seam({ {7, 21}, {40, 21} }, { free = true })
  c:part(c:rrect(17, 26, 29, 38, 4), "gold")
  c:part(c:rrect(19, 29, 27, 38, 3), dark)
  c:part(c:rect(9, 26, 14, 31), "gold", { flat = true })
  c:part(c:rect(33, 26, 38, 31), "gold", { flat = true })
end

local k = tonumber(app.params.tier)
for _, i in ipairs(k and { k } or { 1, 2, 3, 4 }) do
  local c = GV.canvas{ w = 48, h = 48, mode = "icon", out = 2 }
  T[i](c)
  local t = c:save(ASE .. "variety-tier-camp-" .. i .. ".aseprite", OUT .. "camp-" .. i .. ".png")
  print("camp-" .. i .. " " .. GV.report(t))
end
