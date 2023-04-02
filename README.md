#  macoswasmr

WebR's Console REPL Running locallly in a macOS SwiftUI app thanks to [goserve](https://pkg.go.dev/github.com/johnsto/goserve).

- `webr/` is just the files from the official distribution
- `goserve-macos` is a universal macOS compile of `goserve`
- `goserve.conf` has the CORS header config for ^^
- `macoswasmrApp.swift` is just boilerplate SwitfUI 
- `ContentView.swift` should really be broken up into multiple files and contains the views, controller, and `goserve-macos`' background process laucher 

## Addendum

- Forgive the name. This is a project I resurrected from last year (thanks to the burnout from the old job I never got around to getting this on GH).
- I'll try to get this ported to iOS soon (I have `goserve` ported to iOS so it should be ~this week. Please feel free to beat me to that :-)
