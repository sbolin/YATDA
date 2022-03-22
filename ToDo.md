#  YATDA
## Things to do:
- Refactor
- Real icon, not using SFSymbol character (will be rejected in app store)
- Clean up widget - separate into files, not dump into YATDAWidget.swift

## Bugs to fix:
- Reordering is broken and removed. Sort view works ok, so use that for now.
- TodoEditView textEditor field frame height seems to be broken - height on screen doesn't follow minHeight or height of frame. Should be SwiftUI bug.

## In Progress:

## One day to do:
- Priority button hard to hit, need to change from Menu to image+tapGesture. Otherwise, leave it at 18x18 frame size so works consistently
- "Simple entry" - like Reminders app, when entering todo hit return and new todo is automatically created. When working AddTaskView can be removed (more space)
- Tags? (requires change in DB)

## Fixed
~~- Edit view has too many horizontal lines (list or section lines)~~
~~- Add notes to todo (change in core data)~~
~~- App icon is ugly~~
~~- Daily Notification~~
~~- Widget not updating (Seems to be xcode bug?)~~
~~- TodoEditView doesn't show correct priority in segmented picker and can't change it.~~
~~- Sort behavior not consistent - some items refuse to sort properly, and sorting is odd.~~

