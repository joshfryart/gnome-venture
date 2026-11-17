-- build-verbs-a.lua : stage icons carry / decorate / wait (96x96, icon mode). only=<name> selects one.
-- Params: --script-param root=<repo> pngdir=<dir> out=<dir> only=<name>
local P = app.params
local root = P.root or "/home/user/gnome-venture"
local GV = dofile(root .. "/aseprite-source/gvlib/gvlib.lua")
local OUT = P.out or (root .. "/aseprite-source/extras-pixel/aseprite")
local PNG = P.pngdir or (root .. "/art-2706")
local ONLY = P.only or "all"

local PLANK = GV.ramp("#c9a96e")
local CREAM = GV.ramp("#f1ece0")
local DWOOD = GV.ramp("#7a4a1f")
local SACK = GV.ramp("#d9bf86")
local GLASS = GV.ramp("#bfe3e8")
local BLUE = GV.ramp("#4a7fb5")
local DK = "#3d2a1c"
local function flat(m, col, c) c:part(m, col, { flat = true, contour = false, contact = false }) end

local function canvas() return GV.canvas{ w = 96, h = 96, mode = "icon", cres = 6, deep = 2, ol = 2, olx = 1 } end
local function save(c, name)
  local t = c:save(OUT .. "/build-verbs-a-" .. name .. ".aseprite", PNG .. "/" .. name .. ".png")
  print(name .. " " .. GV.report(t))
end

----------------------------------------------------------------- carry: pole with sack + crate
local function carry(c)
  -- ropes first (behind)
  for _, x in ipairs({ 22, 28 }) do flat(c:rect(x, 16, x, 36), "#8a6a3a", c) end
  for _, x in ipairs({ 70, 76 }) do flat(c:rect(x, 16, x, 36), "#8a6a3a", c) end
  -- sack (left): round belly, tied neck
  c:part(c:ellipse(25, 60, 19, 22), SACK, { cres = 8, deep = 3 })
  c:part(c:rrect(17, 33, 33, 43, 3), SACK, { cres = 4, deep = 1, gloss = false })
  c:part(c:rect(16, 40, 34, 43), "red", { cres = 3, deep = 1, gloss = false })
  c:seam({ { 20, 56 }, { 26, 66 }, { 32, 56 } }, { free = false })
  c:part(c:rect(22, 52, 25, 55), DWOOD, { flat = true, contour = false, contact = false })
  -- crate (right)
  c:part(c:rrect(52, 38, 86, 84, 3), PLANK, { cres = 8, deep = 2 })
  for _, y in ipairs({ 51, 64, 77 }) do flat(c:rect(54, y, 84, y + 1), DWOOD, c) end
  for _, x in ipairs({ 56, 80 }) do flat(c:rect(x, 40, x + 1, 82), DWOOD, c) end
  c:part(c:poly({ { 54, 40 }, { 58, 40 }, { 82, 82 }, { 78, 82 } }), DWOOD, { flat = true, contour = false, contact = false })
  c:button(61, 44); c:button(72, 74)
  -- pole on top, bowed ends
  c:part(c:line({ { 9, 20 }, { 48, 15 }, { 87, 20 } }, 6), DWOOD, { cres = 3, deep = 1 })
  c:part(c:rrect(6, 16, 14, 25, 3), PLANK, { cres = 3, deep = 1, gloss = false })
  c:part(c:rrect(82, 16, 90, 25, 3), PLANK, { cres = 3, deep = 1, gloss = false })
  -- hooks/knots where ropes meet pole
  for _, x in ipairs({ 22, 28, 70, 76 }) do c:px(x, 22, "#e9c46a") end
  save(c, "stage-carry")
end

----------------------------------------------------------------- decorate: bunting + bell + flower
local function flag(c, x, y, w, h, col)
  c:part(c:poly({ { x, y }, { x + w, y }, { x + w / 2, y + h } }), col, { cres = 5, deep = 1, gloss = false })
