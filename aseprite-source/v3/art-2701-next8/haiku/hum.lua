-- hum (tag "hum": Charm that also calms the creature). Haiku first pass.
-- Two beamed eighth notes in sea blue with a calm moss ripple under them; a small cream sparkle for the charm.
-- quirk: the ripple, the calming part of the tag.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local OUT = app.params.out or (DIR .. "/")
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "hum" }

local notes = HP.ellipse(21, 45, 6, 4)
  :add(HP.ellipse(41, 40, 6, 4))
  :add(HP.line({ {26, 44}, {26, 14} }, 2))
  :add(HP.line({ {46, 39}, {46, 9} }, 2))
  :add(HP.poly({ {26, 14}, {47, 8}, {47, 15}, {26, 21} }))
c:part(notes, "sea", { band = 1 })

local tok = { r = { name = "ripple" } }
HP.line({ {8, 55}, {14, 52}, {20, 55}, {26, 52}, {32, 55} }, 1):each(function(x, y) c:put(x, y, P.moss.base, tok) end)

c:sparkle(54, 24)
c:finish{ outline = true }
HP.assertClean(c)
c:save{ aseprite = OUT .. "hum.aseprite", png = OUT .. "hum.png", scale = 1 }
