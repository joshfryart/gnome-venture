-- delve-firefly-caves: a dark cave lake lit by a swarm of fireflies; a few big chibi fireflies up close. SEA, night cave.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV, W, H = L.GV, L.W, L.H
local c = L.new()
local LAKE = 92

-- far cave wall with a dim moonlit exit far away
c:bands(c:rect(0, 0, W - 1, LAKE), { "#0e0e24", "#14142e", "#1a1a3a", "#20224a", "#262c58", "#2c3666" }, { dir = "v" })
c:fill(c:rrect(104, 54, 136, LAKE + 4, 14), "#3a4a8a"); c:fill(c:rrect(108, 58, 132, LAKE + 4, 12), "#6a86c0"); c:fill(c:rrect(113, 64, 127, LAKE + 4, 8), "#a8c4e0")
c:fill(c:rect(118, 70, 122, 76), "#e2f0e0")
-- far jungle silhouette in the exit
c:fill(c:poly({ {108,LAKE},{112,80},{118,86},{124,78},{130,84},{132,LAKE} }), "#2f5a6a")
-- lake with night colours
c:bands(c:rect(0, LAKE + 1, W - 1, H - 1), { "#183a54", "#16344e", "#142e48", "#122842", "#10223a", "#0e1c32" }, { dir = "v" })

-- ceiling and walls -------------------------------------------------------------------------------------------------------------
local ceil = c:poly({ {0,0},{W,0},{W,22},{210,26},{180,20},{150,30},{120,22},{90,32},{60,22},{30,28},{0,20} })
c:part(ceil, GV.ramp("#3a3050"), { cres = 6, deep = 10, gloss = false, rim = false })
local lw = c:poly({ {0,0},{0,H},{26,H},{22,110},{30,84},{20,64},{30,40},{22,22} })
c:part(lw, GV.ramp("#34304e"), { cres = 5, deep = 9, gloss = false, rim = false })
local rw = c:poly({ {W,0},{W,H},{214,H},{218,110},{210,86},{222,66},{212,42},{220,22} })
c:part(rw, GV.ramp("#34304e"), { cres = 5, deep = 9, gloss = false, rim = false })
-- stalactites
for _, p in ipairs({ {40,26,14},{64,24,18},{82,30,10},{98,30,20},{122,24,12},{142,28,22},{162,28,10},{178,22,16},{198,26,12} }) do
  c:part(c:poly({ {p[1]-4,p[2]},{p[1],p[2]+p[3]},{p[1]+4,p[2]} }), GV.ramp("#4a4066"), { flat = true, gloss = false })
end
-- rock texture lines
for _, l in ipairs({ { {4,30},{14,34} }, { {6,60},{16,66} }, { {222,34},{234,40} }, { {226,70},{236,74} }, { {70,6},{100,8} }, { {150,8},{190,6} } }) do c:fill(c:line(l, 1), "#1c1830") end

-- floor ledges (left and right) and stalagmites -----------------------------------------------------------------------------------
local lf = c:poly({ {0,H},{0,108},{30,102},{54,106},{70,114},{86,H} })
c:part(lf, GV.ramp("#4a4066"), { cres = 6, deep = 10, gloss = false })
local rf = c:poly({ {W,H},{W,104},{196,100},{172,108},{160,H} })
c:part(rf, GV.ramp("#4a4066"), { cres = 6, deep = 10, gloss = false })
for _, p in ipairs({ {96,H-6,8,12},{108,H-3,5,8},{136,H-5,6,9} }) do
  c:part(c:poly({ {p[1]-p[3],p[2]+3},{p[1],p[2]-p[4]},{p[1]+p[3],p[2]+3} }), GV.ramp("#4a4066"), { flat = true, gloss = false })
end
-- the lake: reflected exit and ripples
c:fill(c:rect(112, LAKE + 6, 128, LAKE + 6), "#6a86c0"); c:fill(c:rect(116, LAKE + 10, 124, LAKE + 10), "#3a4a8a"); c:fill(c:rect(118, LAKE + 15, 122, LAKE + 15), "#2a3a70")
for i, p in ipairs({ {40,100,12},{150,98,10},{70,112,14},{160,118,12},{96,104,8},{130,124,14},{190,112,10} }) do c:fill(c:rect(p[1], p[2], p[1] + p[3], p[2]), "#24507a") end

-- glowing mushrooms on the ledges -----------------------------------------------------------------------------------------------------
local function shroom(x, y, col, sz)
  c:fill(c:rect(x, y - sz, x + 1, y), "#d8d0b0")
  c:part(c:ellipse(x + 0.5, y - sz - 1, sz + 1.5, sz * 0.7 + 1), GV.ramp(col), { cres = 2, deep = 3, gloss = false })
  c:px(x - 1, y - sz - 2, "#fff1c8"); c:px(x + 2, y - sz - 2, "#fff1c8")
end
shroom(12, 104, "#5ad8c8", 5); shroom(22, 106, "#e46a9b", 3); shroom(38, 104, "#5ad8c8", 3)
shroom(206, 102, "#e46a9b", 5); shroom(222, 104, "#5ad8c8", 4); shroom(188, 100, "#5ad8c8", 2)
-- shroom glow on the ledge
for _, x in ipairs({ 6, 14, 30 }) do c:fill(c:rect(x, 107, x + 6, 107), "#5ad8c8") end

