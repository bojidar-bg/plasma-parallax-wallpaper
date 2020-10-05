# Parallax wallpaper plugin

[![KDE store link](https://img.shields.io/badge/kde.store.org-1427588-blue)](https://store.kde.org/p/1427588/)

[![video](https://user-images.githubusercontent.com/5276727/95115954-f8538a00-074e-11eb-9b93-38842f07bb1a.png)](https://streamable.com/w5rg0x)

This is a wallpaper plugin for Plasma 5 which allows its users to "stretch" an image between multiple virtual desktops, so that moving between those desktops shows different portions of the background.

*Note:* If using the Slide animation between virtual desktops, make sure that <kbd>System Settings</kbd> / <kbd>Workspace Behavior</kbd> / <kbd>Virtual Desktops</kbd> / <kbd>("Slide" animation configuration)</kbd> / <kbd>Slide desktop background</kbd> is off.

---

**Settings:**
* **Desktop Rows:** The number of desktop rows; this setting should have the same value as Settings / Workspace Behavior / Virtual Desktops.
* **Parallax Zoom Factor:** How much to zoom into the image. At 100%, parallax can be observed only on the side of the image that is longer than the screen. At higher values, parallax can be observed in both directions.
* **Parallax Crop Factor:** How much of the image to crop. At 100%, makes sure that parallax on X and parallax on Y moves the background by the same amount. At 0%, makes sure that all parts of the image are visible on some virtual desktop.
* **Slide Duration:** How long the slide animation should be.
