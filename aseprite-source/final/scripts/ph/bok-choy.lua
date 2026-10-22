local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- ruffled leaf: union of scallop discs
local function ruffle(list)
  local m = c:mask()
  for _, e in ipairs(list) do m:add(c:ellipse(e[1], e[2], e[3], e[4] or e[3])) end
  return m
end

local leafL = ruffle({ {19, 24, 7, 7}, {14, 20, 4}, {19, 16, 4}, {25, 18, 4}, {13, 26, 3} })
local leafR = ruffle({ {44, 24, 7, 7}, {49, 20, 4}, {44, 16, 4}, {38, 18, 4}, {50, 26, 3} })
local leafM = ruffle({ {31.5, 20, 7, 7}, {27, 15, 4}, {31.5, 12.5, 4, 3.5}, {36, 15, 4} })

local stalkL = c:poly({ {21, 28}, {27, 29}, {30, 48}, {25, 48} })
local stalkR = c:poly({ {37, 29}, {43, 28}, {39, 48}, {34, 48} })
local stalkM = c:rrect(28, 24, 35, 49, 3)
local base = c:rrect(22, 40, 41, 52, 6)
local root = c:rrect(28, 52, 35, 54, 1)

local leaf = GV.ramp("#4a8a3e", { shade = "#2f5a2a" })
local stalk = GV.ramp("#a4b86a")
local all = stalkL:copy():add(stalkR):add(stalkM)
local p = c:build{
  { "root",   root,   "#d9a660", { flat = true } },
  { "leafL",  leafL,  leaf },
  { "leafR",  leafR,  leaf },
  { "stalkL", stalkL, stalk, { light = all } },
  { "stalkR", stalkR, stalk, { light = all } },
  { "leafM",  leafM,  leaf },
  { "stalkM", stalkM, stalk },
  { "base",   base,   GV.ramp("#c8d77a"), { gloss = { 25, 43 } } },
}
-- veins along stalk centres
for y = 28, 39 do c:px(31, y, "#c8d77a") end
for y = 32, 38, 2 do c:px(25 + math.floor((y - 28) / 5), y, "#c8d77a") end
for y = 32, 38, 2 do c:px(39 - math.floor((y - 28) / 5), y, "#c8d77a") end
-- leaf midribs
c:paint({ "v...", ".v..", "..v.", "...v" }, 16, 20, { v = "#6a9a3a" })
c:paint({ "...v", "..v.", ".v..", "v..." }, 44, 20, { v = "#6a9a3a" })
for y = 14, 22 do c:px(31, y, "#6a9a3a") end
-- seam across the base where the stalks join
c:seam({ {24, 46}, {39, 46} })

local t = c:save(D .. "img-redraw-full/aseprite/ph/bok-choy.aseprite", D .. "img-redraw-full/png/ph/bok-choy.png")
print(GV.report(t))
