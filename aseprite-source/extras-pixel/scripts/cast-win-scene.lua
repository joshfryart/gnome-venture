-- puzzles/cast/win-scene.png: 320x200 (drawn 160x100, out=2). A finished jigsaw on an easel, Jeff cheering,
-- the Old Wizard clapping, confetti. Also writes win-scene-dark.png (dusk room, lamp glow, dimmed cast).
-- Families: wall = cream/soil, easel + floor = wood, picture = water/moss/gold, confetti = Part A bases.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local CAST = dofile(D .. "extras-pixel/scripts/cast-lib.lua")(GV)
local PNG = "/home/user/gnome-venture/game/assets/img/puzzles/cast/"
local ASE = D .. "extras-pixel/cast/"
local W, H = 160, 100
local rnd = function(v) return math.floor(v + 0.5) end

local function scene(dark)
  local c = GV.canvas{ w = W, h = H, mode = "scene", out = 2, ol = 1, olx = 1, cres = 3, deep = 1 }
  local dim = function(h) return CAST.dim(h, dark) end
  -- wall and picture rail
  if dark then
    c:bands(c:rect(0, 0, W - 1, 75), { "#3a2f5e", "#3e3364", "#433869", "#48406f", "#4d4675" }, { dir = "v" })
  else
    c:bands(c:rect(0, 0, W - 1, 75), { "#f1e6c8", "#efe2c2", "#ecdcba", "#e8d6b2", "#e4d0aa" }, { dir = "v" })
  end
  c:fill(c:rect(0, 9, W - 1, 9), dark and "#2d2448" or "#d9c49a")
  c:fill(c:rect(0, 10, W - 1, 10), dark and "#52477c" or "#f8f0d8")
  -- hanging lamp top-left, lit at night
  local lamp = c:poly({ { 20, 2 }, { 36, 2 }, { 41, 13 }, { 15, 13 } })
  c:part(lamp, GV.ramp(dim("#dd3a2a")), { gloss = { 19, 5 }, cres = 3, deep = 1 })
  c:fill(c:rect(28, 0, 28, 1), "#4a2c1a")
  if dark then
    c:bands(c:ellipse(28, 28, 26, 14):clip(c:rect(0, 14, W - 1, 75)), { "#6a5a4a", "#5e4f5a", "#52456a" }, { dir = "radial", cx = 28, cy = 14, r = 26 })
    c:part(c:ellipse(28, 14, 8, 2), GV.ramp("#fff1c8"), { flat = true, outline = false })
  else
    c:part(c:ellipse(28, 14, 8, 2), GV.ramp("#f5cf6a"), { flat = true, outline = false })
  end
  -- wooden floor with a skirting board and a hem stitch
  c:fill(c:rect(0, 76, W - 1, 79), dim("#d9c49a")); c:fill(c:rect(0, 76, W - 1, 76), dim("#f8f0d8"))
  c:fill(c:rect(0, 80, W - 1, 80), "#4a2c1a")
  c:bands(c:rect(0, 81, W - 1, H - 1), { dim("#b07a45"), dim("#a8703e"), dim("#9c6638"), dim("#8a4f2a") }, { dir = "v" })
  for x = -8, W - 1, 28 do c:fill(c:rect(x + 14, 82, x + 14, H - 1), dim("#8a4f2a")) end
  c:fill(c:rect(0, 90, W - 1, 90), dim("#8a4f2a"))
  c:seam({ { 0, 97 }, { W - 1, 97 } }, { free = true })
  -- easel: two legs and a tray, picture leaning on it
  local legs = c:line({ { 58, 70 }, { 66, 20 } }, 2):add(c:line({ { 102, 70 }, { 94, 20 } }, 2))
  legs:add(c:line({ { 80, 20 }, { 80, 8 } }, 2))
  c:part(legs, GV.ramp(dim("#b07a45")), { flat = true })
  -- picture frame and the finished jigsaw (meadow, sun, tree) with piece cuts
  local px0, py0, px1, py1 = 50, 18, 109, 62
  local frame = c:rrect(px0, py0, px1, py1, 1)
  c:part(frame, GV.ramp(dim("#d9a660")), { gloss = false, cres = 2, deep = 1 })
  local pic = c:rect(px0 + 3, py0 + 3, px1 - 3, py1 - 3)
  c:bands(c:rect(px0 + 3, py0 + 3, px1 - 3, py0 + 26), dark and { "#2a356c", "#334579", "#3d5386" } or { "#7fc0de", "#92cce4", "#a8d8ea" }, { dir = "v" })
  c:part(c:ellipse(70, 52, 30, 12):clip(pic), GV.ramp(dim("#94c46e")), { gloss = false, outline = false, cres = 4 })
  c:part(c:ellipse(98, 56, 26, 10):clip(pic), GV.ramp(dim("#7ab55c")), { gloss = false, outline = false, cres = 4 })
  c:part(c:ellipse(96, 28, 5, 5), dark and GV.ramp("#f1ece0", { pale = true }) or GV.ramp("#f5cf6a"), { outline = false, gloss = false })
  c:part(c:rect(63, 38, 65, 50), GV.ramp(dim("#8a4f2a")), { flat = true, outline = false })
  c:part(c:ellipse(64, 35, 8, 7):clip(pic), GV.ramp(dim("#4a8a3e")), { outline = false, gloss = { 59, 31 }, cres = 3 })
  -- jigsaw cuts: a 4x3 grid of wobbly lines in a light tone over the picture
  local cut = dark and "#8a86b0" or "#fff3c8"
  local cm = c:mask()
  for i = 1, 3 do
    local x = px0 + 3 + i * 13.5
    for y = py0 + 3, py1 - 3 do cm:set(rnd(x + (((y + i) // 4) % 2) * 0 + ((y // 5) % 2 == 0 and 0 or 1)), y) end
  end
  for j = 1, 2 do
    local y = py0 + 3 + j * 13.5
    for x = px0 + 3, px1 - 3 do cm:set(x, rnd(y + ((x // 5) % 2 == 0 and 0 or 1))) end
  end
  -- knobs on the cuts: small discs at every other junction
  for i = 1, 3 do for j = 1, 2 do
    local kx, ky = rnd(px0 + 3 + i * 13.5), rnd(py0 + 3 + j * 13.5)
    if (i + j) % 2 == 0 then cm:add(c:ellipse(kx + 3, ky, 1.5, 1.5):edge()) else cm:add(c:ellipse(kx, ky + 3, 1.5, 1.5):edge()) end
  end end
  cm:clip(pic)
  cm:each(function(x, y) if c:get(x, y) ~= "#2a1a10" then c:px(x, y, cut) end end)
  -- ribbon rosette on the frame corner
  c:part(c:ellipse(px1 - 2, py0 + 2, 4, 4), GV.ramp(dim("#dd3a2a")), { gloss = false, cres = 2, deep = 1 })
  c:fill(c:ellipse(px1 - 2, py0 + 2, 1.5, 1.5), "#f5cf6a")
  c:part(c:poly({ { px1 - 3, py0 + 5 }, { px1 - 1, py0 + 5 }, { px1 + 1, py0 + 12 }, { px1 - 5, py0 + 12 } }), GV.ramp(dim("#dd3a2a")), { flat = true })
  -- the cast on the floor: Jeff cheering (left), Wizard clapping (right)
  CAST.jeff(c, 32, 56, 0.85, { pose = "cheer", dark = dark })
  c:ground(32, 76, 14, 2)
  CAST.wizard(c, 128, 54, 0.85, { pose = "clap", dark = dark })
  c:ground(128, 76, 15, 2)
  -- confetti: little felt flakes drifting down
  local CF = { "#dd3a2a", "#f5cf6a", "#3f8fb0", "#e46a9b", "#7ab55c", "#8a5fd0", "#f08a24" }
  local pts = { { 8, 20 }, { 14, 34 }, { 5, 48 }, { 22, 26 }, { 44, 10 }, { 50, 4 }, { 40, 30 }, { 46, 44 }, { 60, 8 }, { 72, 4 },
    { 86, 12 }, { 100, 6 }, { 112, 14 }, { 118, 26 }, { 124, 6 }, { 138, 18 }, { 146, 8 }, { 152, 30 }, { 150, 46 }, { 142, 38 },
    { 112, 40 }, { 20, 60 }, { 56, 68 }, { 110, 66 }, { 150, 64 }, { 4, 70 }, { 136, 4 }, { 66, 72 }, { 94, 70 } }
  for i, p in ipairs(pts) do
    local col = dim(CF[(i - 1) % #CF + 1])
    local m
    if i % 3 == 0 then m = c:rect(p[1], p[2], p[1] + 1, p[2] + 2)
    elseif i % 3 == 1 then m = c:rect(p[1], p[2], p[1] + 2, p[2] + 1)
    else m = c:rect(p[1], p[2], p[1] + 1, p[2] + 1) end
    c:part(m, GV.ramp(col), { flat = true, outline = false })
    c:outline(m, { ol = 1, olx = 0 })
  end
  local name = dark and "win-scene-dark" or "win-scene"
  local t = c:save(ASE .. name .. ".aseprite", PNG .. name .. ".png")
  print(name, GV.report(t))
  assert(t.semi == 0 and t.bw == 0)
end
scene(false)
scene(true)
