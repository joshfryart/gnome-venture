-- crop-vegetable.lua : giant marrow, phase 7 (critique fixes: stem chunkier, gloss/stripe split, petalled flower)
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/crop-vegetable-20261120-135835/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- critic fix 1: thin curled tendril, x52..59 y15..25, 3px stalk arcing up, hooking right
local stem = c:line({ { 51, 27}, { 53.5, 21}, { 54.5, 17.5}, { 55.5, 18}, { 55.5, 21} }, 3)
c:part(stem, GV.ramp("#7a5a2c", { rim = "#8a4f2a" }), { gloss = false, flat = true, stitch = false })

-- body: long bulgy oval x6..57, y16..54, full moss shading
local body = c:ellipse(32, 35.5, 25.5, 19)
local p = c:part(body, "leaf", { gloss = false, stitch = false })

-- blossom: petalled gold flower over the body's lower-left end
local blos = c:ellipse(9, 36, 4.5, 3.5)          -- main bud
blos:add(c:ellipse(7, 34, 1.5, 1.5))               -- upper-left petal
blos:add(c:ellipse(8, 40, 1.5, 1.2))               -- lower petal
c:part(blos, GV.ramp("#d6c24a"), { gloss = false, flat = true, stitch = false, contour = false })
c:px(9, 37, "#e8a317"); c:px(10, 36, "#e8a317")   -- warm centre
c:px(7, 35, "#fff8e0")                            -- tiny glint

-- ground shadow hugging the body bottom
c:ground(32, 56, 20, 1.5)

-- ---- lengthwise stripes following the arch, tapering at the ends ----
local leaf = GV.R.leaf
local base, shade = leaf.base, leaf.shade
local pale, pale2 = "#a4b86a", "#7ab55c"
local function rowOk(x, y, allowed)
  local v = c:get(x, y)
  for _, a in ipairs(allowed) do if v == a then return true end end
  return false
end
for x = 7, 56 do
  local t = (x - 32) / 25.5
  local s = 1 - t * t
  if s >= 0 then
    local h = 19 * math.sqrt(s)
    local yt = math.floor(35.5 - h + 0.5)
    local yb = math.ceil(35.5 + h - 0.5)
    local mid = math.floor((yt + yb) / 2 + 0.5)
    for dy = 0, 1 do
      if rowOk(x, yt + 3 + dy, { base, shade }) then c:px(x, yt + 3 + dy, pale) end
      if rowOk(x, mid - 1 + dy, { base, shade }) then c:px(x, mid - 1 + dy, pale2) end
      if rowOk(x, yb - 10 - dy, { base, shade }) then c:px(x, yb - 10 - dy, pale) end
    end
  end
end

-- enamel gloss comma: below the top stripe, parallel to the arch (gap from stripe)
local gloss = c:line({ { 15, 31}, { 21, 27}, { 28, 24}, { 34, 22} }, 3):clip(body)
gloss:each(function(x, y)
  local v = c:get(x, y)
  if v and v ~= "#000000" then c:px(x, y, leaf.gloss) end
end)
c:px(36, 24, leaf.dot)

-- dither: 1px shade specks along the light/shade boundary
for _, pt in ipairs({ {13,24}, {26,19}, {45,22} }) do
  if c:get(pt[1], pt[2]) == base and c:get(pt[1] - 1, pt[2]) == shade then c:px(pt[1], pt[2], shade) end
end

-- skin pits: sparse small marks, one shade step down
for _, pt in ipairs({ {18,33}, {38,31}, {43,41}, {22,44} }) do
  if c:get(pt[1], pt[2]) == base then c:px(pt[1], pt[2], shade) end
end

-- stem: 1px deep mark under the curl
c:px(53, 21, "#5e2f1e"); c:px(54, 20, "#5e2f1e")

local t = c:save(D .. "out/crop-vegetable.aseprite", D .. "out/crop-vegetable.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 2)
