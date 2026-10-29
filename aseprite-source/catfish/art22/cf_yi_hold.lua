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

-- yarn thread: rises from behind the left thumb and curls into a loop, end trailing to the right
local thread = c:line({ {9, 33}, {7, 26}, {8, 19}, {12, 14}, {17, 13}, {20, 16}, {19, 20}, {15, 20}, {14, 16}, {17, 10}, {23, 7} }, 3)
-- cat: loaf body, round head left, two ears, tail tip curling over the right hand
local body = c:ellipse(36, 34, 15, 9)
local head = c:ellipse(23, 30, 10, 8.5)
local earL = c:poly({ {14, 27}, {15, 17}, {22, 23} })
local earR = c:poly({ {24, 22}, {31, 18}, {32, 27} })
local tail = c:line({ {48, 40}, {52, 36}, {52, 31} }, 4)
-- hands: two cupped palms, low in the middle, thumbs up at the outer ends
local handL = rell(c, 20, 47, 15, 9, 0.30):add(rell(c, 9.5, 39, 4, 7, 0.25))
local handR = rell(c, 43, 47, 15, 9, -0.30):add(rell(c, 53.5, 39, 4, 7, -0.25))

local p = c:build{
  { "thread", thread, RED, { cres = 1, deep = 0, gloss = false } },
  { "body", body, GREY, { cres = 4, gloss = false } },
  { "earL", earL, GREY, { cres = 2, gloss = false } },
  { "earR", earR, GREY, { cres = 2, gloss = false } },
  { "head", head, GREY, { cres = 3, gloss = { 17, 25 } } },
  { "tail", tail, GREY, { cres = 2, gloss = false } },
  { "handL", handL, SKIN, { cres = 4, gloss = { 9, 41 } } },
  { "handR", handR, SKIN, { cres = 4, gloss = false } },
}
-- inner ears
c:paint({ ".p", "pp", "pp" }, 16, 21, { p = PINKN })
c:paint({ "p.", "pp" }, 28, 22, { p = PINKN })
-- closed sleeping eyes and nose
c:paint({ "u...u", ".uuu." }, 16, 30, { u = "ol3" })
c:paint({ "u...u", ".uuu." }, 25, 30, { u = "ol3" })
c:paint({ "pp" }, 22, 33, { p = PINKN })
-- body stripe seam down the back
c:seam({ { 34, 27 }, { 41, 26 }, { 47, 29 } }, { gap = GREY.shade })
-- finger grooves on the front of each palm
for _, q in ipairs({ { 15, 49 }, { 21, 51 } }) do onPart(c, c:line({ { q[1], q[2] }, { q[1] + 1, q[2] + 4 } }, 1), p.handL, SKIN.shade, true) end
for _, q in ipairs({ { 47, 49 }, { 41, 51 } }) do onPart(c, c:line({ { q[1], q[2] }, { q[1] - 1, q[2] + 4 } }, 1), p.handR, SKIN.shade, true) end
-- palm seams
c:seam({ { 8, 46 }, { 14, 52 }, { 24, 55 } }, { gap = SKIN.shade })
c:seam({ { 55, 46 }, { 49, 52 }, { 39, 55 } }, { gap = SKIN.shade })
-- thread twist glints
trace(c, { {8, 25}, {8, 20} }, RED.gloss, set(RED.base, RED.rim), function(n) return n % 3 == 0 end)
c:paint({ "gg", "g." }, 38, 39, { g = SKIN.gloss })

local t = c:save(OUT .. "cf-yi-hold.aseprite", OUT .. "cf-yi-hold.png")
print("hold " .. GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.colours <= 20 and t.bw == 0, "check failed")
