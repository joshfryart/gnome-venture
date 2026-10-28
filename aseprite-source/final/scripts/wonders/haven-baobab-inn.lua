-- haven-baobab-inn.lua : "Baobab Inn. A guesthouse inside a giant baobab." ESA, golden-hour savanna. Warm light spills from the door.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV = L.GV
local c = L.new()
local W, H = L.W, L.H
local HOR = 84

-- sky: hazy golden hour, big sun low
L.sky(c, "warm", HOR)
c:fill(c:ellipse(52, 62, 20, 20), "#fbe8c0"); c:fill(c:ellipse(52, 62, 14, 14), "#fff1c8")
L.cloud(c, 170, 30, 18, "#fdf2d8", "#f5cc92"); L.cloud(c, 40, 24, 13, "#fdf2d8", "#f5cc92"); L.cloud(c, 210, 56, 12, "#fbe8c0", "#f0be80")
-- far hills + flat-topped acacias
c:part(c:poly({ {0,HOR+1},{0,76},{30,70},{70,74},{110,68},{150,74},{190,69},{W,74},{W,HOR+1} }), GV.ramp("#c9a070"), { gloss = false, rim = false, bounce = false, outline = false, cres = 3, deep = 4 })
local function acacia(x, y, s)
  c:part(c:rect(x - 1, y, x + 1, y + 10 * s), GV.ramp("#7a4a1f"), { flat = true, gloss = false, outline = false })
  c:part(c:ellipse(x, y - 1, 9 * s, 3 * s), GV.ramp("#7ea04e"), { gloss = false, cres = 2, deep = 3, outline = false })
end
acacia(16, 70, 1); acacia(212, 68, 1); acacia(188, 72, 0.8)
-- ground: dry grass
local ground = L.below(c, function(x) return HOR + 2 + math.sin(x / 22) * 1.5 end)
c:part(ground, GV.ramp("#d2b25c"), { gloss = false, rim = false, bounce = false, outline = false, cres = 4, deep = 8 })
-- grass tufts
for i = 0, 40 do
  local x = (i * 53 + 7) % W; local y = HOR + 8 + (i * 29) % 38
  c:px(x, y, "#a88a3e"); c:px(x + 1, y - 1, "#e8cf7a"); c:px(x + 2, y, "#a88a3e")
end
-- dirt path to the door
c:part(c:poly({ {106,H},{114,112},{126,112},{136,H} }), GV.ramp("#e0c08a"), { gloss = false, rim = false, bounce = false, outline = false, cres = 3, deep = 6 })

-- the baobab (one part: bottle trunk + fat branches)
local trunk = c:poly({ {86,112},{94,100},{100,86},{103,70},{106,54},{108,46},{132,46},{134,54},{137,70},{140,86},{146,100},{154,112},{138,116},{120,117},{102,116} })
for _, b in ipairs({
  { { {108,50},{96,40},{82,32},{70,30} }, 5 }, { { {113,48},{111,36},{106,24},{102,18} }, 5 },
  { { {127,48},{129,36},{134,24},{138,18} }, 5 }, { { {132,50},{144,40},{158,32},{170,30} }, 5 },
}) do trunk:add(c:line(b[1], b[2])) end
c:part(trunk, GV.ramp("#b08a60"), { cres = 5, deep = 8, gloss = false })
for _, s in ipairs({ { {102,64},{104,80},{100,96} }, { {116,56},{117,72},{114,86} }, { {128,60},{130,76},{134,90} }, { {140,84},{142,96} } }) do
  c:seam(s, { free = true, on = 3, off = 0, gap = "#8a6a44" })
end
local function clump(x, y, r)
  c:part(c:ellipse(x, y, r, r * 0.7), GV.ramp("#6aa04a"), { cres = 3, deep = 5, gloss = false })
  c:px(x - r * 0.4, y - r * 0.3, "#a4d070")
end
clump(66, 28, 9); clump(100, 16, 8); clump(140, 16, 8); clump(174, 28, 9); clump(88, 33, 6); clump(152, 33, 6); clump(120, 30, 6)
for _, p in ipairs({ {72,38},{168,38},{110,28} }) do
  c:part(c:ellipse(p[1], p[2], 2, 3), GV.ramp("#c9b070"), { flat = true, gloss = false })
