-- puzzles/cast/jigsaw-banner.png: 400x120 (drawn 200x60, out=2). Jigsaw night in: a big half-built picture
-- (meadow, red-cap cottage) stands on a board in the middle with gaps still showing the cardboard; the box
-- lid leans on the left with the same picture; Jeff waits on the right with a sky piece; Ffej peeks over the
-- table edge at the far right; pieces scattered over a green felt mat. Also writes jigsaw-banner-dark.png
-- (dusk wallpaper, moon in the round window, desk lamp lit, dimmed cast).
-- Families: wall = moss/cream (day) / dusk (night), table = wood, mat = moss felt, picture = water/moss/red.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local CAST = dofile(D .. "extras-pixel/scripts/cast-lib.lua")(GV)
local P = app.params or {}
local PNG = P.out or "/home/user/gnome-venture/game/assets/img/puzzles/cast/"
local ASE = P.ase or D .. "extras-pixel/cast/"
local W, H = 200, 60
local rnd = function(v) return math.floor(v + 0.5) end

local function scene(dark)
  local c = GV.canvas{ w = W, h = H, mode = "scene", out = 2, ol = 1, olx = 1, cres = 3, deep = 1 }
  local dim = function(h) return CAST.dim(h, dark) end
  -- striped wallpaper (6 px stripes) with a dado rail
  local wall = c:rect(0, 0, W - 1, 41)
  local A, B = dark and "#3a3460" or "#e6e8c8", dark and "#403a68" or "#dde2bc"
  c:fill(wall, A)
  for x = 0, W - 1, 12 do c:fill(c:rect(x, 0, x + 5, 41), B) end
  for x = 3, W - 1, 12 do for y = 2, 41, 6 do c:px(x, y, dark and "#4d4678" or "#c9d4a4") end end
  c:fill(c:rect(0, 32, W - 1, 41), dark and "#342c56" or "#cdbf98")
  c:fill(c:rect(0, 31, W - 1, 31), dark and "#5a5288" or "#f3ead0"); c:fill(c:rect(0, 32, W - 1, 32), dark and "#2d2448" or "#b49f74")
  -- round window top right, above Ffej
  local win = c:ellipse(186, 14, 9, 9)
  c:part(win, GV.ramp(dim("#b07a45")), { gloss = false, cres = 2, deep = 1 })
  local gl = c:ellipse(186, 14, 7, 7)
  if dark then
    c:bands(gl, { "#1c1f4a", "#232a5c", "#2a356c" }, { dir = "v" })
    c:part(c:ellipse(184, 11, 3, 3):cut(c:ellipse(186, 10, 2.5, 2.5)), GV.ramp("#f5cf6a"), { flat = true, outline = false })
    c:px(190, 16, "#f5cf6a"); c:px(181, 17, "#f5cf6a")
  else
    c:bands(gl, { "#8fcbd8", "#a8d8e2", "#b5dfe6" }, { dir = "v" })
    c:part(c:ellipse(188, 18, 6, 2.5):clip(gl), GV.ramp("#7ab55c"), { flat = true, outline = false })
  end
  c:fill(c:rect(179, 14, 193, 14), dim("#b07a45")); c:fill(c:rect(186, 7, 186, 21), dim("#b07a45"))
  c:outline(win)
  -- the box: base on the table, lid leaning on the wall showing the picture
  local lid = c:poly({ { 8, 41 }, { 13, 14 }, { 39, 14 }, { 35, 41 } })
  local lidm = c:rrect(9, 15, 35, 41, 1)
  c:part(lidm, GV.ramp(dim("#d9a660")), { gloss = { 11, 17 }, cres = 2, deep = 1 })
  CAST.picture(c, 12, 18, 32, 34, dark)
  c:outline(c:rect(12, 18, 32, 34), { ol = 1, olx = 0 })
  c:seam({ { 11, 38 }, { 33, 38 } })
  -- desk lamp: gold arm, red shade (lit at night)
  if dark then
    c:bands(c:ellipse(46, 30, 14, 12):clip(c:rect(0, 0, W - 1, 41)), { "#6a5a4a", "#5e4f5a", "#52456a" }, { dir = "radial", cx = 46, cy = 30, r = 14 })
  end
  c:part(c:line({ { 44, 41 }, { 41, 33 }, { 45, 26 } }, 2), GV.ramp(dim("#e8a317")), { flat = true })
  c:part(c:rrect(40, 40, 49, 41, 1), GV.ramp(dim("#e8a317")), { flat = true })
  c:part(c:poly({ { 43, 22 }, { 49, 22 }, { 52, 29 }, { 41, 29 } }), GV.ramp(dim("#dd3a2a")), { gloss = { 44, 23 }, cres = 2, deep = 1 })
  c:fill(c:rect(43, 29, 50, 29), dark and "#fff1c8" or "#f5cf6a")
  -- the big board standing on two feet, half-built picture inside
  local bx0, by0, bx1, by1 = 56, 3, 128, 41
  c:part(c:rect(60, 40, 64, 41):add(c:rect(120, 40, 124, 41)), GV.ramp(dim("#8a4f2a")), { flat = true })
  local board = c:rrect(bx0, by0, bx1, by1 - 2, 1)
  c:part(board, GV.ramp(dim("#b07a45")), { gloss = false, cres = 2, deep = 1 })
  local px0, py0, px1, py1 = bx0 + 3, by0 + 3, bx1 - 3, by1 - 5
  local pic = CAST.picture(c, px0, py0, px1, py1, dark)
  -- 7 x 4 grid; the gaps still to fill show the cardboard tray (shadowed on the top and left)
  local NC, NR = 7, 4
  local cw, ch = (px1 - px0 + 1) / NC, (py1 - py0 + 1) / NR
  local miss = {}   -- {col,row}: the right side is still open, ragged edge, one lone gap at the left
  for _, g in ipairs({ { 4, 0 }, { 5, 0 }, { 6, 0 }, { 5, 1 }, { 6, 1 }, { 6, 2 }, { 3, 2 }, { 5, 3 }, { 6, 3 }, { 4, 3 }, { 0, 3 } }) do miss[g[2] * NC + g[1] + 1] = true end
  local holes = c:mask()
  for j = 0, NR - 1 do for i = 0, NC - 1 do
    if miss[j * NC + i + 1] then
      local x0, y0 = rnd(px0 + i * cw), rnd(py0 + j * ch)
      local x1, y1 = rnd(px0 + (i + 1) * cw) - 1, rnd(py0 + (j + 1) * ch) - 1
      c:fill(c:rect(x0, y0, x1, y1), dim("#c9a878")); holes:add(c:rect(x0, y0, x1, y1))
      c:fill(c:rect(x0, y0, x1, y0), dim("#8a6a4a")); c:fill(c:rect(x0, y0, x0, y1), dim("#8a6a4a"))
    end
  end end
  -- jigsaw cut lines with knobs (light tone), over the whole picture
  local cut = dark and "#8a86b0" or "#fff3c8"
  local cm = c:mask()
  for i = 1, NC - 1 do local x = rnd(px0 + i * cw) for y = py0, py1 do cm:set(x, y) end end
  for j = 1, NR - 1 do local y = rnd(py0 + j * ch) for x = px0, px1 do cm:set(x, y) end end
  for i = 1, NC - 1 do for j = 0, NR - 1 do
    local x, y = rnd(px0 + i * cw), rnd(py0 + (j + 0.5) * ch)
    local kx = x + (((i + j) % 2 == 0) and 2 or -2)
    local disc = c:ellipse(kx, y, 2, 2)
    cm:cut(disc); cm:add(disc:edge()); for yy = y - 1, y + 1 do cm:del(x, yy) end
  end end
  for j = 1, NR - 1 do for i = 0, NC - 1 do
    local x, y = rnd(px0 + (i + 0.5) * cw), rnd(py0 + j * ch)
    local ky = y + (((i + j) % 2 == 0) and 2 or -2)
    local disc = c:ellipse(x, ky, 2, 2)
    cm:cut(disc); cm:add(disc:edge()); for xx = x - 1, x + 1 do cm:del(xx, y) end
  end end
  cm:clip(pic); cm:cut(holes)
  -- cut lines are the picture's own colour lifted toward cream, so the picture still reads through them
  local function lift(hex)
    local r, g, b = tonumber(hex:sub(2, 3), 16), tonumber(hex:sub(4, 5), 16), tonumber(hex:sub(6, 7), 16)
    local k = dark and 0.3 or 0.45
    return string.format("#%02x%02x%02x", rnd(r + (255 - r) * k), rnd(g + (243 - g) * k), rnd(b + (200 - b) * k))
  end
  cm:each(function(x, y) local h = c:get(x, y); c:px(x, y, h and lift(h) or cut) end)
  -- Jeff waits with a sky-blue piece
  CAST.jeff(c, 152, 23, 0.84, { pose = "hold", piece = "#7fc0de", dark = dark })
  -- Ffej peeks over the table edge at the far right (the table hides the rest of him)
  CAST.ffej(c, 183, 37, 0.66, { dark = dark })
  -- table: oak top, green felt mat, front with drawers and gold knobs
  local top = c:rect(0, 42, W - 1, 47)
  c:part(top, GV.ramp(dim("#d9a660")), { gloss = false, cres = 2, deep = 1, outline = false })
  c:fill(c:rect(0, 42, W - 1, 42), dim("#ecc58a"))
  c:outline(top, { ol = 1, olx = 0 })
  local mat = c:rect(4, 43, 170, 46)
  c:part(mat, GV.ramp(dim("#2f6a3a")), { flat = true, outline = false })
  local front = c:rect(0, 48, W - 1, H - 1)
  c:bands(front, { dim("#b07a45"), dim("#a8703e"), dim("#9c6638"), dim("#8a4f2a") }, { dir = "v" })
  c:fill(c:rect(0, 48, W - 1, 48), "#4a2c1a")
  for _, dx in ipairs({ 14, 84, 154 }) do
    local dr = c:rrect(dx, 50, dx + 32, 57, 1)
    c:part(dr, GV.ramp(dim("#a8703e")), { gloss = false, cres = 1, deep = 0 })
    c:part(c:rect(dx + 15, 52, dx + 17, 54), GV.ramp(dim("#e8a317")), { flat = true })
  end
  -- scattered pieces on the mat in picture colours
  local PC = {
    { 6, 41, 6, "rB", "#7fc0de" }, { 50, 42, 5, "tL", "#94c46e" }, { 70, 43, 5, "lT", "#dd3a2a" },
    { 98, 42, 6, "bR", "#a8d8ea" }, { 116, 43, 5, "tr", "#7ab55c" }, { 136, 42, 6, "lb", "#7fc0de" },
    { 30, 43, 5, "B", "#f5cf6a" }, { 158, 42, 5, "R", "#4a8a3e" }, { 84, 42, 5, "Tb", "#f1ece0" },
  }
  for _, p in ipairs(PC) do CAST.piece(c, p[1], p[2], p[3], p[4], p[5], dark) end
  local name = dark and "jigsaw-banner-dark" or "jigsaw-banner"
  local t = c:save(ASE .. name .. ".aseprite", PNG .. name .. ".png")
  print(name, GV.report(t))
  assert(t.semi == 0 and t.bw <= 4)
end
scene(false)
scene(true)
