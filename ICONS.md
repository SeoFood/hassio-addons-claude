# Icons für Home Assistant Add-on

Für ein professionelleres Erscheinungsbild können Sie Icons hinzufügen:

## Add-on Icon

**Datei:** `icon.png`
**Größe:** 128x128 Pixel
**Format:** PNG mit transparentem Hintergrund

Das Icon wird im Home Assistant Add-on Store neben dem Add-on-Namen angezeigt.

## Repository Logo (optional)

**Datei:** `logo.png`
**Größe:** 256x256 Pixel (oder größer)
**Format:** PNG mit transparentem Hintergrund

Das Logo wird oben im Repository im Add-on Store angezeigt.

## Icon erstellen

Sie können ein Icon mit verschiedenen Tools erstellen:

1. **Online:**
   - [Canva](https://www.canva.com/) - Einfacher Grafik-Editor
   - [Figma](https://www.figma.com/) - Professionelles Design-Tool

2. **Desktop:**
   - GIMP (kostenlos)
   - Photoshop
   - Inkscape (für Vektorgrafiken)

3. **KI-generiert:**
   - DALL-E, Midjourney, oder Stable Diffusion
   - Prompt: "minimalist icon for a code development environment, Claude AI theme, 128x128, transparent background"

## Beispiel-Theme

Passend zu "Claude Code":
- **Farben:** Blau/Orange (Claude-Farben) oder Dunkelblau mit Code-Symbolen
- **Symbol:** Terminal-Symbol, Code-Brackets, oder KI-Symbol
- **Stil:** Minimalistisch, flat design

## Nach dem Erstellen

1. Speichern Sie `icon.png` im Root-Verzeichnis
2. Optional: `logo.png` im Root-Verzeichnis
3. Committen und pushen Sie die Icons
4. Home Assistant lädt die Icons automatisch beim nächsten Rebuild
