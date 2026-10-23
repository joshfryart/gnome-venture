-- kit.lua : hoop map kit (hoop.png, landmark-medium/hard/deep, felt-<tier>) and fight effects (fx-*). Part E: hoop/felt/fx no black border; landmarks are sprites (1 px black border).
-- Run: GV_ROOT=... Aseprite -b --script kit.lua
local X = dofile(os.getenv("GV_ROOT") .. "opus-test-run/scripts/gvx.lua")
local GV = X.GV
local ROOT = X.ROOT
local function R(base, shade, rim) return X.ramp(base, { shade = shade, deep = shade, bounce = shade, rim = rim or base, gloss = base, dot = base }) end
local WOOD = R("#b07a45", "#8a4f2a", "#d9a660")
local function raw(c, rel, name, cap)   -- save with gvlib (single layer) and report
  local t = c:save(ROOT .. "opus-test-run/aseprite/" .. name .. ".aseprite", ROOT .. "opus-test-run/game/assets/img/" .. rel .. ".png")
  print(string.format("%-18s %dx%d colours=%d/%d semi=%d bw=%d %s", name, t.w, t.h, t.colours, cap, t.semi, t.bw, (t.semi == 0 and t.colours <= cap) and "OK" or "FAIL"))
end

-- ===== hoop: 120x120 grid -> 240x240, rim 6 grid px, transparent cloth centre =====
do
  local c = GV.canvas{ mode = "scene", w = 120, h = 120, out = 2, ol = 1, olx = 1 }
  local ring = c:ellipse(59.5, 59.5, 59, 59):cut(c:ellipse(59.5, 59.5, 52, 52))
  c:part(ring, WOOD, { gloss = false, cres = 3, deep = 0 })
  c:fill(c:ellipse(59.5, 59.5, 53, 53):cut(c:ellipse(59.5, 59.5, 52, 52)), "#8a4f2a")                  -- inner wood lip, second tone
  -- brass screw block at the top with a slot and a lit edge
  c:part(c:rrect(52, 0, 67, 9, 1), "gold", { gloss = false, cres = 2, deep = 0 })
  c:fill(c:rect(58, 1, 61, 1), "#8a4f2a"); c:fill(c:rect(53, 1, 54, 8), "#fff1c8")
  c:fill(c:rect(0, 0, 0, 0), nil)
  raw(c, "map/hoop", "hoop", 16)
end
-- ===== landmarks 16x16 (sprites, black border, <=16 colours) =====
local function sprite(name, draw) local c = GV.canvas{ w = 16, h = 16, mode = "icon", ol = 1, olx = 1, cres = 2, deep = 1 }; draw(c); raw(c, "map/" .. name, name, 16) end
sprite("landmark-medium", function(c)      -- signpost
  c:part(c:ellipse(7.5, 12.5, 3.5, 1.2), "soil", { gloss = false, cres = 1, deep = 0, bounce = false })
  c:part(c:rect(7, 3, 8, 12), "wood", { flat = true })
  c:part(c:poly({ { 3, 3 }, { 12, 3 }, { 14, 5 }, { 12, 7 }, { 3, 7 } }), "wood", { gloss = false, cres = 1, deep = 0 })
  c:px(5, 5, "#8a4f2a"); c:px(7, 5, "#8a4f2a"); c:px(9, 5, "#8a4f2a")
end)
sprite("landmark-hard", function(c)        -- stone cairn
  c:part(c:ellipse(7.5, 11.5, 5, 1.8), "stone", { gloss = false, cres = 1, deep = 0 })
  c:part(c:ellipse(7.5, 8.5, 3.5, 1.6), "stone", { gloss = false, cres = 1, deep = 0 })
  c:part(c:ellipse(7.5, 5.5, 2.2, 1.3), "stone", { gloss = false, cres = 1, deep = 0 })
  c:px(5, 11, "#c9c5bc"); c:px(6, 8, "#c9c5bc")
end)
sprite("landmark-deep", function(c)        -- glowing mushroom
  c:part(c:rect(6, 8, 9, 12), "cream", { gloss = false, flat = true })
  c:part(c:ellipse(7.5, 6.5, 5, 3.5):cut(c:rect(0, 8, 15, 15)), "dusk", { gloss = false, cres = 2, deep = 0 })
  c:px(5, 5, "#f5cf6a"); c:px(9, 4, "#f5cf6a"); c:px(7, 6, "#fff3c8"); c:px(11, 6, "#f5cf6a")
end)
-- ===== felt textures 16x16 tileable (period-4 weave, hard pixels) =====
local FELT = { gentle = { "#bdd292", "#a4b86a" }, medium = { "#a4b86a", "#7ab55c" }, hard = { "#e8a317", "#d0862a" }, wild = { "#d9885a", "#c47a52" }, deep = { "#c3b2ea", "#7a5cc0" } }
for tier, col in pairs(FELT) do
  local c = GV.canvas{ mode = "scene", w = 16, h = 16, out = 1 }
  c:fill(c:rect(0, 0, 15, 15), col[1])
  for y = 0, 15 do for x = 0, 15 do
    if (x + y) % 4 == 0 then c:px(x, y, col[2]) elseif (x - y) % 8 == 5 then c:px(x, y, col[2]) end
  end end
  raw(c, "map/felt-" .. tier, "felt-" .. tier, 4)
end

