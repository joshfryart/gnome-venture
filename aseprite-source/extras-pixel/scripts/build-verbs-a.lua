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
-- inkfix: after finish(), the 1 px #000000 border becomes ink and any #ffffff becomes cream (Hearth Pop: no pure B/W)
local function inkfix(c)
  c:finish()
  for k, v in pairs(c.pix) do
    if v == "#000000" then c.pix[k] = "#2b1c26" elseif v == "#ffffff" then c.pix[k] = "#fff4d6" end
  end
end

----------------------------------------------------------------- carry: pole with sack + crate
-- quirk: a patched hole on the sack, stitched in gold
local function carry(c)
  local BURLAP = GV.ramp("#d4a85e", { gloss = "#f7dc9a", dot = "#fff4d6", rim = "#ecc77c", shade = "#a8743c", deep = "#6e4424", bounce = "#b8844a" })
  local CRATE = GV.ramp("#c98a4a", { gloss = "#f2c98a", dot = "#fff4d6", rim = "#e3ab68", shade = "#9a5e32", deep = "#5e3220", bounce = "#a86a3a" })
  local SLAT = GV.ramp("#e0a862", { gloss = "#f8d8a0", dot = "#fff4d6", rim = "#f2c482", shade = "#b07440", deep = "#6e4424" })
  local ROPE = { "#e8c47a", "#a8743c" }
  -- twisted ropes (behind), 3 px wide
  local function rope(x, y0, y1)
    for y = y0, y1 do for i = 0, 2 do c:px(x + i, y, ((y + i) % 3 == 0) and ROPE[2] or ROPE[1]) end end
    c.sil:add(c:rect(x, y0, x + 2, y1))
  end
  rope(19, 20, 36); rope(27, 20, 36)
  rope(62, 20, 40); rope(78, 20, 40)
  -- sack (left): chunky pear belly, cinched neck, flared top ears
  local sack = c:ellipse(25, 64, 20, 21)
  sack:add(c:poly({ { 12, 52 }, { 18, 42 }, { 32, 42 }, { 38, 52 } }))
  c:part(sack, BURLAP, { cres = 7, deep = 3, gloss = { 14, 54 } })
  c:part(c:poly({ { 15, 30 }, { 35, 30 }, { 32, 40 }, { 18, 40 } }), BURLAP, { cres = 3, deep = 1, gloss = false })
  c:part(c:rrect(15, 39, 35, 44, 2), "red", { cres = 2, deep = 1, gloss = false })
  -- patch (quirk): darker square, gold stitch round it
  c:part(c:rect(25, 66, 33, 74), GV.ramp("#8a6fd0"), { flat = true, contact = false })
  c:seam({ { 25, 66 }, { 33, 66 }, { 33, 74 }, { 25, 74 }, { 25, 67 } }, { on = 1, off = 1 })
  -- crate (right): thick frame, horizontal slats with dark gaps, nails
  c:part(c:rrect(52, 40, 88, 86, 2), CRATE, { cres = 6, deep = 2, gloss = false })
  for _, y in ipairs({ 55, 70 }) do c:fill(c:rect(57, y, 83, y + 1), "#5e3220") end
  -- frame boards (lighter, own shading)
  local frame = c:rect(52, 40, 88, 45):add(c:rect(52, 81, 88, 86)):add(c:rect(52, 40, 57, 86)):add(c:rect(83, 40, 88, 86))
  frame:clip(c:rrect(52, 40, 88, 86, 2))
  c:part(frame, SLAT, { cres = 2, deep = 1, gloss = false, contour = false, contact = false })
  c:fill(c:rect(58, 46, 82, 46), "#5e3220"); c:fill(c:rect(82, 46, 82, 80), "#5e3220")
  -- nails at the frame corners
  for _, p in ipairs({ { 54, 42 }, { 85, 42 }, { 54, 83 }, { 85, 83 } }) do c:px(p[1], p[2], "#444663"); c:px(p[1] + 1, p[2] + 1, "#2b1c26"); c:px(p[1] + 1, p[2], "#aaa9b8") end
  -- stencilled gold arrow on the crate front (this side up)
  c:part(c:poly({ { 70, 52 }, { 76, 59 }, { 72.5, 59 }, { 72.5, 66 }, { 67.5, 66 }, { 67.5, 59 }, { 64, 59 } }), "gold", { flat = true, contour = false, contact = false })
  -- pole on top, bowed ends
  c:part(c:line({ { 9, 21 }, { 48, 15 }, { 86, 21 } }, 7), DWOOD, { cres = 3, deep = 1 })
  c:part(c:rrect(6, 16, 14, 26, 3), PLANK, { cres = 3, deep = 1, gloss = false })
  c:part(c:rrect(81, 16, 89, 26, 3), PLANK, { cres = 3, deep = 1, gloss = false })
  -- rope wraps on the pole
  for _, x in ipairs({ 19, 27, 62, 78 }) do
    local y = math.floor(15 + math.abs(x + 1 - 48) * 6 / 39 + 0.5)
    c:fill(c:rect(x - 1, y - 2, x + 3, y + 3), "#e8c47a"); c:fill(c:rect(x - 1, y + 1, x + 3, y + 3), "#a8743c")
  end
  -- Hearth Pop: no pure black (gvlib finish() border) or white
  c:finish()
  for k, h in pairs(c.pix) do
    if h == "#000000" then c.pix[k] = "#2b1c26" elseif h == "#ffffff" then c.pix[k] = "#fff4d6" end
  end
  save(c, "stage-carry")
