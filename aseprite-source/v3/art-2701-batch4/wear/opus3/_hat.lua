-- _hat.lua: shared drawing for wayfarers-hat (common), -lined and -fine (opus3 richness pass,
-- built on opus2/_hat.lua). One hat, three ranks: the cut, crown, band, bow and feather are the same
-- in all three, so the rank set reads as one item.
-- Same hat as the game base: brown felt crown with a pinched top, wide brim, red band, blue feather.
-- opus3: hue-shifted 6-tone felt (violet deep, honey light), brim tips curl up, felt nap + brushed
-- streaks, rim light on the lit contour and a bounce line under the brim, a real ribbon bow (two
-- loops, knot, two tails) instead of the flat knot block, bigger ladybird.
-- rank = "common" | "lined" | "fine"
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local W = dofile(DIR .. "/_w.lua")
local HP, X, K = W.HP, W.X, W.K
local floor, abs, max, min = math.floor, math.abs, math.max, math.min

local FELT = { "#2f1c2c", "#4e2a2c", "#6e3e2e", "#8e5634", "#b07440", "#d49a5a" }
local RED = { "#561a32", "#8a2638", "#b8393c", "#dc5040", "#f2744e", "#ffa070" }
local BLUE = { "#22285a", "#2c4a94", "#3a6cc0", "#5596e0", "#88c2f4", "#cfeeff" }

-- brim tips curl up: lift a mask's pixels by s(x)
local function curl(c, m)
  local o = HP.mask()
  m:each(function(x, y)
    local d = (x + .5 - 31.5) / 28
    o:set(x, y - floor(3.2 * d * d * d * d + 0.5))
  end)
  return o
end