-- ===== fight effects: transparent, no border, <=8 colours =====
local GOLD, CREAM, EMBER, DEEP = "#f5cf6a", "#fff3c8", "#f08a24", "#e8a317"
local function fxc(w, h) return GV.canvas{ mode = "scene", w = w, h = h, out = 1, ol = 0, olx = 0 } end
local function ray(c, x, y, dx, dy, a, b, col, th)   -- straight ray from radius a to b along (dx,dy), th px thick
  c:fill(c:line({ { x + dx * a, y + dy * a }, { x + dx * b, y + dy * b } }, th), col) end
do   -- fx-hit: 4 frames of an impact spark (192x48): ring of rays that grows then breaks into dots
  local c = fxc(192, 48)
  local dirs = { { 1, 0 }, { 0.7, 0.7 }, { 0, 1 }, { -0.7, 0.7 }, { -1, 0 }, { -0.7, -0.7 }, { 0, -1 }, { 0.7, -0.7 } }
  local spec = { { 3, 9, 3, GOLD }, { 7, 17, 3, GOLD }, { 12, 20, 2, DEEP }, { 17, 21, 1, DEEP } }
  for f = 0, 3 do local ox, oy = 24 + f * 48, 24; local s = spec[f + 1]
    for i, d in ipairs(dirs) do ray(c, ox, oy, d[1], d[2], s[1], s[2], (i % 2 == 0) and s[4] or EMBER, s[3]) end
    if f < 3 then c:fill(c:ellipse(ox, oy, 4 - f, 4 - f), CREAM) end
  end
  raw(c, "fx/fx-hit", "fx-hit", 8)
end
do   -- fx-heal: 4 frames of green plus-sparkles rising
  local c = fxc(192, 48)
  local pts = { { 12, 34, 0 }, { 24, 30, 1 }, { 36, 36, 2 }, { 18, 40, 3 }, { 30, 42, 0 } }
  for f = 0, 3 do local ox = f * 48
    for _, p in ipairs(pts) do
      local y = p[2] - f * 6 - p[3] * 2
      if y > 3 then local x = ox + p[1]
        c:fill(c:rect(x - 2, y, x + 2, y), "#7ab55c"); c:fill(c:rect(x, y - 2, x, y + 2), "#7ab55c"); c:px(x, y, CREAM)
        if (f + p[3]) % 2 == 0 then c:px(x + 3, y - 3, "#a4b86a") end
      end
    end
  end
  raw(c, "fx/fx-heal", "fx-heal", 8)
end
do   -- fx-ko: three stars circling
  local c = fxc(48, 48)
  for i = 0, 2 do local a = i * 2.0944 + 0.4; local x, y = 24 + math.cos(a) * 14, 22 + math.sin(a) * 6
    c:fill(c:rect(x - 3, y, x + 3, y), GOLD); c:fill(c:rect(x, y - 3, x, y + 3), GOLD); c:fill(c:rect(x - 1, y - 1, x + 1, y + 1), CREAM); c:fill(c:rect(x - 2, y - 2, x - 2, y - 2), DEEP); c:fill(c:rect(x + 2, y + 2, x + 2, y + 2), DEEP) end
  raw(c, "fx/fx-ko", "fx-ko", 8)
end
do   -- fx-shield: 96x96 bubble ring, hard-stepped (no translucency): lit arc upper-left, shade arc lower-right
  local c = fxc(96, 96)
  local ring = c:ellipse(47.5, 47.5, 44, 44):cut(c:ellipse(47.5, 47.5, 41, 41))
  ring:each(function(x, y) local s = (x - 47.5) + (y - 47.5); c:px(x, y, s < -30 and "#eef8f2" or (s > 26 and "#3f8fb0" or "#a9d6ea")) end)
  c:fill(c:rect(24, 24, 29, 26), "#eef8f2"); c:fill(c:rect(24, 24, 26, 30), "#eef8f2")
  raw(c, "fx/fx-shield", "fx-shield", 8)
end
do   -- fx-snack: 4 frames, a thrown snack flies along an arc then bursts into a puff with crumbs
  local c = fxc(192, 48)
  local arc = { { 8, 36 }, { 18, 22 }, { 30, 18 } }
  for f = 0, 3 do local ox = f * 48
    if f < 3 then local p = arc[f + 1]; c:fill(c:ellipse(ox + p[1], p[2], 4, 3), GOLD); c:fill(c:rect(ox + p[1] - 2, p[2] - 2, ox + p[1], p[2] - 2), CREAM); for k = 0, f - 1 do c:px(ox + arc[k + 1][1], arc[k + 1][2], DEEP) end
    else
      c:fill(c:ellipse(ox + 24, 26, 12, 9), "#f2e4c0"); c:fill(c:ellipse(ox + 16, 22, 7, 6), "#f2e4c0"); c:fill(c:ellipse(ox + 32, 21, 7, 6), "#f2e4c0")
      c:fill(c:rect(ox + 14, 30, ox + 34, 34), "#d8c49a"); c:px(ox + 10, 14, GOLD); c:px(ox + 38, 12, GOLD); c:px(ox + 24, 8, GOLD); c:px(ox + 6, 24, DEEP); c:px(ox + 42, 24, DEEP)
    end
  end
  raw(c, "fx/fx-snack", "fx-snack", 8)
end
do   -- fx-ground-shadow: 64x16 hard-stepped umber ellipse (opaque rows, two tones)
  local c = fxc(64, 16)
  c:fill(c:ellipse(31.5, 7.5, 30, 6), "#7a4a1f"); c:fill(c:ellipse(31.5, 7.5, 22, 4), "#4a2c1a")
  raw(c, "fx/fx-ground-shadow", "fx-ground-shadow", 8)
end
