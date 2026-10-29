-- cf_yi_keepsake.lua : Cat Fish Yarn panel icon "keepsake" (a Nap keeps the first upgrade of each branch).
-- A gold heart locket with a teal enamel face and a cream paw print, hung from a rose yarn bow.
-- House look of cf_icons.lua (gvlib icon mode, felt ramps, gold seams, gloss comma, 1 px #000000 border).
-- Run: AppRun -b --script cf_yi_keepsake.lua      Writes out/cf-yi-keepsake.png + .aseprite.
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../gvlib/gvlib.lua")
local OUT = here .. "/out/"
local C = GV.C

-- helpers copied from cf_icons.lua
local function felt(hex, ov)
  local r = GV.ramp(hex)
  local n = {} for k, v in pairs(r) do n[k] = v end
  for k, v in pairs(ov or {}) do n[k] = v end
  n.deep, n.bounce = (ov or {}).deep or n.shade, (ov or {}).bounce or n.base
  return n
end
local function tint(c, m, from, to) m:each(function(x, y) if c:get(x, y) == from then c:px(x, y, to) end end) end
local function set(...) local s = {} for _, v in ipairs({ ... }) do s[v] = true end return s end
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
local function onPart(c, m, P, hex, litOnly)
  m:each(function(x, y)
    local k = c:key(x, y)
    if c.own[k] == P and not c.gl.s[k] and not (litOnly and c.shd[k]) then c:px(x, y, hex) end
  end)
end

local GOLD = { gloss = "#fff1c8", dot = "#fff1c8", rim = "#f5cf6a", base = "#e8a317", shade = "#b8661a" }
GOLD.deep, GOLD.bounce = GOLD.shade, GOLD.base
local TEAL = felt("#2f9a8e", { gloss = "#c8f0d8", dot = "#c8f0d8", rim = "#5cc0a8", shade = "#1f6a78" })
local ROSE = felt("#d2507e", { gloss = "#ffb8c8", dot = "#ffb8c8", rim = "#ec86a6", shade = "#a03466" })
local CREAM = { rim = "#fff3c8", base = "#f2dca8", shade = "#c49a60" }

local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
-- heart locket
local heart = c:ellipse(21.5, 32, 11, 10):add(c:ellipse(41.5, 32, 11, 10))
heart:add(c:poly({ {11, 35}, {53, 35}, {32, 55} }))
local face = heart:shrink(4)
local bail = c:ellipse(31.5, 22, 4, 3.5)
-- rose yarn bow on top
local loopL = c:poly({ {29, 13}, {17, 7}, {11, 8}, {11, 16}, {15, 20}, {29, 17} }):closed(2)
local loopR = c:poly({ {35, 13}, {46, 7}, {52, 8}, {52, 16}, {48, 20}, {35, 17} }):closed(2)
local knot = c:rrect(27, 10, 36, 19, 3)
local p = c:build{
  { "bail", bail, GOLD, { cres = 2, gloss = false, bounce = false } },
  { "heart", heart, GOLD, { cres = 4, gloss = false } },
  { "face", face, TEAL, { cres = 3, gloss = { 17, 28 }, contact = false } },
  { "loopL", loopL, ROSE, { cres = 3, gloss = false } },
  { "loopR", loopR, ROSE, { cres = 3, gloss = false } },
  { "knot", knot, ROSE, { cres = 2, gloss = false } },
}
c:fill(c:ellipse(31.5, 22, 1.5, 1), GOLD.shade)                                     -- bail hole
-- yarn strands on the bow loops (curved grooves)
local onL, onR = set(ROSE.base, ROSE.rim), set(ROSE.base, ROSE.rim)
trace(c, { {14, 10}, {20, 10}, {27, 14} }, ROSE.shade, onL)
trace(c, { {14, 15}, {21, 15}, {27, 16} }, ROSE.shade, onL)
trace(c, { {49, 10}, {43, 10}, {37, 14} }, ROSE.shade, onR)
trace(c, { {49, 15}, {42, 15}, {37, 16} }, ROSE.shade, onR)
c:paint({ "gg", "g." }, 13, 8, { g = ROSE.gloss })
c:paint({ "gg" }, 29, 12, { g = ROSE.gloss })
-- paw print on the enamel face
local pad = c:ellipse(31.5, 45, 6, 4.5):add(c:ellipse(31.5, 42, 4, 3))
local toes = { {23.5, 36, 2.5, 3}, {28.5, 32.5, 2.5, 3}, {34.5, 32.5, 2.5, 3}, {39.5, 36, 2.5, 3} }
local paw = pad:copy()
for _, t in ipairs(toes) do paw:add(c:ellipse(t[1], t[2], t[3], t[4])) end
onPart(c, paw, p.face, CREAM.base)
c:fill(paw:copy():cut(paw:shift(-1, -1)), CREAM.shade)                                 -- lower-right shade
c:fill(paw:copy():cut(paw:shift(1, 1)), CREAM.rim)                                     -- lit upper-left
-- gold bezel seam around the face
c:stitch(heart)
c:px(15, 26, GOLD.gloss); c:px(16, 25, GOLD.gloss); c:px(17, 25, GOLD.gloss)
local t = c:save(OUT .. "cf-yi-keepsake.aseprite", OUT .. "cf-yi-keepsake.png")
print("keepsake " .. GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.colours <= 20 and t.bw == 0, "check failed")
