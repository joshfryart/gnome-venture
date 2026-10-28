-- delve-anaconda-hollows: a long jungle creek, a huge cute-menacing anaconda coiled in it. SA, jungle day.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV, W, H = L.GV, L.W, L.H
local c = L.new()
local HOR = 74

-- jungle backdrop: hazy light low, dark canopy high
c:bands(c:rect(0, 0, W - 1, HOR + 8), { "#1f4a2a", "#26582c", "#2f6a34", "#3f8038", "#5a9a42", "#86b45a", "#b4cc78", "#d6e29a" }, { dir = "v" })
-- light shafts
for _, x in ipairs({ 70, 98, 150, 176 }) do
  c:fill(c:poly({ {x,0},{x+8,0},{x+30,HOR},{x+14,HOR} }):clip(c:rect(0, 0, W, HOR)), (x % 2 == 0) and "#4f8f40" or "#5a9a42")
end
-- far trunks
for _, x in ipairs({ 30, 62, 118, 160, 204, 232 }) do
  c:part(c:rect(x, 8, x + 4, HOR + 6), GV.ramp("#5e4a2a"), { gloss = false, rim = false, outline = false, cres = 2 })
end
-- far foliage mounds
for _, p in ipairs({ {20,HOR,22,9},{70,HOR+2,26,10},{130,HOR,22,8},{176,HOR+2,28,10},{226,HOR,22,9} }) do
  c:part(c:ellipse(p[1], p[2], p[3], p[4]), GV.ramp("#4a8a3e"), { gloss = false, outline = false, cres = 3, deep = 4 })
end
-- creek: narrow at the horizon, wide in front
local creek = c:poly({ {112,HOR+4},{134,HOR+4},{170,100},{236,H},{4,H},{66,100} })
c:bands(creek, { "#6aa898", "#4a8a82", "#3a7a78", "#2f6a6e", "#25586a", "#1e4a5e" }, { dir = "v" })
-- banks: mud and moss left and right
local lb = c:poly({ {0,HOR+6},{66,HOR+6},{112,HOR+4},{66,100},{4,H},{0,H} })
c:part(lb, GV.ramp("#6a4a2a"), { cres = 6, deep = 10, gloss = false })
local rb = c:poly({ {W,HOR+6},{134,HOR+4},{170,100},{236,H},{W,H} })
c:part(rb, GV.ramp("#6a4a2a"), { cres = 6, deep = 10, gloss = false })
-- moss on the banks
for _, p in ipairs({ {20,96,10},{40,112,7},{8,120,8},{210,100,9},{228,114,8},{196,126,6},{90,86,5},{160,86,5} }) do
  c:part(c:ellipse(p[1], p[2], p[3], 2.5), GV.ramp("#6a9a3a"), { flat = true, gloss = false })
end
-- creek sparkle dashes
for i, p in ipairs({ {128,86,6},{110,92,8},{148,96,8},{100,106,10},{172,108,10},{60,128,9},{184,122,10},{136,114,9} }) do
  c:fill(c:rect(p[1], p[2], p[1] + p[3], p[2]), (i % 2 == 0) and "#8fcbd8" or "#6aa898")
end
-- lily pads with a tiny frog
local function pad(x, y, r) c:part(c:ellipse(x, y, r, r * 0.45), GV.ramp("#4a8a3e"), { flat = true, gloss = false }); c:fill(c:rect(x, y - 1, x + r, y - 1), "#3f8fb0") end
pad(150, 108, 7); pad(174, 120, 6); pad(128, 128, 8)
c:part(c:ellipse(150, 105, 3, 2.5), GV.ramp("#a4b86a"), { flat = true, gloss = false }); c:px(149, 103, "#f2e4c0"); c:px(152, 103, "#f2e4c0"); c:px(149, 103, "#2a1a10"); c:px(152, 103, "#2a1a10")