-- an outrigger canoe waiting on the lake ----------------------------------------------------------------------------------------------------
local CX, CY = 76, 118
c:part(c:poly({ {CX-22,CY},{CX+24,CY},{CX+30,CY-6},{CX+22,CY+6},{CX-16,CY+6},{CX-28,CY-4} }), GV.ramp("#a8582f"), { cres = 3, deep = 5, gloss = false })
c:fill(c:rect(CX - 20, CY, CX + 22, CY), "#d9a660")
c:fill(c:line({ {CX - 12, CY - 1}, {CX - 12, CY + 5} }, 1), "#5e2f1e"); c:fill(c:line({ {CX + 6, CY - 1}, {CX + 6, CY + 5} }, 1), "#5e2f1e")
c:fill(c:line({ {CX - 8, CY - 2}, {CX - 8, CY - 14} }, 1), "#7a4a1f")   -- paddle
c:part(c:ellipse(CX - 8, CY - 16, 3, 4), GV.ramp("#d9a660"), { flat = true, gloss = false })
c:fill(c:line({ {CX - 6, CY + 3}, {CX - 30, CY + 4}, {CX - 32, CY + 10} }, 1), "#5e2f1e"); c:fill(c:rect(CX - 38, CY + 8, CX - 24, CY + 10), "#7a4a1f")   -- outrigger float
c:fill(c:rect(CX - 30, CY + 12, CX + 28, CY + 12), "#24507a")

-- the swarm: tiny fireflies, each a 1 px spark with a dim cross; reflected in the lake ---------------------------------------------------------
local s = 41
local function rnd(n) s = (s * 1103515245 + 12345) % 2147483648; return s % n end
for i = 1, 48 do
  local x, y = 24 + rnd(W - 48), 18 + rnd(100)
  if y < LAKE or rnd(3) == 0 then
    c:px(x - 1, y, "#4a8a3e"); c:px(x + 1, y, "#4a8a3e"); c:px(x, y - 1, "#4a8a3e"); c:px(x, y + 1, "#4a8a3e")
    c:px(x, y, (i % 3 == 0) and "#fff1c8" or "#c8d77a")
    if y < LAKE - 2 and rnd(2) == 0 then
      local ry = LAKE + (LAKE - y) // 2 + 3
      if ry < H - 8 then c:px(x, ry, "#6a9a3a"); c:px(x + 1, ry, "#4a8a3e") end
    end
  end
end

-- big friendly fireflies up close ------------------------------------------------------------------------------------------------------------------
local function fly(x, y, sc)
  c:part(c:ellipse(x - 10, y - 12, 8, 4), GV.ramp("#cfd6e8"), { flat = true, gloss = false, outline = false })   -- wings
  c:part(c:ellipse(x + 10, y - 12, 8, 4), GV.ramp("#cfd6e8"), { flat = true, gloss = false, outline = false })
  c:fill(c:ellipse(x, y + 8, 14, 12):grow(2):clip(c:rect(0, 0, W, H)), "#3a4a2a")           -- soft glow halo, hard-edged
  c:fill(c:ellipse(x, y + 8, 12, 10), "#6a9a3a")
  c:part(c:ellipse(x, y + 8, 9, 8), GV.ramp("#c8d77a"), { cres = 3, deep = 4 })                        -- glowing abdomen
  c:fill(c:rect(x - 4, y + 7, x + 4, y + 7), "#fff1c8"); c:fill(c:rect(x - 2, y + 11, x + 2, y + 11), "#a4b86a")
  c:part(c:ellipse(x, y - 2, 8, 6), GV.ramp("#5e3a2a"), { cres = 3, deep = 4, gloss = false })        -- body
  c:part(c:ellipse(x, y - 11, 9, 8), GV.ramp("#5e3a2a"), { cres = 3, deep = 4 })                      -- head
  c:eye(x - 7, y - 15); c:eye(x + 2, y - 15)
  c:fill(c:line({ {x - 4, y - 19}, {x - 8, y - 24} }, 1), "#2a1a10"); c:fill(c:line({ {x + 4, y - 19}, {x + 8, y - 24} }, 1), "#2a1a10")
  c:fill(c:rect(x - 10, y - 26, x - 7, y - 24), "#c8d77a"); c:fill(c:rect(x + 7, y - 26, x + 10, y - 24), "#c8d77a")
end
fly(172, 62)
fly(52, 52)
fly(198, 84)

-- foreground fern fronds at the corners -----------------------------------------------------------------------------------------------------------
for _, p in ipairs({ {6,126},{20,130},{232,126},{218,130} }) do
  c:fill(c:line({ {p[1], p[2] + 4}, {p[1] - 6, p[2] - 10} }, 2), "#1e4a3a"); c:fill(c:line({ {p[1], p[2] + 4}, {p[1] + 8, p[2] - 10} }, 2), "#2f6a4a"); c:fill(c:line({ {p[1], p[2] + 4}, {p[1] + 1, p[2] - 14} }, 2), "#2f6a4a")
end

L.finish(c, "delve-firefly-caves")
