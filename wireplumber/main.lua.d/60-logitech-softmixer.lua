-- Force software volume for Logitech PRO X 2 so desktop OSD shows changes
alsa_monitor.rules = alsa_monitor.rules or {}
table.insert(alsa_monitor.rules, {
  matches = {
    { { "device.name", "equals", "alsa_card.usb-Logitech_PRO_X_2_LIGHTSPEED_0000000000000000-00" } },
  },
  apply_properties = {
    ["api.alsa.soft-mixer"] = true, -- disable hardware mixer; PipeWire handles volume
    ["api.alsa.ignore-dB"] = false,
  },
})
