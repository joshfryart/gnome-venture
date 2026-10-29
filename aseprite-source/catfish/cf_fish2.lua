-- cf_fish2.lua : Cat Fish step 4 (claude/catfish-art-brief.md): plushie fish 2..5, 48x48 stickers, Stitched Toy.
-- Run: AppRun -b --script cf_fish2.lua       Writes test/cf-fish-<2..5>.png + .aseprite.
-- Same body language as cf-fish-1 (cf_test.lua): felt ramps (rim, base, one crescent shade, gloss comma), a
-- light belly panel or patch joined by a gold seam, a gill seam, the locked eye at the front, an umber mouth,
-- facing left. Each kind changes silhouette AND colour so the five tell apart at 16 px:
--   1 plain     orange, plain oval, fan tail                              (cf_test.lua)
--   2 silk-tail rose, small body, two long ribbon tails and a ribbon fin trailing down-right; silk sheen is
--               1 px light bands running along each ribbon
--   3 catnip    green, chubby round body, short round tail, a pale leaf patch blanket-stitched on the side
--               and a catnip sprig (stem + 3 leaves) sewn into the back seam, standing up
--   4 glitter   blue/violet, long slim body, swallow tail with long points, spiky dorsal; 1 px scale arcs in
--               a staggered grid and three big diamond sparkles (pass 7)
--   5 golden    rare: gold, deep body, 3-point crown dorsal with gloss beads on the tips, lyre tail with
--               crown points, a second gloss streak, pale-gold thread (brighter than the body), a tiny
--               ruby button at the head of the tail seam
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../gvlib/gvlib.lua")
local OUT = here .. "/test/"

-- felt(hex): gvlib ramp with deep = shade and bounce = base (cf_test.lua props: 4 felt steps)
local function felt(hex, ov)
  local r = GV.ramp(hex)
  local n = {} for k, v in pairs(r) do n[k] = v end
  n.deep, n.bounce = n.shade, n.base
  for k, v in pairs(ov or {}) do n[k] = v end
  return n
end
local function tint(c, m, from, to) m:each(function(x, y) if c:get(x, y) == from then c:px(x, y, to) end end) end
-- tapered ribbon: polyline whose pen narrows from w0 to w1 (each segment a c:line, unioned)
local function ribbon(c, pts, w0, w1)
  local m = c:mask()
  local n = #pts - 1
  for i = 1, n do
    local w = math.floor(w0 + (w1 - w0) * (i - 1) / math.max(1, n - 1) + 0.5)
    m:add(c:line({ pts[i], pts[i + 1] }, w))
  end
  return m
end
-- paint pixels of polyline pts (1 px, rounded) with hex, only where the pixel is currently one of `on`
local function trace(c, pts, hex, on, skip)
  local seen = {}
  local n = 0
  for i = 1, #pts - 1 do
    local x0, y0, x1, y1 = pts[i][1], pts[i][2], pts[i + 1][1], pts[i + 1][2]
    local s = math.max(1, math.ceil(math.max(math.abs(x1 - x0), math.abs(y1 - y0))))
    for t = 0, s do
      local x, y = math.floor(x0 + (x1 - x0) * t / s + 0.5), math.floor(y0 + (y1 - y0) * t / s + 0.5)
      local k = y * 100 + x
      if not seen[k] then
        seen[k] = true; n = n + 1
        if on[c:get(x, y) or ""] and not (skip and skip(n)) then c:px(x, y, hex) end
      end
    end
  end
