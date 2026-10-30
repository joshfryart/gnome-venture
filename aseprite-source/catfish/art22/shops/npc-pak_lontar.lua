-- npc-pak_lontar.lua : Cat Fish pet shop keeper bust, Pak Lontar of Monsoon Mew Market (Monsoon Tangle, SEA).
-- claude/catfish-shops-art-spec.md (FRONT job). Matches the shipped villager busts (game/assets/img/ph/npc-*.png,
-- scripts in aseprite-source/final/scripts/ph/npc-*.lua): 80 x 100, gvlib "bust" mode (1 px umber outline +1
-- lower right, 1 px #000000 border, none on the bottom edge), pale round disc behind the head, locked eyes.
-- Pak Lontar: a kindly older gnome shopkeeper with warm brown skin, a black velvet peci cap with a gold thread
-- band, grey brows, sideburns and moustache, a big smile, an indigo batik shirt with gold diamond motifs. He holds
-- an upturned woven paddy-hat bed (a shop item) with the shop's ginger kitten peeking out, paws on the rim.
-- Run: AppRun -b --script npc-pak_lontar.lua   Writes ../out/npc-pak_lontar.png + .aseprite
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../../gvlib/gvlib.lua")
local OUT = here .. "/../out/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }

local SKIN  = GV.ramp("#a8693f", { gloss = "#e0a868", dot = "#f0c890" })
local BATIK = GV.ramp("#3e5a9a")
local PECI  = GV.ramp("#3a2c44", { gloss = "#6e5a86", dot = "#8a76a2", rim = "#54447f" })
local STRAW = GV.ramp("#d9a85a", { pale = false })
local GINGER = GV.ramp("#e8913a")
local GREY  = "#c9c5bc"

local disc = c:ellipse(39.5, 48, 35, 35)
local coat = c:ellipse(39.5, 108, 36, 34)
local head = c:ellipse(39.5, 53, 19.5, 16)
local cap  = c:rrect(20, 23, 59, 42, 6):add(c:rect(19, 37, 60, 42))
local neck = c:poly({ { 31, 66 }, { 48, 66 }, { 40, 78 } })

c:build{
  { "disc", disc, "#b8d8d2", { contour = false, gloss = false } },
  { "coat", coat, BATIK, { stitch = { side = "lit" } } },
}
-- batik motif: gold diamonds with a dark eye, staggered rows (drawn on the shirt before the hat covers it)
for row = 0, 4 do
  for col = 0, 9 do
    local x = 2 + col * 8 + (row % 2) * 4
    local y = 79 + row * 6
    if coat:has(x + 1, y + 1) and coat:has(x + 1, y - 2) and coat:has(x - 1, y + 1) and coat:has(x + 3, y + 1) then
      c:paint({ ".g.", "gdg", ".g." }, x, y, { g = "#f5cf6a", d = "#2a3c6c" })
    end
  end
end
c:build{
  { "neck", neck, SKIN, { flat = true } },
}
-- collar flaps
c:build{
  { "collarL", c:poly({ { 26, 72 }, { 34, 72 }, { 39, 81 }, { 30, 78 } }), "#f1ece0", { flat = true } },
  { "collarR", c:poly({ { 46, 72 }, { 54, 72 }, { 50, 78 }, { 41, 81 } }), "#f1ece0", { flat = true } },
}
c:build{
  { "head", head, SKIN },
  { "cap",  cap,  PECI, { gloss = { 26, 28 } } },
}
-- gold thread band along the cap hem (a real join)
c:seam({ { 20, 39 }, { 59, 39 } })
-- grey sideburns under the cap
c:fill(c:rect(20, 43, 22, 50):add(c:rect(57, 43, 59, 50)), GREY)
c:fill(c:rect(22, 49, 22, 50):add(c:rect(57, 49, 57, 50)), "#8b8f96")
-- brows, eyes, nose, moustache, smile
c:paint({ ".bbbb", "b...." }, 28, 45, { b = GREY })
c:paint({ "bbbb.", "....b" }, 46, 45, { b = GREY })
c:eye(29, 48); c:eye(46, 48)
c:paint({ ".nn.", "nnnn", ".ss." }, 38, 53, { n = SKIN.rim, s = SKIN.shade })
c:paint({
  "..gggg..gggg..",
  ".gggggggggggg.",
  "ggggss..ssgggg",
  "gs..........sg",
}, 33, 56, { g = GREY, s = "#8b8f96" })
c:paint({ "u........u", ".uu....uu.", "...uuuu..." }, 35, 60, { u = "#2a1a10" })
c:paint({ "rrrr" }, 38, 61, { r = "#dd3a2a" }) -- tongue of the open smile
-- smile lines at the eye corners
c:px(26, 51, SKIN.shade); c:px(25, 50, SKIN.shade)
c:px(53, 51, SKIN.shade); c:px(54, 50, SKIN.shade)

-- the upturned paddy-hat bed (a cone turned over), with the ginger kitten peeking out
local bowl = c:poly({ { 8, 90 }, { 72, 90 }, { 48, 103 }, { 31, 103 } })
local rim  = c:ellipse(39.5, 90, 31, 3.5)
local kitten = c:ellipse(39.5, 80, 11, 7)
kitten:add(c:poly({ { 29, 79 }, { 30, 68 }, { 37, 74 } })):add(c:poly({ { 42, 74 }, { 49, 68 }, { 50, 79 } }))
c:build{
  { "kitten", kitten, GINGER, { gloss = { 32, 75 } } },
}
c:fill(c:poly({ { 31, 75 }, { 31, 71 }, { 35, 74 } }), "#f6b8cf")
c:fill(c:poly({ { 44, 74 }, { 48, 71 }, { 48, 75 } }), "#f6b8cf")
-- tabby stripes on the crown
c:fill(c:rect(37, 74, 37, 75):add(c:rect(39, 73, 40, 75)):add(c:rect(42, 74, 42, 75)), GINGER.shade)
c:eye(32, 77); c:eye(43, 77)
c:fill(c:rect(36, 83, 43, 85):add(c:rect(37, 86, 42, 86)), "#f1ece0") -- muzzle
c:fill(c:rect(39, 82, 40, 83), "#dd3a2a")                       -- nose
c:paint({ "u..u", ".uu." }, 38, 84, { u = "#4a2c1a" })           -- small happy mouth
c:build{
  { "bowl", bowl, STRAW, { gloss = false } },
  { "rim",  rim,  STRAW, { flat = true } },
  { "pawL", c:ellipse(31.5, 89, 3, 1.6), GINGER, { flat = true } },
  { "pawR", c:ellipse(47.5, 89, 3, 1.6), GINGER, { flat = true } },
  { "handL", c:ellipse(10, 94, 5, 4.5), SKIN, { gloss = false } },
  { "handR", c:ellipse(69, 94, 5, 4.5), SKIN, { gloss = false } },
}
-- woven straw: plaits running down to the cone tip
for i = 0, 10 do
  local x = 14 + i * 5.2
  c:fill(c:line({ { x, 94 }, { 39.5 + (x - 39.5) * 0.4, 100 } }, 1):clip(bowl):cut(c:ellipse(10, 94, 6, 5.5)):cut(c:ellipse(69, 94, 6, 5.5)), STRAW.shade)
end
c:seam({ { 12, 92 }, { 67, 92 } })
c:px(30, 89, GINGER.shade); c:px(32, 89, GINGER.shade); c:px(46, 89, GINGER.shade); c:px(48, 89, GINGER.shade) -- toes

local t = c:save(OUT .. "npc-pak_lontar.aseprite", OUT .. "npc-pak_lontar.png")
print(GV.report(t))