-- the anaconda: a coil in the creek rising to a raised head on the left ---------------------------------------------
local path = { {212,124},{186,126},{160,123},{134,127},{108,122},{90,112},{84,98},{86,84} }
local body = c:mask()
local function interp(i, t) local a, b = path[i], path[i + 1]; return a[1] + (b[1] - a[1]) * t, a[2] + (b[2] - a[2]) * t end
local pts = {}
for i = 1, #path - 1 do
  for k = 0, 5 do local x, y = interp(i, k / 6); pts[#pts + 1] = { x, y } end
end
local n = #pts
for i, p in ipairs(pts) do
  local r = 4 + math.floor(5 * math.min(1, i / (n * 0.35)))
  body:add(c:ellipse(p[1], p[2], r, r))
end
-- the mass of the coil: a second loop behind the first
local loop = c:mask()
for a = 0, 40 do
  local th = a / 40 * math.pi
  loop:add(c:ellipse(150 + math.cos(th) * 36, 118 - math.sin(th) * 12, 7, 7))
end
c:part(loop, GV.ramp("#3f7a3a"), { cres = 4, deep = 6, gloss = false })
c:part(body, GV.ramp("#4a8a3e"), { cres = 5, deep = 8 })
-- diamond markings along the body
for i = 3, n, 4 do
  local p = pts[i]
  local dm = c:poly({ {p[1], p[2] - 3}, {p[1] + 3, p[2]}, {p[1], p[2] + 3}, {p[1] - 3, p[2]} }):clip(body)
  c:fill(dm, "#2f5a2a"); c:px(p[1], p[2], "#a4b86a")
end
-- the head, raised and grinning, looking at you
local HX, HY = 86, 76
c:part(c:ellipse(HX, HY + 8, 6, 8), GV.ramp("#e9d9a0"), { flat = true, gloss = false })   -- pale throat
c:part(c:ellipse(HX, HY, 14, 10), GV.ramp("#4a8a3e"), { cres = 5, deep = 8 })
c:part(c:ellipse(HX + 3, HY + 3, 11, 6):clip(c:rect(0, HY + 2, W, HY + 12)), GV.ramp("#e9d9a0"), { flat = true, gloss = false }) -- jaw
c:eye(HX - 11, HY - 8); c:eye(HX + 3, HY - 8)
c:fill(c:rect(HX - 11, HY - 9, HX - 6, HY - 9), "#2f5a2a"); c:fill(c:rect(HX + 3, HY - 9, HX + 8, HY - 9), "#2f5a2a")  -- heavy brows
c:px(HX - 5, HY - 10, "#2f5a2a"); c:px(HX + 9, HY - 10, "#2f5a2a")
-- big cheeky smile, nostrils, forked tongue
c:fill(c:line({ {HX-8,HY+2},{HX-5,HY+5},{HX+5,HY+5},{HX+8,HY+2} }, 1), "#2a1a10")
c:px(HX - 2, HY, "#2a1a10"); c:px(HX + 2, HY, "#2a1a10")
c:fill(c:rect(HX, HY + 7, HX, HY + 13), "#d6322b"); c:px(HX - 1, HY + 14, "#d6322b"); c:px(HX + 1, HY + 14, "#d6322b"); c:px(HX - 2, HY + 15, "#d6322b"); c:px(HX + 2, HY + 15, "#d6322b")
c:px(HX - 3, HY + 6, "#f2e4c0"); c:px(HX + 4, HY + 6, "#f2e4c0")   -- two tiny fangs
-- ripples around the coil
for _, r in ipairs({ {100,128,22},{186,130,20},{140,132,26} }) do c:fill(c:rect(r[1], r[2], r[1] + r[3], r[2]), "#8fcbd8") end

-- canopy and vines framing the top and sides ---------------------------------------------------------------------------
local function leaf(x, y, rx, ry, col) c:part(c:ellipse(x, y, rx, ry), GV.ramp(col), { cres = 3, deep = 5, gloss = false, outline = false }) end
for _, p in ipairs({ {10,6,18,8},{44,2,16,7},{190,4,20,8},{226,8,18,9},{236,28,10,12},{2,32,8,12} }) do leaf(p[1], p[2], p[3], p[4], "#2f6a34") end
for _, p in ipairs({ {26,12,12,5},{208,12,12,5} }) do leaf(p[1], p[2], p[3], p[4], "#3f8038") end
for _, v in ipairs({ {20,12,38},{34,8,26},{206,14,44},{222,16,30},{236,34,50},{4,28,30} }) do
  c:fill(c:rect(v[1], v[2], v[1], v[3]), "#2f5a2a"); c:fill(c:ellipse(v[1], v[3], 1.5, 2), "#6a9a3a")
end
-- a startled macaw on a branch, right
c:fill(c:rect(190, 40, 240, 42), "#5e2f1e")
c:part(c:ellipse(214, 34, 6, 8), GV.ramp("#d6322b"), { cres = 3, deep = 4 })
c:part(c:ellipse(212, 24, 6, 5), GV.ramp("#d6322b"), { cres = 2, deep = 3, gloss = false })
c:eye(205, 20); c:fill(c:rect(205, 26, 209, 28), "#f2e4c0"); c:px(204, 24, "#e8a317")
c:fill(c:rect(218, 34, 220, 42), "#3f8fb0"); c:fill(c:rect(220, 36, 222, 44), "#e8a317")
-- foreground ferns, bottom corners
for _, p in ipairs({ {10,126},{24,130},{230,126},{216,130} }) do
  c:fill(c:line({ {p[1], p[2] + 4}, {p[1] - 6, p[2] - 8} }, 2), "#4a8a3e"); c:fill(c:line({ {p[1], p[2] + 4}, {p[1] + 6, p[2] - 8} }, 2), "#6a9a3a"); c:fill(c:line({ {p[1], p[2] + 4}, {p[1], p[2] - 12} }, 2), "#7ab55c")
end

L.finish(c, "delve-anaconda-hollows")
