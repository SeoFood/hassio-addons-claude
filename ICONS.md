# Icons for Home Assistant Add-on

For a more professional appearance, you can add icons:

## Add-on Icon

**File:** `icon.png`
**Size:** 128x128 pixels
**Format:** PNG with transparent background

The icon is displayed in the Home Assistant Add-on Store next to the add-on name.

## Repository Logo (optional)

**File:** `logo.png`
**Size:** 256x256 pixels (or larger)
**Format:** PNG with transparent background

The logo is displayed at the top of the repository in the Add-on Store.

## Creating an Icon

You can create an icon using various tools:

1. **Online:**
   - [Canva](https://www.canva.com/) - Simple graphics editor
   - [Figma](https://www.figma.com/) - Professional design tool

2. **Desktop:**
   - GIMP (free)
   - Photoshop
   - Inkscape (for vector graphics)

3. **AI-generated:**
   - DALL-E, Midjourney, or Stable Diffusion
   - Prompt: "minimalist icon for a code development environment, Claude AI theme, 128x128, transparent background"

## Example Theme

Matching "Claude Code":
- **Colors:** Blue/Orange (Claude colors) or dark blue with code symbols
- **Symbol:** Terminal symbol, code brackets, or AI symbol
- **Style:** Minimalist, flat design

## After Creating

1. Save `icon.png` in the root directory
2. Optional: `logo.png` in the root directory
3. Commit and push the icons
4. Home Assistant will load the icons automatically on next rebuild
