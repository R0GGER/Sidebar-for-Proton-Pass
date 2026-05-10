# Sidebar for Proton Pass (Firefox extension)

A simple Firefox extension that opens [Proton Pass](https://pass.proton.me)
in the Firefox sidebar. With one click on the toolbar icon (or via
`Ctrl+Alt+P`) you toggle the sidebar open or closed.

## Files

```
manifest.json     ← extension manifest (MV3, Firefox-specific)
background.js     ← click handler that toggles the sidebar
sidebar.html      ← local page that immediately redirects to Proton Pass
icons/icon.svg    ← icon for toolbar and sidebar
```

## Temporary install (for testing)

1. Open Firefox and go to `about:debugging#/runtime/this-firefox`.
2. Click **"Load Temporary Add-on…"**.
3. Select the `manifest.json` file from this folder.
4. The Proton Pass icon now appears in your toolbar. Click it to open the
   sidebar, or use `Ctrl+Alt+P`.

> Note: temporary add-ons are automatically removed when Firefox is
> closed. For permanent use, see below.

## Important: Proton Pass vault unlock

Cookies (and therefore your Proton login) are preserved between opening
and closing the sidebar — you don't have to log in again every time.

**However, on top of your login Proton Pass has a separate "vault
unlock"**. The decryption key for that lives only in the memory of the
sidebar page. As soon as you close the sidebar that memory is gone, and
you have to unlock your vault again. This is by design (zero-knowledge
encryption) and no extension can work around it, with the exception of
the official Proton Pass extension — which has its own background process
that keeps the key outside of the UI.

**Don't want to keep unlocking?** Change this in Proton Pass itself:

1. Open Proton Pass (in the sidebar or in a tab).
2. Click on your avatar/initials → **Settings**.
3. Go to **Security**.
4. Set **"Unlock with"** to **"None"**.

You will then stay signed in *and* your vault will stay unlocked as long
as you are signed in to your Proton account in Firefox.

## Permanent install

By default Firefox requires extensions to be signed by Mozilla. You have
two options:

### Option A — Package and self-sign via AMO

1. Create a ZIP of the contents of this folder (note: zip the files, not
   the folder itself):
   - Select `manifest.json`, `background.js`, `sidebar.html`, and the
     `icons/` folder.
   - Make a ZIP and rename the extension to `.xpi`.
2. Create a (free) account on
   [addons.mozilla.org](https://addons.mozilla.org/developers/).
3. Upload the `.xpi` file under **"Submit a New Add-on"** and choose
   **"On your own"** (self-hosted). You will receive a signed `.xpi`
   that you can install in Firefox via `about:addons` → gear icon →
   *"Install Add-on From File…"*.

### Option B — Firefox Developer Edition / Nightly / ESR

In these editions you can set `xpinstall.signatures.required` to `false`
in `about:config`, allowing you to install the unsigned `.xpi` directly.
This does **not** work in regular Firefox release.

## FAQ

**Can I assign a different keyboard shortcut?**
Yes. Go to `about:addons` → gear icon → *"Manage Extension Shortcuts"*
and pick a different combination. Default is `Ctrl+Alt+P`.

**Does my login from a normal tab also work in the sidebar?**
Yes, the sidebar uses the same Firefox cookies, so if you are signed in
to `pass.proton.me` in a tab, you are also signed in inside the sidebar.

**Does this work in Chrome or Edge?**
No. The `sidebar_action` API is Firefox-specific. Chrome has no
equivalent sidebar API for extensions.
