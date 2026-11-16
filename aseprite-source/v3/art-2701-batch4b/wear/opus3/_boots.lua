-- shared richness for both flood-boots-b ranks (loaded by the two icon scripts)
local O = ...
return function(img, rank)
  local GR = O.ramp({ "#c4e07a", "#9cd27a", "#86c262", "#5eab55", "#4f9a50", "#3f8a4c", "#2e6b45", "#22503f", "#1b3533" })
  -- patch box on the front shaft (gingham, its stitches and dog-ear) stays untouched
  local function safe(x, y) return not (x >= 13 and x <= 29 and y >= 27 and y <= 40) end
  -- rubber: faint horizontal crinkle rows on the shafts and a long gloss streak on the front shaft
  O.texture(img, GR, 12, 17, 50, 50, function(x, y, i)
    if y % 6 == 0 and (x % 5 ~= 0) and i >= 4 and i <= 7 then return 1 end
  end, safe)
  for y = 20, 26 do O.step(img, 15, y, GR, -2) end
  O.px(img, 15, 18, "#e8f4b0")
  -- rubber sole: tread grain (lighter fleck every 4th px on the welt rows) and a lit toe bumper
  local SOLE = O.ramp({ "#c48e68", "#a87458", "#80563f", "#6a4537", "#51342f", "#3a2629" })
  O.texture(img, SOLE, 11, 51, 46, 54, function(x, y, i) if (x + y) % 4 == 0 and i > 1 then return -1 end end)
  if rank == "lined" then
    -- quirk: a snail climbing the back boot's instep, shell spiral in cream and tan
    O.paint(img, 39, 33, {
      "..####....",
      ".#hbbs#...",
      "#hbdsbd#.#",
      "#bdhdsd##k#",
      "#bsddsd#kk#",
      "#kkkkkkkkk#",
      ".#########.",
    }, { h = "#fff4d6", b = "#ecd4a8", s = "#c49a6a", d = "#8a5a3a", k = "#b8a8b8" })
  end
end
