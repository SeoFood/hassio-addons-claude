# Adding Claude Code to Home Assistant Sidebar

Since vibe-kanban doesn't work with Home Assistant's Ingress, you can manually add it to the sidebar using an iFrame panel.

## Method: Manual iFrame Panel

Add this to your Home Assistant `configuration.yaml`:

```yaml
panel_iframe:
  claude_code:
    title: "Claude Code"
    icon: mdi:code-braces
    url: "http://homeassistant.local:3000"
```

### Steps:

1. **Edit configuration.yaml**:
   - Settings → System → ⚙️ → Edit in YAML

2. **Add the panel_iframe section** (see above)

3. **Save and restart Home Assistant**:
   - Developer Tools → YAML → Restart

4. **Access via sidebar**:
   - The "Claude Code" panel will appear in the sidebar

## Alternative: Using IP Address

If `homeassistant.local` doesn't work, use your Home Assistant IP:

```yaml
panel_iframe:
  claude_code:
    title: "Claude Code"
    icon: mdi:code-braces
    url: "http://192.168.199.35:3000"  # Replace with your HA IP
```

## Note

The add-on provides a "Open Web UI" button that you can use without adding it to the sidebar.
