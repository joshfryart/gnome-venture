-- wonder-prayer-flag-pass.lua : CSA zone 4. Colourful flags flutter along a high pass, each carrying a wish; the wind reads them out loud.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV = L.GV
local c = L.new()
local W, H = L.W, L.H

c:bands(c:rect(0, 0, W - 1, 90), { "#4f8fcc", "#5a9ad2", "#6aa8d8", "#7ab4e0", "#92c4e6", "#aed6ee", "#cce6f2" }, { dir = "v" })
L.cloud(c, 36, 20, 14, "#f4f0e0", "#cfd8e4"); L.cloud(c, 190, 12, 16, "#f4f0e0", "#cfd8e4"); L.cloud(c, 100, 8, 10, "#f4f0e0", "#cfd8e4")
-- snow peaks: big shapes, rock below a snow line, shaded lower-right
local function peak(pts, snowY)
  local m = c:poly(pts)
  c:part(m, GV.ramp("#7a8494"), { cres = 8, deep = 14, gloss = false, outline = false })
  c:part(m:copy():clip(c:rect(0, 0, W, snowY)), GV.ramp("#f2f0e8", { shade = "#b8c8e0", deep = "#8ea0c8", rim = "#f8f4ea" }), { cres = 6, deep = 10, gloss = false, outline = false, contour = false })
end
peak({ {0,88},{26,34},{44,18},{70,52},{84,88} }, 52)
peak({ {64,88},{104,40},{128,12},{160,44},{190,88} }, 50)
peak({ {150,88},{190,32},{212,22},{240,46},{240,88} }, 52)
-- cloud drifts crossing the lower peaks
c:fill(c:ellipse(40, 70, 28, 3), "#e6eef4"); c:fill(c:ellipse(180, 64, 26, 3), "#e6eef4")

-- the pass floor ----------------------------------------------------------------------------------------
local back = L.below(c, function(x) return 82 + 6 * math.sin(x / 30 + 1) end)
c:part(back, GV.ramp("#8b7a66"), { cres = 6, deep = 10, gloss = false, outline = false })
local fore = L.below(c, function(x) return 100 + 8 * math.sin(x / 34 + 3) end)
c:part(fore, GV.ramp("#a89a78"), { cres = 6, deep = 10, gloss = false, outline = false })
-- path
c:fill(c:poly({ {112,H},{116,102},{124,102},{150,H} }), "#c9b88a")
for _, r in ipairs({ {20,112},{60,122},{190,118},{214,126},{30,128},{84,108} }) do c:part(c:ellipse(r[1], r[2], 3, 2), GV.ramp("#8b8f96"), { flat = true, gloss = false }) end
for _, g in ipairs({ {8,110},{44,118},{170,112},{226,114},{70,128},{200,130} }) do c:px(g[1], g[2], "#a4b86a"); c:px(g[1] + 1, g[2] - 1, "#c8d77a"); c:px(g[1] + 2, g[2], "#a4b86a") end
-- blue gentians
for _, f in ipairs({ {16,120},{54,126},{176,124},{222,120} }) do c:fill(c:rect(f[1], f[2], f[1], f[2] + 3), "#4a8a3e"); c:fill(c:rect(f[1] - 1, f[2] - 2, f[1] + 1, f[2]), "#3f6ad0"); c:px(f[1], f[2] - 1, "#f2e4c0") end

-- the cairn with its pole (centre) -----------------------------------------------------------------------
local cx, cy = 120, 100
local stones = { {0,0,16,6,"#8b8f96"},{-1,-8,13,5,"#a8a498"},{1,-15,10,5,"#8b8f96"},{0,-21,7,4,"#c9c5bc"} }
for _, s in ipairs(stones) do c:part(c:ellipse(cx + s[1], cy + s[2], s[3], s[4]), GV.ramp(s[5]), { cres = 3, deep = 5, gloss = false }) end
c:part(c:rect(cx - 1, cy - 50, cx + 1, cy - 22), GV.ramp("#7a4a1f"), { flat = true, gloss = false })
c:part(c:ellipse(cx, cy - 52, 3, 3), GV.ramp("#e8a317"), { cres = 2, deep = 3 })
c:ground(cx, cy + 6, 18, 2)
-- left and right poles
local pl = { 22, 36 }; local pr = { 220, 44 }
for _, p in ipairs({ pl, pr }) do
  c:part(c:rect(p[1] - 1, p[2], p[1] + 1, 108), GV.ramp("#7a4a1f"), { flat = true, gloss = false })
  c:part(c:ellipse(p[1], p[2] - 1, 3, 3), GV.ramp("#e8a317"), { cres = 2, deep = 3 })
end
c:ground(22, 108, 5, 1); c:ground(220, 108, 5, 1)

