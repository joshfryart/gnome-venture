-- haven-aurora-camp.lua : "Aurora Camp. Northern-lights rest stop; a night here gives a Luck buff." NA zone 4, snowy night under the aurora.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV = L.GV
local c = L.new()
local W, H = L.W, L.H
local HOR = 88
local NF = { gloss = false, rim = false, bounce = false, outline = false }
local function nf(t) local o = {}; for k, v in pairs(NF) do o[k] = v end; for k, v in pairs(t or {}) do o[k] = v end; return o end

L.sky(c, "night", HOR)
L.stars(c, 60, 60, 11)
-- aurora: layered curtains made of vertical stripe columns (hard pixels), green core, teal and violet edges
local function curtain(x0, x1, ybase, amp, per, top, cols)
  for x = x0, x1 do
    local yb = ybase + math.floor(math.sin(x / per) * amp)
    local h = top + math.floor(math.sin(x / (per * 0.6) + 1) * 6)
    for y = yb - h, yb do
      local t = (y - (yb - h)) / h
      local col = (t < 0.35) and cols[1] or ((t < 0.8) and cols[2] or cols[3])
      c:px(x, y, col)
    end
    if x % 3 == 0 then c:px(x, yb - h - 1, cols[1]) end
  end
end
curtain(0, W - 1, 52, 8, 17, 30, { "#4a8a8a", "#5acf8a", "#a8f0b8" })
curtain(0, 239, 42, 6, 13, 18, { "#6a4fa8", "#8c6ab8", "#5acf8a" })
-- mountains
c:part(c:poly({ {0,HOR+2},{0,70},{24,58},{40,68},{70,50},{100,70},{140,62},{170,74},{200,56},{W,72},{W,HOR+2} }), GV.ramp("#4a5a8a"), nf{ cres = 4, deep = 7 })
for _, p in ipairs({ {24,58,3},{70,50,4},{200,56,3} }) do c:fill(c:poly({ {p[1]-p[3]-3,p[2]+6},{p[1],p[2]},{p[1]+p[3]+3,p[2]+6} }), "#c3d0ea") end
-- snowfield with reflection of aurora tint
local snow = L.below(c, function(x) return HOR + 2 + math.sin(x / 19) * 1.5 end)
c:part(snow, GV.ramp("#d8e4f2"), nf{ cres = 5, deep = 9 })
c:bands(c:rect(0, HOR + 3, W - 1, HOR + 6):clip(snow), { "#8cd8b0", "#b8e8d0" }, { dir = "v" })
for i = 0, 26 do local x = (i * 41 + 5) % W; local y = HOR + 10 + (i * 23) % 34; c:fill(c:rect(x, y, x + 3 + i % 3, y), (i % 2 == 0) and "#a8bcd8" or "#f4f8ff") end
-- pines (silhouette dark with snow caps)
local function pine(x, y, s)
  for k = 0, 3 do
    local w = (14 - k * 3) * s
    c:part(c:poly({ {x - w, y - k * 8 * s + 8 * s}, {x, y - k * 8 * s - 4 * s}, {x + w, y - k * 8 * s + 8 * s} }), GV.ramp("#2a5a4a"), { cres = 3, deep = 5, gloss = false })
    c:fill(c:poly({ {x - w * 0.4, y - k * 8 * s + 1}, {x, y - k * 8 * s - 4 * s}, {x + w * 0.4, y - k * 8 * s + 1} }), "#e8f0fa")
  end
  c:part(c:rect(x - 1, y + 8 * s, x + 1, y + 12 * s), GV.ramp("#4a2c1a"), { flat = true, gloss = false, outline = false })
end
pine(14, 96, 1.1); pine(34, 102, 0.8); pine(212, 94, 1.2); pine(194, 102, 0.8); pine(228, 108, 0.9)