end

----------------------------------------------------------------- decorate: bunting + bell + flower
-- pennant hanging from (cx, top): w wide, h tall, swallow-free plain point; 1 px stripe near the top
local function flag(c, cx, top, w, h, ramp, stripe)
  local m = c:poly({ { cx - w / 2, top }, { cx + w / 2 + 1, top }, { cx + 0.5, top + h } })
  c:part(m, ramp, { cres = 4, deep = 1, gloss = false })
  if stripe then c:fill(c:rect(cx - w / 2, top + 4, cx + w / 2, top + 5):clip(m:shrink(1)), stripe) end
end
local function decorate(c)
  local ROPE = GV.ramp("#e9c46a")
  local RED = GV.ramp("red")
  local TEAL = GV.ramp("#3f9cc4")
  -- posts with round finials
  c:part(c:rrect(7, 12, 13, 88, 2), DWOOD, { gloss = false })
  c:part(c:rrect(83, 12, 89, 88, 2), DWOOD, { gloss = false })
  c:part(c:ellipse(10, 9, 4, 4), DWOOD, { cres = 3, deep = 1 })
  c:part(c:ellipse(86, 9, 4, 4), DWOOD, { cres = 3, deep = 1 })
  -- sagging rope (parabola)
  local function ry(x) local u = (x - 48) / 36 return 15 + 15 * (1 - u * u) end
  local pts = {}
  for x = 13, 83, 5 do pts[#pts + 1] = { x, ry(x) } end
  pts[#pts + 1] = { 83, ry(83) }
  c:part(c:line(pts, 3), ROPE, { flat = true, contact = false })
  -- four big pennants, red / teal alternating, with a cream stripe
  local xs = { 22, 36, 60, 74 }
  local rs = { RED, TEAL, TEAL, RED }
  for i, x in ipairs(xs) do flag(c, x, math.floor(ry(x)) + 1, 13, 21, rs[i], "#fff4d6") end
  -- bell hanging from the middle
  c:part(c:rect(47, 30, 48, 45), ROPE, { flat = true, contact = false })
  c:part(c:rrect(43, 43, 52, 48, 2), "gold", { cres = 2, deep = 1, gloss = false })
  local bell = c:ellipse(47.5, 61, 12, 13):cut(c:rect(0, 62, 99, 99))
  bell:add(c:poly({ { 35.5, 61 }, { 60.5, 61 }, { 63, 73 }, { 33, 73 } }))
  bell:add(c:rrect(31, 70, 64, 76, 2))
  c:part(c:ellipse(47.5, 79, 4, 4), DWOOD, { cres = 2, deep = 1, gloss = false })
  c:part(bell, "gold", { cres = 6, deep = 2 })
  c:fill(c:rect(36, 66, 59, 67):clip(bell:shrink(1)), "#b8661a")
  -- flowers at the post feet, on leaves
  for _, fx in ipairs({ 21, 75 }) do
    c:part(c:ellipse(fx, 84, 7, 3), "leaf", { cres = 2, deep = 1, gloss = false })
    for _, d in ipairs({ { -5, 0 }, { 5, 0 }, { 0, -5 }, { 0, 5 } }) do
      c:part(c:ellipse(fx + d[1], 76 + d[2], 3, 3), "petal", { cres = 2, deep = 1, gloss = false })
    end
    c:part(c:ellipse(fx, 76, 2, 2), "gold", { cres = 2, deep = 1, gloss = false })
  end
  inkfix(c)
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
  inkfix(c)
  save(c, "stage-wait")
end

local fns = { ["stage-carry"] = carry, ["stage-decorate"] = decorate, ["stage-wait"] = wait }
for _, n in ipairs({ "stage-carry", "stage-decorate", "stage-wait" }) do
  if ONLY == "all" or ONLY == n then fns[n](canvas()) end
end
