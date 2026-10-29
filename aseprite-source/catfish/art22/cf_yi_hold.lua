-- cf_yi_hold.lua : Cat Fish Yarn panel icon `hold` (Hold for tomorrow, 2 Yarn, one hold a day: today's shelter
-- cat comes back to the same spot tomorrow). 64x64 gvlib "icon" mode, house look of cf_icons.lua (cf-up-*).
-- Picture: two cupped peach felt hands cradling a small grey sleeping cat (cf-cat-grey-nap colours), its tail
-- tip curled over the right hand; a red yarn thread loops up from the left thumb (the Yarn panel's shared motif).
-- Run: AppRun -b --script cf_yi_hold.lua     Writes art22/out/cf-yi-hold.png + .aseprite.
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
local function rell(c, cx, cy, rx, ry, a)
  local m, ca, sa, R = c:mask(), math.cos(a), math.sin(a), math.max(rx, ry) + 1
  for y = math.floor(cy - R), math.ceil(cy + R) do
    for x = math.floor(cx - R), math.ceil(cx + R) do
      local dx, dy = x - cx, y - cy
      local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
      if (u / rx) ^ 2 + (v / ry) ^ 2 <= 1 then m:set(x, y) end
    end
  end
  return m
end
local function onPart(c, m, P, hex, litOnly)
  m:each(function(x, y)
    local k = c:key(x, y)
    if c.own[k] == P and not c.gl.s[k] and not (litOnly and c.shd[k]) then c:px(x, y, hex) end
  end)
end

local SKIN = felt("#e9b98a", { gloss = "#ffe2a8", dot = "#fff4d8", rim = "#f9d49c", shade = "#c47a52" })
local GREY = felt("#a6a1b6", { gloss = "#f1ebe3", dot = "#f1ebe3", rim = "#cdc9d3", shade = "#7a7490" })
local RED = felt("#dd3a2a", { gloss = "#ff9158", dot = "#ff9158", rim = "#f2793a", shade = "#ae2a2a" })
local PINKN = "#e8909e"

local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- cat: loaf body, round head left, two ears, tail tip curling down over the right fingers
local body = c:ellipse(37, 29, 14, 8)
local head = c:ellipse(24, 25, 10, 8.5)
local earL = c:poly({ {15, 22}, {16, 11}, {23, 18} })
local earR = c:poly({ {25, 17}, {32, 13}, {33, 22} })
local tail = c:line({ {47, 35}, {51, 31}, {51, 26} }, 4)
-- hands: palms under the cat, four stubby fingers each forming the front wall (outer fingers higher),
-- knitted red yarn cuffs at the wrists, a loose cuff thread curling out to the right
local palmL = c:rrect(8, 38, 30, 52, 5)
local palmR = c:rrect(33, 38, 55, 52, 5)
local fx = { 8, 14, 20, 26 }
local ft = { 31, 33, 35, 36 }
local cuffL = c:rrect(12, 50, 29, 56, 2)
local cuffR = c:rrect(34, 50, 51, 56, 2)
local thread = c:line({ {51, 52}, {55, 49}, {56, 44}, {54, 41}, {51, 42}, {51, 45} }, 3)
local list = {
  { "body", body, GREY, { cres = 4, gloss = false } },
  { "earL", earL, GREY, { cres = 2, gloss = false } },
  { "earR", earR, GREY, { cres = 2, gloss = false } },
  { "head", head, GREY, { cres = 3, gloss = { 18, 20 } } },
  { "palmL", palmL, SKIN, { cres = 4, gloss = false } },
  { "palmR", palmR, SKIN, { cres = 4, gloss = false } },
}
for i = 1, 4 do
  list[#list + 1] = { "fl" .. i, c:rrect(fx[i], ft[i], fx[i] + 5, 46, 2), SKIN, { cres = 2, gloss = false, contact = false } }
  local xr = 63 - fx[i] - 5
  list[#list + 1] = { "fr" .. i, c:rrect(xr, ft[i], xr + 5, 46, 2), SKIN, { cres = 2, gloss = false, contact = false } }
end
list[#list + 1] = { "tail", tail, GREY, { cres = 2, gloss = false } }
list[#list + 1] = { "thread", thread, RED, { cres = 1, deep = 0, gloss = false } }
list[#list + 1] = { "cuffL", cuffL, RED, { cres = 2, gloss = false } }
list[#list + 1] = { "cuffR", cuffR, RED, { cres = 2, gloss = false } }
local p = c:build(list)
-- inner ears
c:paint({ ".p", "pp", "pp" }, 17, 15, { p = PINKN })
c:paint({ "p.", "pp" }, 29, 17, { p = PINKN })
-- closed sleeping eyes and nose
c:paint({ "u...u", ".uuu." }, 17, 25, { u = "ol3" })
c:paint({ "u...u", ".uuu." }, 26, 25, { u = "ol3" })
c:paint({ "pp" }, 23, 28, { p = PINKN })
-- back seam on the cat
c:seam({ { 35, 22 }, { 41, 21 }, { 47, 24 } }, { gap = GREY.shade })
-- knit ribs on the cuffs
for x = 14, 28, 3 do onPart(c, c:rect(x, 52, x, 55), p.cuffL, RED.shade, true) end
for x = 36, 50, 3 do onPart(c, c:rect(x, 52, x, 55), p.cuffR, RED.shade, true) end
-- fingertip nails glints
for i = 1, 4 do
  c:px(fx[i] + 1, ft[i] + 1, SKIN.gloss); c:px(63 - fx[i] - 4, ft[i] + 1, SKIN.gloss)
end
local t = c:save(OUT .. "cf-yi-hold.aseprite", OUT .. "cf-yi-hold.png")
print("hold " .. GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.colours <= 20 and t.bw == 0, "check failed")
