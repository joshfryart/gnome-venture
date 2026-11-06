-- satchel3.lua: three v3 satchel designs on the same geometry (front panel x292-422 y128-210). S.back(c,GX,v,shadowHex) / S.front(c,GX,v)
-- A = leather bag, red-lined flap, brass buckle, leaf patch. B = canvas rucksack-satchel, rope tie, wood toggle, front pocket, green lining.
-- C = patchwork cloth bag, star-stamped blue lining, shell button, hanging star charm.
local S = {}
local H = nil
local LEA = { hi = "#e8b982", base = "#c08550", shade = "#8f5a3c", deep = "#5a3430" }
local CAN = { hi = "#f4e6bc", base = "#d8c08a", shade = "#a8885a", deep = "#6e5238" }
local LINR = { hi = "#ffb08a", base = "#e8604a", shade = "#b52e3f", deep = "#7a2440" }
local LING = { hi = "#c4e07a", base = "#7cc35a", shade = "#3f9150", deep = "#24544a" }
local LINB = { hi = "#8ab0f0", base = "#4a6ad0", shade = "#34469c", deep = "#222c68" }
local BRASS = { hi = "#fff0a0", base = "#f5b82e", shade = "#d98322", deep = "#8f4a1f" }
local WOOD = { hi = "#e8b982", base = "#b97a4a", shade = "#864c33", deep = "#51302b" }
local MOUTH = { hi = "#5a3a48", base = "#37212e", shade = "#241418", deep = "#160d12" }
local QUILT = { { hi = "#7ad0c8", base = "#3a9aa8", shade = "#2a6a88", deep = "#1c3e5e" }, { hi = "#ffd470", base = "#f0a830", shade = "#c0701e", deep = "#7a3e1e" },
  { hi = "#e08ac0", base = "#b8508c", shade = "#843468", deep = "#4e1e42" }, { hi = "#a8d070", base = "#68a048", shade = "#3e7040", deep = "#244a36" } }

local function vars(v) if v == "A" then return LEA, LINR elseif v == "B" then return CAN, LING else return QUILT[1], LINB end end

function S.back(c, GX, v, shadow)
  local HP, X = GX.HP, GX.X
  local H = X.hash
  local outer, lin = vars(v)
  local ob = { hi = outer.base, base = outer.shade, shade = outer.deep, deep = GX.mix(outer.deep, "#000000", .3) }   -- inside of the bag is darker
  if shadow then local sh = HP.mask(); GX.disc(sh, 357, 213, 74, 5); c:fillMask(sh, shadow) end
  local wall = c:rrect(296, 96, 418, 180, 18):clip(c:rect(0, 100, 479, 269))
  GX.lit(c, wall, GX.ramp6(ob), { R = 10, tex = .18, sc = 4, seed = 5 })
  local flap = c:poly{ { 300, 116 }, { 414, 116 }, { 406, 80 }, { 396, 66 }, { 318, 66 }, { 308, 80 } }
  local fo = outer
  GX.lit(c, flap, GX.ramp6(fo), { R = 7, tex = .2, sc = 4, seed = 7, rimlight = true })
  local lm = c:poly{ { 308, 112 }, { 406, 112 }, { 400, 82 }, { 392, 73 }, { 322, 73 }, { 314, 82 } }
  GX.lit(c, lm, GX.ramp6(lin), { R = 7, tex = .16, sc = 5, seed = 9, ink = false })
  for x = 316, 398, 6 do c:px(x, 75, "#fff4d6"); c:px(x + 1, 75, "#fff4d6") end
  for y = 80, 106, 6 do c:px(315, y, "#fff4d6"); c:px(400, y, "#fff4d6") end
  if v == "C" then c:sparkle(340, 92); c:sparkle(357, 86); c:sparkle(375, 94) elseif v == "A" then c:sparkle(357, 92) else
    c:px(357, 88, "#fff4d6"); c:px(356, 89, "#fff4d6"); c:px(358, 89, "#fff4d6"); c:px(357, 90, "#fff4d6"); c:px(357, 91, "#fff4d6") end
  local mouth = HP.mask(); GX.disc(mouth, 357, 124, 54, 11)
  GX.lit(c, mouth, GX.ramp6(MOUTH), { R = 5, tex = .2, sc = 4, seed = 11 })
  c:px(340, 123, "#ffe38a"); c:px(341, 123, "#ffe38a"); c:px(372, 126, "#9ae0c0"); c:px(373, 126, "#9ae0c0"); c:px(358, 120, "#f5809f")
