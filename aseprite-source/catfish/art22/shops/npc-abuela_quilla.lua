-- npc-abuela_quilla.lua : Cat Fish pet shops (claude/plan-catfish-petshops.md s1), SA "Canopy Critter Co."
-- Shopkeeper bust: Abuela Quilla, a kind grandmother gnome of the Rainroot Reaches. 80x100 gvlib "bust" mode,
-- same build as the ph/npc-* busts (round backdrop disc, head ~40 px, coat bleeding off the bottom, 1 px #000000
-- border). Silver braids tied with red wool, a brown felt hat with a red band and a toucan feather, a striped
-- woven shawl (Andean-weave stripes in felt) pinned with a gold button, and an orange tabby kitten plush in her
-- arms. Light from the upper left; locked eyes; no text.
-- Run: AppRun -b --script npc-abuela_quilla.lua     Writes ../out/npc-abuela_quilla.png + .aseprite
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../../gvlib/gvlib.lua")
local OUT = here .. "/../out/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }
local D = "#2a1a10"

local SKIN  = GV.ramp("#a8703f")             -- warm brown skin (wood family)
local HAIR  = GV.ramp("#cfc8d0", { pale = true }) -- silver hair (stone family, pale)
local HAT   = GV.ramp("#6e4a2e")             -- felt hat (soil family)
local SHAWL = GV.ramp("#c23a4a")             -- red woven shawl (red family)
local CAT   = GV.ramp("#e8913a")             -- orange tabby (gold/ember family)

-- shapes
local disc  = c:ellipse(39.5, 50, 34, 34)
local coat  = c:ellipse(39.5, 104, 35, 28)
local braidL = c:line({ {22, 54}, {19, 64}, {18, 74} }, 5)
local braidR = c:line({ {57, 54}, {60, 64}, {61, 72} }, 5)
local tieL  = c:rrect(15, 74, 21, 77, 1)
local tieR  = c:rrect(58, 72, 64, 75, 1)
local head  = c:ellipse(39.5, 55, 19, 18)
local hair  = c:ellipse(39.5, 47, 20, 12):cut(c:ellipse(39.5, 57, 16, 10)):clip(c:rect(0, 0, 79, 56))
local hat   = c:rrect(26, 22, 53, 38, 7):cut(c:rect(0, 38, 79, 99))
local brim  = c:ellipse(39.5, 38, 22, 3.5)
local band  = c:rect(27, 30, 52, 34)
local feather = c:line({ {50, 33}, {55, 25}, {58, 18} }, 3)
local shawl = c:poly({ {9, 99}, {12, 84}, {22, 75}, {40, 79}, {58, 75}, {68, 84}, {71, 99} })
local vneck = c:poly({ {32, 77}, {48, 77}, {40, 87} })
-- kitten plush held in front, lower right
local catH  = c:ellipse(52.5, 87, 12, 9.5)
catH:add(c:poly({ {41, 85}, {42, 71}, {51, 79} }))
catH:add(c:poly({ {54, 79}, {63, 71}, {64, 85} }))
local handL = c:ellipse(40, 95, 4, 3)
local handR = c:ellipse(65, 95, 4, 3)

c:build{
  { "disc",   disc,   "#9fcf8a", { contour = false, gloss = false } },
  { "coat",   coat,   "#3f8f7a" },
  { "braidL", braidL, HAIR, { flat = true } },
  { "braidR", braidR, HAIR, { flat = true } },
  { "tieL",   tieL,   "red", { flat = true } },
  { "tieR",   tieR,   "red", { flat = true } },
  { "head",   head,   SKIN },
  { "hair",   hair,   HAIR, { gloss = false } },
  { "feather", feather, "#f2b51e", { flat = true } },
  { "hat",    hat,    HAT },
  { "band",   band,   "red", { flat = true } },
  { "brim",   brim,   HAT, { gloss = false } },
  { "shawl",  shawl,  SHAWL, { stitch = { side = "lit" }, gloss = false } },
  { "vneck",  vneck,  "cream", { flat = true } },
  { "cat",    catH,   CAT },
  { "handL",  handL,  SKIN, { gloss = false } },
  { "handR",  handR,  SKIN, { gloss = false } },
}

-- woven stripes across the shawl (aguayo-style bands, felt colours), skipping the kitten and hands
local stripeCols = { "#f2b51e", "#2f8fa8", "#e46a9b" }
local shawlOnly = shawl:copy():cut(vneck):cut(catH):cut(handL):cut(handR):shrink(1)
for i, y in ipairs({ 84, 90, 96 }) do
  local col = stripeCols[i]
  shawlOnly:each(function(x, yy) if yy == y or yy == y + 1 then c:px(x, yy, col) end end)
end
-- diamond motif row between the stripes
for x = 14, 66, 6 do
  local m = c:ascii({ ".x.", "xxx", ".x." }, x, 86):clip(shawlOnly)
  c:fill(m, "#fff1c8")
end
-- feather tip (red/black toucan tip)
c:fill(c:line({ {57, 20}, {58, 18} }, 2), "#dd3a2a")
-- braid weave
for _, p in ipairs({ { 20, 60 }, { 19, 66 }, { 59, 60 }, { 60, 66 } }) do
  c:paint({ "x.x", ".x." }, p[1] - 1, p[2], { x = "#8b8f96" })
end

-- face
c:eye(29, 50); c:eye(46, 50)
c:paint({ "u........u", ".uuuuuuuu.", "..uuuuuu.." }, 35, 62, { u = D })
c:fill(c:rect(37, 63, 42, 63), "#dd3a2a")
-- smile lines and a soft nose
c:paint({ ".n.", "nnn" }, 38, 57, { n = "#8a5634" })

-- kitten face: small locked eyes, pink nose, mouth, tabby stripes
c:eye(46, 84, true); c:eye(56, 84, true)
c:paint({ "pp", }, 52, 88, { p = "#e46a9b" })
c:paint({ "u.uu.u", ".u..u." }, 50, 89, { u = D })
c:fill(c:rect(52, 78, 53, 81), "#b8661a")
c:fill(c:rect(48, 79, 49, 81), "#b8661a")
c:fill(c:rect(56, 79, 57, 81), "#b8661a")
c:fill(c:rect(43, 75, 44, 78), "#e46a9b"); c:fill(c:rect(61, 75, 62, 78), "#e46a9b")

-- joins
c:seam({ { 27, 38 }, { 52, 38 } })
c:button(38, 76)
c:seam({ { 22, 76 }, { 33, 79 } }); c:seam({ { 47, 79 }, { 57, 76 } })

local t = c:save(OUT .. "npc-abuela_quilla.aseprite", OUT .. "npc-abuela_quilla.png")
print(GV.report(t))
