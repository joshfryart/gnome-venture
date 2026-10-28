-- delve-salt-mine-galleries.lua : EE zone 2 delve. "Salt caves with carved gnome halls."
-- Lamp-lit cutaway of a salt mine: rosy-white salt walls, carved arched gnome doorways with lit windows, a carved-salt chandelier,
-- timber props, a rail cart of salt blocks and a chibi miner in a lamp helmet.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV, W, H = L.GV, L.W, L.H
local c = L.new()
local SLUG = "delve-salt-mine-galleries"
local SALT = GV.ramp("#e8d8d0", { gloss = "#fff3c8", dot = "#fff3c8", rim = "#f5d8c0", shade = "#b8a0b4", deep = "#6a5878" })
local FL = { gloss = false, rim = false, bounce = false, outline = false }

-- hall back wall: concentric warm-to-cool bands
c:fill(c:rect(0, 0, W - 1, H - 1), "#4a3a5a")
local bands = { "#56446a", "#665478", "#7a6888", "#8e7c98", "#a090a8" }
for i, col in ipairs(bands) do c:fill(c:ellipse(120, 70, 130 - i * 20, 76 - i * 10), col) end
-- carved block lines on the wall (salt bricks)
for y = 14, 100, 10 do
  c:seam({ {0, y}, {W - 1, y} }, { free = true, on = 3, off = 3, gap = "#4a3a5a" })
end

-- three carved arched gnome doorways in the back wall
local function door(cx, top, w, h, lit)
  local m = c:rect(cx - w, top + w, cx + w, top + h); m:add(c:ellipse(cx, top + w, w, w))
  -- stone surround (salt carved frame)
  c:part(m:grow(3), SALT, { cres = 3, deep = 5, gloss = false })
  c:fill(m, lit and "#5a3a2a" or "#2a1d2e")
  if lit then
    c:fill(m:copy():clip(c:rect(0, 0, W, top + h - 14)), "#8a5a30")
    c:fill(m:copy():clip(c:rect(0, 0, W, top + h - 26)), "#b07a45")
    c:fill(c:ellipse(cx, top + h - 10, w - 3, 8):clip(m), "#f5cf6a")
    c:fill(c:ellipse(cx, top + h - 10, w - 6, 5):clip(m), "#fff1c8")
  end
  -- carved keystone gem
  c:part(c:rect(cx - 1, top - 4, cx + 1, top - 2), GV.ramp("#e46a9b"), { flat = true, gloss = false })
end
door(52, 34, 11, 50, true); door(188, 34, 11, 50, true); door(120, 42, 9, 42, false)
-- tiny round window gnome-house fronts: little carved chimneys with lamp glow
for _, x in ipairs({ 22, 218 }) do
  c:part(c:rrect(x - 7, 70, x + 7, 98, 3), SALT, { cres = 3, deep = 5, gloss = false })
  c:fill(c:rect(x - 3, 76, x + 3, 84), "#f5cf6a"); c:fill(c:rect(x - 3, 76, x + 3, 77), "#fff1c8"); c:px(x, 80, "#b07a45"); c:fill(c:rect(x, 76, x, 84), "#b07a45")
  c:fill(c:rect(x - 3, 76, x + 3, 84), "#f5cf6a"); c:fill(c:rect(x, 76, x, 84), "#b07a45"); c:fill(c:rect(x - 3, 80, x + 3, 80), "#b07a45")
end

-- ceiling: salt vault with stalactites, crystal clusters
local ceil = c:poly({ {0,0},{W,0},{W,16},{216,22},{190,14},{160,24},{120,14},{80,24},{50,14},{22,22},{0,16} })
c:part(ceil, SALT, { cres = 5, deep = 8, gloss = false })
for _, s in ipairs({ {30,22,9},{72,24,13},{104,16,7},{140,16,9},{170,24,12},{206,20,8},{12,18,6} }) do
  c:part(c:poly({ {s[1]-3, s[2]-4}, {s[1]+3, s[2]-4}, {s[1], s[2]+s[3]} }), SALT, { cres = 2, deep = 3, gloss = false })
