-- chest.lua : wooden treasure chest (img/chest.svg), Stitched Toy, 64x64 sticker.
-- Writes three same-canvas PNGs that stack: chest-body.png (cs-bodyg, with the dark
-- inside showing for the open state), chest-lid.png (cs-lid, pivot ~32,31) and chest.png
-- (closed = body + lid). chest.aseprite holds Body and Lid as two layers.
-- Families: wood preset (lid), soil #9a6b3f (body), soil #7a4a1f (plinth), gold (straps,
-- rim), wood deep #5e2f1e (lock plate), soil dark #3d2a1c (inside).
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/extras-pixel/"
local C = GV.C

local function allm(c) return c:ellipse(30.5, 25, 21.5, 12):add(c:rrect(9, 25, 52, 52, 3)) end

local function body(c)
  local A = allm(c)
  local bm = c:rrect(9, 28, 52, 52, 3)
  local p = c:build{
    { "body", bm, GV.ramp("#9a6b3f", { gloss = "#e8a060", dot = "#ffc27a", rim = "#c98a4a" }), { gloss = { 11, 37 }, light = A } },
    { "plinth", c:rrect(9, 45, 52, 52, 3), GV.ramp("#7a4a1f"), { gloss = false, light = A } },
  }
  c:stitch(c:rect(9, 28, 52, 46):clip(bm), { side = "lit" })
  for _, x in ipairs({ 14, 43 }) do
    local s = c:part(c:rect(x, 28, x + 4, 52):clip(bm), "gold", { gloss = false, contact = false, light = A })
    for y = 28, 52 do if c:get(x + 1, y) == GV.R.gold.base then c:px(x + 1, y, GV.R.gold.rim) end end
  end
  -- plinth hem seam, between and beyond the straps
  c:seam({ { 11, 48 }, { 50, 48 } })
  -- the inside (seen when the lid lifts): back wall catches a little light, floor is dark
  local ins = c:ellipse(30.5, 32, 19.5, 2.5)
  c:part(ins, GV.ramp("#3d2a1c"), { flat = true, rim = false, contact = false, gloss = false })
  ins:each(function(x, y) if not ins:has(x, y - 1) and ins:has(x, y + 1) then c:px(x, y, "#5e2f1e") end end)
  c:ground(30.5, 56, 19, 1.5)
end

local function lid(c)
  local A = allm(c)
  local dome = c:ellipse(30.5, 25, 21.5, 12):add(c:rect(9, 25, 52, 31))
  dome:cut(c:rect(0, 32, 63, 63))
  local p = c:build{
    { "dome", dome, "wood", { gloss = { 22, 16 }, light = A } },
  }
  c:stitch(dome:copy():cut(c:rect(0, 27, 63, 63)), { side = "lit" })
  for _, x in ipairs({ 14, 43 }) do
    c:part(c:rect(x, 10, x + 4, 31):clip(dome), "gold", { gloss = false, contact = false, light = A })
    for y = 10, 31 do if c:get(x + 1, y) == GV.R.gold.base then c:px(x + 1, y, GV.R.gold.rim) end end
  end
  c:seam({ { 10, 28 }, { 51, 28 } })                        -- lid hem
  c:part(c:rrect(9, 30, 52, 34, 1), "gold", { gloss = false, light = A })  -- gold rim band
  for x = 11, 50 do if c:get(x, 31) == GV.R.gold.base then c:px(x, 31, GV.R.gold.rim) end end
  c:part(c:rrect(26, 30, 35, 40, 2), GV.ramp("#7a3a20"), { gloss = false, light = A })     -- lock plate
  c:button(29, 33)                                           -- the lock
end

-- render each group on its own canvas (own outline + halo)
local cb = GV.canvas{ w = 64, h = 64, mode = "sticker" }; body(cb); cb:finish()
local cl = GV.canvas{ w = 64, h = 64, mode = "sticker" }; lid(cl); cl:finish()

-- lid layer: lid fill; its outline except over the body front (keep 1 px there as the
-- contour); its halo only where the body layer is empty or halo.
local Lfill, Bfill = cl.sil, cb.sil
local Lnear = Lfill:grow(1)
local lidpix = {}
for k, h in pairs(cl.pix) do
  local keep
  if Lfill.s[k] then keep = true
  elseif h ~= C.halo then keep = (not Bfill.s[k]) or Lnear.s[k]
  else local b, _, y = cb.pix[k], cl:xy(k) keep = (b == nil or b == C.halo) and y <= 34 end
  if keep then lidpix[k] = h end
end
local full = {}
for k, h in pairs(cb.pix) do full[k] = h end
for k, h in pairs(lidpix) do full[k] = h end
cl.pix = lidpix

local cf = GV.canvas{ w = 64, h = 64, mode = "sticker" }; cf.done = true; cf.pix = full
local tb = cb:save(O .. "aseprite/chest-body.aseprite", O .. "png/chest-body.png")
local tl = cl:save(O .. "aseprite/chest-lid.aseprite", O .. "png/chest-lid.png")
local tf = cf:save(nil, O .. "png/chest.png")

-- layered chest.aseprite (Body under Lid)
local spr = Sprite(64, 64, ColorMode.RGB)
spr.layers[1].name = "Body"
spr.cels[1].image = cb:image()
local L = spr:newLayer(); L.name = "Lid"
spr:newCel(L, 1, cl:image(), Point(0, 0))
spr:saveAs(O .. "aseprite/chest.aseprite")
spr:close()

print("chest      " .. GV.report(tf))
print("chest-body " .. GV.report(tb))
print("chest-lid  " .. GV.report(tl))
assert(tf.semi == 0 and tf.bw == 0 and tf.margin >= 3)
