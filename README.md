<h1 align="center">MagnificationScaler</h1>
<p align="center">A macOS app that makes the dock magnification scale with its size.</p>

Has your dock ever automatically shrunk, but the magnification changed the same, giving it a weird feel? Well that's happened to me, so I made this!

![MagnificationScaler Home](./assets/screenshots/1.png)

## How it Works

This app monitors the dock's height (or width) and adjusts the magnification based on that. It writes to the dock's preferences (same as using the `defaults` command), then restarts the dock.

The caveat is that there is a small flicker when the dock restarts.

## Settings

- Scale: The scaling of the magnification compared to the dock's size. Use the Info button to learn more.
- Dock location: The app needs to know this, so it knows whether to use the width or the height of the dock as its factor. Click the Info button to learn more.
- Enable Magnification: Whether to enable magnification. Turning this off doesn't disable the app's functionality; it just tells macOS to not use magnification. If you turn this off, you should also probably turn off Auto-Restart Dock.
- Auto-Restart Dock: To restart the dock automatically on size changes. If this is disabled, then it just skips restarting the dock, and you'll have to do this manually. The preferences will still be set.

## Buttons
- Apply: Apply the settings you set and restart the dock (if Auto-Restart Dock is enabled).
- Restart Dock: Same as running `killall dock`.
- Quit: Quit MagnificationScaler.