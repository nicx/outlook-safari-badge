# Outlook Unread Badge – Safari Extension

A small Safari Web Extension that shows the number of unread Inbox mails as a red badge on the **Outlook PWA's dock icon** (the standalone Outlook web app added to the macOS Dock via Safari).

Modern Outlook (`outlook.cloud.microsoft`) doesn't keep the dock badge sticky — as soon as you open the inbox, Outlook clears it. This extension hijacks Outlook's calls to `navigator.setAppBadge`/`clearAppBadge` and keeps the badge in sync with the actual unread count.

---

## For end users: install the prebuilt app

You received `OutlookSafariBadge.zip`.

1. Unzip → `OutlookSafariBadge.app`
2. Drag & drop into `/Applications/`
3. **First launch:** right-click the app → **„Open"** → in the dialog confirm with **„Open"**
   (one-time Gatekeeper bypass — the app isn't App-Store-signed)
4. The app runs briefly to register the extension with Safari. You can quit it afterwards.
5. Safari → Settings (⌘,) → tab **„Advanced"** → enable „Show features for web developers"
6. Safari menu bar → **„Develop"** → enable **„Allow Unsigned Extensions"**
   ⚠️ You must re-enable this after every Safari restart — Apple's security policy for non-certified extensions.
7. Safari → Settings → **„Extensions"** → tick „Outlook Unread Badge"
8. In the permissions on the right → for `outlook.cloud.microsoft` → **„Always Allow on This Website"**
9. Open Outlook PWA from the dock (or as a Safari tab) — badge appears as soon as there are unread mails.

**Requirements on the Mac:**
- macOS 14+
- Safari 17.4+
- Outlook added as PWA (Safari → File → „Add to Dock") or open as a tab

---

## For maintainers: build the app yourself

### One-time setup

```bash
# Install Xcode from the App Store (free), then:
./setup.sh
# → Generates the Xcode project from the sources in Extension/
```

### Release build for distribution

```bash
./build-release.sh   # produces dist/OutlookSafariBadge.app (ad-hoc signed, doesn't expire)
./package.sh         # packages it into dist/OutlookSafariBadge.zip
```

Distribute the zip. Recipients follow the **„For end users"** section above.

### Local test of the release build

```bash
open dist/OutlookSafariBadge.app
# Then verify in Safari that the extension is active
# and the badge appears on the Outlook PWA dock icon.
```

### After changing extension code

1. Edit files in `Extension/` (`badge.js`, `manifest.json`)
2. If icons changed: `swift generate-icons.swift .`
3. Run `./build-release.sh` again
4. Distribute the new zip

---

## Known limitations (without Apple Developer Program)

| Issue | Impact |
|-------|--------|
| „Allow Unsigned Extensions" toggle | resets after every Safari quit — must be re-enabled |
| Gatekeeper on first launch | one-time right-click → „Open" per Mac |
| No auto-update | new versions must be distributed manually |
| Not notarized | some security tools may warn |

With Apple Developer Program ($99/yr) + notarization these would all go away.

---

## How it works (in brief)

- `Extension/badge.js` runs in Outlook's **main world** (`"world": "MAIN"` in the manifest), so it can directly intercept `navigator.setAppBadge()`.
- Outlook's own `setAppBadge`/`clearAppBadge` calls are hijacked into no-ops — otherwise Outlook would wipe our badge as soon as the inbox is viewed.
- The unread count is read primarily from `[role="treeitem"][title="Posteingang - N Elemente (X ungelesen)"]` (the folder tree's tooltip), with fallbacks on `document.title` and counting `aria-label^="Ungelesen "` mail rows.
- A `MutationObserver` triggers updates on DOM changes, plus a 10-second safety-net interval.

---

## Project structure

```
OutlookSafariBadge/
├── Extension/                      ← Web Extension source
│   ├── manifest.json
│   ├── badge.js
│   └── icons/                      ← 48/96/128 px
├── OutlookSafariBadge/             ← generated Xcode project (gitignored)
├── dist/                           ← build output (.app + .zip, gitignored)
├── setup.sh                        ← generates Xcode project from Extension/
├── build-release.sh                ← builds release .app
├── package.sh                      ← packages .app into .zip
├── generate-icons.swift            ← icon generator
└── README.md
```

---

## License

MIT — see [LICENSE](LICENSE).
