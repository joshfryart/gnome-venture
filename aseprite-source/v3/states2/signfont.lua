-- Shared 3x5 pixel lettering for every "BUILD" sign, so all signs share one hand.
-- Usage: local SF = dofile("/tmp/ase/states2/signfont.lua")
--        SF.text(px, x, y, color [, shadowColor])   -- (x, y) is the top-left of the word, 19 px wide, 5 px tall
--        px(x, y, hex) is your own single-pixel painter (for example function(x, y, hex) c:px(x, y, hex) end)
local SF = {}
SF.glyphs = {
  B = { "##.", "#.#", "##.", "#.#", "##." },
  U = { "#.#", "#.#", "#.#", "#.#", "###" },
  I = { "###", ".#.", ".#.", ".#.", "###" },
  L = { "#..", "#..", "#..", "#..", "###" },
  D = { "##.", "#.#", "#.#", "#.#", "##." },
}
SF.word = "BUILD"
SF.width, SF.height = 19, 5
function SF.text(px, x, y, color, shadow)
  local cx = x
  for i = 1, #SF.word do
    local g = SF.glyphs[SF.word:sub(i, i)]
    for r = 1, 5 do
      for q = 1, 3 do
        if g[r]:sub(q, q) == "#" then
          if shadow then px(cx + q, y + r, shadow) end
        end
      end
    end
    cx = cx + 4
  end
  cx = x
  for i = 1, #SF.word do
    local g = SF.glyphs[SF.word:sub(i, i)]
    for r = 1, 5 do
      for q = 1, 3 do
        if g[r]:sub(q, q) == "#" then px(cx + q - 1, y + r - 1, color) end
      end
    end
    cx = cx + 4
  end
end
return SF
