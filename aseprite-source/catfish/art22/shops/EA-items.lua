-- shops/EA-items.lua : Cat Fish pet shop EA (Blossom Lantern Cattery, Blossomreach) item sprites, art22 v1.
-- Five 1x room sprites (Stitched Toy, Part D) at the exact slot max sizes of claude/catfish-shops-art-spec.md:
--   cf-pet-maneki_neko           shelf        20 x 24  beckoning cream felt cat, red collar + bell, gold coin
--   cf-pet-paper_lantern_string  ceiling      48 x 34  swag cord from the top edge, two red + one paper lantern
--   cf-pet-bonsai                sill         30 x 26  blossom bonsai in an indigo glazed pot, flat bottom
--   cf-pet-koi_kite_lure         rod          16 x 16  kohaku koi streamer hanging nose-up from the string
--   cf-pet-tea_tray              floor-right  36 x 28  red lacquer tray, jade teapot, two cups, flat bottom
-- Shared regional set: vermilion lacquer red, cream paper felt, sakura pink, jade green, dusk lacquer black,
-- thread gold. Small-sprite pens: 1 px three-tone umber outline +1 px lower right, then the 1 px #000000 border
-- (like the room's 1x yarn ball), so the sprites match the 2x room's 2 px dark edges.
-- Run: AppRun -b --script shops/EA-items.lua    Writes art22/out/cf-pet-<slug>.png + .aseprite
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
-- regional ramps (one set for all five)
local RED   = felt("#dd3a2a", { gloss = "#ff9158", dot = "#ffc27a", rim = "#f2793a", shade = "#ae2a2a" })
local PAPER = felt("#f1e2bc", { shade = "#d8b884", rim = "#fff3c8", gloss = "#fff3c8", dot = "#ffffff", pale = true })
local PINK  = felt("#f08fb4", { gloss = "#ffd6e2", rim = "#f6b8cf", shade = "#c85a8c" })
local JADE  = felt("#5fae8a", { gloss = "#c8ecc0", rim = "#9ad2a6", shade = "#3c7f6e" })
local LEAF  = felt("#4f9a45", { gloss = "#c8d77a", rim = "#a4b86a", shade = "#2f6a3a" })
local INDIGO= felt("#3e4f8f", { gloss = "#a8b8ec", rim = "#6f82c4", shade = "#2a3266" })
local LAC   = felt("#5e2f1e", { gloss = "#d9a660", rim = "#8a4f2a", shade = "#3d2016" })   -- dark lacquered wood
local GOLD  = felt("#e8a317", { gloss = "#fff1c8", rim = "#f5cf6a", shade = "#b8661a" })
local BARK  = felt("#8a5a3a", { gloss = "#d9a660", rim = "#b07a45", shade = "#5e2f1e" })
local TEA   = "#9ab84a"

local FAILS, RES = {}, {}
local function canvas(w, h) return GV.canvas{ w = w, h = h, mode = "sticker", ol = 1, olx = 1, margin = 0, cres = 2, deep = 1 } end
local function save(c, slug)
  local name = "cf-pet-" .. slug
  local t = c:save(OUT .. name .. ".aseprite", OUT .. name .. ".png")
  print(string.format("%-30s ", name) .. GV.report(t))
  if not (t.semi == 0 and t.bw <= 1) then FAILS[#FAILS + 1] = name end
  return t
end
local function tint(c, m, from, to) m:each(function(x, y) if c:get(x, y) == from then c:px(x, y, to) end end) end
-- hand(c, rows, legend): a hand-placed 1x sprite (too small for auto shading). The rows' non-'.' pixels form one
-- flat silhouette part (so finish() still grows the three-tone umber outline and the black border), then every
-- pixel is painted from the legend: rim / base / crescent shade / gloss placed by hand, light from the upper left.
local function hand(c, rows, legend, pale)
  for j, r in ipairs(rows) do assert(#r == c.W, "row " .. j .. " is " .. #r .. " wide") end
  assert(#rows <= c.H)
  local m = c:ascii(rows, 0, 0)
  c:part(m, pale and PAPER or RED, { flat = true, contour = false, contact = false, gloss = false, pale = pale })
  c:paint(rows, 0, 0, legend)
  return m
end

-- ===== maneki_neko (shelf, 20 x 24) =====
-- Cream felt beckoning cat sitting on the shelf: left paw raised beside the face (pink pad), red collar with a
-- gold bell, a gold koban coin hugged to the lit side, gold hem seam round the base. Hand-placed (1x, 20 px).
do
  local c = canvas(20, 24)
  local L = { W = PAPER.rim, c = PAPER.base, s = PAPER.shade, p = PINK.base, n = PINK.shade, e = "ol3", m = "ol2",
              r = RED.base, R = RED.shade, q = RED.rim, g = GOLD.rim, G = GOLD.base, h = GOLD.shade, o = "hole", T = "gold" }
  hand(c, {
    "....................",
    "....................",
    "..Wc.....Wc...WWc...",
    "..Wpc...Wpcs..Wccs..",
    "..WppcccWppcs.Wpps..",
    "..Wcccccccccs.Wpps..",
    "..Wcccccccccs.cccs..",
    "..Wceeccceecs.ccs...",
    "..Wceeccceecs.ccs...",
    "..Wccccnccccs.ccs...",
    "..Wcccmcmccss.ccs...",
    "...csccccccss.ccs...",
    "..qrrrrrrrrrrrccs...",
    "..rrrrrgGhrrRRcss...",
    "..WccccGohcccccs....",
    "..WgGGhcccccccss....",
    "..gGGGhcccccccss....",
    "..ghhhhcccccccss....",
    "..gGGGhcccccccss....",
    "..gGGhhcTTcTTcTs....",
    "..chhhcccccsssss....",
    "...ssssssssssss.....",
  }, L, true)
  RES[#RES + 1] = { "maneki_neko", save(c, "maneki_neko") }
end

-- ===== paper_lantern_string (ceiling, 48 x 34) =====
do
  local c = canvas(48, 34)
  local cordPts = {}
  for x = 0, 47 do cordPts[#cordPts + 1] = { x, math.floor(1 + 5 * (1 - ((x - 23.5) / 23.5) ^ 2) + 0.5) } end
  local cord = c:line(cordPts, 1)
  c:part(cord, RED, { flat = true })
  local function lantern(cx, top, rx, ry, R, motif)
    local cap1 = c:rrect(cx - rx + 2, top, cx + rx - 2, top + 1, 0)
    local bodyM = c:ellipse(cx, top + 2 + ry, rx, ry)
    local cap2 = c:rrect(cx - rx + 2, top + 2 * ry + 3, cx + rx - 2, top + 2 * ry + 4, 0)
    local tas = c:rect(cx - 0.5, top + 2 * ry + 5, cx + 0.5, top + 2 * ry + 7)
    local p = c:build{
      { "b", bodyM, R, { cres = 3 } },
      { "c1", cap1, LAC, { flat = true } },
      { "c2", cap2, LAC, { flat = true } },
      { "t", tas, GOLD, { flat = true } },
    }
    -- ribs: every 3rd row a shade groove inside the body
    local inner = bodyM:shrink(1)
    for y = top + 4, top + 2 * ry + 1, 3 do
      for x = cx - rx, cx + rx do
        if inner:has(x, y) and not c.gl.s[c:key(x, y)] then c:px(x, y, R.shade) end
      end
    end
    if motif then motif(cx, top + 2 + ry) end
  end
  local function blossom(x, y)
    c:paint({ ".p.", "pyp", ".p." }, x - 1, y - 1, { p = PINK.base, y = GOLD.rim })
  end
  -- each lantern hangs 4 rows under the cord: the cord's outline, the gap and the cap's outline make a short
  -- dark hanging thread (re-inked 1 px umber after the border pass)
  local function cy(x) for _, q in ipairs(cordPts) do if q[1] == x then return q[2] end end end
  lantern(7.5, cy(7) + 4, 4, 5, RED)
  lantern(40.5, cy(40) + 4, 4, 5, RED)
  lantern(24, cy(24) + 4, 6, 7, PAPER, function(x, y)
    c:paint({ ".p.p.", "ppppp", ".pyp.", "ppppp", ".p.p." }, x - 2, y - 2, { p = PINK.base, y = GOLD.base })
  end)
  c:finish()
  for _, x in ipairs({ 7, 8, 40, 41, 24 }) do for y = cy(x) + 1, cy(x) + 3 do c:px(x, y, C.ol3) end end
  RES[#RES + 1] = { "paper_lantern_string", save(c, "paper_lantern_string") }
end

-- ===== bonsai (sill, 30 x 26) =====
do
  local c = canvas(30, 26)
  local pot = c:rrect(4, 19, 25, 23, 1)
  local lip = c:rect(3, 18, 26, 19)
  local trunk = c:line({ { 14, 19 }, { 12, 15 }, { 10, 12 }, { 13, 9 }, { 17, 7 } }, 3)
  local br = c:line({ { 13, 14 }, { 19, 13 }, { 22, 13 } }, 2)
  local p = c:build{
    { "trunk", trunk, BARK, { cres = 2, gloss = false } },
    { "br", br, BARK, { flat = true } },
    { "padA", c:ellipse(8, 10, 5, 3), LEAF, {} },
    { "padB", c:ellipse(18, 5.5, 7, 3.5), LEAF, {} },
    { "padC", c:ellipse(23, 12, 4, 2.5), LEAF, {} },
    { "lip", lip, INDIGO, { flat = true } },
    { "pot", pot, INDIGO, { cres = 2 } },
  }
  for _, b in ipairs({ { 6, 9 }, { 15, 4 }, { 21, 6 }, { 24, 11 }, { 10, 11 } }) do
    c:px(b[1], b[2], PINK.base); c:px(b[1] + 1, b[2], PINK.rim); c:px(b[1], b[2] + 1, PINK.shade)
  end
  c:seam({ { 5, 21 }, { 24, 21 } }, { gap = INDIGO.shade })
  RES[#RES + 1] = { "bonsai", save(c, "bonsai") }
end

-- ===== koi_kite_lure (rod, 16 x 16) =====
-- Kohaku koi streamer (koinobori) hanging level from the rod string like the game's fish lures: gold mouth
-- ring at the nose (left), cream felt body with red back patches, one eye, a pectoral fin, a forked red tail
-- with a gold rib. The 1 px umber string runs from the top edge to the back (painted after the border pass
-- so it joins the game's own string, which ends at the top centre). Hand-placed (1x).
do
  local c = canvas(16, 16)
  local L = { W = PAPER.rim, c = PAPER.base, s = PAPER.shade, e = "ol3", r = RED.base, R = RED.shade, q = RED.rim,
              g = GOLD.rim, G = GOLD.base, h = GOLD.shade }
  hand(c, {
    "................",
    "................",
    "................",
    "................",
    "................",
    "....WcqrrR..qR..",
    "..gWceeqrrRsrR..",
    "..GWceecccccgR..",
    "..GWccccqrRcrR..",
    "..hWcccqrRRsqR..",
    "....sssssss.qR..",
    "......qR........",
  }, L, true)
  c:finish()
  for y = 0, 3 do c:px(8, y, C.ol3) end
  RES[#RES + 1] = { "koi_kite_lure", save(c, "koi_kite_lure") }
end

-- ===== tea_tray (floor-right, 36 x 28) =====
do
  local c = canvas(36, 28)
  local top = c:rrect(2, 16, 33, 21, 2)
  local face = c:rect(3, 21, 32, 23)
  local legL = c:rect(5, 23, 8, 25)
  local legR = c:rect(27, 23, 30, 25)
  local pot = c:ellipse(13, 12, 6, 5)
  local lid = c:rrect(10, 5, 16, 7, 1)
  local knob = c:rect(12, 3, 14, 4)
  local spout = c:line({ { 7, 12 }, { 4, 9 } }, 2)
  local handle = c:line({ { 18, 13 }, { 21, 10 }, { 21, 7 } }, 2)
  local cup1 = c:rrect(22, 13, 26, 17, 1)
  local cup2 = c:rrect(28, 14, 32, 18, 1)
  c:build{
    { "legL", legL, RED, { flat = true } },
    { "legR", legR, RED, { flat = true } },
    { "face", face, RED, { flat = true } },
    { "top", top, RED, { cres = 2, gloss = { 4, 17 } } },
    { "spout", spout, JADE, { flat = true } },
    { "handle", handle, BARK, { flat = true } },
    { "pot", pot, JADE, { cres = 3 } },
    { "lid", lid, JADE, { flat = true } },
    { "knob", knob, GOLD, { flat = true } },
    { "cup1", cup1, PAPER, { flat = true } },
    { "cup2", cup2, PAPER, { flat = true } },
  }
  c:paint({ "ttt" }, 23, 14, { t = TEA }); c:paint({ "ttt" }, 29, 15, { t = TEA })
  c:seam({ { 4, 22 }, { 31, 22 } }, { gap = RED.shade })
  RES[#RES + 1] = { "tea_tray", save(c, "tea_tray") }
end

assert(#FAILS == 0, "check failed: " .. table.concat(FAILS, " "))
