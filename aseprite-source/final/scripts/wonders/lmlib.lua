-- lmlib.lua : shared helpers for the unique-location scene set (480x270 = 240x135 grid at 2x, gvlib scene mode).
-- Use:  local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua"); local c = L.new()
--       ... draw with c (gvlib canvas) and L helpers ...   L.finish(c, SLUG)     (reads --script-param out= / ase=)
-- The reference scene is wonder-lighthouse-of-the-lost-lantern.lua (sky, sea, rock, tower, crab, hem stitch).
local REPO = "/home/user/gnome-venture/"
local GV = dofile(REPO .. "aseprite-source/gvlib/gvlib.lua")
local L = { GV = GV, W = 240, H = 135 }

-- Sky ramps, top to bottom (5-8 hard bands). Pick one per scene so the set varies in light.
L.SKY = {
  day   = { "#7fb8dc", "#8fc4e2", "#a4d0e8", "#b9dcee", "#cfe8f0", "#e2f0e0" },
  dawn  = { "#5a6aa8", "#7a7ab8", "#a48ac0", "#d49ab8", "#f0aa98", "#f8c890", "#fbe0a8" },
  dusk  = { "#2a2250", "#352a68", "#4e3a8a", "#6a4fa8", "#8c6ab8", "#b784b4", "#e39a86", "#f5b878" },
  night = { "#141234", "#1c1a48", "#26225a", "#322c6c", "#3e3680", "#4a428e" },
  storm = { "#4a5468", "#5a6478", "#6c7688", "#808a9a", "#98a0ae", "#aab0ba" },
  warm  = { "#e8b070", "#f0be80", "#f5cc92", "#f8dba8", "#fbe8c0", "#fdf2d8" }, -- hazy desert / golden hour
}
L.SEA = {
  day  = { "#5aa8c8", "#4a98bc", "#3f8fb0", "#3584a6", "#2f78a0", "#2a6c94" },
  dusk = { "#3a5f9a", "#2f6290", "#2b5a86", "#25507a", "#25446e", "#2a3c6c" },
  night = { "#1e3466", "#1a2e5c", "#172852", "#142248", "#101c3e", "#0e1834" },
}

function L.new() return GV.canvas{ w = L.W, h = L.H, mode = "scene", out = 2 } end

-- full-width sky from row 0 to `hor`
function L.sky(c, kind, hor)
  c:bands(c:rect(0, 0, L.W - 1, hor or 80), L.SKY[kind], { dir = "v" })
end
function L.stars(c, n, maxy, seed)
  local s = seed or 7
  for i = 1, n do
    s = (s * 1103515245 + 12345) % 2147483648
    local x = s % L.W; s = (s * 1103515245 + 12345) % 2147483648
    local y = s % (maxy or 50)
    c:px(x, y, (i % 4 == 0) and "#fff1c8" or "#c3b2ea")
  end
end
function L.cloud(c, cx, cy, rx, top, under)
  local m = c:ellipse(cx, cy, rx, 2.2); m:add(c:ellipse(cx - rx * 0.4, cy - 1.5, rx * 0.5, 2.2)); m:add(c:ellipse(cx + rx * 0.3, cy - 2, rx * 0.45, 2.4))
  c:fill(m, top or "#f4f0e0"); c:fill(m:copy():clip(c:rect(0, cy + 1, L.W, L.H)), under or "#cfd8e4")
end
-- mask of everything below y = f(x) (rolling ground/hill). f may use math.sin.
function L.below(c, f)
  local m = c:mask()
  for x = 0, L.W - 1 do
    for y = math.max(0, math.floor(f(x) + 0.5)), L.H - 1 do m:set(x, y) end
  end
  return m
end
-- water from row `top` down, with wave dashes. kind = key of L.SEA (or pass your own band list)
function L.water(c, top, kind)
  local cols = type(kind) == "table" and kind or L.SEA[kind or "day"]
  c:bands(c:rect(0, top, L.W - 1, L.H - 1), cols, { dir = "v" })
  local hi = cols[1]
  for i = 0, 14 do
    local x = (i * 37 + 11) % (L.W - 14); local y = top + 4 + (i * 11) % (L.H - top - 8)
    c:fill(c:rect(x, y, x + 6 + (i % 3) * 3, y), hi)
  end
end
-- gold hem stitch top and bottom (every banner and scene has it)
function L.hem(c)
  c:seam({ {0, 1}, {L.W - 1, 1} }, { free = true })
  c:seam({ {0, L.H - 2}, {L.W - 1, L.H - 2} }, { free = true })
end
-- hem, save, print the check line. Params: out=<png> ase=<.aseprite> (script-params), else repo paths.
function L.finish(c, slug)
  L.hem(c)
  local P = app.params
  local png = P.out or (REPO .. "game/assets/img/wonders/" .. slug .. ".png")
  local ase = P.ase or (REPO .. "aseprite-source/final/aseprite/wonders/" .. slug .. ".aseprite")
  local t = c:save(ase, png)
  print(slug .. " " .. GV.report(t))
  assert(t.semi == 0 and t.bw == 0, slug .. ": semi/bw check failed")
end
return L
