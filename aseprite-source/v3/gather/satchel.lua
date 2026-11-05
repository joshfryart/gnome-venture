-- Shared gather satchel, Hearth Pop v3. Back part goes into every scene-<land>.lua, front part is satchel-front.png (transparent overlay).
-- Geometry (480x270): front panel x292-422, y128-210 (same box the old front used). Quirk: a tiny leaf patch sewn on, one crooked stitch.
local S = {}
local INK, CREAM = "#2b1c26", "#fff4d6"
local LEA = { hi = "#e8b982", base = "#c08550", shade = "#8f5a3c", deep = "#5a3430" }
local LEA2 = { hi = "#c08550", base = "#9a6038", shade = "#6e3f2a", deep = "#43261f" }
local LINE = { hi = "#ffb08a", base = "#e8604a", shade = "#b52e3f", deep = "#7a2440" }
local BRASS = { hi = "#fff0a0", base = "#f5b82e", shade = "#d98322", deep = "#8f4a1f" }

local function mk(c)
  local E = function(cx, cy, rx, ry) return c:ellipse(cx, cy, rx, ry or rx) end
  local R = function(x0, y0, x1, y1) return c:rect(x0, y0, x1, y1) end
  local fm = function(m, h) c:fillMask(m, h) return m end
  local px = function(x, y, h) c:px(x, y, h) end
  local function form(m, Rm, o)
    o = o or {}
    fm(m, Rm.base)
    local lt, sh, dp = {}, {}, {}
    m:each(function(x, y)
      if not m:has(x - 2, y - 2) then lt[#lt + 1] = { x, y } end
      if not m:has(x + 3, y + 3) then sh[#sh + 1] = { x, y } end
      if o.deep and not m:has(x, y + 1) then dp[#dp + 1] = { x, y } end
    end)
    for _, p in ipairs(lt) do px(p[1], p[2], Rm.hi) end
    for _, p in ipairs(sh) do px(p[1], p[2], Rm.shade) end
    for _, p in ipairs(dp) do px(p[1], p[2], Rm.deep) end
  end
  return E, R, fm, px, form
end

local function body(c, E, R)   -- rounded, bulging bag body used by both halves
  return R(294, 140, 420, 190):copy():add(E(357, 176, 66, 34)):add(R(292, 128, 422, 176))
end

function S.back(c)
  local E, R, fm, px, form = mk(c)
  fm(E(357, 212, 74, 5), "#24604a")   -- contact shadow
  -- bag back wall, slightly higher than the front so the mouth reads as a gap
  local wall = R(296, 108, 418, 176):copy():add(E(357, 168, 62, 30))
  c:rim(wall, INK); form(wall, LEA2, { deep = true })
  -- open flap folded back and standing up, lining shows (red cloth, cream hem)
  local flap = c:poly{ { 302, 114 }, { 412, 114 }, { 404, 78 }, { 394, 68 }, { 320, 68 }, { 310, 78 } }
  c:rim(flap, INK); form(flap, LEA, { deep = true })
  local lin = c:poly{ { 310, 110 }, { 404, 110 }, { 398, 80 }, { 390, 74 }, { 324, 74 }, { 316, 80 } }
  form(lin, LINE)
  for x = 316, 396, 6 do px(x, 76, CREAM); px(x + 1, 76, CREAM) end   -- cream hem stitches
  for y = 80, 106, 6 do px(318, y, CREAM); px(402, y, CREAM) end
  fm(R(352, 88, 362, 98), LINE.shade); c:sparkle(357, 93)   -- tiny star stamped in the lining
  -- dark mouth with a glint of something inside
  local mouth = E(357, 124, 54, 11)
  c:rim(mouth, INK); fm(mouth, "#241418"); fm(E(357, 128, 46, 6), "#3a2430")
  px(340, 122, "#ffe38a"); px(341, 122, "#ffe38a"); px(372, 125, "#9ae0c0"); px(373, 125, "#9ae0c0")
end

function S.front(c)
  local E, R, fm, px, form = mk(c)
  local b = body(c, E, R)
  -- soft shoulders: cut the top corners so the top edge dips like a pulled-open mouth
  b:cut(c:poly{ { 292, 128 }, { 304, 128 }, { 292, 138 } }):cut(c:poly{ { 422, 128 }, { 410, 128 }, { 422, 138 } })
  c:rim(b, INK); form(b, LEA, { deep = true })
  -- gold stitched seam just inside the edge
  local inner = b:copy():shrink(5)
  local n = 0
  inner:edge():each(function(x, y) n = n + 1; if n % 3 ~= 0 then px(x, y, "#ffe38a") end end)
  -- top lip band
  fm(R(298, 130, 416, 136), LEA.shade); fm(R(298, 130, 416, 130), LEA.hi)
  -- strap and brass buckle
  local strap = R(346, 130, 368, 172)
  c:rim(strap, INK); form(strap, LEA2)
  for y = 138, 166, 8 do px(352, y, "#ffe38a"); px(362, y + 4, "#ffe38a") end
  local buckle = c:rrect(342, 150, 372, 174, 3)
  c:rim(buckle, INK); form(buckle, BRASS, { deep = true })
  fm(R(350, 156, 364, 168), LEA2.deep); fm(R(352, 158, 362, 166), LEA2.base); px(357, 162, BRASS.hi)   -- eyelet slot
  -- sewn leaf patch (quirk) lower-left
  local patch = c:rrect(306, 170, 336, 198, 6)
  c:rim(patch, INK); form(patch, LEA2)
  local leaf = c:poly{ { 312, 192 }, { 314, 182 }, { 320, 175 }, { 330, 174 }, { 330, 182 }, { 324, 190 }, { 316, 194 } }
  c:rim(leaf, "#24544a"); form(leaf, { hi = "#c4e07a", base = "#7cc35a", shade = "#3f9150", deep = "#24544a" })
  fm(c:line({ { 313, 193 }, { 328, 177 } }, 1), "#24544a"); px(318, 181, "#c4e07a"); px(322, 178, "#c4e07a")
  for k = 0, 4 do px(310 + k * 6, 200, "#ffe38a") end   -- stitches under the patch
  -- belly shading + a crease
  for y = 178, 204, 7 do local x0 = 380 + (y - 178) // 3; fm(R(x0, y, x0 + 6, y), LEA.shade) end
  fm(R(388, 150, 389, 168), LEA.shade); fm(R(318, 140, 319, 156), LEA.hi)
  -- side tassel pull on the right
  fm(R(412, 140, 413, 152), LEA.deep); local k = E(412, 156, 3, 4); c:rim(k, INK); fm(k, BRASS.base); px(411, 155, BRASS.hi)
end

return S