return function(rank)
  local c = W.new("wayfarers-hat" .. (rank == "common" and "" or "-" .. rank))

  -- ===== brim: top surface ellipse + 3 px front thickness (underside rim), tips curled up
  local top0 = c:ellipse(31.5, 41, 27.5, 7)
  local rim0 = top0:shift(0, 3):add(c:ellipse(31.5, 42.5, 27.5, 7)):cut(top0)
  local top, rim = curl(c, top0), curl(c, rim0)
  rim:cut(top)
  local brim = top:copy():add(rim)
  local crown = c:poly{ { 23, 18 }, { 28, 17.6 }, { 29.5, 19.6 }, { 31, 17.6 }, { 36.5, 18 }, { 39, 19.2 }, { 40.6, 22 }, { 41.6, 28 }, { 42.5, 41 }, { 17.5, 41 }, { 18.4, 28 }, { 19.4, 22 }, { 21, 19.2 } }
  local band = c:poly{ { 17, 31.5 }, { 30, 32.5 }, { 43, 31.5 }, { 43, 37.5 }, { 30, 38.5 }, { 17, 37.5 } }
  local hatTop = crown:copy():add(band)

  local bb = {}
  W.speck(bb, brim, 11, 0.10, -1) W.speck(bb, brim, 12, 0.05, 1)
  -- brushed felt: short streaks running round the brim
  brim:each(function(x, y) if X.hash(x // 3, y, 13) < 0.12 then W.addBias(bb, x, y, 1) end end)
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
  top:each(function(x, y) if not top:has(x, y - 1) and x < 46 then W.addBias(bb, x, y, 1) end end)
  W.lit(c, brim, nb, FELT, { bias = bb, amb = 0.12 })
  -- the brim's front lip: a lit roll line where top meets underside (lit side), dark crease right
  top:each(function(x, y) if rim:has(x, y + 1) then c:put(x, y, x < 22 and FELT[5] or (x < 42 and FELT[4] or FELT[3])) end end)
  -- crown shadow cast lower right on the brim
  hatTop:shift(3, 2):clip(top):cut(hatTop):each(function(x, y) W.step(c, x, y, FELT, -1) end)
  hatTop:shift(1, 1):clip(top):cut(hatTop):each(function(x, y) W.step(c, x, y, FELT, -1) end)

  -- ===== crown: vertical cylinder + pillow, centre crease, side pinches, felt nap
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
  c:put(22, 21, FELT[6]) c:put(23, 20, FELT[6]) c:put(21, 22, FELT[5])

  -- ===== band: grosgrain red ribbon with ribs
  local nbd = W.mixN(W.vcylN(band, 17, 43, 0), W.hcylN(band, 31, 38), 0.7)
  local rb = {}
  band:each(function(x, y) if x % 2 == 0 then W.addBias(rb, x, y, -1) end end)
  band:each(function(x, y) if not band:has(x, y - 1) then W.addBias(rb, x, y, 1) end if not band:has(x, y + 1) then W.addBias(rb, x, y, -1) end end)
  W.lit(c, band, nbd, RED, { bias = rb, amb = 0.12 })
  for x = 18, 42 do for y = 36, 41 do
    if band:has(x, y) and not band:has(x, y + 1) and crown:has(x, y + 1) then W.step(c, x, y + 1, FELT, -2) end
  end end

  -- ===== feather: curved vane, quill, barbs, a notch
  local fm, fn, FT, FS = W.tube({ { 38, 37 }, { 42, 28 }, { 47, 17 }, { 52, 8 } }, function(t)
    if t < 0.1 then return 1.0 end
    return 1.2 + 2.2 * math.sin(math.pi * min(1, (t - 0.05) * 1.0)) ^ 0.6
  end)
  fm:cut(c:rect(50, 15, 53, 16))
  local fb = {}
  fm:each(function(x, y)
    local k = K(x, y)
    local s, t = FS[k], FT[k]
    if s > 0 then W.addBias(fb, x, y, -1) end
    if ((t * 32 + abs(s) * 2.6) % 3) < 1 and abs(s) > 0.3 then W.addBias(fb, x, y, -1) end
  end)
  W.lit(c, fm, fn, BLUE, { bias = fb, amb = 0.15, wrap = 0.3 })
  fm:each(function(x, y)
    local k = K(x, y)
    if abs(FS[k]) < 0.22 and FT[k] > 0.08 and FT[k] < 0.92 then c:put(x, y, FT[k] < 0.5 and "#e6f4fb" or BLUE[5]) end
  end)
  W.paint(c, 37, 34, { "ab", "bc" }, { a = RED[4], b = RED[3], c = RED[2] })
  for _, p in ipairs{ { 36, 30 }, { 37, 29 }, { 37, 28 }, { 38, 27 } } do if crown:has(p[1], p[2]) and not fm:has(p[1], p[2]) then W.step(c, p[1], p[2], FELT, -1) end end

  -- ===== ribbon bow on the left of the band: two loops with fold holes, a knot, swallowtail tails
  local BOW = {
    ".kkk......kkk.",
    "k6554kkkkk443k",
    "k5421k565k123k",
    "k5311k453k112k",
    "k4333k342k222k",
    ".k222k232k21k.",
    "..kkk.k43k2k..",
    "....k543k21k..",
    "....k43k.k21k.",
    "...k53k...k21k",
    "...k42k...k21k",
    "...k3k.....k1k",
    "....k.......k.",
  }
  W.paint(c, 13, 30, BOW, { k = W.INK, ["1"] = RED[1], ["2"] = RED[2], ["3"] = RED[3], ["4"] = RED[4], ["5"] = RED[5], ["6"] = RED[6] })
  local bow = HP.mask()
  for j, row in ipairs(BOW) do for i = 1, #row do if row:sub(i, i) ~= "." then bow:set(13 + i - 1, 30 + j - 1) end end end
  -- the bow casts a little shade onto the brim and crown
  bow:shift(1, 1):cut(bow):each(function(x, y) W.step(c, x, y, FELT, -1) end)
  -- ===== rim light + bounce on the free contours
  W.rimb(c, crown, FELT, { bounce = false })
  W.rimb(c, rim, FELT, { rim = false, bounceTo = 2 })
  W.rimb(c, top, FELT, { bounce = false, rimMax = 6 })
  W.rimb(c, fm, BLUE, { rimMax = 6 })

  if rank == "common" then
    -- quirk: a ladybird out for a walk on the brim, head to the left
    W.paint(c, 7, 40, {
      "...kkkk..",
      "..kqrrrk.",
      ".kkrkrrrk",
      "kekdddddk",
      ".kkrrrkrk",
      "..krrrrk.",
      "...kkkk..",
    }, { k = W.INK, r = "#e04838", q = "#ffb08a", d = "#962a36", e = "#f2e6c8" })
    c:put(9, 39, W.INK) c:put(9, 47, W.INK)   -- antennae / legs
  elseif rank == "lined" then
    -- cream fleece turned out round the whole brim edge: under the front lip (2-3 px, lumpy)
    local fl = rim:copy():add(rim:shift(0, 1))
    local lumps = HP.mask()
    fl:each(function(x, y) if not fl:has(x, y + 1) and (x % 4 ~= 3) then lumps:set(x, y + 1) end end)
    fl:add(lumps)
    W.fleece(c, fl, 31)
    -- and peeking over the far edge of the brim on both sides of the crown
    local far = HP.mask()
    top:each(function(x, y) if not top:has(x, y - 1) and not hatTop:has(x, y) and not bow:has(x, y) then far:set(x, y) far:set(x, y - 1) end end)
    far:cut(hatTop):cut(bow):cut(fm)
    W.fleece(c, far, 5, { bias = 1 })
    top:each(function(x, y) if fl:has(x, y + 1) then W.step(c, x, y, FELT, -1) end end)
    -- fleece sweatband rolled out under the band on the lit side
    for x = 26, 36 do c:put(x, band:has(x, 38) and 39 or 38, (x % 3 == 0) and W.FLEECE[4] or W.FLEECE[6]) end
    -- quirk: a fat fleece tuft snagged on the feather's vane, a wisp trailing off it
    W.paint(c, 44, 18, {
      ".aab.",
      "abbcd",
      "bccdd",
      ".ddd.",
    }, { a = W.FLEECE[6], b = W.FLEECE[5], c = W.FLEECE[4], d = W.FLEECE[2] })
    c:put(49, 20, W.FLEECE[5]) c:put(50, 21, W.FLEECE[4])
    c:put(43, 19, W.INK) c:put(43, 20, W.INK) c:put(44, 21, W.INK) c:put(45, 22, W.INK) c:put(46, 22, W.INK) c:put(47, 22, W.INK) c:put(48, 21, W.INK)
  elseif rank == "fine" then
    local Gd = W.GOLD
    -- gold braid bound round the brim edge: twisted cord, darker on the shade side
    rim:each(function(x, y)
      if not rim:has(x, y - 1) or not rim:has(x, y - 2) then
        local tw = (x + y) % 3
        c:put(x, y, ({ Gd[5], Gd[4], Gd[3] })[tw + 1])
        if x > 42 then W.step(c, x, y, Gd, -1) end
      end
    end)
    -- gold edging along the band's top and bottom
    band:each(function(x, y)
      if x > 22 and (not band:has(x, y - 1)) then c:put(x, y, (x < 34) and Gd[5] or Gd[4]) end
      if x > 22 and (not band:has(x, y + 1)) then c:put(x, y, (x < 34) and Gd[3] or Gd[2]) end
    end)
    -- three embroidered gold diamonds on the band (calmer than a zig-zag)
    for _, x in ipairs{ 27, 32 } do
      W.paint(c, x - 1, 33, { ".a.", "abc", ".c." }, { a = Gd[6], b = Gd[4], c = Gd[2] })
    end
    -- gold ring slid over the bow knot and gold aglets on the tail tips
    W.paint(c, 19, 31, {
      "aba",
      "b.c",
      "a.d",
      "cdd",
    }, { a = Gd[5], b = Gd[6], c = Gd[3], d = Gd[2] })
    c:put(20, 32, RED[3]) c:put(20, 33, RED[2])
    for _, p in ipairs{ { 17, 40 }, { 17, 41 }, { 25, 40 }, { 25, 41 } } do c:put(p[1], p[2], (p[2] == 40) and Gd[5] or Gd[3]) end
    -- gold clasp pinning the feather to the band
    W.paint(c, 36, 32, {
      ".ab.",
      "abcd",
      "bcdd",
      ".dd.",
    }, { a = Gd[6], b = Gd[5], c = Gd[4], d = Gd[3] })
    -- gleam: a cream four-point star off the clasp
    c:put(35, 30, "#fff6dc") c:put(34, 30, Gd[6]) c:put(36, 30, Gd[6]) c:put(35, 29, Gd[6]) c:put(35, 28, Gd[5])
    -- quirk: a tiny gold acorn charm hangs from the ring knot on a gold chain
    c:put(20, 35, Gd[4]) c:put(20, 36, Gd[3]) c:put(20, 37, Gd[4])
    W.paint(c, 18, 38, {
      ".aab.",
      "abbcd",
      ".eef.",
      ".eef.",
      "..f..",
    }, { a = Gd[5], b = Gd[4], c = Gd[3], d = Gd[2], e = Gd[5], f = Gd[3] })
  end
  return c
end
