-- pl-ambr-3-perch.lua : chibi red sprout-pal on a twig perch (36x36)
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-ambr-3-perch-20261120-162000/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PHASE = 7 -- 2 block-in, 3 perspective, 4 shade, 5 texture, 6 detail

local c = GV.canvas{ w = 36, h = 36, mode = "scene", ol = 1, olx = 0 }
c.tone = function(self, x, y) return "#2b1c26" end -- 1px dark-plum selective outline (spec palette dark)

local FLAT = (PHASE < 4)
local function partOpts(o)
  o = o or {}
  if FLAT then return { flat = true, rim = false, gloss = false, contact = false } end
  return o
end

-- ramps
local rb = GV.ramp("#d95652", { -- body reds pinned to the pal's own 64px ramp
  gloss = "#f2c7ad", rim = "#e09870", dot = "#ffe98a",
  shade = "#9c223d", deep = "#631535", bounce = "#be2f2e",
})
local rl = GV.ramp("#a2db6a") -- leaf greens
local rt = GV.ramp("#9a6a45") -- twig browns (soil/wood family from the pal)
local rm = GV.ramp("#79617b") -- lilac moss
local rberry = GV.ramp("#f35651")

-- masks
local mossL = c:ellipse(12, 30, 4, 1.4)
local mossR = c:ellipse(25, 30, 4, 1.4)
local twig  = c:rrect(5, 26, 30, 28, 1)
local blob  = c:ellipse(18, 17, 11, 10.5)
local leafL = c:ellipse(4.75, 22.5, 1.6, 2.6)  -- small upright sprout left of the twig
local stemL = c:line({ { 7, 27 }, { 5.5, 24 } }, 1)  -- thin stem joining leaf to twig

-- crown leaves: base y9 (1-2px into the blob top), alternating heights
local LEAFX = { {11,4.5}, {14.5,2.5}, {18,2}, {21.5,3}, {25,5} }
local function leafMask(cx, ay)
  return c:poly({ { cx - 1.6, 9 }, { cx, ay }, { cx + 1.6, 9 } })
end

local P = c:build{
  { "mossL", mossL, rm, partOpts{ cres = 1, deep = 0 } },
  { "mossR", mossR, rm, partOpts{ cres = 1, deep = 0 } },
  { "twig",  twig,  rt, partOpts{ cres = 1, deep = 0 } },
  { "blob",  blob,  rb, partOpts{ cres = 4, deep = 2, gloss = { 12, 11 } } },
}
for i = 1, #LEAFX do
  c:part(leafMask(LEAFX[i][1], LEAFX[i][2]), rl, partOpts{ flat = true })
end
c:part(stemL, rt, partOpts{ flat = true })
c:part(leafL, rl, partOpts{ flat = true })
c:part(c:ellipse(27.5, 26.5, 1.5, 1.5), rberry, partOpts{ flat = true })

-- texture (phase 5+)
if PHASE >= 5 then
  -- wide pale-lit upper-left zone on the body, dithered into the base (form-following)
  local bm = P.blob.m
  for y = 9, 18 do
    local xL = nil
    for x = 7, 29 do if bm:has(x, y) then xL = x break end end
    if xL then
      local d = (y <= 12) and 3 or (y <= 15 and 2 or 1)
      for i = 1, d do
        local lit = (i < d) or ((xL + y) % 2 == 0)
        c:px(xL + i, y, lit and rb.gloss or rb.rim)
      end
    end
  end
  -- hand-put gloss: the part opts place the comma near (12,11) on the lit curve
  -- detail (phase 6+)
  if PHASE >= 6 then
    c:px(14, 10, rb.dot) -- enamel dot high on the lit curve
    c:px(9, 30, rm.bounce) -- moss tuft glint
  end
  -- critique fixes (phase 7): pal's yellow leaf-tip accent on the middle leaf
  if PHASE >= 7 then c:px(18, 2, "#ffe98a") end
  -- 1px dither of shade one step inside the body crescent boundary
  c:px(23, 11, rb.shade); c:px(24, 15, rb.shade); c:px(25, 19, rb.shade); c:px(24, 23, rb.shade)
  -- twig grain, tone-on-tone
  c:px(10, 27, rt.shade); c:px(12, 26, rt.shade); c:px(25, 27, rt.shade)
  -- moss bump specks
  c:px(10, 30, rm.shade); c:px(14, 31, rm.shade); c:px(23, 31, rm.shade); c:px(27, 30, rm.shade)
end

-- face + berries (phases 4+)
if PHASE >= 4 then
  local EY = "#2b1c26"
  c:paint({ "gdd", "ddd", "ddd", "ddd" }, 12, 12, { g = "#fff4d6", d = EY })
  c:paint({ "gdd", "ddd", "ddd", "ddd" }, 20, 12, { g = "#fff4d6", d = EY })
  c:px(10, 17, "#f5809f"); c:px(11, 17, "#f5809f")
  c:px(24, 17, "#f5809f"); c:px(25, 17, "#f5809f")
  c:px(17, 16, "#631535"); c:px(18, 16, "#631535")
  c:px(27, 26, rberry.dot)
end

local t = c:save(
  "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-ambr-3-perch-20261120-162000/out/pl-ambr-3-perch.aseprite",
  "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-ambr-3-perch-20261120-162000/out/pl-ambr-3-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 1)
