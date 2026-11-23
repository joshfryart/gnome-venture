-- pl-ana-1-perch.lua : perch (36x36) for the moss-log pal. Light from upper-left.
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-ana-1-perch-20261120-162614/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 36, h = 36, mode = "sticker", ol = 1, olx = 1, cres = 2, deep = 1 }

-- ramps (from the pal's palette). TEXTURE: tuft rim = dome green.
local moss  = GV.ramp("#8fd05a", { rim = "#c8d179", gloss = "#e4eca3", dot = "#e4eca3", shade = "#4f9255" })
local tuft  = GV.ramp("#4f9255", { rim = "#8fd05a" })
local bodyR = GV.ramp("#847349", { rim = "#adba49", gloss = "#c8d179", shade = "#5a4a2a", deep = "#3d3018", bounce = "#8a7a4a" })
local wood  = GV.ramp("#67331e", { gloss = "#e9c57e" })

-- silhouettes (CRITIQUE: tufts were outline-dominated "brown ears" -> thicker tips)
local head  = c:ellipse(18, 12, 10, 8)                       -- x8..28, y4..20
local body  = c:rrect(12, 19, 23, 27, 3)                     -- khaki log under the dome
local perch = c:rrect(10, 26, 25, 30, 2)                     -- small wooden perch/branch
local tufts = c:mask()
tufts:poly({ { 9, 7 }, { 10, 3 }, { 11, 3 }, { 12, 3 }, { 14, 7 } })   -- left spike, flat 2px tip
tufts:poly({ { 14, 6 }, { 15, 3 }, { 16, 3 }, { 17, 3 }, { 18, 3 }, { 19, 6 } }) -- centre spike
tufts:poly({ { 20, 7 }, { 21, 3 }, { 22, 3 }, { 23, 3 }, { 25, 7 } })  -- right spike

local p = c:build{
  { "tufts", tufts, tuft,  { flat = true, gloss = false } },
  { "perch", perch, wood,  { gloss = false, contour = false } },
  { "head",  head,  moss,  { contact = false } },
  { "body",  body,  bodyR, { gloss = false, contour = false, contact = true } },
}

-- gold sparkle accent (floating, upper-left, like the pal's)
local sp = c:ascii({ ".g.", "ggg", ".g." }, 4, 8)
c:fill(sp, "#e9c57e")

-- TEXTURE: hand-placed, tone-on-tone, following the form
-- 1px dither of base stepping into the dome's shade crescent
p.head.m:each(function(x, y)
  if c:get(x, y) == moss.shade and c:get(x - 1, y - 1) ~= moss.shade and (x + y) % 3 == 0 then
    c:px(x, y, moss.base)
  end
end)
-- khaki log: short darker grain dashes along the form
c:px(15, 22, "#5a4a2a"); c:px(16, 22, "#5a4a2a")
c:px(18, 23, "#5a4a2a"); c:px(19, 23, "#5a4a2a")
-- wood knots on the perch, along the log (1 shade step from the base) + lit end-grain glint
c:px(15, 27, "#552c19"); c:px(16, 27, "#552c19")
c:px(12, 29, "#552c19"); c:px(13, 29, "#552c19")
c:px(13, 27, "#b98736"); c:px(14, 27, "#b98736")
-- small moss patch sprouting at the body-perch join, right side
c:part(c:rrect(21, 25, 25, 28, 2), tuft, { flat = true, gloss = false, contour = false, contact = false })

-- DETAIL: the pal's face (closed happy eyes like the 64x64 art, tiny mouth, pink cheeks)
local face = "#2b1c26"
c:px(13, 13, face); c:px(14, 12, face); c:px(15, 13, face)   -- left ∧ eye
c:px(21, 13, face); c:px(20, 12, face); c:px(19, 13, face)   -- right ∧ eye
c:px(17, 15, face); c:px(18, 15, face)                       -- tiny smile (∪)
c:px(16, 14, face); c:px(19, 14, face)
c:fill(c:rrect(10, 14, 11, 15, 0), "#ff8a8a")                -- left cheek
c:fill(c:rrect(23, 14, 24, 15, 0), "#ff8a8a")                -- right cheek
-- 1px gold glint on the moss patch and sparkle
c:px(22, 26, "#e9c57e")

c:ground(18, 31.5, 11, 2, "#454363")

-- face goes in the SHADE phase; keep block-in pure silhouette
local t = c:save(D .. "out/pl-ana-1-perch.aseprite", D .. "out/pl-ana-1-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 1)
