-- acai (pass 2, final). Squat, lopsided mound of 6 glossy dark acai + 1 shy little berry hiding under the leaf.
-- Berry ramp = dusk one step down (base dusk.shade, shade dusk.deep, pop dusk.hi): acai read darker than grapes.
-- Separation (rule 2): the BACK berry gets a dusk.deep contact line where a front berry overlaps it, so front
-- berries keep a clean lit rim and the heap reads as stacked balls, not one blob.
-- quirk: the shy berry (paler, smaller) peeks out from under the right leaf.
local HP = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../lib/hp.lua")
local out = app.params.out or "./"
local P = HP.P
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "acai" }
local ACAI = { hi = P.dusk.hi, base = P.dusk.shade, shade = P.dusk.deep, deep = P.dusk.deep }
local SHY  = { hi = P.dusk.hi, base = P.dusk.base, shade = P.dusk.shade, deep = P.dusk.deep }

local berries, owner = {}, {}
local function key(x, y) return y * 64 + x end
local function berry(cx, cy, r, rp, o)
  local m = c:ellipse(cx, cy, r, r)
  c:part(m, rp or ACAI, o or { band = 3, inner = false })
  local i = #berries + 1
  berries[i] = m
  m:each(function(x, y) owner[key(x, y)] = i end)
  return m
end

local leafCut = HP.mask()
-- back: shy berry + top berry
-- stem with a little curl on top (drawn first: it disappears into the heap)
c:part(c:line({ {35, 7}, {33, 11}, {32, 15}, {32, 22} }, 2), "moss", { nopop = true, band = 1 })
c:fillMask(c:line({ {36, 6}, {38, 5}, {39, 6} }, 1), P.moss.shade)
local shy = berry(42, 25, 4, SHY, { band = 2, inner = false, pop = { x = 40, y = 24 } })
berry(26, 24, 7)
-- leaves: plump, pointed, with a moss.shade midrib
local function leaf(pts, rib, popx, popy)
  local m = c:poly(pts)
  c:part(m, "moss", { band = 1, pop = { x = popx, y = popy } })
  local r = c:line(rib, 1):clip(m:shrink(1))
  c:fillMask(r, P.moss.shade)
  m:each(function(x, y) owner[key(x, y)] = nil end)
  return m
end
leaf({ {32,15},{27,9},{20,6},{14,7},{12,10},{17,14},{25,16} }, { {30,14},{24,11},{16,9} }, 18, 8)
local rl = leaf({ {33,16},{39,11},{46,11},{52,14},{54,19},{47,18},{39,19} }, { {35,16},{43,14},{51,17} }, 40, 12)
-- middle row
berry(16, 38, 6) berry(31, 35, 7) berry(46, 37, 6)
-- front row (hero = front left, carries the sparkle)
berry(23, 47, 7) berry(39, 47, 7)
-- contact lines on back berries where a later (front) berry overlaps
local contact = {}
for i, m in ipairs(berries) do
  m:each(function(x, y)
    if owner[key(x, y)] == i then
      for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do
        local j = owner[key(x + d[1], y + d[2])]
        if j and j > i then contact[#contact + 1] = { x, y } break end
      end
    end
  end)
end
for _, p in ipairs(contact) do c:px(p[1], p[2], P.dusk.deep) end
c:px(20, 42, P.cream)                                   -- the one sparkle, next to the hero berry pop
-- nudge the whole drawing 1 px down (5 px top margin)
for y = 62, 0, -1 do for x = 0, 63 do
  c.pix[(y + 1) * 64 + x], c.own[(y + 1) * 64 + x] = c.pix[y * 64 + x], c.own[y * 64 + x]
end end
for x = 0, 63 do c.pix[x], c.own[x] = nil, nil end
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "acai.aseprite", png = out .. "acai.png" }