end
-- carved-salt chandelier in the middle: chain, ring, crystal pendants and candle flames
c:fill(c:rect(120, 14, 120, 34), "#b8a0b4"); c:fill(c:rect(121, 14, 121, 34), "#7a6888")
c:part(c:ellipse(120, 36, 22, 4), GV.ramp("#e8a317"), { cres = 2, deep = 4, gloss = false })
for _, dx in ipairs({ -18, -9, 0, 9, 18 }) do
  c:fill(c:rect(120 + dx - 1, 28, 120 + dx, 32), "#f2e4c0"); c:px(120 + dx - 1, 26, "#f5cf6a"); c:px(120 + dx - 1, 27, "#fff1c8")
  c:part(c:poly({ {120 + dx - 2, 40}, {120 + dx + 2, 40}, {120 + dx, 47} }), GV.ramp("#e8f0f8", { dot = "#fff3c8" }), { flat = true, gloss = false, pale = true })
end

-- timber props and beams
local function prop(x)
  c:part(c:rect(x - 3, 20, x + 3, 104), GV.ramp("#b07a45"), { cres = 3, deep = 5, gloss = false })
  c:part(c:rect(x - 8, 18, x + 8, 24), GV.ramp("#a8582f"), { cres = 2, deep = 4, gloss = false })
  c:seam({ {x - 1, 28}, {x - 1, 98} }, { free = true, on = 1, off = 6, gap = "#8a4f2a" })
end
prop(86); prop(154); 
-- hanging lamps on the props
for _, x in ipairs({ 86, 154 }) do
  c:fill(c:rect(x + 5, 30, x + 5, 36), "#2a1a10")
  c:part(c:rrect(x + 2, 36, x + 8, 44, 2), GV.ramp("#e8a317"), { cres = 2, deep = 3, gloss = false })
  c:fill(c:rect(x + 4, 38, x + 6, 42), "#fff1c8")
end
-- crystals on the wall
for _, p in ipairs({ {8,56},{232,52},{100,86},{140,84},{6,30},{234,26} }) do
  c:part(c:poly({ {p[0+1]-2, p[2]+6}, {p[1], p[2]}, {p[1]+2, p[2]+6} }), GV.ramp("#e8f0f8", { dot = "#fff3c8" }), { flat = true, gloss = false, pale = true })
  c:part(c:poly({ {p[1]+2, p[2]+6}, {p[1]+4, p[2]+2}, {p[1]+6, p[2]+6} }), GV.ramp("#c3b2ea"), { flat = true, gloss = false })
end

-- floor: grey salt dust with a plank walk, rails
local floor = L.below(c, function(x) return 104 end)
c:part(floor, GV.ramp("#a898a8", { shade = "#7a6888", deep = "#4a3a5a" }), { cres = 6, deep = 10, gloss = false })
-- rails
c:fill(c:rect(0, 116, W - 1, 117), "#5b6470"); c:fill(c:rect(0, 116, W - 1, 116), "#c9c5bc")
c:fill(c:rect(0, 124, W - 1, 125), "#5b6470"); c:fill(c:rect(0, 124, W - 1, 124), "#c9c5bc")
for x = 6, W, 12 do c:fill(c:rect(x, 114, x + 3, 127), "#8a4f2a"); c:fill(c:rect(x, 114, x, 127), "#b07a45") end
c:fill(c:rect(0, 116, W - 1, 116), "#c9c5bc"); c:fill(c:rect(0, 124, W - 1, 124), "#c9c5bc")

-- salt block stack (left foreground) and loose chunks
for _, b in ipairs({ {20,104,10},{36,104,10},{28,94,10} }) do
  c:part(c:rect(b[1] - b[3], b[2] - 10, b[1] + b[3] - 2, b[2]), SALT, { cres = 3, deep = 4, gloss = false })
  c:seam({ {b[1] - b[3] + 2, b[2] - 5}, {b[1] + b[3] - 4, b[2] - 5} }, { free = true, on = 2, off = 1, gap = "#b8a0b4" })