end
local function decorate(c)
  -- posts
  c:part(c:rrect(6, 10, 13, 88, 2), DWOOD, { gloss = false })
  c:part(c:rrect(83, 10, 90, 88, 2), DWOOD, { gloss = false })
  -- sagging rope
  local pts = { { 13, 17 }, { 28, 28 }, { 48, 33 }, { 68, 28 }, { 83, 17 } }
  c:part(c:line(pts, 3), GV.ramp("#e9c46a"), { flat = true, contact = false })
  local cols = { "red", "leaf", "gold", "red", "leaf", "gold" }
  local xs = { 16, 26, 36, 56, 66, 76 }
  local ys = { 22, 27, 30, 30, 27, 22 }
  for i, x in ipairs(xs) do flag(c, x - 4, ys[i] + 1, 10, 15, cols[i]) end
  -- bell hanging from the middle
  c:part(c:rect(47, 33, 48, 46), GV.ramp("#e9c46a"), { flat = true, contact = false })
  local bell = c:ellipse(47.5, 62, 12, 13):cut(c:rect(0, 63, 99, 99))
  bell:add(c:rrect(35, 60, 60, 72, 2))
  c:part(bell, "gold", { cres = 6, deep = 2 })
  c:part(c:ellipse(47.5, 76, 4, 4), DWOOD, { cres = 2, deep = 1, gloss = false })
  c:part(c:rect(44, 46, 51, 49), "gold", { flat = true })
  -- flower at the lower left of the rope, on a leaf
  c:part(c:ellipse(22, 76, 5, 3), "leaf", { flat = true })
  c:part(c:ellipse(74, 76, 5, 3), "leaf", { flat = true })
  for _, fx in ipairs({ 22, 74 }) do
    for _, d in ipairs({ { -5, 0 }, { 5, 0 }, { 0, -5 }, { 0, 5 } }) do
      c:part(c:ellipse(fx + d[1], 68 + d[2], 3, 3), "petal", { cres = 2, deep = 1, gloss = false })
    end
    c:part(c:ellipse(fx, 68, 3, 3), "gold", { cres = 2, deep = 1, gloss = false })
  end
  save(c, "stage-decorate")
end

----------------------------------------------------------------- wait: hourglass
local function wait(c)
  -- glass: two triangles meeting at the neck
  local top = c:poly({ { 22, 20 }, { 74, 20 }, { 53, 48 }, { 43, 48 } })
  local bot = c:poly({ { 43, 48 }, { 53, 48 }, { 74, 76 }, { 22, 76 } })
  local glass = top:copy():add(bot)
  c:part(glass, GLASS, { cres = 8, deep = 2 })
  -- sand: remaining on top, pile at the bottom, falling stream
  c:part(c:poly({ { 32, 34 }, { 64, 34 }, { 53, 48 }, { 43, 48 } }), "gold", { cres = 5, deep = 1, gloss = false })
  c:part(c:rect(47, 49, 48, 64), "gold", { flat = true, contour = false, contact = false })
  c:part(c:poly({ { 48, 58 }, { 60, 74 }, { 36, 74 } }), "gold", { cres = 6, deep = 1, gloss = false })
  -- frame: plates top & bottom, two posts
  c:part(c:rrect(35, 22, 38, 74, 1), DWOOD, { flat = true, contour = false, contact = false })
  c:part(c:rrect(58, 22, 61, 74, 1), DWOOD, { flat = true, contour = false, contact = false })
  c:part(c:rrect(12, 8, 83, 20, 4), DWOOD, { cres = 5, deep = 2 })
  c:part(c:rrect(12, 76, 83, 88, 4), DWOOD, { cres = 5, deep = 2 })
  -- glass glints
  c:px(28, 26, "#f4fbff"); c:px(29, 27, "#f4fbff"); c:px(28, 28, "#f4fbff")
  save(c, "stage-wait")
end

local fns = { ["stage-carry"] = carry, ["stage-decorate"] = decorate, ["stage-wait"] = wait }
for _, n in ipairs({ "stage-carry", "stage-decorate", "stage-wait" }) do
  if ONLY == "all" or ONLY == n then fns[n](canvas()) end
end
