-- wonder-the-silk-road-caravanserai.lua : trade stop. Courtyard, fountain, travelling gnomes from a dozen lands swapping seeds; golden hour.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV = L.GV
local c = L.new()
local W, H = L.W, L.H

L.sky(c, "warm", 70)
c:fill(c:ellipse(40, 22, 9, 9), "#fff1c8"); c:fill(c:ellipse(40, 22, 6, 6), "#fff8e0")
L.cloud(c, 190, 18, 16, "#fdf2d8", "#f5cc92"); L.cloud(c, 110, 10, 12, "#fdf2d8", "#f5cc92")
-- far desert mountains
c:fill(L.below(c, function(x) return 56 + 10 * math.sin(x / 23 + 1) + 5 * math.sin(x / 9) end), "#d9a78a")
c:fill(L.below(c, function(x) return 66 + 6 * math.sin(x / 15) end), "#c98f6a")

-- the caravanserai walls ------------------------------------------------------------------------------
local SAND = GV.ramp("#d9b07a", { rim = "#f5d9a0" })
-- corner towers with blue domes
for _, tx in ipairs({ 30, 210 }) do
  c:part(c:ellipse(tx, 36, 8, 8), GV.ramp("#3f8fb0"), { cres = 4, deep = 6 })
  c:part(c:rect(tx - 7, 38, tx + 7, 92), SAND, { cres = 4, deep = 7, gloss = false })
  c:fill(c:rect(tx - 7, 44, tx + 7, 44), "#3f8fb0")
  c:part(c:rrect(tx - 2, 52, tx + 2, 62, 2), GV.ramp("#4a2c1a"), { flat = true, gloss = false })
  c:fill(c:rect(tx, 26, tx, 21), "#e8a317"); c:px(tx - 1, 21, "#e8a317"); c:px(tx + 1, 21, "#e8a317")
end
-- main wall with battlements
c:part(c:rect(36, 56, 204, 94), SAND, { cres = 5, deep = 9, gloss = false })
for x = 38, 200, 8 do c:part(c:rect(x, 51, x + 4, 56), SAND, { cres = 2, deep = 3, gloss = false, contour = false }) end
-- arcade arches on the wall
for _, ax in ipairs({ 48, 66, 84, 148, 166, 184 }) do
  local a = c:rect(ax, 68, ax + 8, 94); a:add(c:ellipse(ax + 4, 68, 4.5, 5))
  c:part(a, GV.ramp("#4a2c1a"), { flat = true, gloss = false, contour = "#2a1a10" })
  c:fill(c:rect(ax + 1, 80, ax + 7, 80), "#7a4a1f"); c:fill(c:rect(ax + 1, 80, ax + 1, 94), "#7a4a1f")
end
-- lanterns hanging in two arches
for _, lx in ipairs({ 52, 170 }) do c:part(c:ellipse(lx, 78, 2, 3), GV.ramp("#e8a317"), { flat = true, gloss = false }); c:px(lx, 78, "#fff1c8") end
-- grand iwan (tall blue-tiled arch) in the middle
c:part(c:rect(94, 40, 146, 94), GV.ramp("#3f8fb0", { rim = "#8fcbd8" }), { cres = 4, deep = 8, gloss = false })
c:part(c:ellipse(120, 40, 26, 8), GV.ramp("#3f8fb0", { rim = "#8fcbd8" }), { cres = 3, deep = 5, gloss = false })
local iw = c:rect(104, 62, 136, 94); iw:add(c:ellipse(120, 62, 16, 14))
c:part(iw, GV.ramp("#3d2a1c"), { flat = true, gloss = false, contour = "#2a1a10" })
-- tile ornament: gold diamonds and a star in the spandrels
for _, d in ipairs({ {99,50},{99,62},{99,74},{141,50},{141,62},{141,74} }) do
  c:fill(c:poly({ {d[1],d[2]-3},{d[1]+3,d[2]},{d[1],d[2]+3},{d[1]-3,d[2]} }), "#f5cf6a"); c:px(d[1], d[2], "#fff1c8")
