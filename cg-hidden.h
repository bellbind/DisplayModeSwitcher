#include <stdio.h>
#include <stdlib.h>
#include <CoreGraphics/CoreGraphics.h>

// https://github.com/robbertkl/ResolutionMenu/blob/master/Resolution%20Menu/DisplayModeMenuItem.m
// CoreGraphics DisplayMode struct used in private APIs
typedef struct {
  uint32_t modeNumber;
  uint32_t flags;
  uint32_t width;
  uint32_t height;
  uint32_t depth;
  uint8_t unknown[170];
  uint16_t freq;
  uint8_t more_unknown[16];
  float density;
} CGSDisplayMode;
// CoreGraphics private APIs with support for scaled (retina) display modes
void CGSGetCurrentDisplayMode(CGDirectDisplayID display, int* modeNum);
void CGSConfigureDisplayMode(
  CGDisplayConfigRef config, CGDirectDisplayID display, int modeNum);
void CGSGetNumberOfDisplayModes(CGDirectDisplayID display, int* nModes);
void CGSGetDisplayModeDescriptionOfLength(
  CGDirectDisplayID display, int idx, CGSDisplayMode* mode, int length);
