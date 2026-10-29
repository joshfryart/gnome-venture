-- cf_yi_catnip.lua : Cat Fish Yarn panel icon "catnip" (Catnip Hour: 1 Yarn a day, taps pay x2 for an hour).
-- 64x64, gvlib "icon" mode, house look of cf_icons.lua (cf-up-*): felt ramps, one crescent, gloss comma,
-- gold thread seams, umber contours, 1 px #000000 border.
-- Picture: a wooden hourglass whose sand is green catnip (pile below, remnant above, a falling stream), a
-- catnip leaf pair sprouting from the top cap, pink yarn tied round the waist (the Yarn panel motif) and two
-- stacked gold 4-point sparkles at the right for "x2". Unlike cf-up-catnip (a green sprig) the hourglass is the
-- main shape.
-- Run: AppRun -b --script cf_yi_catnip.lua     Writes out/cf-yi-catnip.png + .aseprite.
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../gvlib/gvlib.lua")
local OUT = here .. "/out/"

-- helpers copied from cf_icons.lua
local function felt(hex, ov)
  local r = GV.ramp(hex)
  local n = {} for k, v in pairs(r) do n[k] = v end
  for k, v in pairs(ov or {}) do n[k] = v end
  n.deep, n.bounce = (ov or {}).deep or n.shade, (ov or {}).bounce or n.base
  return n
end
local function rell(c, cx, cy, rx, ry, a)
  local m, ca, sa, R = c:mask(), math.cos(a), math.sin(a), math.max(rx, ry) + 1
  for y = math.floor(cy - R), math.ceil(cy + R) do
    for x = math.floor(cx - R), math.ceil(cx + R) do
      local dx, dy = x - cx, y - cy
      local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
      if (u / rx) ^ 2 + (v / ry) ^ 2 <= 1 then m:set(x, y) end
    end
  end
  return m
end
local function star(c, cx, cy, R, r, a)
  local pts = {}
  for i = 0, 7 do
    local ang = (a or 0) + i * math.pi / 4 - math.pi / 2
    local d = (i % 2 == 0) and R or r
    pts[#pts + 1] = { cx + 0.5 + math.cos(ang) * d, cy + 0.5 + math.sin(ang) * d }
  end
  return c:poly(pts)
end
local function onPart(c, m, P, hex, litOnly)
  m:each(function(x, y)
    local k = c:key(x, y)
    if c.own[k] == P and not c.gl.s[k] and not (litOnly and c.shd[k]) then c:px(x, y, hex) end
  end)
end

-- ramps (shared with cf_icons.lua)
local WOOD = felt("#b07a45", { gloss = "#fff1c8", dot = "#fff1c8", rim = "#d9a660", shade = "#8a4f2a" })
local GOLD = { gloss = "#fff1c8", dot = "#fff1c8", rim = "#f5cf6a", base = "#e8a317", shade = "#b8661a" }
GOLD.deep, GOLD.bounce = GOLD.shade, GOLD.base
local PINK = felt("#e46a9b", { gloss = "#ffc8dc", dot = "#ffc8dc", rim = "#f29abb" })
local LEAF = felt("#5aa83c", { gloss = "#d4ec8a", dot = "#d4ec8a", rim = "#8ccc5a", shade = "#2f7a3a" })
local GLASS = felt("#a9d6ea", { gloss = "#fff1c8", dot = "#fff1c8", rim = "#d4ecf4", shade = "#6f98c4" })

local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local cx = 23.5
local leafL = rell(c, 16, 10, 8, 3.8, -0.7)
local leafR = rell(c, 31, 10, 8, 3.8, 0.7)
local sprout = c:rect(23, 9, 24, 14)
for _, lf in ipairs({ leafL, leafR }) do                                  -- toothed outer edge
  lf:edge():each(function(x, y) if ((x + 2 * y) % 5 == 0) and y < 11 then lf:del(x, y) end end)
end
local glass = c:ellipse(cx, 22, 12, 11):clip(c:rect(0, 18, 63, 33))
glass:add(c:rect(21, 30, 26, 37))
glass:add(c:ellipse(cx, 47, 12, 11):clip(c:rect(0, 36, 63, 51)))
local capT = c:rrect(8, 14, 39, 19, 2)
local capB = c:rrect(8, 50, 39, 56, 2)
local inner = glass:shrink(2)
local pile = c:ellipse(cx, 52, 11, 8):clip(inner)
local rem = c:rect(0, 26, 63, 33):clip(inner)
local stream = c:rect(23, 33, 24, 46)
local yarn = c:rrect(18, 31, 29, 36, 2)
local loose = c:line({ {29, 35}, {32, 38}, {33, 42}, {31, 44} }, 2)
local big = star(c, 48, 15, 7, 2.5, 0)
local small = star(c, 48, 32, 5.5, 1.7, 0)

local p = c:build{
  { "sprout", sprout, LEAF, { flat = true, contact = false } },
  { "leafL", leafL, LEAF, { cres = 2, gloss = false } },
  { "leafR", leafR, LEAF, { cres = 2, gloss = false } },
  { "glass", glass, GLASS, { cres = 3, gloss = false } },
  { "rem", rem, LEAF, { cres = 2, gloss = false, contact = false } },
  { "stream", stream, LEAF, { flat = true, contact = false } },
  { "pile", pile, LEAF, { cres = 3, gloss = false, contact = false } },
  { "capT", capT, WOOD, { cres = 2, gloss = { 10, 15 } } },
  { "capB", capB, WOOD, { cres = 3, gloss = { 10, 51 } } },
  { "loose", loose, PINK, { flat = true, contact = false } },
  { "yarn", yarn, PINK, { cres = 2, gloss = false } },
  { "small", small, GOLD, { cres = 1, gloss = false, bounce = false, contact = false } },
  { "big", big, GOLD, { cres = 2, gloss = false, bounce = false, contact = false } },
}
-- glass glints (upper-left of each bulb)
c:paint({ ".ggg", "g...", "g...", "g..." }, 14, 20, { g = GLASS.gloss })
c:paint({ "g", "g" }, 14, 41, { g = GLASS.gloss })
-- catnip leaf specks in the sand
c:paint({ ".r.", "rr." }, 17, 47, { r = LEAF.rim })
c:paint({ ".r", "r." }, 27, 46, { r = LEAF.rim })
c:paint({ "r.", ".r" }, 17, 27, { r = LEAF.rim })
-- yarn wraps
for _, x in ipairs({ 21, 24, 27 }) do onPart(c, c:line({ {x, 32}, {x + 1, 35} }, 1), p.yarn, PINK.shade) end
c:px(19, 32, PINK.rim); c:px(20, 32, PINK.rim)
-- leaf midribs, cap seams
c:seam({ { 21, 13 }, { 16, 10 }, { 12, 6 } }, { gap = LEAF.shade })
c:seam({ { 26, 13 }, { 31, 10 }, { 35, 6 } }, { gap = LEAF.shade })
c:seam({ { 11, 17 }, { 36, 17 } }, { gap = WOOD.shade })
c:seam({ { 11, 53 }, { 36, 53 } }, { gap = WOOD.shade })
-- star glints
c:px(47, 14, GOLD.gloss); c:px(48, 14, GOLD.gloss); c:px(47, 31, GOLD.gloss)

local t = c:save(OUT .. "cf-yi-catnip.aseprite", OUT .. "cf-yi-catnip.png")
print("catnip " .. GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.colours <= 20 and t.bw == 0, "check failed")
