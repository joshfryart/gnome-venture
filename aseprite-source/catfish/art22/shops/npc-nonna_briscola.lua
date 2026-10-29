-- npc-nonna_briscola.lua : shopkeeper bust for The Olive Pantry Pets (Olivewhistle Shore, SE), Cat Fish pet shops.
-- Nonna Briscola: a smiling gnome grandmother in a red polka-dot headscarf (soft gnome peak, knotted under the
-- chin), white curls, olive knitted shawl over a dusk dress, hugging a stitched felt sardine cat toy.
-- House bust format: 80x100, gvlib "bust" mode (1 px umber outline + 1 px black border, open at the bottom),
-- pale backdrop disc, locked eyes. Run: AppRun -b --script npc-nonna_briscola.lua -> ../out/npc-nonna_briscola.png
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../../gvlib/gvlib.lua")
local OUT = here .. "/../out/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }

local sky    = GV.ramp("#b8d8e0")                      -- backdrop: Mediterranean sky
local dress  = GV.R.dusk
local shawl  = GV.ramp("#8f9a4f", { gloss = "#c8d77a", rim = "#a4b86a" })   -- olive knit
local scarfR = GV.R.red
local cream  = GV.ramp("#f1ece0", { dot = "#fff3c8" })  -- curls, blouse
local fish   = GV.ramp("#3f8fb0", { gloss = "#c8ecdc", dot = "#eaf8e4", rim = "#8fcbd8", bounce = "#5a86b8", shade = "#2f6290", deep = "#2a3c6c" })

-- shapes
local disc  = c:ellipse(39.5, 50, 36, 36)
local body  = c:ellipse(39.5, 102, 34, 24)
local blouse = c:poly({ { 30, 78 }, { 49, 78 }, { 44, 90 }, { 35, 90 } })
local shawlL = c:poly({ { 6, 100 }, { 9, 86 }, { 18, 79 }, { 31, 77 }, { 38, 92 }, { 36, 100 } })
local shawlR = c:poly({ { 74, 100 }, { 71, 86 }, { 62, 79 }, { 49, 77 }, { 42, 92 }, { 44, 100 } })
local scarf = c:ellipse(39.5, 47, 25, 24):cut(c:rect(0, 70, 79, 99))
scarf:add(c:poly({ { 31, 27 }, { 45, 12 }, { 50, 12 }, { 53, 18 }, { 52, 28 } }))   -- soft gnome peak, tipped right
local face  = c:ellipse(39.5, 57, 18, 16)
local knot  = c:ellipse(39.5, 74.5, 4.5, 3.5)
local tails = c:poly({ { 36, 75 }, { 31, 83 }, { 35, 84 }, { 39, 77 } }):add(c:poly({ { 41, 77 }, { 45, 84 }, { 48, 82 }, { 43, 75 } }))
local curls = c:mask()
for _, q in ipairs({ { 25, 45, 3.5 }, { 31, 42, 3.5 }, { 37, 40.5, 3.5 }, { 43, 40.5, 3.5 }, { 49, 42, 3.5 }, { 55, 45, 3.5 },
                     { 22.5, 51, 2.5 }, { 57, 51, 2.5 } }) do curls:add(c:ellipse(q[1], q[2], q[3], 2.5)) end
curls:clip(face:grow(2)):cut(c:rect(0, 47, 79, 99):clip(face:shrink(2)))
local nose  = c:ellipse(39.5, 59.5, 4, 3.5)
-- felt sardine toy held across the chest
local fbody = c:ellipse(37, 90, 18, 6.5)
local ftail = c:poly({ { 52, 90 }, { 63, 82 }, { 61, 90 }, { 64, 98 } })
local fbelly = c:ellipse(37, 93.5, 15, 3):clip(fbody)
local handL = c:ellipse(26, 91.5, 3.5, 4)
local handR = c:ellipse(50, 91.5, 3.5, 4)