end

local function stitch(c, GX, m, col, shrink)
  local inner = m:shrink(shrink or 5)
  inner:edge():each(function(x, y) if (x + y) % 4 < 2 then c:px(x, y, col) end end)
end

function S.front(c, GX, v)
  local HP, X = GX.HP, GX.X
  local H = X.hash
  local outer = vars(v)
  local body = c:rrect(292, 96, 422, 210, 26):clip(c:rect(0, 128, 479, 269))
  if v == "A" then
    GX.lit(c, body, GX.ramp6(LEA), { R = 16, tex = .1, sc = 5, seed = 21, rimlight = true,
      fn = function(x, y) return (H(x, y, 2) - .5) * .05 + (GX.vn(x * .6, y * 1.6, 3, 5) - .5) * .1 end })
    stitch(c, GX, body, "#ffe38a")
    local lip = c:rect(298, 130, 416, 137); GX.lit(c, lip, GX.ramp6({ hi = LEA.base, base = LEA.shade, shade = LEA.deep, deep = LEA.deep }), { R = 3, tex = .1, ink = false })
    local strap = c:rect(346, 129, 368, 174); GX.lit(c, strap, GX.ramp6({ hi = LEA.hi, base = "#9a6038", shade = "#6e3f2a", deep = "#43261f" }), { R = 6, tex = .2, sc = 3, seed = 3 })
    for y = 138, 166, 8 do c:px(352, y, "#ffe38a"); c:px(362, y + 4, "#ffe38a") end
    local bk = c:rrect(342, 150, 372, 174, 4); GX.lit(c, bk, GX.ramp6(BRASS), { R = 5, tex = .12, seed = 4, rimlight = true })
    c:fillMask(c:rect(350, 156, 364, 168), BRASS.deep); c:fillMask(c:rect(352, 158, 362, 166), "#43261f"); c:px(358, 162, BRASS.hi)
    local pat = c:rrect(306, 170, 336, 198, 6); GX.lit(c, pat, GX.ramp6({ hi = "#c08550", base = "#9a6038", shade = "#6e3f2a", deep = "#43261f" }), { R = 5, tex = .2, sc = 3, seed = 8 })
    local leaf = c:poly{ { 312, 192 }, { 314, 182 }, { 320, 175 }, { 330, 174 }, { 330, 182 }, { 324, 190 }, { 316, 194 } }
    GX.lit(c, leaf, GX.ramp6(LING), { R = 4, tex = .1, ink = "#24544a" })
    c:fillMask(c:line({ { 313, 193 }, { 328, 177 } }, 1), "#24544a")
    for k = 0, 4 do c:px(310 + k * 6, 200, "#ffe38a") end
    c:fillMask(c:rect(412, 140, 413, 152), LEA.deep); local tz = HP.mask(); GX.disc(tz, 412, 157, 3, 4); GX.lit(c, tz, GX.ramp6(BRASS), { R = 3, tex = 0, seed = 2 })
  elseif v == "B" then
    GX.lit(c, body, GX.ramp6(CAN), { R = 16, tex = .1, sc = 5, seed = 31, rimlight = true,
      fn = function(x, y) return ((x + y) % 2) * .05 + (((x // 2) + (y // 2)) % 2) * .04 - .045 + (GX.vn(x, y * 1.4, 5, 6) - .5) * .08 end })
    stitch(c, GX, body, "#8f6a3a", 4)
    for x = 296, 418 do   -- rope drawstring lip (twisted)
      for y = 129, 135 do local t = (x + y * 2) % 6; c:px(x, y, t < 2 and "#f4e6bc" or (t < 4 and "#b9965f" or "#8a6a3e")) end
      c:px(x, 128, GX.INK); c:px(x, 136, GX.INK)
    end
    local pk = c:rrect(304, 150, 342, 194, 4)
    GX.lit(c, pk, GX.ramp6({ hi = CAN.base, base = CAN.shade, shade = CAN.deep, deep = "#4a3626" }), { R = 5, tex = .15, sc = 3, seed = 12,
      fn = function(x, y) return ((x + y) % 2) * .05 end })
    local fl = c:rect(304, 150, 342, 160); GX.lit(c, fl, GX.ramp6(CAN), { R = 3, tex = .1, ink = false }); stitch(c, GX, pk, "#fff4d6", 3)
    local tg = c:rrect(354, 140, 362, 170, 3); GX.lit(c, tg, GX.ramp6(WOOD), { R = 3, tex = .25, sc = 2, seed = 13, rimlight = true })
    for y = 144, 166, 6 do c:px(357, y, WOOD.deep) end
    c:fillMask(c:line({ { 358, 132 }, { 358, 142 } }, 2), "#8a6a3e")
    local st = c:poly{ { 322, 176 }, { 326, 168 }, { 330, 176 }, { 336, 178 }, { 330, 182 }, { 332, 190 }, { 326, 185 }, { 320, 190 }, { 322, 182 }, { 316, 178 } }
    GX.lit(c, st, GX.ramp6(LING), { R = 3, tex = 0, ink = "#24544a" })
  else
    local cw, ch = 33, 27
    local pick = function(x, y) local gx, gy = (x - 292) // cw, (y - 128) // ch; return GX.ramp6(QUILT[1 + (gx + gy * 2) % 4]) end
    GX.lit(c, body, pick, { R = 16, tex = .2, sc = 3, seed = 41, rimlight = true,
      fn = function(x, y) return ((x + y) % 2) * .045 + (H(x, y, 3) - .5) * .06 end })
    for gx = 1, 3 do for y = 129, 209 do if body:has(292 + gx * cw, y) and y % 4 < 2 then c:px(292 + gx * cw, y, "#fff4d6") end end end
    for gy = 1, 3 do for x = 293, 421 do if body:has(x, 128 + gy * ch) and x % 4 < 2 then c:px(x, 128 + gy * ch, "#fff4d6") end end end
    stitch(c, GX, body, "#fff4d6", 4)
    local bt = HP.mask(); GX.disc(bt, 357, 160, 9, 9); GX.lit(c, bt, GX.ramp6({ hi = "#ffffff", base = "#f4e6d0", shade = "#c8b8a8", deep = "#8a7a78" }), { R = 8, tex = .05, seed = 5, rimlight = true })
    for _, p in ipairs{ { -2, -2 }, { 2, -2 }, { -2, 2 }, { 2, 2 } } do c:px(357 + p[1], 160 + p[2], "#6a4a58") end
    c:px(355, 158, "#e8604a"); c:px(359, 162, "#e8604a")
    local ch2 = c:poly{ { 420, 150 }, { 424, 160 }, { 434, 162 }, { 426, 168 }, { 428, 178 }, { 420, 172 }, { 412, 178 }, { 414, 168 }, { 406, 162 }, { 416, 160 } }
    c:fillMask(c:line({ { 420, 134 }, { 420, 152 } }, 1), "#fff4d6")
    GX.lit(c, ch2, GX.ramp6(BRASS), { R = 4, tex = 0, rimlight = true })
  end
end
return S
