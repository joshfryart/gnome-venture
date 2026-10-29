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

local TEAL = felt("#2a9d9a", { gloss = "#d0f4dc", dot = "#d0f4dc", rim = "#6ccab4", shade = "#1f6478" })
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

local A = { x = 19, y = 20, R = 11 }       -- back rosette (upper left)
local B = { x = 41, y = 26, R = 13 }       -- front rosette (lower right)
local outA, outB = pleats(A.x, A.y, A.R, 14), pleats(B.x, B.y, B.R, 16)
local inA, inB = c:ellipse(A.x, A.y, 7), c:ellipse(B.x, B.y, 8)
local btnA = c:ellipse(A.x, A.y, 4)
-- cat head button on B: round face plus two ears
local head = c:ellipse(B.x, B.y + 1, 5.5, 4.5)
head:add(c:poly({ { B.x - 6, B.y + 1 }, { B.x - 5, B.y - 6 }, { B.x - 1, B.y - 3 } }))
head:add(c:poly({ { B.x + 2, B.y - 3 }, { B.x + 6, B.y - 6 }, { B.x + 7, B.y + 1 } }))
-- yarn strand: pink cord looping between the two tail pairs, with a knot in the middle
local yarn = c:line({ { 13, 44 }, { 20, 49 }, { 27, 49 }, { 31, 46 } }, 3)
yarn:add(c:line({ { 31, 46 }, { 36, 49 }, { 43, 50 }, { 49, 46 } }, 3))
local knot = c:ellipse(31, 46, 3.5)
local loose = c:line({ { 31, 49 }, { 29, 54 }, { 32, 57 } }, 2)

local p = c:build{
  { "tA1", tail(A.x - 2, A.y + 2, 12, 47, 5), TEAL, { cres = 2, gloss = false } },
  { "tA2", tail(A.x + 2, A.y + 2, 24, 49, 5), TEAL, { cres = 2, gloss = false } },
  { "outA", outA, TEAL, { cres = 4, gloss = { A.x - A.R + 3, A.y - A.R + 5 } } },
  { "inA", inA, TEAL, { cres = 3, gloss = false } },
  { "btnA", btnA, GOLD, { cres = 2, gloss = false } },
  { "tB1", tail(B.x - 2, B.y + 2, 37, 54, 5), TEAL, { cres = 2, gloss = false } },
  { "tB2", tail(B.x + 3, B.y + 2, 50, 52, 5), TEAL, { cres = 2, gloss = false } },
  { "outB", outB, TEAL, { cres = 4, gloss = { B.x - B.R + 3, B.y - B.R + 5 } } },
  { "inB", inB, GOLD, { cres = 3, gloss = false } },
  { "head", head, CREAM, { cres = 2, gloss = false } },
  { "yarn", yarn, PINK, { cres = 1, deep = 0, gloss = false } },
  { "loose", loose, PINK, { flat = true, contact = false } },
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
folds(p.outB, B.x, B.y, 10, B.R + 1, 0.5, 16)
folds(p.inA, A.x, A.y, 5, 6, 0, 10)
c:stitch(inA)
c:seam({ { B.x - 7, B.y + 3 }, { B.x - 6, B.y + 6 }, { B.x - 3, B.y + 8 }, { B.x + 3, B.y + 8 }, { B.x + 6, B.y + 6 } },
  { gap = GOLD.shade })
-- button A: two thread holes
c:px(A.x - 1, A.y - 1, C.hole); c:px(A.x + 1, A.y + 1, C.hole)
c:px(A.x - 2, A.y - 3, GOLD.gloss)
-- cat face: inner ears, small eyes, nose
c:px(B.x - 4, B.y - 3, PINK.base); c:px(B.x + 5, B.y - 3, PINK.base)
c:paint({ "u....u" }, B.x - 2, B.y, { u = "ol3" })
c:paint({ "u....u" }, B.x - 2, B.y + 1, { u = "ol3" })
c:px(B.x - 2, B.y, CREAM.gloss); c:px(B.x + 3, B.y, CREAM.gloss)
c:paint({ "pp", ".." }, B.x, B.y + 2, { p = PINK.shade })
c:paint({ "u..u", ".uu." }, B.x - 1, B.y + 3, { u = "ol2" })
-- yarn twist lines
for _, q in ipairs({ { 16, 46 }, { 22, 49 }, { 39, 50 }, { 45, 49 } }) do
  onPart(c, c:rect(q[1], q[2] - 1, q[1], q[2] + 1), p.yarn, PINK.shade)
end
c:px(30, 44, PINK.gloss); c:px(29, 45, PINK.gloss)

local t = c:save(OUT .. "cf-yi-show2.aseprite", OUT .. "cf-yi-show2.png")
print("show2 " .. GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.colours <= 22 and t.bw == 0, "check failed")
