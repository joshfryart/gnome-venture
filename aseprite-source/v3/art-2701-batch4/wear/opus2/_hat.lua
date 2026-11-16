-- _hat.lua: shared drawing for wayfarers-hat (common), -lined and -fine (opus2 full redraw).
-- Same hat as the game base: brown felt crown with a pinched top, wide brim, red band, blue feather.
-- rank = "common" | "lined" | "fine"
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local W = dofile(DIR .. "/_w.lua")
local HP, X, K = W.HP, W.X, W.K
local floor, abs, max, min = math.floor, math.abs, math.max, math.min

local FELT = { "#3a2026", "#5a3127", "#7a4630", "#9a613b", "#b97e4b", "#d59e66" }
local RED = { "#5e1e30", "#8e2a38", "#b8393c", "#dc5040", "#f2744e", "#ff9c6e" }
local BLUE = { "#22285a", "#2c4a94", "#3a6cc0", "#5596e0", "#88c2f4", "#cfeeff" }

return function(rank)
  local c = W.new("wayfarers-hat" .. (rank == "common" and "" or "-" .. rank))

  -- ===== brim: top surface ellipse + 3 px front thickness (underside rim)
  local top = c:ellipse(31.5, 41, 27.5, 7)
  local rim = top:shift(0, 3):cut(top)
  rim:add(c:ellipse(31.5, 42.5, 27.5, 7)):cut(top)
  local brim = top:copy():add(rim)
  -- crown and band masks (needed for AO on the brim)
  local crown = c:poly{ { 23, 18 }, { 28, 17.6 }, { 29.5, 19.6 }, { 31, 17.6 }, { 36.5, 18 }, { 39, 19.2 }, { 40.6, 22 }, { 41.6, 28 }, { 42.5, 41 }, { 17.5, 41 }, { 18.4, 28 }, { 19.4, 22 }, { 21, 19.2 } }
  local band = c:poly{ { 17, 31.5 }, { 30, 32.5 }, { 43, 31.5 }, { 43, 37.5 }, { 30, 38.5 }, { 17, 37.5 } }
  local hatTop = crown:copy():add(band)

  local bb = {}
  W.speck(bb, brim, 11, 0.10, -1) W.speck(bb, brim, 12, 0.05, 1)
  -- brim lies flat: normal up-and-toward viewer; edge rolls down; AO where the crown sits
  local nb = {}
  brim:each(function(x, y)
    local dx, dy = (x + .5 - 31.5) / 28.5, (y + .5 - 41) / 7.5
    local q = dx * dx + dy * dy
    local roll = q > 0.72 and (q - 0.72) * 2.2 or 0
    nb[K(x, y)] = { W.norm(dx * (0.35 + roll), -0.25 + dy * (0.3 + roll), 0.9) }
  end)
  brim:each(function(x, y) W.addBias(bb, x, y, -1) end)
  rim:each(function(x, y) W.addBias(bb, x, y, -2) end)
  W.ao(bb, top, hatTop, 2, -1)
  -- rolled lip catches the light on the far (top) edge
  top:each(function(x, y) if not top:has(x, y - 1) and x < 46 then W.addBias(bb, x, y, 1) end end)
  W.lit(c, brim, nb, FELT, { bias = bb, amb = 0.12 })
  -- crown shadow cast lower right on the brim
  local cs = hatTop:shift(3, 2):clip(top):cut(hatTop)
  cs:each(function(x, y) W.step(c, x, y, FELT, -1) end)
  hatTop:shift(1, 1):clip(top):cut(hatTop):each(function(x, y) W.step(c, x, y, FELT, -1) end)

  -- ===== crown: vertical cylinder + pillow, centre crease, side pinches, felt fuzz
  local nc = W.mixN(W.vcylN(crown, 18, 42, -0.1), X.pillow(crown, 3), 0.8)
  local cb = {}
  W.speck(cb, crown, 21, 0.11, -1) W.speck(cb, crown, 22, 0.05, 1)
  for y = 19, 31 do
    local x = (y < 25) and 29 or 30
    W.addBias(cb, x, y, -2) W.addBias(cb, x - 1, y, -1) W.addBias(cb, x + 1, y, 1)
  end
  for _, p in ipairs{ { 22, 23 }, { 23, 24 }, { 23, 25 }, { 24, 26 } } do W.addBias(cb, p[1], p[2], -1) W.addBias(cb, p[1] + 1, p[2], 1) end
  for _, p in ipairs{ { 37, 23 }, { 36, 24 }, { 36, 25 }, { 35, 26 } } do W.addBias(cb, p[1], p[2], -1) end
  W.lit(c, crown, nc, FELT, { bias = cb })

  -- ===== band: grosgrain red ribbon with ribs, wraps the crown (curves down in the middle)
  local nbd = W.mixN(W.vcylN(band, 17, 43, 0), W.hcylN(band, 31, 38), 0.7)
  local rb = {}
  band:each(function(x, y) if x % 2 == 0 then W.addBias(rb, x, y, -1) end end)
  band:each(function(x, y) if not band:has(x, y - 1) then W.addBias(rb, x, y, 1) end if not band:has(x, y + 1) then W.addBias(rb, x, y, -1) end end)
  local bandRamp = RED
  W.lit(c, band, nbd, bandRamp, { bias = rb, amb = 0.12 })
  -- contact row under the band on the crown
  for x = 18, 42 do
    for y = 36, 41 do
      if band:has(x, y) and not band:has(x, y + 1) and crown:has(x, y + 1) then W.step(c, x, y + 1, FELT, -2) end
    end
  end
  -- ribbon knot at the left: a folded loop and two short tails
  W.paint(c, 19, 31, {
    "abbbc",
    "bdddc",
    "bdeec",
    "bdddc",
    "abbbc",
    "accca",
    ".a.a.",
  }, { a = RED[1], b = RED[5], c = RED[2], d = RED[4], e = RED[3] })

  -- ===== feather: curved vane, quill, barbs, a notch
  local fm, fn, FT, FS = W.tube({ { 38, 37 }, { 42, 28 }, { 47, 17 }, { 52, 8 } }, function(t)
    if t < 0.1 then return 1.0 end
    return 1.2 + 2.2 * math.sin(math.pi * min(1, (t - 0.05) * 1.0)) ^ 0.6
  end)
  fm:cut(c:rect(50, 15, 53, 16))  -- notch in the trailing vane
  local fb = {}
  local len = 32
  fm:each(function(x, y)
    local k = K(x, y)
    local s, t = FS[k], FT[k]
    if s > 0 then W.addBias(fb, x, y, -1) end
    if ((t * len + abs(s) * 2.6) % 3) < 1 and abs(s) > 0.3 then W.addBias(fb, x, y, -1) end
  end)
  W.lit(c, fm, fn, BLUE, { bias = fb, amb = 0.15, wrap = 0.3 })
  fm:each(function(x, y)
    local k = K(x, y)
    if abs(FS[k]) < 0.22 and FT[k] > 0.08 and FT[k] < 0.92 then c:put(x, y, FT[k] < 0.5 and "#e6f4fb" or BLUE[5]) end
  end)
  -- feather tucked under the band: band overlaps the quill end
  W.paint(c, 37, 34, { "ab", "bc" }, { a = RED[4], b = RED[3], c = RED[2] })
  -- base of feather against crown: contact shade
  for _, p in ipairs{ { 36, 30 }, { 37, 29 }, { 37, 28 }, { 38, 27 } } do if crown:has(p[1], p[2]) and not fm:has(p[1], p[2]) then W.step(c, p[1], p[2], FELT, -1) end end

  -- crown glint (felt only gets a soft lit nap)
  c:put(22, 21, FELT[6]) c:put(23, 20, FELT[6])

  if rank == "common" then
    -- quirk: a ladybird out for a walk on the brim
    W.paint(c, 8, 41, {
      "..kkk..",
      ".kqrrk.",
      "kkrkrrk",
      "kqrrrkr",
      ".krkrk.",
      "..kkk..",
    }, { k = W.INK, r = "#e04838", q = "#ff9a70" })
    W.paint(c, 7, 43, { "k", "k" }, { k = W.INK })
  elseif rank == "lined" then
    -- cream fleece lining turned out round the whole brim edge (the opening), lumpy curls below the rim
    local fl = rim:copy():add(rim:shift(0, 1))
    local lumps = HP.mask()
    fl:each(function(x, y) if not fl:has(x, y + 1) and (x % 5 == 1 or x % 5 == 2) then lumps:set(x, y + 1) end end)
    fl:add(lumps)
    -- the lip of the brim stays felt: a 1 px felt line between brim top and fleece
    W.fleece(c, fl, 31)
    top:each(function(x, y) if fl:has(x, y + 1) then W.step(c, x, y, FELT, -1) end end)
    -- a second fleece edge peeks out under the band (sweatband lining) on the lit side
    for x = 19, 24 do c:put(x, 38, (x % 2 == 0) and W.FLEECE[5] or W.FLEECE[4]) end
    -- quirk: a tuft of the fleece has caught on the feather quill
    W.paint(c, 41, 28, { ".ab", "abc", ".c." }, { a = W.FLEECE[6], b = W.FLEECE[5], c = W.FLEECE[3] })
  elseif rank == "fine" then
    local Gd = W.GOLD
    -- gold braid bound round the brim edge: 2 px twisted cord on the rim
    rim:each(function(x, y)
      if not rim:has(x, y - 1) or not rim:has(x, y - 2) then
        local tw = (x + y) % 3
        c:put(x, y, ({ Gd[5], Gd[4], Gd[3] })[tw + 1])
        if x > 40 then W.step(c, x, y, Gd, -1) end
      end
    end)
    -- gold embroidery on the band: running zig-zag with dots between (no other colour)
    for x = 24, 41 do
      local yb = band:has(x, 38) and 35 or 34
      local zig = (x % 4 < 2) and 0 or 1
      if x ~= 37 and x ~= 38 then c:put(x, yb - 1 + zig, (x < 34) and Gd[5] or Gd[4]) end
    end
    -- gold edging along the band's top and bottom (the band reads gold-framed at 32 px)
    band:each(function(x, y)
      if x > 23 and (not band:has(x, y - 1)) then c:put(x, y, (x < 33) and Gd[5] or Gd[4]) end
      if x > 23 and (not band:has(x, y + 1)) then c:put(x, y, (x < 33) and Gd[3] or Gd[2]) end
    end)
    -- the knot becomes a gold buckle-knot ring
    W.paint(c, 19, 31, {
      "abbba",
      "b...c",
      "b.r.c",
      "b...c",
      "accca",
    }, { a = Gd[2], b = Gd[5], c = Gd[3], r = Gd[4] })
    -- gold clasp pinning the feather to the band, with the gleam
    W.paint(c, 36, 32, {
      ".ab.",
      "abcd",
      "bcdd",
      ".dd.",
    }, { a = Gd[6], b = Gd[5], c = Gd[4], d = Gd[3] })
    c:put(36, 31, Gd[1]) -- (outline side)
    W.px(c, 36, 31, nil)
    -- gleam: a cream sparkle off the clasp, and a lit nap streak on the crown
    c:put(34, 29, "#fff4d6") c:put(33, 29, Gd[6]) c:put(35, 29, Gd[6]) c:put(34, 28, Gd[6]) c:put(34, 30, Gd[6])
    -- quirk: a tiny gold acorn charm hangs from the buckle-knot
    W.paint(c, 20, 36, {
      ".a.",
      ".a.",
      "bcb",
      "ded",
      ".e.",
    }, { a = Gd[3], b = Gd[2], c = Gd[5], d = Gd[4], e = Gd[3] })
  end
  return c
end
