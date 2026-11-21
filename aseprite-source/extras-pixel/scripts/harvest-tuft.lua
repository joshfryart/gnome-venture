-- harvest-tuft.lua : leaves shown above a crop picture in the harvest show (Stitched Toy).
-- Three 32x24 PNGs, transparent, no halo, anchor bottom-centre (sits on the crop's top edge):
--   harvest-tuft-leafy.png  fan of 5 broad leaves (cabbage, lettuce, radish)
--   harvest-tuft-vine.png   two curling tendrils + 3 small leaves (tomato, bean)
--   harvest-tuft-stalk.png  tall thin blades + one tiny flower bud (onion, flower, grain)
-- Families: moss + leaf presets (moss green), petal (bud), thread gold (one stitch per tuft).
-- Small canvas: outline 1 px + 1 px lower-right, crescent 2, deep 1.
local GV = dofile("/home/user/gnome-venture/aseprite-source/gvlib/gvlib.lua")
local O = "/home/user/gnome-venture/aseprite-source/extras-pixel/"
local rad, sin, cos = math.rad, math.sin, math.cos

local function canvas()
  return GV.canvas{ w = 32, h = 24, mode = "sticker", ol = 1, olx = 1, cres = 2, deep = 1, margin = 1 }
end

-- leaf polygon from base (bx,by), angle a in degrees (0 = straight up, + = right),
-- length L, half-width W; widest at t = wpos; tip pointed
local function leaf(c, bx, by, a, L, W, wpos, base)
  wpos = wpos or 0.55
  base = base or 0.6
  local dx, dy = sin(rad(a)), -cos(rad(a))
  local nx, ny = -dy, dx
  local left, right = {}, {}
  local N = 10
  for i = 0, N do
    local t = i / N
    local w
    if t <= wpos then w = base + (W - base) * sin((t / wpos) * math.pi / 2)
    else w = W * cos(((t - wpos) / (1 - wpos)) * math.pi / 2) end
    local px, py = bx + dx * L * t, by + dy * L * t
    left[#left + 1] = { px + nx * w, py + ny * w }
    right[#right + 1] = { px - nx * w, py - ny * w }
  end
  local pts = {}
  for i = 1, #left do pts[#pts + 1] = left[i] end
  for i = #right, 1, -1 do pts[#pts + 1] = right[i] end
  return c:poly(pts)
end

local function arc(cx, cy, r, a0, a1, n)
  local pts = {}
  for i = 0, n do
    local a = rad(a0 + (a1 - a0) * i / n)
    pts[#pts + 1] = { cx + r * cos(a), cy + r * sin(a) }
  end
  return pts
end

local function save(c, name)
  local t = c:save(O .. "aseprite/" .. name .. ".aseprite", O .. "png/" .. name .. ".png")
  print(string.format("%-20s %s", name, GV.report(t)))
  assert(t.semi == 0 and t.bw == 0, name .. " failed check")
  return t
end

---------------------------------------------------------------- leafy: fan of 5 broad leaves
do
  local c = canvas()
  local bx, by = 15.5, 21
  local P = {}
  -- outer pair (back, darker leaf), inner pair, centre leaf on top
  P.l2 = c:part(leaf(c, bx, by, -66, 13, 3.6), "leaf", { gloss = false })
  P.r2 = c:part(leaf(c, bx + 1, by, 66, 13, 3.6), "leaf", { gloss = false })
  P.l1 = c:part(leaf(c, bx, by, -32, 15, 4.0), "moss", { gloss = false })
  P.r1 = c:part(leaf(c, bx + 1, by, 32, 15, 4.0), "moss", { gloss = false })
  P.c  = c:part(leaf(c, bx + 0.5, by, 0, 18, 4.4, 0.5), "moss", { gloss = { 14, 8 } })
  -- small hand gloss dots on the side leaves (lit upper-left)
  for _, g in ipairs({ { P.l1, -32, 15 }, { P.r1, 32, 15 } }) do
    local x0, y0, x1, y1 = g[1].m:bbox()
  end
  -- midribs: 1 px leaf-shade vein on the four side leaves
  local function rib(a, L, col, x)
    local dx, dy = sin(rad(a)), -cos(rad(a))
    for t = 0.25, 0.7, 0.05 do
      local px, py = math.floor(x + dx * L * t + 0.5), math.floor(by + dy * L * t + 0.5)
      c:px(px, py, col)
    end
  end
  rib(-32, 15, GV.R.moss.shade, bx); rib(32, 15, GV.R.moss.shade, bx + 1)
  rib(-66, 13, GV.R.leaf.shade, bx); rib(66, 13, GV.R.leaf.shade, bx + 1)
  -- the one gold stitch: a seam down the centre leaf's midrib
  c:seam({ { 16, 7 }, { 16, 17 } })
  save(c, "harvest-tuft-leafy")
end

---------------------------------------------------------------- vine: 2 curling tendrils + 3 small leaves
do
  local c = canvas()
  -- main stem, gently bending
  local stem = c:line({ { 15, 21 }, { 15, 16 }, { 16, 12 }, { 16, 8 } }, 2)
  c:part(stem, "leaf", { flat = true })
  -- left tendril: out and up from the stem, ending in an open hook curl
  local lt = { { 15, 15 }, { 12, 14 }, { 9, 12 } }
  for _, p in ipairs(arc(6.5, 8.5, 3.2, 60, -200, 9)) do lt[#lt + 1] = p end
  c:part(c:line(lt, 2), "moss", { flat = true, contact = false })
  -- right tendril: mirrored, higher, curling the other way
  local rt = { { 17, 12 }, { 20, 11 }, { 23, 10 } }
  for _, p in ipairs(arc(25.5, 7, 3, 150, 400, 9)) do rt[#rt + 1] = p end
  c:part(c:line(rt, 2), "moss", { flat = true, contact = false })
  -- three small ovate leaves: top, low-left, low-right
  c:part(leaf(c, 16, 9, 8, 8, 3.2, 0.45, 1.0), "moss", { gloss = { 15, 3 } })
  c:part(leaf(c, 14.5, 19, -62, 8, 2.8, 0.45, 1.0), "leaf", { gloss = false })
  c:part(leaf(c, 17, 17, 70, 8, 2.8, 0.45, 1.0), "moss", { gloss = false })
  -- the one gold stitch: short seam along the top leaf's centre
  c:seam({ { 17, 4 }, { 16, 8 } })
  save(c, "harvest-tuft-vine")
end

---------------------------------------------------------------- stalk: tall thin blades + one tiny bud
do
  local c = canvas()
  -- blade: pointed, 3 px at the base tapering to a tip
  local function blade(bx, tx, ty, w)
    w = w or 1.6
    local L = math.sqrt((tx - bx) ^ 2 + (ty - 21) ^ 2)
    local a = math.deg(math.atan(tx - bx, 21 - ty))
    return leaf(c, bx, 21, a, L, w, 0.15, w)
  end
  -- back blades first
  c:part(blade(13, 5, 7), "leaf", { gloss = false, cres = 1 })
  c:part(blade(19, 27, 8), "leaf", { gloss = false, cres = 1 })
  -- the bud stalk (2 px) with a tiny petal bud and two sepals
  c:part(c:line({ { 17, 20 }, { 18, 12 }, { 19, 6 } }, 2), "leaf", { flat = true })
  c:part(c:ellipse(19.5, 3.5, 1.5, 2), "petal", { gloss = false, cres = 2, deep = 1, contact = false })
  c:px(19, 2, GV.R.petal.gloss)
  -- sepals hugging the bud base
  c:part(c:rect(18, 5, 18, 6):add(c:rect(21, 5, 21, 6)), "moss", { flat = true, contact = false })
  -- front blades
  c:part(blade(14, 9, 2), "moss", { gloss = false, cres = 1 })
  c:part(blade(16, 14, 1, 1.8), "moss", { gloss = false, cres = 1 })
  c:part(blade(18, 23, 4), "moss", { gloss = false, cres = 1 })
  -- the one gold stitch: a seam up the tallest blade
  c:seam({ { 15, 18 }, { 15, 6 } })
  save(c, "harvest-tuft-stalk")
end
