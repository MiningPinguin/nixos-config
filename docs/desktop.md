# Desktop

## Session

The desktop module is the shared graphical base. The Plasma module adds the session, the display manager, KDE Connect and the KDE applications.

Discord starts minimised through a KDE autostart entry, because it is a graphical application that wants the session. KDE Connect has no entry there because its Plasma setting already installs one.

## Panels

The panel layout is declared in a module. plasma-manager applies it with a startup script on the next login after a rebuild, which replaces panel edits made by hand. The file is the source of truth, not the running session.

## Theme

One theme module owns the look. It sets the flavor and accent, and the lighter flavor Plasma switches to in light mode. The icon theme is named separately, because Catppuccin ships no icon theme.

Plasma swaps its whole global theme when dark mode changes and defaults to Breeze, so both global themes are named explicitly. The icon theme is re-asserted because Breeze's global themes revert it.

The same module seeds the JetBrains colour scheme and look-and-feel files from the central flavor, so the IDEs do not choose a variant of their own.

Catppuccin for Plasma also needs the Plasma backend; the theme module alone does not provide it.

### Cursor aliases

nixpkgs' `catppuccin-kde` asks for a capitalised cursor theme name, while `catppuccin-cursors` installs a lowercase one. Plasma matches the name exactly, so the theme module creates aliases until nixpkgs catches up.

## Lock screen

SDDM draws the login screen and kscreenlocker draws the lock screen. They are separate programs with separate settings, and nothing binds them together ([SDDM's maintainer on this](https://github.com/sddm/sddm/issues/721)). nixpkgs has no option over either one, so there is nowhere to put a shared decision.

Up to Plasma 6.0 a theme could supply the lock screen through `contents/lockscreen/LockScreen.qml` in its global theme ([porting guide](https://develop.kde.org/docs/plasma/theme/theme-porting-to-plasma6)). Both surfaces then came from the same file, so one theme covered both.

Since Plasma 6.1 the lock screen comes from the Plasma shell package instead ([source](https://invent.kde.org/plasma/kscreenlocker/-/blob/master/settings/shell_integration.cpp)). The global theme lost that hook, so a theme can no longer supply one. Breeze, the theme Plasma itself ships, does not provide one either.

No theme fills the gap:

- `catppuccin-kde` has only a splash screen.
- Neither nixpkgs nor the `catppuccin` flake packages a lock screen.

Recheck when:

- Plasma restores a lock-screen component for global themes, or documents an equivalent for shell packages.
- `catppuccin-kde` or the `catppuccin` flake ships a lock screen.