local p = c:build{
  { "disc",   disc,   sky,    { solid = false, gloss = false } },
  { "body",   body,   dress,  { gloss = false } },
  { "blouse", blouse, cream,  { gloss = false } },
  { "shawlL", shawlL, shawl,  { gloss = false, stitch = { side = "lit" } } },
  { "shawlR", shawlR, shawl,  { gloss = false } },
  { "scarf",  scarf,  scarfR, { stitch = { side = "lit" } } },
  { "face",   face,   "skin", { gloss = { 27, 47 } } },
  { "curls",  curls,  cream,  { flat = true } },
  { "nose",   nose,   "skin", { gloss = false } },
  { "tails",  tails,  scarfR, { gloss = false } },
  { "knot",   knot,   scarfR, { gloss = false } },
  { "ftail",  ftail,  fish,   { gloss = false } },
  { "fbody",  fbody,  fish,   { gloss = { 24, 86 } } },
  { "fbelly", fbelly, cream,  { gloss = false, contour = false } },
  { "handL",  handL,  "skin", { gloss = false } },
  { "handR",  handR,  "skin", { gloss = false } },
}

-- polka dots on the headscarf (cream, avoid the gloss and the edge)
for _, d in ipairs({ { 22, 38 }, { 31, 31 }, { 41, 27 }, { 50, 33 }, { 57, 41 }, { 18, 50 }, { 60, 52 }, { 46, 17 },
                     { 26, 63 }, { 55, 64 } }) do
  if p.scarf.m:has(d[1], d[2]) and p.scarf.m:has(d[1] + 1, d[2] + 1) and not p.face.m:has(d[1], d[2]) then
    c:fill(c:rect(d[1], d[2], d[1] + 1, d[2] + 1), "#f1ece0"); c:px(d[1] + 1, d[2] + 1, "#d8c49a")
  end
end
c:part(c:rrect(48, 9, 52, 13, 1), GV.R.gold, { flat = true })   -- bead on the peak

-- face: locked eyes set wide, white brows, crow's feet, big kind smile
c:eye(28, 50); c:eye(47, 50)
c:fill(c:rect(27, 47, 32, 47), "#fff3c8"); c:fill(c:rect(47, 47, 52, 47), "#fff3c8")
c:px(26, 48, "#fff3c8"); c:px(53, 48, "#fff3c8")
c:px(25, 51, "#c47a52"); c:px(25, 53, "#c47a52"); c:px(54, 51, "#c47a52"); c:px(54, 53, "#c47a52")
c:paint({
  "u...........u",
  ".u.........u.",
  "..uuuuuuuuu..",
  "...urrrrru...",
  "....uuuuu....",
}, 33, 63, { u = "#2a1a10", r = "#ae2a2a" })

-- blouse lace collar + cameo button
for x = 32, 47, 2 do c:px(x, 79, "#d8c49a") end
c:button(38, 85)

-- shawl knit ribs
for _, s in ipairs({ { 12, 90 }, { 17, 86 }, { 23, 83 }, { 14, 96 }, { 20, 93 } }) do
  c:px(s[1], s[2], "#6f7a3a"); c:px(s[1] + 1, s[2] + 1, "#6f7a3a")
end
for _, s in ipairs({ { 66, 90 }, { 61, 86 }, { 56, 83 }, { 64, 96 }, { 59, 93 } }) do
  c:px(s[1], s[2], "#6f7a3a"); c:px(s[1] - 1, s[2] + 1, "#6f7a3a")
end

-- sardine details: seam along the side, button eye, gill, tail rays, a green catnip patch
c:seam({ { 22, 90 }, { 51, 90 } })
c:button(22, 86)
c:fill(c:line({ { 28, 85 }, { 27, 88 }, { 28, 91 } }, 1), "#2f6290")
c:fill(c:rect(58, 86, 58, 94), "#2f6290")
c:part(c:rrect(41, 85, 45, 88, 1), GV.R.moss, { flat = true })

local t = c:save(OUT .. "npc-nonna_briscola.aseprite", OUT .. "npc-nonna_briscola.png")
print(GV.report(t))
