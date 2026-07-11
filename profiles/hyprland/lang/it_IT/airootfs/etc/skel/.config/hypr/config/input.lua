hl.config({
    input = {
        kb_layout = "it",
        kb_variant = "",
        kb_model = "pc105",
        kb_options = "grp:alt_shift_toggle",   -- Alt + Shift to switch layout
        kb_rules = "",

        resolve_binds_by_sym = true,           -- Very important for IT
        follow_mouse = 1,
        sensitivity = 0.0,
        accel_profile = "flat",

        -- Touchpad (if present)
        touchpad = {
            natural_scroll = false,
            tap_to_click = true,
            middle_button_emulation = false,
        },

        -- For a specific external keyboard (optional)
        -- device = {
        --     ["external-keyboard-name"] = {
        --         kb_layout = "it"
        --     }
        -- }
    }
})
