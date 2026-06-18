# Features missing from `aurora-mp/omp-cef` main

Draft GitHub issue. Compared our fork's working tree against `origin/main` (aurora-mp).

**Already covered upstream — dropping our versions:**
- Browser-create freeze-to-desktop (D3D off render thread) → upstream `06fb567` already marshals all three `Create*Internal` D3D allocations via `PostToMainThread` (manager.cpp:532/618/683).
- All our natives → upstream is a superset (it also adds `CEF_LoadUrl`, `CEF_SetEscapeMenuMode`, `CEF_SetPlayerListMode` + enums).

---

## Title
Gaps in aurora-mp/omp-cef main vs our fork: 3 client/server fixes + 2 features

## Body

Migrating from our fork to upstream `main`. Most of our prior fixes are now upstream. The following are **not** present in upstream main and we'd lose them on migration:

### 1. Camera heading flips ~180° at steep pitch (client)
`camera_heading` in the player-data tick is derived from the camera forward vector (`TheCamera.m_mCameraMatrix.at`) projected onto XY (manager.cpp ~L1905, `current.camera_heading = NormalizeDeg(camDeg)`). When the camera looks steeply up/down the horizontal part shrinks toward zero and flips sign crossing vertical, so heading jumps ~180°. Anything driven by it (e.g. a radar that rotates with the camera) flips with it.

**Fix:** use the horizontal camera→player bearing (orbit direction), which is pitch-independent; fall back to the forward vector only when the camera sits directly above the player.

### 2. WndProc not re-claimed as outermost (client)
`WndProcHook::EnsureInstalled()` exists (wndproc.cpp:32) but is never called. omp-cef subclasses the game window once at startup; SA-MP installs its own subclass *after* us, so SA-MP sees keystrokes first — e.g. Tab opens the scoreboard while a CEF input is focused, and our hook can never consume them.

**Fix:** call `wndproc_->EnsureInstalled()` from the per-frame `OnPresent` loop (the method already self-throttles to 250ms), so we keep re-claiming the outermost position after SA-MP and anything else that subclasses later.

### 3. PAWN callbacks fire on the network thread (server)
The OMP bridge invokes PAWN publics (`CallPawnPublic`) and the typed callbacks (`OnCefBrowserCreated` / `OnCefDownloadStart` / `OnCefDownloadFinish` / `OnCefPressKey`) directly from the plugin's network thread. PAWN/AMX execution and open.mp natives are not thread-safe, so these race the main server tick — observed as intermittent crashes with backtraces running Cef.dll → Pawn → streamer → fault.

**Fix:** queue every PAWN-facing call and drain it on the main thread. `IPlatformBridge` gains `ProcessPending()`; the bridge enqueues under a mutex; the component registers `onTick` and drains there. No public API or PAWN-facing behaviour changes — callbacks just fire on the next main-thread tick.

### 4. Feature: chat send from the CEF UI (`send_chat_message`)
Lets the JS UI make the local player send a chat line / client command. Render process posts IPC `send_chat_message` (client.cpp:264) → `BrowserManager::QueueChatSend` (thread-safe queue) → flushed on the main thread in `app.cpp` via `FlushPendingChatSends` → `ChatComponent::Send` → `ChatView::Send` per SA-MP version.

Each `ChatView::Send` registers SA-MP's reserved client commands (`Commands::Setup()`) once before forwarding, because omp-cef disables the native chat input so SA-MP's own setup never runs — without it `CInput::Send` forwards every `/cmd` to the server instead of dispatching the client handler.

### 5. Feature: 3D model preview rendering (client)
`rendering/model_preview.{cpp,hpp}` — renders a GTA model into a CEF-facing texture for preview UIs. Entirely absent upstream; wired through `app.cpp`, `browser/client.cpp`, `browser/manager.{cpp,hpp}`.

---

## Divergences (not bugs, decide per-case — likely keep upstream's)
- **Pause-menu draw gate:** we gate `SetDrawEnabled` on `m_nCurrentMenuPage == MENUPAGE_PAUSE_MENU`; upstream gates on `!m_bDontDrawFrontEnd` and explicitly hides browsers in *all* menus (`90116ff`). Upstream's is broader — keep it.
- **Foreground-window diagnostics:** our `DescribeForegroundWindow()` + WM_ACTIVATE/WM_ACTIVATEAPP logging is debug-only (fullscreen minimize investigation). Drop or keep as logging.
- **Scoreboard:** we removed the old `ScoreboardHook`; upstream replaced it with `CEF_SetPlayerListMode` + samp scoreboard hook (`42b854f`). Adopt upstream's.