end
local function set(...) local s = {} for _, v in ipairs({ ... }) do s[v] = true end return s end
local FAILS = {}
local function save(c, name)
  local t = c:save(OUT .. name .. ".aseprite", OUT .. name .. ".png")
  print(string.format("%-9s ", name:sub(4)) .. GV.report(t))
  if not (t.semi == 0 and t.margin >= 3 and t.colours <= 24) then FAILS[#FAILS + 1] = name end
  return t
end

-- ===== 2 silk-tail: small rose body, long ribbon tails flowing down-right =====
do
  local c = GV.canvas{ w = 48, h = 48, mode = "sticker" }
  local f = felt("#d2507e", { gloss = "#ffb8c8", dot = "#fff0f0", rim = "#ec86a6" })
  local silk = felt("#e9a0c4", { gloss = "#fff0f4", rim = "#fbd2e2" })
  local body = c:ellipse(17, 21, 11, 8)
  local rA = ribbon(c, { {25, 22}, {31, 21}, {35, 24}, {37, 29}, {35, 34}, {36, 38} }, 6, 3)  -- main ribbon, S down
  local rB = ribbon(c, { {25, 18}, {30, 14}, {35, 13}, {39, 15} }, 4, 3)                     -- streamer, up and back
  local dors = c:poly({ {10, 15}, {15, 9}, {22, 9}, {27, 13}, {25, 15} })
  local pelv = c:poly({ {13, 27}, {19, 27}, {17, 34}, {15, 31} })
  local p = c:build{
    { "rA", rA, silk, { cres = 2, gloss = false } },
    { "rB", rB, silk, { cres = 2, gloss = false } },
    { "dors", dors, silk, { cres = 2, gloss = false } },
    { "pelv", pelv, silk, { cres = 2, gloss = false } },
    { "body", body, f, { gloss = false } },
  }
  -- silk sheen: 1 px light bands along each ribbon on its lit side, broken every 5th px so they read as
  -- satin highlights, not an outline
  local on = set(silk.base, silk.rim)
  local brk = function(n) return n % 5 == 0 end
  trace(c, { {28, 20}, {32, 20}, {35, 22}, {36, 26} }, silk.gloss, on, brk)
  trace(c, { {35, 31}, {34, 34}, {35, 37} }, silk.gloss, on, brk)
  trace(c, { {29, 14}, {33, 12}, {37, 13} }, silk.gloss, on, brk)
  trace(c, { {14, 11}, {18, 10}, {22, 10} }, silk.gloss, on, brk)
  tint(c, c:ellipse(16, 27, 8, 2):clip(body), f.base, f.rim)                              -- belly panel
  c:seam({ { 8, 25 }, { 12, 27 }, { 18, 28 }, { 23, 27 } }, { gap = f.shade })
  c:seam({ { 11, 15 }, { 13, 18 }, { 13, 22 }, { 12, 26 } }, { gap = f.shade })           -- gill seam
  c:seam({ { 26, 18 }, { 27, 22 }, { 26, 25 } }, { gap = f.shade })                       -- tail panel seam
  c:paint({ "...ggdd", "..gddd.", ".gdd...", "gdd....", "gd....." }, 14, 15, { g = f.gloss, d = f.dot }) -- enamel comma, 2 px thick
  c:eye(8, 18)
  c:paint({ "uu", "u." }, 7, 25, { u = "ol2" })
  save(c, "cf-fish-2")
end

-- ===== 3 catnip: chubby green, leaf patch, catnip sprig sewn into the back =====
do
  local c = GV.canvas{ w = 48, h = 48, mode = "sticker" }
  local f = felt("#4f9a5a", { gloss = "#c8e89a", dot = "#eef8c8", rim = "#86c070" })
  local fin = felt("#2f7a52", { gloss = "#9ad0a0", rim = "#5aa070" })
  local patch = felt("#c4dc6a", { gloss = "#f4f8c8", rim = "#e4f09a" })
  local leaf = felt("#7cc04a", { gloss = "#e0f4a0", rim = "#a8dc6a" })
  local body = c:ellipse(20, 28, 13, 10.5)
  local tail = c:ellipse(35, 28, 5, 7):add(c:poly({ {30, 26}, {34, 24}, {34, 33}, {30, 31} }))
  local stem = c:line({ {22, 18}, {23, 14}, {24, 11} }, 2)
  local lf1 = c:poly({ {23, 14}, {16, 11}, {14, 15}, {19, 17} })                          -- left leaf
  local lf2 = c:poly({ {24, 13}, {30, 8}, {33, 11}, {27, 16} })                           -- right leaf
  local lf3 = c:ellipse(24.5, 9, 2, 2.5)                                                  -- bud on top
  local p = c:build{
    { "tail", tail, fin, { cres = 2, gloss = false } },
    { "stem", stem, leaf, { flat = true } },
    { "lf1", lf1, leaf, { cres = 2, gloss = false } },
    { "lf2", lf2, leaf, { cres = 2, gloss = false } },
    { "lf3", lf3, leaf, { flat = true } },
    { "body", body, f, { gloss = false } },
  }
  -- leaf patch sewn on the flank: a pale felt leaf, edge-stitched in gold, with a stitched midrib
  local pm = c:poly({ {17, 33}, {21, 26}, {28, 23}, {32, 25}, {29, 31}, {22, 35} })
  c:part(pm, patch, { cres = 2, gloss = false, contour = false, contact = false })
  local ring = pm:shrink(1):edge()
  local i = 0
  local pts = {}
  ring:each(function(x, y) pts[#pts + 1] = { x, y, math.atan(y - 29, x - 24) } end)
  table.sort(pts, function(a, b) return a[3] < b[3] end)
  for _, q in ipairs(pts) do i = i + 1; if i % 3 ~= 0 then c:px(q[1], q[2], GV.C.goldS) end end
  trace(c, { {20, 32}, {24, 29}, {29, 26} }, patch.shade, set(patch.base, patch.rim, patch.shade, GV.C.goldS))
  c:paint({ "s..", ".s.", "..s" }, 18, 11, { s = leaf.shade })                             -- leaf veins
  c:paint({ "..s", ".s.", "s.." }, 27, 10, { s = leaf.shade })
  c:paint({ "s", ".", "s" }, 35, 25, { s = fin.shade }); c:paint({ "s", ".", "s" }, 37, 27, { s = fin.shade })
  tint(c, c:ellipse(18, 36, 9, 2):clip(body), f.base, f.rim)                              -- belly panel
  c:seam({ { 9, 34 }, { 13, 37 }, { 19, 38 }, { 25, 37 } }, { gap = f.shade })
  c:seam({ { 12, 20 }, { 16, 18 }, { 21, 17 }, { 26, 18 }, { 30, 21 } }, { gap = f.shade }) -- back seam (sprig sewn in)
  c:seam({ { 12, 23 }, { 14, 26 }, { 14, 30 }, { 13, 34 } }, { gap = f.shade })          -- gill seam
  c:paint({ "...ggdd", "..gddd.", ".gdd...", "gdd....", "gd.....", "g......" }, 13, 20, { g = f.gloss, d = f.dot }) -- enamel comma, 2 px thick
  c:eye(8, 24)
  c:paint({ "uu", "u." }, 8, 32, { u = "ol2" })
  save(c, "cf-fish-3")
end

-- ===== 4 glitter: slim blue/violet, swallow tail, sparkle scales =====
do
  local c = GV.canvas{ w = 48, h = 48, mode = "sticker" }
  local f = felt("#4a5fc8", { gloss = "#b8c8ff", dot = "#eef2ff", rim = "#7c90e8" })
  local fin = felt("#8a5ad0", { gloss = "#e0c8ff", rim = "#b48ce8" })
  local body = c:ellipse(21, 24, 14, 7):add(c:poly({ {6, 24}, {10, 20}, {10, 28} }))
  local tail = c:poly({ {33, 24}, {41, 13}, {39, 22}, {37, 24}, {39, 26}, {41, 35} }):grow(0)
  local dors = c:poly({ {12, 18}, {14, 12}, {17, 16}, {20, 11}, {23, 16}, {26, 12}, {28, 18} })
  local pelv = c:poly({ {17, 29}, {22, 29}, {19, 35} })
  local p = c:build{
    { "tail", tail, fin, { cres = 2, gloss = false } },
    { "dors", dors, fin, { cres = 2, gloss = false } },
    { "pelv", pelv, fin, { cres = 2, gloss = false } },
    { "body", body, f, { gloss = false } },
  }
  -- scale arcs: 1 px shade "v" marks on a staggered grid over the back half of the body (felt only).
  -- Pass 7: the 1 px lattice dots and small glints were lost at 16 px; now three big sparkles instead: two
  -- 5 x 5 diamond stars (solid 3 x 3 core) and one 3 x 3 plus, all on the lit felt, plus fin-tip glints.
  local felt_ = set(f.base, f.rim, f.shade)
  local inner = body:shrink(2)
  local skip = c:mask()
  for _, g in ipairs({ { 23, 21, 3 }, { 31, 25, 2 }, { 17, 26, 2 } }) do skip:add(c:ellipse(g[1], g[2], g[3] + 1)) end
  for row = 0, 2 do
    local y = 20 + row * 3
    for col = 0, 3 do
      local x = 18 + col * 5 + (row % 2) * 2
      if inner:has(x, y) and inner:has(x + 2, y + 1) and not skip:has(x + 1, y) and c:get(x, y) and felt_[c:get(x, y)] then
        local s = c:get(x + 1, y + 1) == f.shade and f.deep or f.shade
        c:px(x, y, s); c:px(x + 1, y + 1, s); c:px(x + 2, y, s)
      end
    end
  end
  c:paint({ "..d..", ".ddd.", "ddwdd", ".ddd.", "..d.." }, 21, 19, { d = f.dot, w = "#fbfcff" })   -- big star
  c:paint({ ".d.", "dwd", ".d." }, 30, 24, { d = f.dot, w = "#fbfcff" })                         -- small star
  c:paint({ ".d.", "ddd", ".d." }, 16, 25, { d = f.dot })
  c:paint({ "dd", "d." }, 38, 15, { d = fin.gloss }); c:paint({ "d.", "dd" }, 38, 31, { d = fin.gloss })
  tint(c, c:ellipse(19, 29, 10, 1.5):clip(body), f.base, f.rim)                           -- belly panel
  c:seam({ { 8, 27 }, { 13, 29 }, { 20, 30 }, { 27, 29 } }, { gap = f.shade })
  c:seam({ { 13, 19 }, { 14, 22 }, { 14, 26 }, { 13, 28 } }, { gap = f.shade })          -- gill seam
  c:paint({ "...ggd", ".ggdd.", "gdd..." }, 14, 18, { g = f.gloss, d = f.dot })           -- enamel comma, 2 px thick
  c:eye(8, 21)
  c:paint({ "uu" }, 7, 26, { u = "ol2" })
  save(c, "cf-fish-4")
end

-- ===== 5 golden: rare, deep gold body, crown dorsal, lyre tail, extra gloss, bright thread, ruby button =====
do
  local c = GV.canvas{ w = 48, h = 48, mode = "sticker" }
  local f = felt("#f0b72a", { gloss = "#fff4c0", dot = "#fffbe8", rim = "#ffd860", shade = "#c47a1a" })
  f.pale = false
  local fin = felt("#e8961a", { gloss = "#ffe8a0", rim = "#ffc050", shade = "#b05a14" })
  local body = c:ellipse(19, 27, 12, 10)
  local crown = c:poly({ {11, 21}, {12, 12}, {16, 17}, {19, 9}, {22, 17}, {26, 12}, {28, 21} })
  local tail = c:poly({ {29, 27}, {40, 15}, {38, 22}, {35, 27}, {38, 32}, {40, 39} })
  local p = c:build{
    { "tail", tail, fin, { cres = 2, gloss = false } },
    { "crown", crown, fin, { cres = 2, gloss = false } },
    { "body", body, f, { gloss = false } },
  }
  -- crown tips: a gloss bead on each point, like the balls on a crown
  for _, q in ipairs({ { 12, 12 }, { 19, 9 }, { 26, 12 } }) do
    c:paint({ ".g.", "gdg" }, q[1] - 1, q[2] - 1, { g = fin.gloss, d = "#fff8e0" })
  end
  c:paint({ "gg", "g." }, 39, 15, { g = fin.gloss }); c:paint({ "g.", "gg" }, 39, 37, { g = fin.gloss })
  local TH, THS = "#fff6d0", f.shade                                                       -- bright thread
  local function seam(pts) c:seam(pts, { gap = THS }); trace(c, pts, TH, set(GV.C.gold, GV.C.goldS)) end
  tint(c, c:ellipse(18, 34, 9, 2.5):clip(body), f.base, f.rim)                            -- belly panel
  seam({ { 9, 32 }, { 13, 35 }, { 19, 36 }, { 25, 35 } })
  seam({ { 12, 20 }, { 14, 24 }, { 14, 29 }, { 13, 33 } })                                 -- gill seam
  seam({ { 29, 24 }, { 30, 28 }, { 28, 32 } })                                             -- tail panel seam
  c:paint({ "...ggddd", "..gddd..", ".gdd....", "gdd.....", "gd......" }, 15, 20, { g = f.gloss, d = f.dot })
  c:paint({ "d.", "gd", ".g" }, 25, 23, { g = f.gloss, d = f.dot })                       -- second gloss streak
  -- tiny ruby button (4x4 cut corners) at the head of the tail seam
  c:paint({ ".rr.", "rhrs", "rsrs", ".ss." }, 27, 20, { r = "#d8384a", s = "#8a1a30", h = "#ffd0c0" })
  c:eye(8, 23)
  c:paint({ "uu", "u." }, 8, 31, { u = "ol2" })
  save(c, "cf-fish-5")
end

assert(#FAILS == 0, "check failed: " .. table.concat(FAILS, " "))
