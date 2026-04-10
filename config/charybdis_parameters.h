#pragma once

// ─── Layer indices ────────────────────────────────────────────────────────────
#define DEFAULT     0
#define RAISE       1
#define LOWER       2
#define MULTI       3
#define MOUSE_LAYER 4
#define SNIPE_LAYER 5

// ─── PMW3610 sensor ──────────────────────────────────────────────────────────
#define TRACKBALL_CPI  1600   // sensor resolution in counts per inch

// ─── Auto-mouse layer ────────────────────────────────────────────────────────
#define TRACKBALL_TTL_MS   750  // ms the mouse layer stays active after last movement
#define TRACKBALL_IDLE_MS  150  // suppress trackball if key pressed within this window

// ─── Scroll mode (active on RAISE / LOWER) ───────────────────────────────────
#define SCROLL_DIVISOR  16  // higher = less sensitive (old value was 8)

// ─── Cursor mode (default) ────────────────────────────────────────────────────
#define CURSOR_DIVISOR  1   // XY scale divisor for normal cursor (1 = raw CPI)

// ─── Snipe mode (precision cursor) ───────────────────────────────────────────
#define SNIPE_DIVISOR   12  // higher divisor = slower cursor

// ─── Mouse button key positions (zero-based) ─────────────────────────────────
// Matrix has 3 full rows of 12 (positions 0–35) then 6 thumb keys (36–41).
// Thumb row order from transform: RC(3,3) RC(3,4) RC(3,1) RC(3,7) RC(3,10) RC(3,9)
//
// These positions are excluded from deactivating the auto-mouse layer so that
// clicking while moving (drag) does not dismiss the layer mid-gesture.
#define POS_MOUSE_MCLK  24   // RC(2,0)  — Mouse layer: middle click
#define POS_MOUSE_LCLK  35   // RC(2,6)  — Mouse layer: left click (pinky row)
#define POS_BASE_LCLK   36   // RC(3,3)  — Base layer:  left click (left thumb)
#define POS_MOUSE_RCLK  38   // RC(3,1)  — Mouse layer: right click (thumb row)
#define POS_BASE_RCLK   41   // RC(3,9)  — Base layer:  right click (right thumb)
