# Wearpiece cards: baked-in text removed

The old cards from claude/wear-pieces/render2.py drew the piece's number (3x5 digits) in a cream box at the top left and its name (3x5 capitals) in a cream ribbon. render2.py still rebuilds them exactly, so the fix is in the generator.

- tools/build_wearpiece_cards.py builds the 280 game/assets/img/wearpiece/<slug>.png cards (132x92 RGBA, hard alpha) from the same template with both plates removed, so the card's fill, light row and stitched rim continue across. Use --check to compare without writing.
- game/shop.php and game/assets/style.css: the shop sheet shows the card as a figure with a caption: "Puzzle piece it gives", the piece name and "Type N", from wear_defs().
- tests/tailor.php: no cream plate pixels in either area (fails on the old cards, passes on the new). tests/shopbasket.sh: the caption HTML, plus tools/shot_wearpiece_cards.js when playwright is installed (light and dark, 412x915 and 844x390; WEARSHOTS=dir for screenshots).
- Not done (other review points): the round medallion (no-circles rule, since overruled by RULINGS 5), the small garment in a busy frame, and the per-item outliers.
