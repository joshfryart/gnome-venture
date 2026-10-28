-- wonder-stone-head-watchers.lua : a row of giant carved stone heads on a sunny headland; one blinks and a seed rolls from its lip.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV = L.GV
local c = L.new()
local W, H = L.W, L.H
local HOR = 74

L.sky(c, "day", HOR)
L.cloud(c, 40, 30, 22, "#f4f0e0", "#cfd8e4"); L.cloud(c, 150, 20, 26, "#f4f0e0", "#cfd8e4"); L.cloud(c, 210, 44, 16, "#f4f0e0", "#cfd8e4"); L.cloud(c, 100, 50, 12, "#f4f0e0", "#cfd8e4")
-- sun
c:fill(c:ellipse(196, 22, 8, 8), "#f5cf6a"); c:fill(c:ellipse(195, 21, 5, 5), "#fff1c8")
-- gulls
for _, g in ipairs({ {70,40},{80,36},{180,56} }) do c:px(g[1], g[2], "#5b6470"); c:px(g[1]+1, g[2]+1, "#5b6470"); c:px(g[1]+2, g[2], "#5b6470"); c:px(g[1]+3, g[2]+1, "#5b6470"); c:px(g[1]+4, g[2], "#5b6470") end
-- sea
L.water(c, HOR + 1, "day")
c:fill(c:rect(0, HOR + 1, W - 1, HOR + 1), "#cfe8f0")
for _, w in ipairs({ {12,84,10},{50,90,12},{96,82,8},{140,88,11},{188,84,9},{222,92,10},{30,98,9} }) do c:fill(c:rect(w[1], w[2], w[1] + w[3], w[2]), "#cfe8f0") end
-- far islet
c:part(c:poly({ {40,HOR+1},{52,HOR-6},{70,HOR-6},{84,HOR+1} }), GV.ramp("#6a9a8a"), { gloss = false, rim = false, bounce = false, outline = false, cres = 2, deep = 3 })
-- headland (grass), rises from sea on the left to the right; cliff face to the sea at lower left
local land = L.below(c, function(x) return 96 + 6 * math.sin(x / 40) - x * 0.05 + 4 end)
c:part(land, "moss", { gloss = false, rim = false, outline = false, cres = 8, deep = 14 })
-- cliff / rock strip down at left bottom
c:part(c:poly({ {0,112},{30,108},{60,114},{70,H},{0,H} }), GV.ramp("#9a6b3f"), { gloss = false, cres = 6, deep = 10, rim = false })
c:part(c:poly({ {0,H-10},{40,H-14},{70,H},{0,H} }), GV.ramp("#5e2f1e"), { gloss = false, outline = false, cres = 4, deep = 6, rim = false })
-- grass tufts and flowers
for i = 0, 45 do local x = (i * 57 + 11) % W; local y = 100 + (i * 31) % 28; if y > 96 + 5 * math.sin(x / 40) - x * 0.05 + 6 then c:px(x, y, "#a4b86a"); c:px(x + 1, y - 1, "#c8d77a"); c:px(x + 2, y, "#a4b86a") end end
for _, f in ipairs({ {80,122},{110,126},{170,124},{210,120},{140,126},{24,120} }) do c:px(f[1], f[2], "#f6b8cf"); c:px(f[1] + 1, f[2], "#fff1c8") end

