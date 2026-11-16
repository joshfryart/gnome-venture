-- shared richness for both trail-pack-b ranks: leather-bound base with a saddle stitch, and a side compression
-- strap on the left pocket. hw = the strap buckle ramp (pewter on the Lined, gold on the Fine).
local O = ...
return function(img, hw)
  local function patch(x, y) return x >= 35 and x <= 50 and y >= 41 and y <= 56 end
  -- 1. leather base: canvas tones in rows 56-59 become a hue-shifted leather ramp
  local MAP = { ["#c9bb92"] = "#d6a46c", ["#ad9e7a"] = "#c08a58", ["#8e7e62"] = "#a46c44", ["#6c5c4a"] = "#844f34",
                ["#4a3c34"] = "#5e3426" }
  for y = 56, 59 do for x = 8, 50 do
    local h = O.get(img, x, y)
    if h and MAP[h] and not patch(x, y) then O.px(img, x, y, MAP[h]) end
  end end
  -- lit top edge of the leather and a saddle stitch (2 on, 1 off) one row below it
  for x = 8, 50 do
    if not patch(x, 56) and O.get(img, x, 56) == "#a46c44" then O.px(img, x, 56, "#c08a58") end
    if (x % 3 ~= 2) and O.get(img, x, 57) and O.get(img, x, 57) ~= O.INK and x > 12 and x < 46 then O.px(img, x, 57, "#ecd0a0") end
  end
  -- 2. compression strap on the left pocket (x 12-13, rows 39-55), leather with a 4x4 buckle
  for y = 39, 55 do
    if O.isBody(img, 12, y) then O.px(img, 12, y, "#c08a58") end
    if O.isBody(img, 13, y) then O.px(img, 13, y, "#844f34") end
    if O.isBody(img, 14, y) and y % 2 == 0 then O.step(img, 14, y, O.ramp({ "#c9bb92", "#ad9e7a", "#8e7e62", "#6c5c4a" }), 1) end
  end
  O.paint(img, 11, 45, {
    "hbbs",
    "b##s",
    "bs#d",
    "sddd",
  }, { h = hw[1], b = hw[2], s = hw[3], d = hw[4] })
end
