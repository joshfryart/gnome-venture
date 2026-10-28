-- wonder-glowworm-grotto.lua : a cavern ceiling of glowworms, a still pool, a wall niche holding a find.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV = L.GV
local c = L.new()
local W, H = L.W, L.H
local G1, G2, G3 = "#c8ecdc", "#7fe0c0", "#3f8fb0"

-- back wall: deep cave bands
c:bands(c:rect(0, 0, W - 1, H - 1), { "#0e1834", "#121c3c", "#162242", "#1a2a4a", "#1e3250", "#223a56", "#264260" }, { dir = "v" })
-- far cave arches / rock layers
c:part(L.below(c, function(x) return 64 + 6 * math.sin(x / 17) + 4 * math.sin(x / 7 + 1) end), GV.ramp("#2a2a54"), { gloss = false, rim = false, bounce = false, outline = false, cres = 3, deep = 4 })
-- far mouth: a small glimpse of night sky on the far right through an arch
c:fill(c:poly({ {196,64},{198,50},{206,42},{214,50},{216,64} }), "#26225a")
c:px(205, 50, "#fff1c8"); c:px(209, 56, "#c3b2ea"); c:px(201, 58, "#c3b2ea")
-- stone pool (water) in the middle ground
local pool = c:ellipse(120, 112, 98, 17)
c:part(pool, GV.ramp("#1e3a5a"), { gloss = false, rim = true, cres = 6, deep = 10, outline = false })
c:bands(c:ellipse(120, 112, 94, 14), { "#1e4a66", "#1e5470", "#256078", "#2a6c82" }, { dir = "v" })
-- ceiling: rocky mass with a jagged lower edge
local ceil = c:mask()
for x = 0, W - 1 do
  local y = 30 + 8 * math.sin(x / 19) + 5 * math.sin(x / 7 + 2) + ((x % 29) < 3 and 4 or 0)
  for yy = 0, math.floor(y) do ceil:set(x, yy) end
end
c:part(ceil, GV.ramp("#3a3a66"), { gloss = false, rim = false, cres = 5, deep = 9 })
-- stalactites
for _, s in ipairs({ {18,34,6,18},{56,30,5,14},{92,36,7,20},{150,34,6,16},{184,30,5,13},{222,36,6,17},{128,30,4,10},{36,28,4,10} }) do
  local x, w, h = s[1], s[3], s[4]
  local y = math.floor(30 + 8 * math.sin(x / 19) + 5 * math.sin(x / 7 + 2)) - 3
  c:part(c:poly({ {x - w, y - 2}, {x + w, y - 2}, {x + 1, y + h}, {x, y + h} }), GV.ramp("#4a4a7a"), { gloss = false, cres = 3, deep = 4 })
end
-- cave walls left and right
c:part(c:poly({ {0,0},{22,0},{14,40},{20,70},{8,100},{0,H} }), GV.ramp("#3a3a66"), { gloss = false, rim = false, cres = 6, deep = 9 })
local rwall = c:poly({ {W,0},{214,0},{222,40},{212,70},{226,100},{W,H} })
c:part(rwall, GV.ramp("#3a3a66"), { gloss = false, rim = false, cres = 6, deep = 9 })
-- the niche in the right wall (arched hole, warm lit)
c:part(c:rrect(212, 84, 230, 112, 8), GV.ramp("#1a1030"), { gloss = false, rim = false, cres = 2, deep = 3, contour = "#2a1a10" })
c:fill(c:rrect(214, 87, 228, 111, 7), "#5e2f1e")
c:fill(c:rrect(216, 90, 226, 111, 5), "#8a4f2a")
c:fill(c:ellipse(221, 104, 6, 6):clip(c:rect(210, 92, 232, 112)), "#e8a317")
-- the find: a small chest with glints
c:part(c:rrect(214, 101, 228, 111, 2), GV.ramp("#b07a45"), { cres = 3, deep = 4, gloss = false })
c:part(c:ellipse(221, 101, 7, 3):cut(c:rect(210, 102, 232, 108)), GV.ramp("#d9a660"), { cres = 2, deep = 3, gloss = false })
c:fill(c:rect(220, 102, 222, 105), "#f5cf6a")
c:px(217, 99, "#fff1c8"); c:px(225, 98, "#fff1c8"); c:px(223, 96, "#f5cf6a"); c:px(219, 94, "#fff1c8")
-- ledge under niche
c:part(c:rect(208, 112, 234, 116), GV.ramp("#5b6470"), { cres = 2, deep = 3, gloss = false })
-- pool edge rocks
for _, r in ipairs({ {20,122,9,5},{58,128,8,4},{180,124,10,5},{206,122,8,4},{100,129,7,3},{150,128,6,3} }) do
  c:part(c:ellipse(r[1], r[2], r[3], r[4]), GV.ramp("#5b6470"), { cres = 3, deep = 4, gloss = false })