end
c:fill(c:rect(104, 66, 136, 66), "#8fcbd8")
for x = 106, 134, 4 do c:px(x, 68, "#f5cf6a") end
-- dark interior glow: market lamps within the iwan
for _, lx in ipairs({ 112, 120, 128 }) do c:fill(c:rect(lx, 72, lx + 1, 74), "#f5cf6a") end
-- small blue dome peeking over the iwan
c:part(c:ellipse(120, 28, 9, 9), GV.ramp("#3f8fb0", { rim = "#8fcbd8" }), { cres = 4, deep = 6 })
c:fill(c:rect(120, 14, 120, 20), "#e8a317"); c:part(c:ellipse(120, 14, 2, 2), GV.ramp("#e8a317"), { flat = true, gloss = false })

-- courtyard floor -------------------------------------------------------------------------------------
local floor = c:rect(0, 94, W - 1, H - 1)
c:bands(floor, { "#e2c288", "#dcb87c", "#d6ae72", "#cfa468" }, { dir = "v" })
for y = 100, 128, 7 do for x = (y // 7 % 2) * 8, W, 16 do c:fill(c:rect(x, y, x + 8, y), "#c9a064") end end
c:fill(c:rect(0, 94, W - 1, 94), "#8a5a34")
-- outer palm trees
for _, p in ipairs({ {8,86},{232,84} }) do
  c:part(c:rect(p[1] - 1, p[2] - 20, p[1] + 1, p[2] + 6), GV.ramp("#a8582f"), { flat = true, gloss = false })
  for _, a in ipairs({ {-8,-3},{8,-3},{-5,-8},{5,-8} }) do c:part(c:ellipse(p[1] + a[1], p[2] - 22 + a[2], 6, 3), GV.ramp("#4a8a3e"), { cres = 2, deep = 3, gloss = false }) end
end

-- fountain ---------------------------------------------------------------------------------------------
local fx, fy = 120, 108
c:part(c:ellipse(fx, fy + 4, 20, 8), GV.ramp("#c9c5bc", { rim = "#f2ecda" }), { cres = 4, deep = 6, gloss = false })
c:fill(c:ellipse(fx, fy + 3, 16, 5), "#5aa8c8"); c:fill(c:ellipse(fx, fy + 3, 11, 3), "#8fcbd8")
c:part(c:rect(fx - 2, fy - 12, fx + 2, fy + 3), GV.ramp("#c9c5bc"), { cres = 2, deep = 3, gloss = false })
c:part(c:ellipse(fx, fy - 12, 7, 3), GV.ramp("#c9c5bc"), { cres = 2, deep = 3, gloss = false })
c:fill(c:rect(fx, fy - 20, fx, fy - 14), "#c8ecdc"); c:fill(c:rect(fx - 1, fy - 18, fx + 1, fy - 18), "#e6f8f0")
for _, d in ipairs({ {-6,-16},{6,-16},{-10,-8},{10,-8} }) do c:px(fx + d[1], fy + d[2], "#8fcbd8") end
c:fill(c:rect(fx - 8, fy - 12, fx - 8, fy - 8), "#8fcbd8"); c:fill(c:rect(fx + 8, fy - 12, fx + 8, fy - 8), "#8fcbd8")

-- gnome helper (chibi trader) --------------------------------------------------------------------------
local function gnome(x, y, robe, hat, hatc, beard)
  c:ground(x, y + 6, 7, 1.5)
  c:part(c:ellipse(x, y, 6, 6), GV.ramp(robe), { cres = 3, deep = 5, gloss = false })
  c:part(c:ellipse(x, y - 9, 5, 5), GV.ramp("#e9b98a"), { cres = 2, deep = 3, gloss = false })
  c:part(c:ellipse(x, y - 5, 4, 3):clip(c:rect(0, y - 5, W, H)), GV.ramp(beard or "#f2e4c0", { dot = "#fff3c8" }), { flat = true, gloss = false, outline = false })
  c:eye(x - 4, y - 12, true); c:eye(x + 1, y - 12, true)
  if hat == "cone" then c:part(c:poly({ {x - 6, y - 12}, {x + 6, y - 12}, {x, y - 28} }), GV.ramp(hatc), { cres = 3, deep = 5, gloss = false })
  elseif hat == "turban" then c:part(c:ellipse(x, y - 15, 7, 4), GV.ramp(hatc), { cres = 2, deep = 4, gloss = false }); c:part(c:ellipse(x + 1, y - 19, 4, 3), GV.ramp(hatc), { flat = true, gloss = false })
  elseif hat == "fez" then c:part(c:rect(x - 4, y - 20, x + 4, y - 13), GV.ramp(hatc), { cres = 2, deep = 3, gloss = false }); c:px(x + 4, y - 18, "#f5cf6a"); c:px(x + 5, y - 17, "#f5cf6a"); c:px(x + 5, y - 15, "#f5cf6a")
  elseif hat == "fur" then c:part(c:ellipse(x, y - 15, 7, 4), GV.ramp(hatc), { cres = 2, deep = 3, gloss = false })
  elseif hat == "straw" then c:part(c:ellipse(x, y - 14, 9, 3), GV.ramp(hatc), { cres = 2, deep = 3, gloss = false }); c:part(c:ellipse(x, y - 17, 4, 3), GV.ramp(hatc), { flat = true, gloss = false }) end
end
-- seed sacks and rugs
c:part(c:rrect(26, 116, 58, 130, 2), GV.ramp("#d6322b"), { cres = 3, deep = 5, gloss = false })
c:seam({ {28, 119}, {56, 119} }, { free = true, on = 2, off = 1 }); c:seam({ {28, 127}, {56, 127} }, { free = true, on = 2, off = 1 })
for _, s in ipairs({ {32,114,"#7ab55c"},{44,112,"#f08a24"},{52,114,"#f5cf6a"} }) do c:part(c:ellipse(s[1], s[2], 4, 3), GV.ramp(s[3]), { cres = 2, deep = 3, gloss = false }) end

-- the traders
gnome(74, 106, "#3f8fb0", "turban", "#d6322b")
gnome(92, 114, "#7ab55c", "fez", "#d6322b", "#c9c5bc")
gnome(150, 112, "#e46a9b", "cone", "#7b66b4")
gnome(166, 106, "#e8a317", "straw", "#d9a660")
gnome(40, 108, "#a8582f", "fur", "#8a4f2a", "#8b8f96")
-- seed packet swap between 74 and 92: small paper packet
c:part(c:rect(80, 104, 86, 111), GV.ramp("#f2e4c0", { dot = "#fff3c8" }), { flat = true, gloss = false, contour = "#74462a" })
c:px(83, 107, "#7ab55c"); c:px(83, 108, "#7ab55c")
c:fill(c:rect(156, 100, 160, 100), "#f5cf6a")

-- camel (chibi) at the right ---------------------------------------------------------------------------
local kx, ky = 198, 108
for _, lx in ipairs({ -10, -4, 5, 11 }) do c:part(c:rect(kx + lx, ky + 6, kx + lx + 2, ky + 18), GV.ramp("#c9a96e"), { flat = true, gloss = false }) end
c:part(c:ellipse(kx, ky, 15, 8), GV.ramp("#d9a660"), { cres = 4, deep = 7, gloss = false })
c:part(c:ellipse(kx - 4, ky - 9, 4, 4), GV.ramp("#d9a660"), { cres = 2, deep = 3, gloss = false })
c:part(c:ellipse(kx + 5, ky - 9, 4, 4), GV.ramp("#d9a660"), { cres = 2, deep = 3, gloss = false })
c:part(c:rect(kx - 22, ky - 20, kx - 16, ky - 2), GV.ramp("#d9a660"), { flat = true, gloss = false })
c:part(c:ellipse(kx - 21, ky - 24, 6, 5), GV.ramp("#d9a660"), { cres = 2, deep = 3 })
c:part(c:ellipse(kx - 27, ky - 22, 3, 3), GV.ramp("#c9a96e"), { flat = true, gloss = false })
c:eye(kx - 25, ky - 28, true)
c:part(c:rrect(kx - 8, ky - 5, kx + 8, ky + 4, 1), GV.ramp("#d6322b"), { flat = true, gloss = false })
c:seam({ {kx - 7, ky - 1}, {kx + 7, ky - 1} }, { free = true })
c:part(c:ellipse(kx + 14, ky - 2, 2, 3), GV.ramp("#3f8fb0"), { flat = true, gloss = false })
c:ground(kx, ky + 19, 16, 1.5)

L.finish(c, "wonder-the-silk-road-caravanserai")
