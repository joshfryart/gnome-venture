-- puzzles/cast/win-scene-jigsaw.png: 320x200 (drawn 160x100, out=2). Jigsaw finished! Out on the meadow,
-- Jeff (cheering) and Ffej (for once helping) hold the completed picture up between them; gold rays burst
-- behind it, balloons and felt confetti in the sky. Also writes win-scene-jigsaw-dark.png: night meadow,
-- stars and fireworks, dimmed cast.
-- Families: sky = water (day) / dusk (night), meadow = moss, frame = gold/wood, picture = water/moss/red.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local CAST = dofile(D .. "extras-pixel/scripts/cast-lib.lua")(GV)
local P = app.params or {}
local PNG = P.out or "/home/user/gnome-venture/game/assets/img/puzzles/cast/"
local ASE = P.ase or D .. "extras-pixel/cast/"
local W, H = 160, 100
local rnd = function(v) return math.floor(v + 0.5) end

local function scene(dark)
  local c = GV.canvas{ w = W, h = H, mode = "scene", out = 2, ol = 1, olx = 1, cres = 3, deep = 1 }
  local dim = function(h) return CAST.dim(h, dark) end
  -- sky
  if dark then
    c:bands(c:rect(0, 0, W - 1, 70), { "#1c1f4a", "#202657", "#252e62", "#2a356c", "#334579", "#3d4f84" }, { dir = "v" })
    for _, p in ipairs({ { 6, 8 }, { 20, 22 }, { 34, 6 }, { 58, 4 }, { 98, 6 }, { 124, 4 }, { 150, 12 }, { 140, 30 }, { 12, 40 }, { 152, 48 }, { 4, 58 }, { 70, 2 } }) do c:px(p[1], p[2], "#f5cf6a") end
    c:px(34, 6, "#fff1c8"); c:px(124, 4, "#fff1c8")
    -- fireworks: rings of felt sparks with a gold heart
    local function burst(cx, cy, r, col)
      for a = 0, 11 do
        local t = a * math.pi / 6
        local x, y = rnd(cx + math.cos(t) * r), rnd(cy + math.sin(t) * r)
        local x2, y2 = rnd(cx + math.cos(t) * (r - 3)), rnd(cy + math.sin(t) * (r - 3))
        c:px(x, y, col); c:px(x2, y2, col)
      end
      c:px(cx, cy, "#fff1c8"); c:px(cx - 1, cy, "#f5cf6a"); c:px(cx + 1, cy, "#f5cf6a"); c:px(cx, cy - 1, "#f5cf6a"); c:px(cx, cy + 1, "#f5cf6a")
    end
    burst(18, 14, 9, "#e46a9b"); burst(142, 18, 10, "#7fc0de"); burst(84, 4, 0, "#f5cf6a")
  else
    c:bands(c:rect(0, 0, W - 1, 70), { "#7fc0de", "#88c5e0", "#92cbe3", "#9dd0e6", "#a8d6e9", "#b3dcec" }, { dir = "v" })
  end
  -- gold rays fanning out behind the picture
  local rays = c:mask()
  for a = 0, 15, 2 do
    local t0, t1 = a * math.pi / 8, (a + 0.9) * math.pi / 8
    rays:add(c:poly({ { 80, 32 }, { 80 + math.cos(t0) * 90, 32 + math.sin(t0) * 90 }, { 80 + math.cos(t1) * 90, 32 + math.sin(t1) * 90 } }))
  end
  rays:clip(c:rect(0, 0, W - 1, 70))
  c:fill(rays, dark and "#2f3a72" or "#c4e4ef")
  -- far hills and meadow
  c:part(c:ellipse(30, 78, 70, 16):clip(c:rect(0, 0, W - 1, 78)), GV.ramp(dark and "#4f7a52" or "#a4cf78"), { gloss = false, outline = false, cres = 5 })
  c:part(c:ellipse(140, 76, 60, 13):clip(c:rect(0, 0, W - 1, 78)), GV.ramp(dark and "#476f4c" or "#94c46e"), { gloss = false, outline = false, cres = 5 })
  local mead = c:rect(0, 76, W - 1, H - 1)
  for x = 0, W - 1, 6 do mead:add(c:poly({ { x, 77 }, { x + 3, 73 }, { x + 6, 77 } })) end
  c:part(mead, GV.ramp(dark and "#3f6a48" or "#7ab55c"), { flat = true, rim = false, outline = false, contour = false })
  c:bands(c:rect(0, 82, W - 1, H - 1), dark and { "#3b6545", "#376042", "#335b3f", "#2f563c" } or { "#74b057", "#6eab52", "#68a64d", "#62a148" }, { dir = "v" })
  -- balloons (day) on strings, upper left and right
  if not dark then
    local function balloon(x, y, col)
      c:fill(c:line({ { x, y + 6 }, { x - 1, y + 12 }, { x + 1, y + 18 } }, 1), "#4a2c1a")
      c:part(c:ellipse(x, y, 4, 5), GV.ramp(col), { gloss = { x - 2, y - 3 }, cres = 2, deep = 1 })
      c:px(x, y + 6, col)
    end
    balloon(12, 12, "#dd3a2a"); balloon(22, 8, "#f5cf6a"); balloon(146, 10, "#8a5fd0"); balloon(136, 14, "#3f8fb0")
  end
  -- the finished picture in a gold frame, held up high
  local fx0, fy0, fx1, fy1 = 46, 12, 114, 54
  local frame = c:rrect(fx0, fy0, fx1, fy1, 1)
  c:part(frame, GV.ramp(dim("#e8a317")), { gloss = { fx0 + 2, fy0 + 1 }, cres = 2, deep = 1 })
  local px0, py0, px1, py1 = fx0 + 3, fy0 + 3, fx1 - 3, fy1 - 3
  local pic = CAST.picture(c, px0, py0, px1, py1, dark)
  CAST.cuts(c, pic, px0, py0, px1, py1, 6, 4, nil, dark)
  c:outline(c:rect(px0, py0, px1, py1), { ol = 1, olx = 0 })
  c:seam({ { fx0 + 2, fy1 - 1 }, { fx1 - 2, fy1 - 1 } })
  -- corner sparkles on the frame
  c:paint({ "..g..", "..g..", "gg.gg", "..g..", "..g.." }, fx1 - 1, fy0 - 5, { g = "#fff1c8" })
  c:paint({ ".g.", "ggg", ".g." }, fx0 - 4, fy0 - 3, { g = "#f5cf6a" })
  -- the cast: Jeff left (cheering, hand on the corner), Ffej right (both arms up, gripping the other corner)
  CAST.jeff(c, 26, 67, 0.9, { pose = "cheer", dark = dark })
  c:ground(26, 86, 15, 2)
  CAST.ffej(c, 133, 64, 0.9, { dark = dark })
  c:ground(133, 86, 15, 2)
  -- flowers in the front
  local function flower(x, y, col)
    c:part(c:line({ { x, y + 6 }, { x, y + 2 } }, 2), GV.ramp(dark and "#2f5a3a" or "#4a8a3e"), { flat = true, outline = false })
    local head = c:ellipse(x, y - 2, 1.5, 1.5):add(c:ellipse(x + 2, y, 1.5, 1.5)):add(c:ellipse(x, y + 2, 1.5, 1.5)):add(c:ellipse(x - 2, y, 1.5, 1.5))
    c:part(head, GV.ramp(dim(col)), { gloss = false, cres = 2, deep = 0 })
    c:px(x, y, "#e8a317"); c:px(x - 1, y - 1, "#f5cf6a")
  end
  flower(58, 88, "#e46a9b"); flower(80, 93, "#f5cf6a"); flower(100, 87, "#f1ece0"); flower(6, 92, "#dd3a2a"); flower(152, 93, "#8a5fd0"); flower(70, 80, "#f08a24")
  -- scattered spare... no: every piece is in! a few confetti flakes instead
  local CF = { "#dd3a2a", "#f5cf6a", "#3f8fb0", "#e46a9b", "#7ab55c", "#8a5fd0", "#f08a24" }
  local pts = { { 34, 30 }, { 40, 4 }, { 52, 6 }, { 66, 3 }, { 96, 4 }, { 108, 7 }, { 122, 30 }, { 118, 40 }, { 40, 46 }, { 8, 30 }, { 150, 36 },
    { 4, 50 }, { 156, 60 }, { 30, 4 }, { 128, 4 }, { 44, 60 }, { 118, 60 }, { 80, 60 }, { 92, 66 }, { 64, 64 } }
  for i, p in ipairs(pts) do
    local col = dim(CF[(i - 1) % #CF + 1])
    local m
    if i % 3 == 0 then m = c:rect(p[1], p[2], p[1] + 1, p[2] + 2)
    elseif i % 3 == 1 then m = c:rect(p[1], p[2], p[1] + 2, p[2] + 1)
    else m = c:rect(p[1], p[2], p[1] + 1, p[2] + 1) end
    c:part(m, GV.ramp(col), { flat = true, outline = false })
    c:outline(m, { ol = 1, olx = 0 })
  end
  local name = dark and "win-scene-jigsaw-dark" or "win-scene-jigsaw"
  local t = c:save(ASE .. name .. ".aseprite", PNG .. name .. ".png")
  print(name, GV.report(t))
  assert(t.semi == 0 and t.bw <= 4)
end
scene(false)
scene(true)