-- strings of flags -----------------------------------------------------------------------------------------
local COLS = { "#3f6ad0", "#f2e4c0", "#d6322b", "#4a9a3e", "#f5cf6a" }
local function string_of_flags(x0, y0, x1, y1, sag, size, phase)
  local n = 0
  for x = x0, x1 do
    local t = (x - x0) / (x1 - x0)
    local y = math.floor(y0 + (y1 - y0) * t + sag * math.sin(math.pi * t) + 0.5)
    c:px(x, y, "#4a2c1a")
    if (x - x0) % (size + 2) == 2 and x + size < x1 then
      n = n + 1
      local col = COLS[(n - 1) % 5 + 1]
      local w = math.floor(1.5 * math.sin((x + phase) / 3.2) + 0.5)
      -- flag: a pennant streaming to the right with a darker underside
      for i = 0, size - 1 do
        local h = size + 2 - (i // 2)
        local wy = math.floor(w * (i / size) * 2 + 0.5)
        c:fill(c:rect(x + i, y + 1 + wy, x + i, y + h + wy), col)
        c:px(x + i, y + h + wy, "#" .. (col == "#f2e4c0" and "d8c496" or "2a1a10"))
      end
      c:px(x + 1, y + 2 + w, "#" .. (col == "#f2e4c0" and "8a6a44" or "f2e4c0"))  -- hint of a printed wish
    end
  end
end
string_of_flags(22, 37, 120, 26, 12, 5, 0)
string_of_flags(120, 26, 220, 45, 12, 5, 7)
string_of_flags(22, 40, 150, 90, 10, 5, 3)
string_of_flags(120, 30, 220, 78, 14, 5, 11)
-- wind: long hard-edged gust dashes sweeping to the right
for _, g in ipairs({ {30,60,22},{64,76,16},{150,34,24},{178,64,18},{48,92,14},{196,88,20},{100,58,12} }) do
  c:fill(c:rect(g[1], g[2], g[1] + g[3], g[2]), "#e6f2f8"); c:px(g[1] + g[3] + 1, g[2] - 1, "#e6f2f8"); c:px(g[1] + g[3] + 2, g[2] - 2, "#e6f2f8"); c:px(g[1] + g[3] + 3, g[2] - 2, "#e6f2f8")
end

-- yak (chibi, shaggy, bell) standing on the path, right ------------------------------------------------------
local yx, yy = 176, 112
for _, lx in ipairs({ -10, -3, 5, 11 }) do c:part(c:rect(yx + lx, yy + 6, yx + lx + 2, yy + 14), GV.ramp("#3d2a1c"), { flat = true, gloss = false }) end
c:part(c:ellipse(yx, yy, 16, 9), GV.ramp("#5e3a2a"), { cres = 5, deep = 8, gloss = false })
local skirt = c:poly({ {yx - 15, yy + 4}, {yx + 15, yy + 4}, {yx + 15, yy + 12}, {yx + 12, yy + 9}, {yx + 8, yy + 13}, {yx + 4, yy + 9}, {yx, yy + 13}, {yx - 4, yy + 9}, {yx - 8, yy + 13}, {yx - 12, yy + 9}, {yx - 15, yy + 12} })
c:part(skirt, GV.ramp("#4a2c1a"), { flat = true, gloss = false, outline = false })
c:part(c:ellipse(yx - 17, yy - 3, 8, 7), GV.ramp("#5e3a2a"), { cres = 3, deep = 5 })
c:part(c:poly({ {yx - 24, yy - 9}, {yx - 29, yy - 15}, {yx - 22, yy - 12} }), GV.ramp("#f2e4c0", { dot = "#fff3c8" }), { flat = true, gloss = false })
c:part(c:poly({ {yx - 12, yy - 9}, {yx - 8, yy - 16}, {yx - 15, yy - 11} }), GV.ramp("#f2e4c0", { dot = "#fff3c8" }), { flat = true, gloss = false })
c:eye(yx - 21, yy - 8, true); c:eye(yx - 15, yy - 8, true)
c:part(c:ellipse(yx - 20, yy + 1, 3, 2), GV.ramp("#e9b98a"), { flat = true, gloss = false, outline = false })
c:part(c:rrect(yx - 7, yy - 6, yx + 7, yy + 3, 1), GV.ramp("#d6322b"), { flat = true, gloss = false })
c:seam({ {yx - 6, yy - 2}, {yx + 6, yy - 2} }, { free = true })
c:part(c:ellipse(yx - 11, yy + 5, 2, 2), GV.ramp("#e8a317"), { flat = true, gloss = false })
c:ground(yx, yy + 15, 18, 1.5)

-- foreground: a small knot of fresh flags on a short post, mid-snap (the one you just tied) --------------------------
local fx, fy = 52, 96
c:part(c:rect(fx - 1, fy - 24, fx + 1, fy + 14), GV.ramp("#7a4a1f"), { flat = true, gloss = false })
for i, col in ipairs({ "#d6322b", "#f5cf6a", "#3f6ad0" }) do
  local y = fy - 22 + (i - 1) * 8
  for k = 0, 11 do
    local wy = math.floor(2 * math.sin(k / 2.2 + i) + 0.5)
    c:fill(c:rect(fx + 2 + k, y + wy, fx + 2 + k, y + 5 + wy - (k // 5)), col)
    c:px(fx + 2 + k, y + 5 + wy - (k // 5), "#2a1a10")
  end
end
c:ground(fx, fy + 14, 6, 1)
-- glimmer of the granted wish
for _, g in ipairs({ {70,80},{78,86},{66,92} }) do c:px(g[1], g[2], "#fff1c8"); c:px(g[1] - 1, g[2], "#f5cf6a"); c:px(g[1] + 1, g[2], "#f5cf6a"); c:px(g[1], g[2] - 1, "#f5cf6a"); c:px(g[1], g[2] + 1, "#f5cf6a") end

L.finish(c, "wonder-prayer-flag-pass")