-- the tent (a-frame canvas, lit from within) in the centre-left
local tx = 80
c:part(c:poly({ {tx - 30, 118}, {tx, 78}, {tx + 30, 118} }), GV.ramp("#e8742b"), { cres = 6, deep = 10, gloss = false })
c:fill(c:poly({ {tx - 8, 118}, {tx, 96}, {tx + 8, 118} }), "#f5cf6a")                 -- open flap: warm glow
c:fill(c:poly({ {tx - 4, 118}, {tx, 106}, {tx + 4, 118} }), "#fff1c8")
c:seam({ {tx - 25, 114}, {tx - 3, 84} }, { free = true, on = 2, off = 1 }); c:seam({ {tx + 25, 114}, {tx + 3, 84} }, { free = true, on = 2, off = 1 })
c:fill(c:rect(tx, 72, tx, 78), "#2a1a10"); c:fill(c:poly({ {tx + 1, 72}, {tx + 8, 74}, {tx + 1, 77} }), "#d6322b")   -- pennant
-- guy ropes and pegs
c:seam({ {tx - 28, 112}, {tx - 40, 122} }, { free = true, on = 1, off = 1 }); c:seam({ {tx + 28, 112}, {tx + 40, 122} }, { free = true, on = 1, off = 1 })
-- campfire (middle ground) with logs, kettle, sparks
local fx, fy = 134, 116
c:fill(c:ellipse(fx, fy + 3, 16, 5), "#f5cf6a"); c:fill(c:ellipse(fx, fy + 3, 10, 3), "#fff1c8")         -- light pool on the snow
for _, a in ipairs({ -1, 1 }) do c:part(c:line({ {fx + a * 9, fy + 5}, {fx - a * 2, fy + 1} }, 3), GV.ramp("#6a4420"), { flat = true, gloss = false, outline = false }) end
c:part(c:poly({ {fx - 8, fy + 3}, {fx - 3, fy - 8}, {fx, fy - 2}, {fx + 3, fy - 12}, {fx + 8, fy + 3} }), GV.ramp("#e0501f"), { flat = true, gloss = false })
c:fill(c:poly({ {fx - 4, fy + 3}, {fx, fy - 6}, {fx + 4, fy + 3} }), "#f5cf6a"); c:fill(c:poly({ {fx - 2, fy + 3}, {fx, fy - 1}, {fx + 2, fy + 3} }), "#fff1c8")
for _, sp in ipairs({ {fx - 6, fy - 16}, {fx + 6, fy - 20}, {fx + 1, fy - 24}, {fx - 3, fy - 28} }) do c:px(sp[1], sp[2], "#f5cf6a") end
-- tripod + kettle
c:seam({ {fx - 14, fy + 6}, {fx, fy - 14}, {fx + 14, fy + 6} }, { free = true, on = 1, off = 0, gap = "#2a1a10" })
-- foreground: the camp's resident red fox watching the lights, chibi
local ox, oy = 176, 114
c:part(c:ellipse(ox - 8, oy + 3, 9, 3), GV.ramp("#d8803a"), { flat = true, gloss = false, outline = false })     -- tail
c:part(c:ellipse(ox, oy, 9, 8), GV.ramp("#d8803a"), { cres = 4, deep = 7, gloss = false })
c:part(c:ellipse(ox + 5, oy - 9, 7, 6), GV.ramp("#d8803a"), { cres = 3, deep = 5, gloss = false })
c:part(c:poly({ {ox, oy - 14}, {ox + 1, oy - 20}, {ox + 4, oy - 14} }), GV.ramp("#d8803a"), { flat = true, gloss = false })
c:part(c:poly({ {ox + 7, oy - 14}, {ox + 10, oy - 20}, {ox + 11, oy - 13} }), GV.ramp("#d8803a"), { flat = true, gloss = false })
c:eye(ox + 1, oy - 12, true); c:eye(ox + 7, oy - 12, true)
c:px(ox + 9, oy - 8, "#2a1a10"); c:px(ox + 10, oy - 8, "#2a1a10")
c:part(c:ellipse(ox + 8, oy - 6, 3, 2), GV.ramp("#f4f0e0"), { flat = true, gloss = false, outline = false })
c:ground(ox, oy + 8, 11, 2, "#a8bcd8")
-- sleeping bags / mugs + a luck charm: a four-leaf clover string on the tent? a little hanging lantern with a clover
c:part(c:rrect(100, 120, 114, 126, 2), GV.ramp("#2f6a8a"), { cres = 2, deep = 4, gloss = false })
c:part(c:rect(104, 112, 108, 117), GV.ramp("#f2e4c0"), { flat = true, gloss = false }); c:px(110, 114, "#f2e4c0"); c:px(105, 109, "#c3d0ea"); c:px(106, 107, "#c3d0ea")
c:ground(80, 120, 32, 2)
L.finish(c, "haven-aurora-camp")
