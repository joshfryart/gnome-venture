-- pl-flfm-1-perch: chibi perch (36x36) of the potato-sprout pal. Scene mode, 1px #2b1c26 outline.
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-flfm-1-perch-20261120-183029/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 36, h = 36, mode = "scene", cres = 2, deep = 2 }
local C = GV.C

local bodyR  = GV.ramp("#bb7547", { gloss = "#e1b392", rim = "#c77c60", shade = "#8a3b2e", deep = "#671926", bounce = "#9c6a4a" })
local sproutR = GV.ramp("#7b9b91")
local berryR = GV.ramp("#1a397a", { gloss = "#4f8ac2" })
local tailR  = GV.ramp("#8a3b2e", { gloss = "#e9ad7c" })
local woodR  = GV.ramp("#9c6a4a")

-- shapes
local perch  = c:rrect(8, 23, 27, 29, 3)
local tail   = c:ascii({
  "..###",
  ".####",
  "####.",
  "###..",
  "###..",
  ".##..",
  ".##..",
}, 25, 10)
local body   = c:ellipse(17.5, 14.5, 9, 7)
local bobL   = c:rrect(10, 5, 13, 8, 1)
local bobR   = c:rrect(22, 5, 25, 8, 1)
local sprout = c:ellipse(15.5, 3.5, 2, 1.5):add(c:ellipse(19.5, 3.5, 2, 1.5)):add(c:rect(17, 4, 18, 7))

c:build{
  { "perch",  perch,  woodR,  { outline = false, contour = false, contact = true, gloss = false } },
  { "tail",   tail,   tailR,  { outline = false, contact = false, cres = 1, deep = 0 } },
  { "body",   body,   bodyR,  { outline = false, contact = true, gloss = { 14, 11 } } },
  { "bobL",   bobL,   berryR, { outline = false, contact = true } },
  { "bobR",   bobR,   berryR, { outline = false, contact = true } },
  { "sprout", sprout, sproutR, { outline = false, contact = true, cres = 1, deep = 0 } },
}

-- berries: hand shade + glint
for _, b in ipairs({ { 10, 13 }, { 22, 25 } }) do
  c:px(b[2], 6, berryR.shade); c:px(b[2], 7, berryR.shade); c:px(b[2], 8, "#120e3f")
  c:px(b[1], 7, berryR.base)
  c:px(b[1] + 1, 6, berryR.gloss)
end

-- texture: wood grain dashes on the stump front, tone-on-tone potato speckles, dither at ramp borders
for _, d in ipairs({ { 18, 25, 3, "#512628" }, { 21, 26, 2, "#80593d" }, { 16, 27, 3, "#512628" }, { 20, 28, 3, "#512628" }, { 13, 25, 2, "#baa56d" } }) do
  for i = 0, d[3] - 1 do c:px(d[1] + i, d[2], d[4]) end
end
c:px(12, 16, "#c77c60"); c:px(11, 12, "#c77c60"); c:px(20, 18, "#c77c60")
c:px(21, 13, "#8a3b2e"); c:px(22, 16, "#8a3b2e")
-- 1px dither where body crescent meets base
c:px(23, 19, "#8a3b2e"); c:px(20, 20, "#8a3b2e")

-- detail: face, tail glint, brighter berry glints
c:eye(11, 10); c:eye(20, 10)
c:px(16, 16, "#2a1a10"); c:px(17, 16, "#2a1a10") -- tiny mouth
c:px(27, 11, "#e9ad7c"); c:px(28, 12, "#e06949"); c:px(28, 13, "#e06949") -- ember glint
c:px(11, 5, "#4f8ac2"); c:px(23, 5, "#4f8ac2")

-- custom 1px outline on the silhouette
local g = c.sil:grow(1)
g:each(function(x, y) if not c.sil:has(x, y) and x >= 0 and y >= 0 and x < 36 and y < 36 then c:px(x, y, "#2b1c26") end end)

c:ground(18, 30.5, 11, 1.5, "#5a5885")
local t = c:save(D .. "out/pl-flfm-1-perch.aseprite", D .. "out/pl-flfm-1-perch.png")
print(GV.report(t))
