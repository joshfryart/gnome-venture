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

-- ===== maneki_neko (shelf, 20 x 24) =====
-- Cream felt beckoning cat sitting on the shelf: left paw raised beside the face (pink pad), red collar with a
-- gold bell, a gold koban coin hugged to the lit side, gold hem seam round the base.
do
  local c = canvas(20, 24)
  local earL = c:poly({ {4, 7}, {5, 2}, {9, 5} })
  local earR = c:poly({ {10, 5}, {14, 2}, {15, 7} })
  local body = c:rrect(3, 12, 15, 21, 3)
  local head = c:ellipse(9.5, 8, 6, 4.5)
  local arm  = c:rect(15, 7, 17, 13)
  local paw  = c:rrect(14, 3, 17, 7, 1)
  c:build{
    { "earL", earL, PAPER, { flat = true } },
    { "earR", earR, PAPER, { flat = true } },
    { "body", body, PAPER, { gloss = false } },
    { "head", head, PAPER, { gloss = false } },
    { "arm",  arm,  PAPER, { flat = true } },
    { "paw",  paw,  PAPER, { flat = true } },
    { "collar", c:rect(4, 12, 14, 13), RED, { flat = true } },
    { "coin", c:rrect(4, 15, 8, 21, 2), GOLD, { cres = 2, gloss = false } },
    { "bell", c:rrect(8, 13, 10, 15, 1), GOLD, { flat = true } },
  }
  c:px(6, 5, PINK.base); c:px(6, 6, PINK.base); c:px(12, 5, PINK.base); c:px(12, 6, PINK.base)   -- inner ears
  c:paint({ "uu....uu", "uu....uu" }, 5, 7, { u = "ol3" })                                         -- pupils
  c:px(5, 7, C.halo); c:px(11, 7, C.halo)                                                          -- glints
  c:px(9, 9, PINK.shade); c:px(8, 10, C.ol2); c:px(10, 10, C.ol2)                                 -- nose, mouth
  c:px(15, 5, PINK.base); c:px(16, 5, PINK.base)                                                    -- paw pad
  c:px(9, 15, C.hole)                                                                              -- bell slot
  c:px(5, 16, GOLD.gloss); c:px(5, 17, GOLD.gloss)                                                 -- coin glint
  c:px(6, 18, GOLD.shade); c:px(7, 18, GOLD.shade)                                                 -- coin rib
  c:paint({ "gg", "g." }, 5, 4, { g = PAPER.gloss })
  c:seam({ { 9, 19 }, { 15, 19 } }, { gap = PAPER.shade })                                         -- base hem
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
    local tas = c:rect(cx - 0.5, top + 2 * ry + 5, cx + 0.5, top + 2 * ry + 8)
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
  lantern(9, 6, 5, 6, RED)
  lantern(38, 6, 5, 6, RED)
  lantern(24, 8, 7, 8, PAPER, function(x, y)
    c:paint({ ".p.p.", "ppppp", ".pyp.", "ppppp", ".p.p." }, x - 2, y - 2, { p = PINK.base, y = GOLD.base })
  end)
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
-- Kohaku koi streamer (koinobori) hanging nose-up from the rod string: gold mouth ring, cream felt body with
-- red patches, red split tail with gold ribs. The 1 px umber string runs from the top edge to the ring (painted
-- after the border pass so it joins the game's own string).
do
  local c = canvas(16, 16)
  local ring = c:rrect(4, 2, 9, 3, 1)
  local body = c:ellipse(6.5, 7, 3.5, 4)
  local tail = c:poly({ {4, 10}, {9, 10}, {13, 15}, {6.5, 12}, {0, 15} })
  local finL = c:rect(2, 7, 2, 8)
  local finR = c:rect(11, 7, 11, 8)
  c:build{
    { "tail", tail, RED, { flat = true } },
    { "finL", finL, RED, { flat = true } },
    { "finR", finR, RED, { flat = true } },
    { "body", body, PAPER, { cres = 2, gloss = false } },
    { "ring", ring, GOLD, { flat = true } },
  }
  c:paint({ ".rrr.", "..rr.", "....." , "rr...", ".rrr." }, 5, 5, { r = RED.base })
  c:paint({ "u....u", "u....u" }, 4, 4, { u = "ol3" })
  c:px(4, 6, PAPER.gloss)
  c:px(6, 3, C.hole); c:px(7, 3, C.hole)
  c:paint({ "g.....g", ".g...g." }, 3, 12, { g = GOLD.rim })
  c:finish()
  c:px(6, 0, C.ol3); c:px(6, 1, C.ol3)
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
