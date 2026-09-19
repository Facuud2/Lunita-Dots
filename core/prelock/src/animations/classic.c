#include "prelock/animations/classic.h"

#include "prelock/components/lock_icon.h"
#include "raylib.h"

#include <math.h>

static void draw_classic(const PrelockFrame *frame) {
  const float global_alpha = frame->global_alpha;
  const PrelockPalette *palette = frame->palette;
  const float center_x = (float)frame->screen_width / 2.0f;
  const float center_y = (float)frame->screen_height / 2.0f;

  float rotation_degrees = 0.0f;
  float shackle_progress = 1.0f; // 1.0 = locked, 0.0 = open
  float anim_alpha = 1.0f;
  float expand_offset = 0.0f;
  float lock_scale = 1.0f;
  float bg_alpha = 0.65f;

  if (!frame->is_unlocked) {
    // ─── LOCKING ANIMATION ───
    const float progress = frame->progress;
    float entry_t = fminf(progress / 0.40f, 1.0f);
    float entry_ease = sinf(entry_t * PI / 2.0f);
    rotation_degrees = (1.0f - entry_ease) * -180.0f;

    if (progress < 0.35f) {
      // Rotating in while open
      shackle_progress = 0.0f;
    } else if (progress < 0.70f) {
      // Snapping CLOSED
      float close_t = (progress - 0.35f) / 0.35f;
      shackle_progress = sinf(close_t * PI / 2.0f);
    } else {
      // Locked firmly in place
      shackle_progress = 1.0f;
    }

    expand_offset = 0.0f;
    lock_scale = 1.0f;
    anim_alpha = 1.0f;
    bg_alpha = entry_ease * 0.65f;
  } else {
    // ─── UNLOCKING ANIMATION (User logged in successfully) ───
    const float u = frame->unlock_progress; // 0.0 to 1.0
    rotation_degrees = 0.0f;

    if (u < 0.42f) {
      // Lock unlatches and pops OPEN
      float open_t = u / 0.42f;
      float open_ease = sinf(open_t * PI / 2.0f);
      shackle_progress = 1.0f - open_ease; // 1.0 -> 0.0 (opens!)
      expand_offset = open_ease * 40.0f;
      lock_scale = 1.0f + open_ease * 0.10f;
      anim_alpha = 1.0f;
      bg_alpha = 0.65f;
    } else {
      // Open lock and blur dissolve smoothly to reveal desktop
      float exit_t = (u - 0.42f) / 0.58f;
      float exit_ease = sinf(exit_t * PI / 2.0f);
      shackle_progress = 0.0f; // completely open
      expand_offset = 40.0f + exit_ease * 160.0f;
      lock_scale = 1.10f + exit_ease * 0.35f;
      anim_alpha = 1.0f - exit_ease;
      bg_alpha = 0.65f * (1.0f - exit_ease);
    }
  }

  const float final_alpha = anim_alpha * global_alpha;

  // Background scrim / dark overlay
  DrawRectangle(0, 0, frame->screen_width, frame->screen_height,
                ColorAlpha(palette->background, bg_alpha * global_alpha));

  // Horizontal rays
  const float line_start_offset = 120.0f + 30.0f + expand_offset;
  const float line_length = (float)frame->screen_width / 2.0f;
  const Color line_color = ColorAlpha(palette->secondary, final_alpha);

  DrawLineEx((Vector2){center_x - line_start_offset, center_y},
             (Vector2){center_x - line_start_offset - line_length, center_y},
             2.0f, line_color);
  DrawLineEx((Vector2){center_x + line_start_offset, center_y},
             (Vector2){center_x + line_start_offset + line_length, center_y},
             2.0f, line_color);

  // Concentric ring 1
  const float outer_radius = 120.0f + expand_offset * 0.8f;
  float outer_inner = outer_radius - 12.0f;
  if (outer_inner < 0.0f) {
    outer_inner = 0.0f;
  }
  DrawRing((Vector2){center_x, center_y}, outer_inner, outer_radius,
           0.0f, 360.0f, 64,
           ColorAlpha(palette->primary, final_alpha));

  // Concentric ring 2
  const float reverse_radius = 145.0f + expand_offset;
  float reverse_inner = reverse_radius - 3.0f;
  if (reverse_inner < 0.0f) {
    reverse_inner = 0.0f;
  }
  DrawRing((Vector2){center_x, center_y}, reverse_inner, reverse_radius,
           0.0f, 360.0f, 64,
           ColorAlpha(palette->accent, final_alpha));

  // Padlock icon
  const PrelockLockIcon lock = {
      .position = (Vector2){center_x, center_y},
      .scale = lock_scale,
      .rotation_degrees = rotation_degrees,
      .shackle_progress = shackle_progress,
      .color = ColorAlpha(palette->tertiary, final_alpha),
      .detail_color = ColorAlpha(palette->contrast, final_alpha),
  };
  prelock_draw_lock_icon(&lock);
}

const PrelockAnimation PRELOCK_ANIMATION_CLASSIC = {
    .name = "classic",
    .description = "rotating lock that closes on lock and opens on unlock",
    .duration_seconds = 1.15f,
    .draw = draw_classic,
};
