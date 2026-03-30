# B-Suite UX Standards

These are the established patterns across all B-Suite apps. When writing a PM brief, include relevant standards by reference (e.g., "Standard modal behavior applies") rather than re-specifying them. Nico's Cowork session should enforce these automatically — deviations require Brian's approval.

Last updated: March 29, 2026

---

## Modals & Panels

- **Escape to close** — all modals, side panels, search overlays. No exceptions.
- **Click-outside to close** — backdrop click closes modals (`e.target === e.currentTarget` pattern).
- **Two-step delete** — first click shows "Confirm Delete" state, second click executes. Never one-click delete.
- **Mobile swipe-down to close** — modals support touch drag-to-dismiss (120px threshold). Uses `passive: false` for preventDefault.
- **Modal as single editing surface** — modals contain all editable fields inline (title, tags, notes, messages). No separate "edit mode" or "edit page."
- **Cmd+Enter to save** from within a modal (if not in a textarea that needs Enter for newlines).
- **Cmd+Backspace to delete** from within a modal.

## Toasts & Notifications

- **react-hot-toast** — bottom-right position, 2.5s default duration.
- **Style:** Plus Jakarta Sans, 13px, 10px border-radius, 10px/16px padding.
- **Success:** green icon (#10B981). **Error:** red icon (#EF4444).
- **CRUD feedback:** every create, update, delete shows a toast confirming the action.
- **Notification feedback:** "Notified [Name]" or "Failed to notify [Name]" with 3s auto-clear.
- **Non-fatal failures:** metadata/notification failures show toast but don't block the user action. Only data-save failures restore state (e.g., restore draft if message send fails).

## Inline Editing

- **Click-to-edit** — fields become editable on click. No separate edit button.
- **Save on blur or Enter.** Cancel on Escape.
- **Auto-expanding textarea** — adjusts height based on scrollHeight.
- **Visual states:** dashed border when empty/placeholder, solid background when filled.
- **Helper text:** "Click outside to save · Esc to cancel" shown in edit mode.

## Drag-and-Drop

- **Native HTML5 DnD** — `draggable` attribute, `dataTransfer.setData('text/plain', id)`.
- **Optimistic update** — status change happens immediately on drop.
- **Mobile alternative:** swipe gestures instead of drag (damped at 0.6x, 60px snap threshold, 80px reveal width).

## Navigation

- **App Switcher bar** — fixed top bar, z-9999, dark bg (#1E1E1E). Color-coded pills per app.
- **Sidebar overlay** — always overlay (never static), even on desktop. Toggle via hamburger. Backdrop: `bg-black/30` with opacity transition.
- **Deep linking** — URL params (`?task=ID`) open modals on page load. Clean URL with `replaceState` after opening.
- **Mobile bottom nav** — tab bar with FAB for quick-add. Replaces sidebar on mobile.

## Responsive & Mobile

- **Breakpoint:** `window.innerWidth < 768` via `useIsMobile()` hook.
- **Separate mobile components** — MobileAgendaView, MobileBottomNav, MobileQuickAdd.
- **Touch targets:** minimum 44px.
- **touchAction: 'manipulation'** on mobile containers.
- **Safe area:** `pt-[env(safe-area-inset-top)]` for notch awareness.
- **Grid scaling:** `grid-cols-1` → `sm:grid-cols-2` or `sm:grid-cols-3` at breakpoints.

## Design System

### Typography
- **Primary font:** Plus Jakarta Sans (Google Fonts) — default for most apps.
- **Alternatives:** Inter (B People UI), Lora (B People brand/serif), DM Sans.
- **Card radius:** 12px across all apps.
- **Shadows:** subtle (`0 1px 3px rgba(0,0,0,0.06)`) to medium (`0 4px 16px rgba(0,0,0,0.08)`).

### Colors (per-app palettes exist, but shared patterns)
- **Priority colors:** Urgent `#EF4444` (red), Important `#F59E0B` (amber), Whenever `#10B981` (green).
- **Surface hierarchy:** white → `#FAFAFB` → `#F5F5F7` background.
- **Border:** `#E8E8ED` default.
- **Error states:** `bg-red-50 border-red-200 text-red-700`.
- **Success states:** green icon, green accent.

## Loading States

- **Skeleton loading** — `animate-pulse` placeholders matching card shapes with border and padding.
- **Spinner** — `animate-spin` circular border (`border-b-2 border-blue-600`, 48px).
- **Full-screen loader** on initial auth/data load. Prevents interaction until ready.
- **authLoading + dataLoading** — two-phase: auth resolves first, then data subscriptions fire.

## Error Handling

- **React ErrorBoundary** — class component wrapping entire app. Shows "Something broke" with reload button.
- **Try/catch on all Firestore writes** — toast on failure, never silent.
- **Graceful degradation:** separate message-save failures (restore draft) from metadata failures (fire-and-forget, toast only).
- **Auth errors:** red box (`bg-red-50 border-red-200`) with error message text.

## Authentication

- **Google Sign-In** — Firebase Auth, popup-based.
- **Allowlisted emails** — ALLOWED_EMAILS array in store.js. Only listed emails can sign in.
- **Owner/Viewer model** — owner UID in `appConfig`. Viewers resolved at runtime. Both get read-write (viewer distinction exists in code but both are full access as of March 16, 2026).
- **Auth state in Zustand** — `{ user, authLoading, isViewer, dataUid }`.
- **First-run seeding** — demo data created on first sign-in if collections are empty.

## Keyboard Shortcuts

- **Cmd/Ctrl+K** — open search modal.
- **Cmd/Ctrl+Z** — undo last delete (pops from `_undoStack`).
- **Escape** — close any modal, panel, search overlay, cancel inline edit.
- **Enter** — save inline edit (unless in textarea).
- **Cmd/Ctrl+Enter** — save modal form.
- **Cmd/Ctrl+Backspace** — delete from within modal.
- **Cross-platform:** always `(e.metaKey || e.ctrlKey)`.

## Data Patterns

- **Zustand single store** — all state in one store. Firebase `onSnapshot` feeds directly in.
- **Optimistic updates** — update Zustand immediately, Firestore write async. Snapshot listener reconciles.
- **Undo stack** — `_undoStack: []` stores full snapshots of deleted items. Cmd+Z restores.
- **Real-time subscriptions** — `onSnapshot` for all collections. Unsubscribe on signOut.
- **Namespaced collections** — Brian: `tasks`, `projects`. Nico: `nicoTasks`, `nicoProjects`, `nicoNotes`.
- **Shared Firebase project** — `b-things` for Things/Content Calendar/Brain Inbox/B Resources. `eddy-tracker-82486` for Eddy/HC Funnel/B Marketing. `b-people-759e5` for B People (standalone).

## Messaging & Collaboration

- **NoteThread** — iMessage-style threaded chat on tasks/cards. Messages in Firestore subcollection.
- **@mention notifications** — Slack DM + Brain Inbox via `handoff-notify` endpoint.
- **Unread indicators** — visual badge on cards with unread messages.
- **CollapsibleMessages** — expandable message thread in modals.
- **User registry** — centralized in `content-calendar/src/users.js` and `brain-inbox/api/handoff-notify.js`.