-- heads, back (small, right) to front (big, left)
local function head(x, y, h, mode, topknot)
  local w = math.floor(h * 0.55)
  c:ground(x, y + 1, w / 2 + 3, 2, "#2f5a2a")
  local m = c:poly({ {x - math.floor(w * 0.4), y - h}, {x + math.floor(w * 0.4), y - h}, {x + math.floor(w * 0.5), y - math.floor(h * 0.72)}, {x + math.floor(w * 0.5), y}, {x - math.floor(w * 0.5), y}, {x - math.floor(w * 0.5), y - math.floor(h * 0.72)} })
  local base = (h > 45) and "#8b8f96" or "#9a9aa2"
  if topknot then
    c:part(c:rrect(x - math.floor(w * 0.34), y - h - math.floor(h * 0.18), x + math.floor(w * 0.34), y - h + 1, 2), GV.ramp("#d6322b"), { cres = 3, deep = 5 })
  end
  c:part(m, GV.ramp(base), { cres = math.floor(w / 5), deep = math.floor(w / 3) })
  -- brow ridge shadow band and nose
  local by = y - math.floor(h * 0.62)
  c:fill(c:rect(x - math.floor(w * 0.44), by, x + math.floor(w * 0.44), by + 1), "#5b6470")
  c:part(c:rect(x - math.floor(w * 0.08), by + 2, x + math.floor(w * 0.08) + 1, y - math.floor(h * 0.3)), GV.ramp(base), { cres = 2, deep = 3, flat = true, gloss = false, contour = "#5b6470" })
  -- mouth
  local my = y - math.floor(h * 0.2)
  c:fill(c:rect(x - math.floor(w * 0.22), my, x + math.floor(w * 0.22), my + 1), "#2a1a10")
  -- eyes
  local ex = math.floor(w * 0.22)
  local ey = by + 2
  local small = h < 45
  if mode == "open" then
    c:fill(c:rect(x - ex - 3, ey - 1, x - ex + 3, ey + 5), "#5b6470"); c:fill(c:rect(x + ex - 3, ey - 1, x + ex + 3, ey + 5), "#5b6470")
    if small then c:eye(x - ex - 1, ey, true); c:eye(x + ex - 1, ey, true) else c:eye(x - ex - 2, ey); c:eye(x + ex - 2, ey) end
  elseif mode == "blink" then
    for _, sx in ipairs({ x - ex, x + ex }) do
      c:fill(c:rect(sx - 3, ey + 1, sx + 3, ey + 2), "#2a1a10"); c:px(sx - 3, ey, "#2a1a10"); c:px(sx + 3, ey, "#2a1a10")
    end
  end
  -- moss and lichen
  c:fill(m:copy():clip(c:rect(x - w, y - h, x + w, y - h + 2)), "#7ab55c")
  c:px(x - math.floor(w * 0.3), y - h + 3, "#7ab55c"); c:px(x + math.floor(w * 0.35), y - h + 3, "#6a9a3a")
  c:px(x + math.floor(w * 0.3), y - 5, "#a4b86a"); c:px(x + math.floor(w * 0.34), y - 6, "#a4b86a")
  c:px(x - math.floor(w * 0.35), y - 4, "#a4b86a")
  return w
end
head(204, 100, 30, "open", false)
head(158, 106, 38, "open", true)
head(102, 114, 48, "blink", false)
head(42, 126, 62, "open", true)
-- seed rolling out from the blinking head's lip, and a bright trail
local sx, sy = 102, 114 - math.floor(48 * 0.2) + 2
c:part(c:ellipse(sx + 1, sy + 3, 2, 2.6), GV.ramp("#e8a317"), { flat = true, gloss = false })
c:px(sx, sy + 2, "#fff1c8")
c:seam({ {sx + 3, sy + 6}, {sx + 12, sy + 8}, {sx + 20, sy + 12} }, { free = true, on = 1, off = 2 })
c:part(c:ellipse(sx + 24, sy + 14, 2, 2.6), GV.ramp("#e8a317"), { flat = true, gloss = false }); c:px(sx + 23, sy + 13, "#fff1c8")
-- sparkles for the answered question
for _, p in ipairs({ {88,66},{116,64},{102,58} }) do c:px(p[1], p[2], "#fff1c8"); c:px(p[1]-1, p[2], "#f5cf6a"); c:px(p[1]+1, p[2], "#f5cf6a"); c:px(p[1], p[2]-1, "#f5cf6a"); c:px(p[1], p[2]+1, "#f5cf6a") end
L.finish(c, "wonder-stone-head-watchers")
