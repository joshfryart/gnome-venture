-- puzzles/cast/puzzles-banner.png: 400x120 (drawn 200x60, out=2). The Puzzles cast at a cosy puzzle table:
-- Jeff centre holding a piece, Ffej sneaking in at the far left, the Old Wizard at the far right.
-- Also writes puzzles-banner-dark.png: dusk recolour (night window, moon, warm lamp, dimmed cast).
-- Families: wall = cream/soil, table = wood, window sky = water (day) / dusk (night), pieces = assorted Part A bases.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local CAST = dofile(D .. "extras-pixel/scripts/cast-lib.lua")(GV)
local PNG = "/home/user/gnome-venture/game/assets/img/puzzles/cast/"
local ASE = D .. "extras-pixel/cast/"
local W, H = 200, 60

local function scene(dark)
  local c = GV.canvas{ w = W, h = H, mode = "scene", out = 2, ol = 1, olx = 1, cres = 3, deep = 1 }
  local dim = function(h) return CAST.dim(h, dark) end
  -- wall: warm cream felt by day, dusk violet by night, with a 1 px picture rail
  if dark then
    c:bands(c:rect(0, 0, W - 1, 41), { "#3a2f5e", "#3e3364", "#433869", "#48406f" }, { dir = "v" })
  else
    c:bands(c:rect(0, 0, W - 1, 41), { "#f1e6c8", "#efe2c2", "#ecdcba", "#e8d6b2" }, { dir = "v" })
  end
  c:fill(c:rect(0, 7, W - 1, 7), dark and "#2d2448" or "#d9c49a")
  c:fill(c:rect(0, 8, W - 1, 8), dark and "#52477c" or "#f8f0d8")
  -- window (centre-left) with four panes
  local wx0, wy0, wx1, wy1 = 54, 10, 85, 34
  local frame = c:rrect(wx0, wy0, wx1, wy1, 1)
  c:part(frame, GV.ramp(dim("#b07a45")), { gloss = false, cres = 2, deep = 1 })
  local glass = c:rect(wx0 + 2, wy0 + 2, wx1 - 2, wy1 - 2)
  if dark then
    c:bands(glass, { "#1c1f4a", "#232a5c", "#2a356c", "#334579" }, { dir = "v" })
    for _, p in ipairs({ { 58, 14 }, { 63, 19 }, { 70, 13 }, { 78, 16 }, { 82, 22 }, { 61, 25 } }) do c:px(p[1], p[2], "#f5cf6a") end
    c:px(70, 13, "#fff1c8")
    c:part(c:ellipse(76, 19, 4, 4):cut(c:ellipse(78, 18, 3.5, 3.5)), GV.ramp("#f5cf6a"), { flat = true, outline = false })
    c:part(c:ellipse(64, 30, 9, 3):clip(glass), GV.ramp("#2f5a2a"), { flat = true, outline = false })
  else
    c:bands(glass, { "#8fcbd8", "#9bd2dd", "#a8d8e2", "#b5dfe6" }, { dir = "v" })
    c:part(c:ellipse(61, 16, 4, 2.5):add(c:ellipse(66, 14, 4, 3)):add(c:ellipse(70, 16.5, 3.5, 2)), GV.ramp("#f1ece0"), { flat = true, outline = false })
    c:part(c:ellipse(64, 30, 9, 3):add(c:ellipse(78, 31, 8, 3)):clip(glass), GV.ramp("#7ab55c"), { flat = true, outline = false })
    c:part(c:ellipse(79, 14, 3, 3), "gold", { outline = false, gloss = false })
  end
  c:fill(c:rect(wx0 + 2, 21, wx1 - 2, 22, 0), dim("#b07a45")); c:fill(c:rect(69, wy0 + 2, 70, wy1 - 2), dim("#b07a45"))
  c:fill(c:rect(wx0 + 2, 21, wx1 - 2, 21), dim("#d9a660")); c:fill(c:rect(69, wy0 + 2, 69, wy1 - 2), dim("#d9a660"))
  c:outline(frame)
  -- shelf with books and a lamp (right of the wizard's hat), small
  local shelf = c:rect(8, 16, 44, 18)
  c:part(shelf, GV.ramp(dim("#b07a45")), { flat = true })
  local bk = { { "#dd3a2a", 4 }, { "#3f8fb0", 3 }, { "#7ab55c", 4 }, { "#e8a317", 3 }, { "#8a5fd0", 4 } }
  local bx = 12
  for _, b in ipairs(bk) do
    c:part(c:rect(bx, 16 - 7 - (b[2] % 2), bx + b[2] - 1, 15), GV.ramp(dim(b[1])), { flat = true, cres = 1, deep = 0 })
    bx = bx + b[2] + 1
  end
  -- hanging lamp (lit in the dark version)
  local lamp = c:poly({ { 128, 2 }, { 142, 2 }, { 147, 12 }, { 123, 12 } })
  c:part(lamp, GV.ramp(dim("#dd3a2a")), { gloss = { 127, 5 }, cres = 3, deep = 1 })
  c:fill(c:rect(135, 0, 135, 1), "#4a2c1a")
  if dark then
    c:bands(c:ellipse(135, 24, 22, 11):clip(c:rect(0, 13, W - 1, 41)), { "#6a5a4a", "#5e4f5a", "#52456a" }, { dir = "radial", cx = 135, cy = 13, r = 22 })
    c:part(c:ellipse(135, 13, 7, 2), GV.ramp("#fff1c8"), { flat = true, outline = false })
  else
    c:part(c:ellipse(135, 13, 7, 2), GV.ramp("#f5cf6a"), { flat = true, outline = false })
  end
  -- wizard (far right) and Jeff (centre) stand behind the table; Ffej sneaks in at the left edge
  CAST.wizard(c, 172, 24, 0.7, { dark = dark })
  CAST.jeff(c, 100, 25, 0.78, { pose = "hold", dark = dark })
  CAST.ffej(c, 20, 34, 0.7, { pose = "sneak", dark = dark })
  -- table: oak top with a lip, front board, hem stitch
  local top = c:rect(0, 42, W - 1, 47)
  c:part(top, GV.ramp(dim("#d9a660")), { gloss = false, cres = 2, deep = 1, outline = false })
  c:fill(c:rect(0, 42, W - 1, 42), dim("#ecc58a"))
  c:outline(top, { ol = 1, olx = 0 })
  local front = c:rect(0, 48, W - 1, H - 1)
  c:bands(front, { dim("#b07a45"), dim("#a8703e"), dim("#9c6638"), dim("#8a4f2a") }, { dir = "v" })
  c:fill(c:rect(0, 48, W - 1, 48), "#4a2c1a")
  for x = 0, W - 1, 34 do c:fill(c:rect(x + 16, 50, x + 16, H - 1), dim("#8a4f2a")) end
  c:seam({ { 0, 57 }, { W - 1, 57 } }, { free = true })
  -- scattered pieces on the table (back row then front row)
  local P = {
    { 36, 40, 6, "rB", "#dd3a2a" }, { 60, 41, 6, "tL", "#3f8fb0" }, { 122, 40, 6, "lT", "#f5cf6a" },
    { 142, 41, 6, "bR", "#7ab55c" }, { 86, 43, 6, "tr", "#e46a9b" }, { 110, 44, 5, "lb", "#8a5fd0" },
    { 10, 44, 6, "r", "#f08a24" }, { 160, 44, 6, "L", "#c9c5bc" }, { 72, 44, 5, "B", "#f5cf6a" },
  }
  for _, p in ipairs(P) do CAST.piece(c, p[1], p[2], p[3], p[4], p[5], dark) end
  -- a candle on the table (warm glow at night)
  c:part(c:rect(188, 36, 190, 44), GV.ramp(dim("#f1ece0"), { pale = true }), { gloss = false, cres = 1, deep = 0 })
  c:part(c:ellipse(189, 34, 1.5, 2), GV.ramp("#f08a24"), { flat = true })
  c:px(189, 34, "#fff1c8")
  if dark then c:fill(c:ellipse(189, 33, 4, 4):cut(c:ellipse(189, 34, 1.5, 2)):clip(c:rect(0, 0, W - 1, 41)), "#6a5a4a") end
  local name = dark and "puzzles-banner-dark" or "puzzles-banner"
  local t = c:save(ASE .. name .. ".aseprite", PNG .. name .. ".png")
  print(name, GV.report(t))
  assert(t.semi == 0 and t.bw == 0)
end
scene(false)
scene(true)
