-- cf_yi_titles.lua : Cat Fish Yarn panel icon `titles` (buy the titles Cat Person 15 Yarn / Napmaster 30 Yarn for
-- the Almanac), 64x64, gvlib "icon" mode, the house look of cf_icons.lua (helpers copied from it).
-- Run: AppRun -b --script cf_yi_titles.lua      Writes out/cf-yi-titles.png + .aseprite.
-- Drawing: a royal violet felt swallowtail banner hanging from a pink yarn cord (pompom knots at both ends),
-- a darker violet top hem the cord runs through, gold edge stitches, and a cream felt cat-head emblem wearing
-- a little gold crown. Violet main colour and a tall notched silhouette keep it apart from the other Yarn
-- icons and from the round cf-badge-* medallions. No text.
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
-- paint only on pixels owned by part P (not gloss, optionally lit felt only) (from cf_icons.lua)
local function onPart(c, m, P, hex, litOnly)
  m:each(function(x, y)
    local k = c:key(x, y)
    if c.own[k] == P and not c.gl.s[k] and not (litOnly and c.shd[k]) then c:px(x, y, hex) end
  end)
end

local VIO = felt("#6a4cb8", { gloss = "#d8c8ff", dot = "#ece4ff", rim = "#9a80e0", shade = "#44308a" })
local HEM = { gloss = VIO.rim, dot = VIO.rim, rim = VIO.rim, base = VIO.shade, shade = "#30226a" }
HEM.deep, HEM.bounce = HEM.shade, HEM.base
local PINK = felt("#e46a9b", { gloss = "#ffc8dc", dot = "#ffc8dc", rim = "#f29abb" })
local CREAM = felt("#f0dcb0", { gloss = "#fff3c8", dot = "#fff3c8", rim = "#fff0c8", shade = "#c8a070" })
local GOLD = { gloss = "#fff1c8", dot = "#fff1c8", rim = "#f5cf6a", base = "#e8a317", shade = "#b8661a" }
GOLD.deep, GOLD.bounce = GOLD.shade, GOLD.base

local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local cord = c:line({ {15, 20}, {23, 14}, {32, 10}, {41, 14}, {49, 20} }, 2)
local knot = c:ellipse(32, 9.5, 3.5)
local pomL = c:ellipse(12.5, 20, 3.5)
local pomR = c:ellipse(51.5, 20, 3.5)
local banner = c:poly({ {15, 19}, {49, 19}, {49, 56}, {32, 47}, {15, 56} })
local hem = c:rrect(14, 17, 50, 23, 2)
-- emblem: cat head with two ears, a crown sitting on its head
local head = c:ellipse(32, 40, 10, 7.5)
  :add(c:poly({ {22, 39}, {23, 27}, {30, 34} })):add(c:poly({ {34, 34}, {41, 27}, {42, 39} }))
local crown = c:poly({ {25, 34}, {25, 25}, {28.5, 29}, {32, 23}, {35.5, 29}, {39, 25}, {39, 34} })
local p = c:build{
  { "cord", cord, PINK, { flat = true, contact = false } },
  { "banner", banner, VIO, { cres = 5, gloss = false } },
  { "hem", hem, HEM, { cres = 2, gloss = false } },
  { "knot", knot, PINK, { cres = 2, gloss = false } },
  { "pomL", pomL, PINK, { cres = 2, gloss = false } },
  { "pomR", pomR, PINK, { cres = 2, gloss = false } },
  { "head", head, CREAM, { cres = 3, gloss = false } },
  { "crown", crown, GOLD, { cres = 2, gloss = false, bounce = false } },
}
-- gold edge stitches down both sides and along the swallowtail
c:seam({ { 18, 26 }, { 18, 51 } }, { gap = VIO.shade })
c:seam({ { 46, 26 }, { 46, 51 } }, { gap = VIO.shade })
c:seam({ { 19, 51 }, { 32, 44 }, { 45, 51 } }, { gap = VIO.shade })
-- banner sheen on the lit left side
c:paint({ "g", "g", "g", ".", "g" }, 20, 27, { g = VIO.gloss })
-- cat face: closed happy eyes, nose, inner ears
c:paint({ "u...u", ".uuu." }, 25, 38, { u = "ol2" })
c:paint({ "u...u", ".uuu." }, 35, 38, { u = "ol2" })
c:paint({ "pp" }, 31, 42, { p = PINK.base })
onPart(c, c:poly({ {24, 36}, {24, 31}, {27, 34} }), p.head, PINK.rim)
onPart(c, c:poly({ {40, 36}, {40, 31}, {37, 34} }), p.head, PINK.rim)
-- crown jewels and glint
c:paint({ ".p.", "ppp", ".p." }, 31, 29, { p = PINK.base }); c:px(31, 29, PINK.gloss)
c:px(26, 27, GOLD.gloss); c:px(26, 28, GOLD.gloss); c:px(32, 24, GOLD.gloss)
c:paint({ "gg", "g." }, 10, 18, { g = PINK.gloss }); c:paint({ "gg", "g." }, 49, 18, { g = PINK.gloss })
c:paint({ "gg", "g." }, 30, 7, { g = PINK.gloss })
c:paint({ "g", "g" }, 23, 39, { g = CREAM.gloss })

local t = c:save(OUT .. "cf-yi-titles.aseprite", OUT .. "cf-yi-titles.png")
print("titles " .. GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.colours <= 20 and t.bw == 0, "check failed")
