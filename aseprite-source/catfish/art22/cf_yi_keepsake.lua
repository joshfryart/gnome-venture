-- cf_yi_keepsake.lua : Cat Fish Yarn panel icon "keepsake" (a Nap keeps the first upgrade of each branch).
-- A gold oval locket with a navy enamel face and a cream paw print, on a ring tied with a rose yarn bow.
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
local NAVY = felt("#4a5ab0", { gloss = "#c8d8ff", dot = "#c8d8ff", rim = "#7a8ad8", shade = "#323a88" })
local ROSE = felt("#d2507e", { gloss = "#ffb8c8", dot = "#ffb8c8", rim = "#ec86a6", shade = "#a03466" })
local CREAM = { rim = "#fff3c8", base = "#f2dca8", shade = "#c49a60" }

local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
-- oval locket on a gold bail ring, the rose yarn bow tied through the ring
local body = c:ellipse(31.5, 39, 16, 17)
local face = c:ellipse(31.5, 39, 11, 12)
local bail = c:ellipse(31.5, 19.5, 4.5, 4)
local loopL = c:poly({ {29, 11}, {20, 5}, {14, 7}, {13, 13}, {16, 18}, {29, 15} }):closed(2)
local loopR = c:poly({ {35, 11}, {44, 5}, {50, 7}, {51, 13}, {48, 18}, {35, 15} }):closed(2)
local knot = c:rrect(28, 8, 35, 16, 2)
local p = c:build{
  { "bail", bail, GOLD, { cres = 2, gloss = false, bounce = false } },
  { "body", body, GOLD, { cres = 4, gloss = false } },
  { "face", face, NAVY, { cres = 3, gloss = false, contact = false } },
  { "loopL", loopL, ROSE, { cres = 3, gloss = false } },
  { "loopR", loopR, ROSE, { cres = 3, gloss = false } },
  { "knot", knot, ROSE, { cres = 2, gloss = false } },
}
c:fill(c:rect(30, 19, 33, 20), GOLD.shade)                                            -- ring hole
-- fold: the inside of each loop near the knot is in shadow
c:fill(c:poly({ {28, 10}, {22, 8}, {22, 15}, {28, 15} }):clip(loopL), ROSE.shade)
c:fill(c:poly({ {36, 10}, {42, 8}, {42, 15}, {36, 15} }):clip(loopR), ROSE.shade)
-- yarn strands on the bow loops (curved grooves) and the knot wrap
local on = set(ROSE.base, ROSE.rim)
trace(c, { {15, 11}, {18, 9}, {21, 10} }, ROSE.shade, on)
trace(c, { {15, 15}, {18, 14}, {21, 14} }, ROSE.shade, on)
trace(c, { {49, 11}, {46, 9}, {43, 10} }, ROSE.shade, on)
trace(c, { {49, 15}, {46, 14}, {43, 14} }, ROSE.shade, on)
trace(c, { {30, 12}, {34, 12} }, ROSE.shade, on)
c:paint({ "gg", "g." }, 16, 7, { g = ROSE.gloss }); c:px(30, 10, ROSE.gloss); c:px(31, 10, ROSE.gloss)
-- cream paw print on the enamel face: pad + four beans, navy gaps between them
local L = { r = CREAM.rim, b = CREAM.base, s = CREAM.shade }
c:paint({
  "...rrrrr...",
  ".rrbbbbbbb.",
  "rbbbbbbbbbs",
  "rbbbbbbbbbs",
  "bbbbbbbbbbs",
  ".bbbbbbbss.",
  "..sss.sss..",
}, 26, 40, L)
local bean = { ".rr.", "rbbs", "rbbs", "bbbs", ".ss." }
c:paint(bean, 22, 33, L); c:paint(bean, 27, 29, L); c:paint(bean, 33, 29, L); c:paint(bean, 38, 33, L)
-- enamel gloss comma, gold gloss on the frame, gold edge stitch round the frame
c:paint({ "..gg", ".g..", "g...", "g..." }, 23, 29, { g = NAVY.gloss })
c:stitch(body)
c:paint({ "..gg", ".g..", "g..." }, 19, 26, { g = GOLD.gloss })
c:px(29, 17, GOLD.gloss)
local t = c:save(OUT .. "cf-yi-keepsake.aseprite", OUT .. "cf-yi-keepsake.png")
print("keepsake " .. GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.colours <= 20 and t.bw == 0, "check failed")