end
-- stepping stones
for _, r in ipairs({ {80,110,5,2},{104,116,5,2},{130,112,5,2},{154,118,5,2} }) do c:part(c:ellipse(r[1], r[2], r[3], r[4]), GV.ramp("#8b8f96"), { flat = true, gloss = false }) end

-- glowworms on the ceiling (dots with hanging beaded threads), then the spelled pattern
local function worm(x, y, len)
  c:fill(c:rect(x, y, x + 1, y + 1), G1); c:px(x - 1, y, G3); c:px(x + 2, y + 1, G3); c:px(x, y - 1, G3)
  for k = 1, len do
    if k % 2 == 1 then c:px(x, y + 1 + k, G3) end
    if k == len then c:fill(c:rect(x - 1, y + 1 + k, x, y + 2 + k), G2) end
  end
end
for i = 0, 70 do
  local x = 20 + (i * 37) % 200; local y = 10 + (i * 11) % 30
  local ceily = 30 + 8 * math.sin(x / 19) + 5 * math.sin(x / 7 + 2)
  y = math.min(y, math.floor(ceily) - 2)
  c:px(x, y, G2); c:px(x + 1, y, G3)
  if i % 3 == 0 then c:px(x, y + 1, G3); c:px(x, y + 3, G2) end
end
-- pattern: a ring of bright worms with a spiral tail, pointing down to the niche
local pat = { {118,50},{124,52},{128,57},{126,63},{120,66},{114,64},{111,59},{113,54},{119,58},{121,60},{138,66},{150,72},{164,78},{178,82},{192,86},{204,90} }
for _, p in ipairs(pat) do
  worm(p[1], p[2], 2 + (p[1] % 3)); c:fill(c:rect(p[1] - 1, p[2] - 1, p[1] + 2, p[2] + 2), G3); c:fill(c:rect(p[1], p[2], p[1] + 1, p[2] + 1), "#fff3c8")
end
-- reflections in the pool
for _, p in ipairs({ {118,100},{124,104},{128,98},{140,104},{150,108},{164,102},{110,108},{98,102},{178,106} }) do
  c:fill(c:rect(p[1], p[2], p[1] + 1, p[2]), G2); c:px(p[1] - 2, p[2] + 3, G3); c:px(p[1] + 3, p[2] + 3, G3)
end
for _, r in ipairs({ {70,106,12},{108,124,9},{150,114,10},{40,114,8} }) do c:fill(c:rect(r[1], r[2], r[1] + r[3], r[2]), "#3f8fb0") end
-- lone gnome-scale mushrooms glowing at the left
for _, m in ipairs({ {36,114},{46,118} }) do
  c:part(c:rect(m[1], m[2], m[1] + 1, m[2] + 4), GV.ramp("#f2e4c0"), { flat = true, gloss = false })
  c:part(c:ellipse(m[1] + 0.5, m[2], 4, 3):cut(c:rect(m[1] - 6, m[2] + 1, m[1] + 6, m[2] + 5)), GV.ramp("#3f8fb0", { gloss = "#c8ecdc" }), { cres = 2, deep = 3, gloss = false })
  c:px(m[1] - 1, m[2] - 1, "#c8ecdc")
end
L.finish(c, "wonder-glowworm-grotto")