end
for _, p in ipairs({ {56,112,3,2},{70,118,2,1},{210,110,3,2},{226,118,3,1} }) do c:part(c:ellipse(p[1], p[2], p[3], p[4]), SALT, { flat = true, gloss = false }) end

-- mine cart loaded with salt blocks, centre-right
local CX = 160
c:part(c:ellipse(CX - 11, 123, 5, 5), GV.ramp("#5b6470"), { cres = 2, deep = 3, gloss = false }); c:part(c:ellipse(CX + 11, 123, 5, 5), GV.ramp("#5b6470"), { cres = 2, deep = 3, gloss = false })
c:part(c:poly({ {CX - 18, 100}, {CX + 18, 100}, {CX + 14, 118}, {CX - 14, 118} }), GV.ramp("#8a4f2a"), { cres = 4, deep = 6, gloss = false })
c:seam({ {CX - 15, 108}, {CX + 15, 108} }, { on = 2, off = 1 })
for _, b in ipairs({ {CX - 12, 92}, {CX, 92}, {CX - 6, 84} }) do
  c:part(c:rect(b[1], b[2], b[1] + 10, b[2] + 8), SALT, { cres = 3, deep = 4, gloss = false })
end
c:ground(CX, 124, 20, 2)

-- miner: chibi gnome-folk in a lamp helmet pushing the cart
local MX, MY = 112, 100
c:part(c:ellipse(MX, MY + 8, 8, 10), GV.ramp("#4e8a9a"), { cres = 4, deep = 6 })
c:part(c:rect(MX - 8, MY + 5, MX + 8, MY + 7), GV.ramp("#b07a45"), { flat = true, gloss = false, outline = false })
c:px(MX, MY + 6, "#e8a317")
for _, dx in ipairs({ -5, 3 }) do c:part(c:ellipse(MX + dx + 1, MY + 18, 3, 2), GV.ramp("#5e2f1e"), { flat = true, gloss = false }) end
-- arm pushing toward the cart
c:part(c:line({ {MX + 5, MY + 4}, {MX + 14, MY + 2}, {MX + 22, MY + 2} }, 3), GV.ramp("#4e8a9a"), { flat = true, gloss = false, outline = false })
-- head
c:part(c:ellipse(MX, MY - 6, 10, 8), GV.ramp("#f9d49c", { shade = "#d9a070", deep = "#a8644a" }), { cres = 3, deep = 5 })
-- beard (salt-white, gnome)
c:part(c:poly({ {MX - 7, MY + 2}, {MX + 7, MY + 2}, {MX + 4, MY + 10}, {MX, MY + 13}, {MX - 4, MY + 10} }), GV.ramp("#f2e4c0", { dot = "#fff3c8" }), { flat = true, gloss = false })
-- hard hat with lamp
c:part(c:ellipse(MX, MY - 16, 10, 6):clip(c:rect(0, 0, W, MY - 14)), GV.ramp("#e8a317"), { cres = 3, deep = 4 })
c:part(c:rect(MX - 12, MY - 15, MX + 12, MY - 14), GV.ramp("#e8a317"), { flat = true, gloss = false })
c:part(c:rect(MX - 3, MY - 22, MX + 3, MY - 17), GV.ramp("#f5cf6a"), { flat = true, gloss = false })
c:fill(c:rect(MX - 1, MY - 21, MX + 1, MY - 19), "#fff1c8")
c:eye(MX - 7, MY - 10); c:eye(MX + 2, MY - 10)
for _, p in ipairs({ {-2,0},{-1,1},{0,1},{1,1},{2,0} }) do c:px(MX + p[1], MY + p[2], "#2a1a10") end
-- lamp beam: little rays on the wall
for _, p in ipairs({ {MX - 6, MY - 26}, {MX - 2, MY - 28}, {MX + 4, MY - 27}, {MX + 9, MY - 24} }) do c:px(p[1], p[2], "#fff1c8") end
c:ground(MX, MY + 20, 12, 2)

-- drifting salt dust motes
for _, p in ipairs({ {70,60},{100,52},{140,60},{170,68},{50,90},{200,80},{30,70} }) do c:px(p[1], p[2], "#fff3c8") end

L.finish(c, SLUG)
