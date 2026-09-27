# macOS defaults

`./macos.sh [-n]`. Opt-in; `install.sh` never runs it. Reads each key first
and writes only on drift. If anything changed, Dock, Finder and
SystemUIServer are restarted; some settings still need a log out.

<!-- BEGIN generated: defaults -->
| Area | Domain | Key | Value |
|---|---|---|---|
| Keyboard and text | `NSGlobalDomain` | `NSAutomaticCapitalizationEnabled` | `false` |
| Keyboard and text | `NSGlobalDomain` | `NSAutomaticPeriodSubstitutionEnabled` | `false` |
| Trackpad | `com.apple.AppleMultitouchTrackpad` | `Clicking` | `true` |
| Trackpad | `com.apple.AppleMultitouchTrackpad` | `TrackpadThreeFingerDrag` | `true` |
| Trackpad | `NSGlobalDomain` | `com.apple.swipescrolldirection` | `true` |
| Dock | `com.apple.dock` | `autohide` | `true` |
| Finder | `com.apple.finder` | `FXPreferredViewStyle` | `Nlsv` |
| Finder | `com.apple.finder` | `NewWindowTarget` | `PfAF` |
| Screenshots | `com.apple.screencapture` | `location` | `~/Screenshots` |
| Screenshots | `com.apple.screencapture` | `type` | `png` |
| Screenshots | `com.apple.screencapture` | `disable-shadow` | `true` |
<!-- END generated: defaults -->

To add one, add a `pref <domain> <key> <bool|int|float|string> <value>` line
to `macos.sh` and dry-run it.
