-- cf_yi_scarf.lua : Cat Fish Yarn panel icon `scarf` (Yarn scarf for the gnome avatar, 12 Yarn, 5 colours),
-- 64x64, gvlib "icon" mode, the house look of cf_icons.lua (helpers copied from it).
-- Run: AppRun -b --script cf_yi_scarf.lua      Writes out/cf-yi-scarf.png + .aseprite.
-- Drawing: a knitted poppy-red scarf loosely draped as if round a neck: a soft loop on top (hole showing),
-- two tails hanging from the front, the front tail crossing over, knit ribs running down each tail, two
-- cream stripes near each end and a row of red fringe tassels. (The on-gnome layer is scarf.lua, not this.)
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../gvlib/gvlib.lua")
local OUT = here .. "/out/"
local C = GV.C

-- felt(hex): gvlib ramp with deep = shade and bounce = base (from cf_icons.lua)
local function felt(hex, ov)
  local r = GV.ramp(hex)
  local n = {} for k, v in pairs(r) do n[k] = v end
  for k, v in pairs(ov or {}) do n[k] = v end
  n.deep, n.bounce = (ov or {}).deep or n.shade, (ov or {}).bounce or n.base
  return n
end
-- paint 1 px polyline with hex where the pixel is one of `on` (skip(n) can break it) (from cf_icons.lua)
local function trace(c, pts, hex, on, skip)
  local seen, n = {}, 0
  for i = 1, #pts - 1 do
    local x0, y0, x1, y1 = pts[i][1], pts[i][2], pts[i + 1][1], pts[i + 1][2]
    local s = math.max(1, math.ceil(math.max(math.abs(x1 - x0), math.abs(y1 - y0))))
    for t = 0, s do
      local x, y = math.floor(x0 + (x1 - x0) * t / s + 0.5), math.floor(y0 + (y1 - y0) * t / s + 0.5)
      local k = y * 100 + x
      if not seen[k] then
        seen[k] = true; n = n + 1
        if (on == nil or on[c:get(x, y) or ""]) and not (skip and skip(n)) then c:px(x, y, hex) end
      end
    end
  end
end
local function set(...) local s = {} for _, v in ipairs({ ... }) do s[v] = true end return s end
-- paint only on pixels owned by part P (not gloss, optionally lit felt only) (from cf_icons.lua)
local function onPart(c, m, P, hex, litOnly)
  m:each(function(x, y)
    local k = c:key(x, y)
    if c.own[k] == P and not c.gl.s[k] and not (litOnly and c.shd[k]) then c:px(x, y, hex) end
  end)
end

-- poppy red (CATFISH_SCARVES red #c0392b), red family of cf_icons.lua, a touch deeper
local RED = felt("#d23a2c", { gloss = "#ff9a68", dot = "#ffc8a0", rim = "#f2733a", shade = "#a02430" })
local CREAM = felt("#f1e6c8", { gloss = "#fff3c8", dot = "#fff3c8", rim = "#fff8e0", shade = "#d8b88a" })

local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- the loop round the (unseen) neck, a little wider than tall, hole set high
local loop = c:ellipse(31.5, 18, 19, 11):cut(c:ellipse(31.5, 15, 10, 4.5))
-- back tail (right): hangs from the loop, swings out to the right, a little shorter
local tailB = c:poly({ {34, 24}, {45, 21}, {51, 42}, {40, 45} })
-- front tail (left): crosses over the loop front, hangs down to the left, longer
local tailF = c:poly({ {21, 21}, {33, 24}, {25, 50}, {13, 47} })
-- fringe: 2 px strands below each end, 1 px gaps
local function fringe(x0, y0, x1, y1, n, len)
  local m = c:mask()
  for i = 0, n - 1 do
    local t = (i + 0.5) / n
    local x, y = x0 + (x1 - x0) * t, y0 + (y1 - y0) * t
    m:add(c:line({ { math.floor(x), math.floor(y) }, { math.floor(x - 1), math.floor(y + len) } }, 2))
  end
  return m
end
local frB = fringe(41, 44, 51, 41, 3, 6)
local frF = fringe(14, 47, 25, 50, 3, 7)
local p = c:build{
  { "frB", frB, RED, { flat = true, contact = false } },
  { "tailB", tailB, RED, { cres = 3, gloss = false } },
  { "loop", loop, RED, { cres = 4, gloss = { 16, 12 } } },
  { "frF", frF, RED, { flat = true, contact = false } },
  { "tailF", tailF, RED, { cres = 3, gloss = false } },
}

-- cream stripes near each end (lit red -> cream base, shaded red -> cream shade)
local function stripe(part, m)
  m:each(function(x, y)
    local k = c:key(x, y)
    if c.own[k] == part and not c.gl.s[k] then
      local h = c:get(x, y)
      if h == RED.shade or h == RED.deep then c:px(x, y, CREAM.shade)
      elseif h == RED.rim then c:px(x, y, CREAM.rim)
      elseif h == RED.base then c:px(x, y, CREAM.base) end
    end
  end)
end
stripe(p.tailF, c:poly({ {14, 38}, {30, 42}, {29, 44}, {13, 40} }))
stripe(p.tailF, c:poly({ {13, 42}, {29, 46}, {28, 48}, {12, 44} }))
stripe(p.tailB, c:poly({ {38, 37}, {52, 33}, {53, 35}, {39, 39} }))

-- knit ribs: shade lines running down each tail (broken every 4th px like knit V's)
local on = set(RED.base, RED.rim)
local brk = function(n) return n % 4 == 0 end
for _, d in ipairs({ 3, 6, 9 }) do
  trace(c, { { 21 + d, 23 + d * 0.25 }, { 14 + d, 48 + d * 0.25 } }, RED.shade, on, brk)
end
for _, d in ipairs({ 3, 6, 9 }) do
  trace(c, { { 35 + d, 24 - d * 0.27 }, { 41 + d, 45 - d * 0.27 } }, RED.shade, on, brk)
end
-- loop ribs: arcs round the front of the loop
for _, r in ipairs({ 14, 17 }) do
  local pts = {}
  for i = 0, 16 do
    local t = math.pi * 0.08 + i * math.pi * 0.84 / 16
    pts[#pts + 1] = { 31.5 + r * math.cos(t), 16.5 + (r * 0.55) * math.sin(t) }
  end
  trace(c, pts, RED.shade, on, brk)
end
-- glints on the tails
c:paint({ "gg", "g." }, 22, 25, { g = RED.gloss })
c:paint({ "g" }, 37, 26, { g = RED.gloss })

local t = c:save(OUT .. "cf-yi-scarf.aseprite", OUT .. "cf-yi-scarf.png")
print("scarf " .. GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.colours <= 20 and t.bw == 0, "check failed")
