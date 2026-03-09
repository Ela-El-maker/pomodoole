# Petal Focus QA Coverage Matrix

## Core Flows
- Onboarding: all 4 steps, back/next navigation, custom duration input with keyboard visible.
- Timer: start/pause/resume/stop, task intent text, completion -> break -> reflection.
- Tasks: create/edit/delete/complete/activate, notes visibility, due date + one-shot reminder.
- Statistics: daily/weekly/monthly buckets, weekly goal edit, achievements render.
- Settings: durations, notifications toggle, vibration toggle, haptic settings, sound preview, default sounds.
- Mixer: toggle/volume/density, solo sound, save/apply/delete mix, leave screen playback stop.

## Lifecycle and Device
- Background/foreground with running timer.
- Lock screen while timer running.
- Notification permission denied.
- Audio muted and headphones vs speaker route.
- Offline mode.

## Regression Assertions
- No keyboard overflow on onboarding custom inputs.
- No orphan preview audio after leaving mixer.
- Session completion increments linked task progress.
- Reminder cancellation on task delete/complete.
- Weekly goal persists after app restart.
