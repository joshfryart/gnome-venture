-- cf_yi_show2.lua : Yarn panel icon `show2` (Second show entry: enter two cats, the better result wins).
-- 64x64 gvlib "icon" mode, house look of cf_icons.lua (helpers copied). Two teal rosettes side by side, the
-- front one with a cream cat-head button; a pink yarn strand ties their tails together (yarn accent).
-- Run: AppRun -b --script cf_yi_show2.lua      Writes out/cf-yi-show2.png + .aseprite.
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../gvlib/gvlib.lua")
local OUT = here .. "/out/"
local C = GV.C

local function felt(hex, ov)
  local r = GV.ramp(hex)
  local n = {} for k, v in pairs(r) do n[k] = v end
  for k, v in pairs(ov or {}) do n[k] = v end
  n.deep, n.bounce = (ov or {}).deep or n.shade, (ov or {}).bounce or n.base
  return n
end
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

local TEAL = felt("#1fa58c", { gloss = "#d4f6d8", dot = "#d4f6d8", rim = "#62cfae", shade = "#1a6a70" })
local GOLD = { gloss = "#fff1c8", dot = "#fff1c8", rim = "#f5cf6a", base = "#e8a317", shade = "#b8661a" }
GOLD.deep, GOLD.bounce = GOLD.shade, GOLD.base
local PINK = felt("#e46a9b", { gloss = "#ffc8dc", dot = "#ffc8dc", rim = "#f29abb" })
local CREAM = felt("#e8d0a0", { gloss = "#fff3c8", dot = "#fff3c8", rim = "#fff0c8", shade = "#c49a60" })

local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- rosette masks: pleat disc with n scallops
local function pleats(cx, cy, R, n)
  local m = c:ellipse(cx, cy, R)
  for i = 0, n - 1 do
    local a = (i + 0.5) * 2 * math.pi / n
    m:add(c:ellipse(cx + math.cos(a) * R, cy + math.sin(a) * R, 2))
  end
  return m
end
local function tail(x0, y0, x1, y1, w)
  local m = c:line({ { x0, y0 }, { x1, y1 } }, w)
  m:cut(c:poly({ { x1 - w, y1 + 4 }, { x1, y1 - 2 }, { x1 + w, y1 + 4 } }))
  return m
end

local A = { x = 19, y = 19, R = 11 }       -- back rosette (upper left)
local B = { x = 41, y = 24, R = 13 }       -- front rosette (right)
local outA, outB = pleats(A.x, A.y, A.R, 14), pleats(B.x, B.y, B.R, 16)
local inA, inB = c:ellipse(A.x, A.y, 7), c:ellipse(B.x, B.y, 9)
local btnA = c:ellipse(A.x, A.y, 4)
-- cat head button on B: round cream face plus two ears
local head = c:ellipse(B.x, B.y + 1, 6, 5)
head:add(c:poly({ { B.x - 6, B.y + 1 }, { B.x - 6, B.y - 7 }, { B.x - 1, B.y - 3 } }))
head:add(c:poly({ { B.x + 2, B.y - 3 }, { B.x + 7, B.y - 7 }, { B.x + 7, B.y + 1 } }))
-- the two inner tails cross and are tied with a pink yarn bow (both entries go in together)
local KX, KY = 30, 42
local loopL = c:poly({ { KX, KY }, { KX - 8, KY - 4 }, { KX - 8, KY + 4 } }):grow(1)
local loopR = c:poly({ { KX + 1, KY }, { KX + 9, KY - 4 }, { KX + 9, KY + 4 } }):grow(1)
local knot = c:ellipse(KX + 0.5, KY, 3)

local p = c:build{
  { "tA1", tail(A.x - 2, A.y + 2, 12, 46, 5), TEAL, { cres = 2, gloss = false } },
  { "tA2", tail(A.x + 2, A.y + 2, 36, 51, 5), TEAL, { cres = 2, gloss = false } },
  { "outA", outA, TEAL, { cres = 4, gloss = { A.x - A.R + 3, A.y - A.R + 5 } } },
  { "inA", inA, TEAL, { cres = 3, gloss = false } },
  { "btnA", btnA, GOLD, { cres = 2, gloss = false } },
  { "tB2", tail(B.x + 3, B.y + 2, 50, 50, 5), TEAL, { cres = 2, gloss = false } },
  { "tB1", tail(B.x - 3, B.y + 4, 24, 52, 5), TEAL, { cres = 2, gloss = false } },
  { "outB", outB, TEAL, { cres = 4, gloss = { B.x - B.R + 3, B.y - B.R + 5 } } },
  { "inB", inB, TEAL, { cres = 3, gloss = false } },
  { "head", head, CREAM, { cres = 2, gloss = false } },
  { "loopL", loopL, PINK, { cres = 2, gloss = false } },
  { "loopR", loopR, PINK, { cres = 2, gloss = false } },
  { "knot", knot, PINK, { cres = 2, gloss = false } },
}

-- pleat folds: radial 1 px shade lines
local function folds(P, cx, cy, r0, r1, off, k)
  for i = 0, k - 1 do
    local a = (i + off) * 2 * math.pi / k
    for r = r0, r1, 0.5 do
      local x, y = math.floor(cx + math.cos(a) * r + 0.5), math.floor(cy + math.sin(a) * r + 0.5)
      local kk = c:key(x, y)
      if c.own[kk] == P and not c.gl.s[kk] then c:px(x, y, P.r.shade) end
    end
  end
end
folds(p.outA, A.x, A.y, 9, A.R + 1, 0.5, 14)
folds(p.outB, B.x, B.y, 11, B.R + 1, 0.5, 16)
folds(p.inA, A.x, A.y, 5, 6, 0, 10)
c:stitch(inA)
-- button A: two thread holes
c:px(A.x - 1, A.y - 1, C.hole); c:px(A.x + 1, A.y + 1, C.hole)
c:px(A.x - 2, A.y - 3, GOLD.gloss)
-- cat face: inner ears, 2x2 eyes with a glint, pink nose, mouth
c:paint({ "p", "p" }, B.x - 5, B.y - 5, { p = PINK.base }); c:paint({ "p", "p" }, B.x + 6, B.y - 5, { p = PINK.base })
c:paint({ "gu....gu", "uu....uu" }, B.x - 3, B.y, { u = "ol3", g = CREAM.gloss })
c:paint({ "pp" }, B.x, B.y + 2, { p = PINK.shade })
c:paint({ "u..u", ".uu." }, B.x - 1, B.y + 3, { u = "ol2" })
-- yarn bow: ply lines on the loops, glint on the knot
onPart(c, c:line({ { KX - 7, KY - 2 }, { KX - 3, KY } }, 1), p.loopL, PINK.shade, true)
onPart(c, c:line({ { KX + 4, KY }, { KX + 8, KY - 2 } }, 1), p.loopR, PINK.shade, true)
c:px(KX - 1, KY - 2, PINK.gloss); c:px(KX - 7, KY - 4, PINK.gloss); c:px(KX + 3, KY - 4, PINK.gloss)

local t = c:save(OUT .. "cf-yi-show2.aseprite", OUT .. "cf-yi-show2.png")
print("show2 " .. GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.colours <= 22 and t.bw == 0, "check failed")
