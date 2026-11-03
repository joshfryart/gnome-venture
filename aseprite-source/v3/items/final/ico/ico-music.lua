-- ico-music first draft (Sonnet). quirk: a green sprout leaf grows out of the beam of the notes
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA7.lua")
local HP, INK, CR = D.HP, D.INK, D.CR
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local c = D.new("ico-music")
local NOTE = D.PLUM
local h1 = D.ell(19, 46, 8, 6, -0.4)
local h2 = D.ell(43, 41, 8, 6, -0.4)
-- stems
D.fill(c:rect(24, 14, 26, 44), "#4a2463")
D.fill(c:rect(48, 9, 50, 39), "#4a2463")
D.fill(c:rect(24, 14, 24, 44), "#7a3a8a") D.fill(c:rect(48, 9, 48, 39), "#7a3a8a")
-- beam
local beam = c:poly{ {24, 14}, {50, 7}, {50, 15}, {24, 22} }
D.lit(beam, NOTE, 2.5)
D.fill(c:poly{ {24, 24}, {50, 17}, {50, 18}, {24, 25} }, "#4a2463")
D.lit(h1, NOTE, 5) D.lit(h2, NOTE, 5)
c:px(15, 43, "#e2a8cc") c:px(16, 43, "#e2a8cc") c:px(39, 38, "#e2a8cc") c:px(40, 38, "#e2a8cc")
-- sprout leaf from beam
D.ln(37, 11, 37, 5, "#3f9150") D.ln(38, 11, 38, 5, "#3f9150")
D.leaf(37, 7, 45, 2, 3, "moss")
D.leaf(37, 8, 30, 3, 3, "moss")
c:sparkle(10, 24) c:sparkle(57, 28)
D.fin()
