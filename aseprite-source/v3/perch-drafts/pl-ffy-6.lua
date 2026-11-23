-- pl-ffy-6-perch.lua : chibi moon-moth pal on its perch (36x36)
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-ffy-6-perch-20261120-182858/"
local GV = dofile(D .. "gvlib/gvlib.lua")
-- palette: #2b1c26 #f8f48a #d4ea58 #c5c99e #6a5684 #7a5a82 #e1eed6 #4c3b6a #9a7e8f #fffacc #8ea47f (+ black border n/a)
GV.C.ol1 = "#6a5684"; GV.C.ol2 = "#2b1c26"; GV.C.ol3 = "#2b1c26" -- examples use one dark outline
GV.C.halo = "#fffacc"                                            -- eye cream

local P = { ink="#2b1c26", glow="#f8f48a", lime="#d4ea58", grey="#c5c99e",
  purple="#6a5684", mauve="#7a5a82", pale="#e1eed6", dusk="#4c3b6a",
  pink="#9a7e8f", cream="#fffacc", sage="#8ea47f" }

local c = GV.canvas{ w = 36, h = 36, mode = "scene", ol = 1, olx = 1, cres = 2, deep = 2 }

local rampHead  = GV.ramp(P.mauve, { deep = P.dusk })
local rampBelly = GV.ramp(P.lime, { gloss = P.glow, dot = P.cream, rim = P.pale,
  shade = "#9da860", deep = "#7a8455", bounce = "#c8cd7a" })
local rampWing  = GV.ramp(P.grey, { shade = P.sage, deep = P.purple, bounce = P.sage })
local rampAnt   = GV.ramp(P.dusk, { rim = P.purple })
local rampClub  = { base = P.glow, rim = P.cream, gloss = P.cream, dot = P.cream,
                    shade = P.lime, deep = P.grey, bounce = P.lime, pale = true }
local rampWood  = GV.ramp("wood")

local p = c:build{
  { "wingL", c:poly({{11,14},{2,19},{8,26},{13,21}}), rampWing },
  { "wingR", c:poly({{22,14},{31,19},{25,26},{20,21}}), rampWing },
  { "clubL", c:rect(6,2,8,3), rampClub, { flat = true } },
  { "clubR", c:rect(24,2,26,3), rampClub, { flat = true } },
  { "body",  c:ellipse(16.5, 21, 7, 6), rampBelly },
  { "stemL", c:line({{12,7},{9,4}}, 2), rampAnt, { flat = true, outline = false } },
  { "stemR", c:line({{21,7},{24,4}}, 2), rampAnt, { flat = true, outline = false } },
  { "perch", c:rrect(7,28,26,30,1), rampWood, { flat = true } },
  { "head",  c:ellipse(16.5, 10, 8, 6.5), rampHead, { deep = 1 } },
  { "footL", c:rrect(12,26,13,28,0), rampAnt, { flat = true, outline = false, contact = true } },
  { "footR", c:rrect(20,26,21,28,0), rampAnt, { flat = true, outline = false, contact = true } },
}

-- texture: hand-placed, tone-on-tone, following the form
for _, v in ipairs({ {7,17},{6,18},{5,19} }) do c:px(v[1], v[2], P.sage) end   -- L vein
for _, v in ipairs({ {25,17},{26,18},{27,19} }) do c:px(v[1], v[2], P.sage) end -- R vein
c:px(9,29,"#8a4f2a"); c:px(10,29,"#8a4f2a"); c:px(23,29,"#d9a660")            -- wood grain
c:px(13,23,"#f8f48a"); c:px(19,25,"#f8f48a")                                   -- belly flecks
c:px(21,25,"#d4ea58")                                                          -- dither into deep
c:px(21,14,"#816575")                                                          -- dither into head deep
c:px(8,3,P.cream); c:px(26,3,P.cream)                                          -- worn club tips

-- details: lantern glow, face, sparkles
c:fill(c:ellipse(16.5, 22.5, 2.5, 1.8), "#f8f48a")
c:px(16,22,"#fffacc"); c:px(17,22,"#fffacc"); c:px(16,23,"#fffacc")
c:eye(11,8,true); c:eye(19,8,true)
c:px(10,13,"#ff9aa8"); c:px(22,13,"#ff9aa8")
c:px(16,13,P.ink)
local LEG = { g = P.glow, C = "#fffacc" }
c:paint({ ".g.", "gCg", ".g." }, 2, 5, LEG)
c:paint({ ".g.", "gCg", ".g." }, 29, 2, LEG)
c:px(3,6,P.cream); c:px(30,3,P.cream)

c:ground(16.5, 32.3, 10.5, 1, "#6a5684")

local t = c:save(D .. "out/pl-ffy-6-perch.aseprite", D .. "out/pl-ffy-6-perch.png")
print(GV.report(t))