end
-- door: arch cut into the trunk, warm light inside
local door = c:rrect(108, 92, 132, 114, 8)
door:add(c:rect(108, 100, 132, 114))
c:part(door, GV.ramp("#f5b860"), { outline = false, gloss = false, cres = 2, deep = 3, contour = "#2a1a10", rim = false })
c:fill(c:rect(110, 104, 130, 114), "#f0a848")
c:fill(c:rect(110, 111, 124, 112), "#d6322b")
c:fill(c:rect(126, 108, 130, 114), "#7a4a1f")
c:fill(c:rect(121, 94, 121, 97), "#2a1a10"); c:part(c:ellipse(121, 99, 1.5, 1.5), GV.ramp("#fff1c8"), { flat = true, gloss = false, outline = false })
c:part(c:rect(104, 114, 136, 117), GV.ramp("#7a4a1f"), { gloss = false, cres = 2, deep = 3 })
-- round windows, lit
for _, w in ipairs({ { 110, 70 }, { 130, 70 } }) do
  c:part(c:ellipse(w[1], w[2], 4, 4), GV.ramp("#f5cf6a"), { cres = 2, deep = 3, gloss = false, contour = "#2a1a10" })
  c:fill(c:rect(w[1], w[2] - 3, w[1], w[2] + 3), "#c98a3a")
end
-- balcony with rope rail + hanging sign
c:part(c:rect(96, 80, 144, 83), GV.ramp("#8a5a2e"), { gloss = false, cres = 2, deep = 3 })
for x = 98, 142, 6 do c:fill(c:rect(x, 75, x, 79), "#5a3a1e") end
c:seam({ {96, 75}, {144, 75} }, { free = true, on = 2, off = 1 })
c:fill(c:rect(120, 84, 120, 86), "#5a3a1e")
c:part(c:rrect(114, 86, 126, 91, 1), GV.ramp("#d8b888"), { flat = true, gloss = false })
c:fill(c:ellipse(120, 88.5, 2, 2), "#f5cf6a"); c:fill(c:ellipse(121, 87.5, 2, 2), "#d8b888")
for i = 0, 10 do
  local x = 90 + i * 6; local y = 100 + math.floor(math.sin(i / 10 * math.pi) * 3)
  c:px(x, y - 1, "#5a3a1e"); c:fill(c:rect(x, y, x + 1, y + 1), (i % 2 == 0) and "#f5cf6a" or "#e0501f")
end
local function bird(x, y)
  c:part(c:ellipse(x, y, 6, 5), GV.ramp("#2a2a38"), { cres = 3, deep = 4, gloss = false })
  c:part(c:ellipse(x + 3, y + 2, 3, 3), GV.ramp("#f2e4c0"), { flat = true, gloss = false, outline = false })
  c:part(c:poly({ {x + 5, y - 2}, {x + 12, y}, {x + 6, y + 3} }), GV.ramp("#f2a030"), { flat = true, gloss = false })
  c:eye(x - 1, y - 4, true)
end
bird(84, 29)
local mx, my = 152, 112
c:part(c:ellipse(mx, my - 2, 5, 8), GV.ramp("#c9a070"), { cres = 3, deep = 5, gloss = false })
c:part(c:ellipse(mx, my - 12, 5, 5), GV.ramp("#d8b888"), { cres = 3, deep = 4, gloss = false })
c:eye(mx - 4, my - 15, true); c:eye(mx + 0, my - 15, true)
c:px(mx - 2, my - 9, "#2a1a10"); c:px(mx - 1, my - 8, "#2a1a10")
c:ground(mx, my + 7, 8, 2)
for _, j in ipairs({ { 80, 119 }, { 168, 119 } }) do
  c:part(c:ellipse(j[1], j[2], 5, 5), GV.ramp("#c9703a"), { cres = 3, deep = 5 }); c:part(c:rect(j[1] - 2, j[2] - 8, j[1] + 2, j[2] - 4), GV.ramp("#c9703a"), { flat = true, gloss = false })
  c:ground(j[1], j[2] + 5, 6, 1)
end
c:ground(120, 117, 38, 3)
L.finish(c, "haven-baobab-inn")
