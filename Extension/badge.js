// Runs in the page's MAIN world (manifest "world": "MAIN") so we can directly
// hijack the Web Badging API. Outlook also calls setAppBadge/clearAppBadge —
// without the hijack our badge would be cleared whenever Outlook deems the
// inbox "seen". We replace Outlook's calls with no-ops; only this script
// controls the dock badge.

const origSet = navigator.setAppBadge && navigator.setAppBadge.bind(navigator);
const origClear = navigator.clearAppBadge && navigator.clearAppBadge.bind(navigator);

if (!origSet) {
  console.warn('[OutlookBadge] Web Badging API not available — needs Safari 17.4+');
} else {
  navigator.setAppBadge = () => Promise.resolve();
  navigator.clearAppBadge = () => Promise.resolve();
}

// ---------- detection ----------

// Folder tree items have `title="Posteingang - 9 Elemente (5 ungelesen)"`.
// Strict match for the top-level Inbox only — filters out subfolders and other
// mailboxes whose names happen to start with "Posteingang"/"Inbox".
// When the inbox is found but no "(N ungelesen)" suffix is present, we return
// 0 explicitly (Outlook drops the suffix entirely when count is 0).
function fromTreeTitle() {
  for (const el of document.querySelectorAll('[role="treeitem"][title]')) {
    const t = el.getAttribute('title') || '';
    if (!/^(Posteingang|Inbox)\s*-\s*[\d.,]+\s*(?:Element|item)/i.test(t)) continue;
    const m = t.match(/\((\d+)\s*(?:ungelesen|unread)/i);
    return m ? parseInt(m[1], 10) : 0;
  }
  return null;
}

// document.title fallback: only Outlook's own "(N) Inbox …" / "(N) Posteingang …"
// — not arbitrary "(N)" appearing in mail subject lines.
function fromDocTitle() {
  const m = document.title.match(/^\((\d+)\)\s*(?:Inbox|Posteingang)\b/i);
  return m ? parseInt(m[1], 10) : null;
}

// Last resort: count unread email rows
function fromUnreadRows() {
  return document.querySelectorAll(
    '[aria-label^="Ungelesen "], [aria-label^="Unread "]'
  ).length;
}

function getUnread() {
  const v = fromTreeTitle();
  if (v !== null) return v;
  const d = fromDocTitle();
  if (d !== null) return d;
  return fromUnreadRows();
}

// ---------- update loop ----------

let lastApplied = -1;
let pendingClear = null;
let scheduled = false;

async function apply(count) {
  if (!origSet) return;
  try {
    if (count > 0) await origSet(count);
    else await origClear();
    lastApplied = count;
  } catch (_) {}
}

async function update() {
  if (scheduled) return;
  scheduled = true;
  await Promise.resolve();
  scheduled = false;

  const count = getUnread();

  if (count > 0) {
    if (pendingClear) { clearTimeout(pendingClear); pendingClear = null; }
    if (count !== lastApplied) await apply(count);
    return;
  }

  // Debounce clear by 2 s — guards against transient 0 during DOM updates
  if (lastApplied <= 0 || pendingClear) return;
  pendingClear = setTimeout(async () => {
    pendingClear = null;
    await apply(getUnread());
  }, 2000);
}

// ---------- bootstrap ----------

function start() {
  if (!document.body) { setTimeout(start, 50); return; }

  update();

  new MutationObserver(update).observe(document.body, {
    subtree: true,
    childList: true,
    attributes: true,
    attributeFilter: ['title', 'aria-label'],
  });

  const titleEl = document.querySelector('title');
  if (titleEl) {
    new MutationObserver(update).observe(titleEl, {
      childList: true, characterData: true, subtree: true,
    });
  }

  setInterval(update, 10_000);
}

start();
