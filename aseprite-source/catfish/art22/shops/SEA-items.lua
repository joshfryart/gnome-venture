-- SEA-items.lua : Monsoon Mew Market (Monsoon Tangle, Southeast Asia) pet-shop item sprites, art22.
-- Run: AppRun -b --script SEA-items.lua      Writes art22/out/cf-pet-<slug>.png + .aseprite (5 files).
-- 1x sprites on the 320x200 room (like the cats), Stitched Toy via gvlib: 1 px three-tone umber outline (+1 lower
-- right), 1 px #000000 border, felt ramps (rim, base, one crescent shade, gloss comma).
-- Shared regional kit so the five read as one shop: woven rattan/bamboo tan, banana-leaf green, monsoon teal and a
-- red cord accent on every piece; lotus pink and gold only where they belong.
--   floating_lantern      shelf   20x24  a lotus float (krathong): candle + flame in pink lotus petals on folded
--                                        banana leaf, in a little teal water dish
--   shadow_puppet_screen  sill    30x26  carved wood screen with a gold crest, glowing cloth, a dusk cat puppet
--                                        with gold punched dots on its stick, all standing in a banana-trunk log
--   banana_leaf_fan       ceiling 48x34  a banana leaf hung like a punkah from a bamboo rod on two red cords,
--                                        torn slits along the edge, gold bead + red tassel
--   paddy_hat_bed         floor-l 38x28  a conical paddy hat as a cat cave: woven rings, arched door with a teal
--                                        cushion inside, on a rattan ring with a red bow
--   gecko_friend          frame   35x31  lashed bamboo frame (red cord corners), rainy jade wall, a tokay-blue felt
--                                        gecko with orange beans and toe pads, tail curling over the frame
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../../gvlib/gvlib.lua")
local OUT = here .. "/../out/"
local C = GV.C

local function felt(hex, ov)
  local r = GV.ramp(hex)
  local n = {} for k, v in pairs(r) do n[k] = v end
  n.deep, n.bounce = n.shade, n.base
  for k, v in pairs(ov or {}) do n[k] = v end
  return n
end
local function tint(c, m, from, to)
  m:each(function(x, y) if c:get(x, y) == from then c:px(x, y, to) end end)
end
local function canvas(w, h)
  return GV.canvas{ w = w, h = h, mode = "sticker", ol = 1, olx = 1, margin = 0 }
