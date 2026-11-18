# 🔔 close-events

> A Bash tool that keeps monitoring clean: when an incident is **closed**, its monitoring event gets **closed** too, so no orphaned alerts are left behind.

![Bash](https://img.shields.io/badge/Bash-4EAA25?logo=gnubash&logoColor=white) ![ShellCheck](https://img.shields.io/badge/ShellCheck-passing-brightgreen) ![Route DevOps Diploma](https://img.shields.io/badge/Route_DevOps_Diploma-final_project-blue)

## The problem
A monitoring tool raises an **event**, and the ticketing system opens an **incident** for it. Engineers fix the issue and close the incident, but the event often stays **open**. Dashboards then show alerts for problems that are already solved.

## What it does
```
incident number ──► ticket_status ──► opened?  → do nothing, show its event
                                  └─► closed?  → find its event → mark it closed
```

| File | Plays the role of | Line format |
|---|---|---|
| `ticket_status` | ticketing system | `INC...  opened/closed` |
| `events_tickets.txt` | monitoring tool (incident → event) | `INC...  event_id` |
| `events_status.txt` | events database | `event_id  opened/closed` |
| `close_events.sh` | the tool | |

## Run it
```bash
git clone https://github.com/VIKking96/close-events.git
cd close-events
./close_events.sh
```

```text
Enter the incident number: INC0000401362
Incident INC0000401362 is closed. Event closed now.
6192fd9a-9b03-71ec-01b9-0a4e23526031  closed
```

## Every case is handled
| Situation | Result |
|---|---|
| Incident is opened | Nothing changes; its event is shown |
| Incident closed, event still open | Event is set to `closed` |
| Incident closed, event already closed | Reported, nothing rewritten |
| Incident closed, event missing from the DB | Event is added as `closed` |
| Unknown incident, no linked event, empty input, missing files | Clear `Error:` message, exit code 1 |

Lowercase input (`inc0000401362`) works too.

## Design choices
- **Safe writes:** `awk` can't edit a file in place, so the tool writes to a temp file and replaces the original with `mv`. A crash never leaves a half-written events file.
- **One small `lookup` function** does every "find column 2 by key" search, so the logic reads top to bottom.
- **Fails loudly:** every missing file or unknown value stops with a message on stderr and a non-zero exit code.
- **Lint clean:** passes [ShellCheck](https://www.shellcheck.net/) with no warnings.

---
Built by [Ahmed Amr Helal](https://www.linkedin.com/in/ahmed-amr-helal) as the Shell Scripting final project of Route Academy's DevOps Diploma (2026).