end
local FAILS = {}
local function save(c, slug, W, H)
  local name = "cf-pet-" .. slug
  local t = c:save(OUT .. name .. ".aseprite", OUT .. name .. ".png")
  print(string.format("%-28s ", name) .. GV.report(t))
  if not (t.semi == 0 and t.bw == 0 and t.w == W and t.h == H) then FAILS[#FAILS + 1] = name end
  return t
end

-- shared regional kit
local RATTAN = felt("#c99a4c", { gloss = "#f5dc9a", rim = "#e3bb6c" })   -- woven rattan / bamboo (wood family)
local STRAW  = felt("#e0bb68", { gloss = "#fff1c8", rim = "#f2d48c" })   -- paddy-hat straw (gold family, paler)
local LEAF   = felt("#7fb447", { gloss = "#d8ec8c", rim = "#a6cf5e" })   -- banana leaf (moss family, yellower)
local TEAL   = felt("#2f9a94", { gloss = "#c8ecdc", rim = "#5cbcb0" })   -- monsoon teal (water family, greener)
local RED    = felt("#d23a2e", { gloss = "#ff9158", rim = "#f2793a" })   -- red cord / lacquer (red row)
local LOTUS  = felt("#e46a9b", { gloss = "#ffd0e0", rim = "#f39cc0" })   -- lotus (petal)
local WOOD   = felt("#9a5a30", { gloss = "#ecc58a", rim = "#c08048" })   -- carved teak (wood row, darker)
local GOLD   = felt("#e8a317", { gloss = "#fff1c8", rim = "#f5cf6a" })
local GREEN_PALE = "#d7e48a"

-- ===== floating_lantern (shelf, 20x24) =====
do
  local W, H = 20, 24
  local c = canvas(W, H)
  local dish  = c:ellipse(9.5, 17, 6.5, 2):add(c:poly({ {3, 17}, {17, 17}, {14, 21}, {6, 21} }))
  local leaf  = c:poly({ {2, 15}, {4, 12}, {6, 14}, {9.5, 12}, {13, 14}, {15, 12}, {17, 15}, {15, 17}, {4, 17} })
  local candle = c:rect(8, 6, 11, 12)
  local lotus = c:poly({ {3, 9}, {7, 11}, {9.5, 9}, {12, 11}, {16, 9}, {15, 15}, {4, 15} })
  local front = c:poly({ {9.5, 10}, {12.5, 13}, {9.5, 16}, {6.5, 13} })
  c:build{
    { "dish",   dish, TEAL, { gloss = false } },
    { "leaf",   leaf, LEAF, { gloss = false } },
    { "candle", candle, "cream", { flat = true } },
    { "lotus",  lotus, LOTUS, { gloss = false } },
    { "front",  front, felt("#f08cb4", { rim = "#ffc0d8" }), { flat = true } },
  }
  tint(c, c:rect(3, 16, 16, 17):clip(dish), TEAL.base, "#8fcbd8")       -- water surface
  c:paint({ ".f.", "fff", "fyf", ".f." }, 8, 2, { f = "#f08a24", y = "#fff1c8" })   -- flame
  c:px(8, 9, "#d8c49a")
  c:px(5, 11, LOTUS.gloss); c:px(14, 11, LOTUS.gloss)
  save(c, "floating_lantern", W, H)
end

-- ===== shadow_puppet_screen (sill, 30x26) =====
do
  local W, H = 30, 26
  local c = canvas(W, H)
  local crest = c:ellipse(14.5, 5, 4.5, 3):cut(c:rect(0, 5, 29, 25))
  local beam  = c:rrect(3, 4, 25, 6, 1)
  local postL, postR = c:rect(4, 7, 6, 19), c:rect(22, 7, 24, 19)
  local screen = c:rect(7, 7, 21, 17)
  local log = c:rrect(2, 18, 26, 22, 2)
  c:build{
    { "screen", screen, felt("#f5d68a", { rim = "#fff1c8" }), { flat = true } },
    { "postL", postL, WOOD, { gloss = false } },
    { "postR", postR, WOOD, { gloss = false } },
    { "crest", crest, GOLD, { flat = true } },
    { "beam",  beam, RED, { gloss = false } },
    { "log",   log, LEAF, { gloss = false } },
  }
  local D = "#3e2f66"
  c:paint({
    "......u..u.",
    "......uuuu.",
    "......uuuuu",
    "u.....uuuu.",
    "u...uuuuu..",
    ".u.uuuuuu..",
    "..uuuuuuu..",
    "...uuuuuu..",
    "....u.u.u..",
  }, 9, 8, { u = D })
  c:px(17, 10, GOLD.base); c:px(13, 13, GOLD.base); c:px(15, 14, GOLD.base); c:px(11, 14, GOLD.base)
  c:px(15, 17, "#4a2c1a"); c:px(15, 18, "#4a2c1a")                          -- puppet stick into the log
  c:px(14, 3, GOLD.shade)
  c:seam({ { 4, 20 }, { 25, 20 } }, { gap = LEAF.shade })
  save(c, "shadow_puppet_screen", W, H)
end

-- ===== banana_leaf_fan (ceiling, 48x34) =====
do
  local W, H = 48, 34
  local c = canvas(W, H)
  local rod  = c:rrect(3, 7, 44, 9, 1)
  local leaf = c:poly({ {4, 10}, {44, 10}, {43, 15}, {38, 21}, {28, 25}, {15, 25}, {8, 21}, {4, 15} })
  for _, sx in ipairs({ 14, 24, 34 }) do                                    -- torn slits along the veins
    for t = 0, 3 do leaf:del(sx + (t > 1 and 1 or 0), 25 - t - (sx == 34 and 2 or 0)) end
  end
  local bead = c:ellipse(25.5, 26.5, 1.5, 1.5)
  local tassel = c:rect(24, 28, 27, 31)
  c:build{
    { "leaf", leaf, LEAF, { gloss = { 8, 13 } } },
    { "rod",  rod, RATTAN, { gloss = false } },
    { "tassel", tassel, RED, { flat = true } },
    { "bead", bead, GOLD, { flat = true } },
  }
  for x = 5, 43 do if leaf:has(x, 11) then c:px(x, 11, GREEN_PALE) end end    -- midrib
  for vx = 8, 42, 4 do                                                      -- veins
    for y = 13, 24 do
      local x = vx + math.floor((y - 13) / 4)
      if leaf:has(x, y) and leaf:has(x + 1, y + 1) and c:get(x, y) == LEAF.base then c:px(x, y, LEAF.shade) end
    end
  end
  for _, nx in ipairs({ 14, 24, 34 }) do c:px(nx, 8, RATTAN.shade); c:px(nx, 9, RATTAN.shade) end
  c:px(25, 30, RED.shade); c:px(25, 31, RED.shade)
  c:finish()
  for y = 0, 6 do c:px(10, y, RED.shade); c:px(37, y, RED.shade) end    -- cords, no border (like the rod strings)
  c:px(10, 7, RED.base); c:px(37, 7, RED.base)
  save(c, "banana_leaf_fan", W, H)
end

-- ===== paddy_hat_bed (floor-left, 38x28) =====
do
  local W, H = 38, 28
  local c = canvas(W, H)
  local base = c:rrect(4, 19, 32, 24, 2)
  local hat = c:poly({ {18.5, 2}, {35, 19}, {2, 19} }):add(c:ellipse(18.5, 18, 16, 2))
  local door = c:ellipse(18.5, 13, 5, 4):add(c:rect(14, 13, 23, 19)):clip(hat)
  local cush = c:ellipse(18.5, 18.5, 5, 2.5)
  local bowL, bowR = c:ellipse(27, 21.5, 2, 1.5), c:ellipse(32, 21.5, 2, 1.5)
  local p = c:build{
    { "base", base, RATTAN, { gloss = false } },
    { "hat",  hat, STRAW, { gloss = { 11, 12 } } },
  }
  local rings = { 7, 11, 15 }
  for _, ry in ipairs(rings) do
    for x = 0, W - 1 do
      local y = ry + math.floor(1.6 * (1 - ((x - 18.5) / 16) ^ 2) + 0.5)
      if hat:has(x, y) and hat:has(x, y - 1) and hat:has(x, y + 1) and not c.gl.s[c:key(x, y)] then
        c:px(x, y, STRAW.shade)
      end
    end
  end
  c:part(door, felt("#5e2f1e"), { flat = true, rim = false, contour = false })
  c:build{
    { "cush", cush, TEAL, { flat = true } },
    { "bowL", bowL, RED, { flat = true } },
    { "bowR", bowR, RED, { flat = true } },
    { "knot", c:rect(29, 20, 30, 22), RED, { flat = true } },
  }
  for x = 6, 31, 3 do if c:get(x, 23) == RATTAN.base then c:px(x, 23, RATTAN.shade) end end
  save(c, "paddy_hat_bed", W, H)
end

-- ===== gecko_friend (frame, 35x31) =====
do
  local W, H = 35, 31
  local c = canvas(W, H)
  local G = felt("#4f86c0", { gloss = "#c8ecdc", rim = "#8fb8e0" })
  c:part(c:rect(4, 4, 29, 25), "#a9d6c4", { flat = true, rim = false })
  c:part(c:poly({ {5, 24}, {5, 15}, {11, 10}, {13, 13}, {11, 20}, {8, 24} }), LEAF, { flat = true })
  c:part(c:line({ { 17, 20 }, { 17, 22 }, { 19, 24 }, { 22, 23 } }, 2), G, { flat = true })
  for _, l in ipairs({ { {15, 13}, {12, 11} }, { {20, 13}, {23, 11} }, { {15, 18}, {12, 21} }, { {19, 18}, {22, 20} } }) do
    c:part(c:line(l, 2), G, { flat = true, contact = false })
  end
  c:build{
    { "body", c:ellipse(17, 16, 3, 4.5), G, {} },
    { "head", c:ellipse(17.5, 9.5, 3.5, 3), G, {} },
  }
  for _, q in ipairs({ {11, 10}, {23, 10}, {11, 21}, {22, 20} }) do c:fill(c:rect(q[1], q[2], q[1] + 1, q[2] + 1), "#f08a24") end
  c:build{
    { "poleL", c:rrect(2, 2, 4, 27, 1), RATTAN, { gloss = false } },
    { "poleR", c:rrect(29, 2, 31, 27, 1), RATTAN, { gloss = false } },
    { "poleT", c:rrect(2, 2, 31, 4, 1), RATTAN, { gloss = false } },
    { "poleB", c:rrect(2, 25, 31, 27, 1), RATTAN, { gloss = false } },
  }
  c:eye(14, 7, true); c:eye(19, 7, true)
  c:px(16, 15, "#f08a24"); c:px(18, 17, "#f08a24"); c:px(16, 19, "#f08a24")
  for _, q in ipairs({ {2, 2}, {29, 2}, {2, 25}, {29, 25} }) do
    c:paint({ "r.r", ".r.", "r.r" }, q[1], q[2], { r = RED.base })
  end
  for _, q in ipairs({ {24, 6}, {7, 7}, {26, 15}, {22, 21} }) do c:px(q[1], q[2], "#d9f0e4"); c:px(q[1] + 1, q[2] + 1, "#d9f0e4") end
  save(c, "gecko_friend", W, H)
end

if #FAILS > 0 then print("FAILED: " .. table.concat(FAILS, ", ")) end
