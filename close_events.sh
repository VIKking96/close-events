#!/usr/bin/env bash
# Close symptom events:
# if an incident is closed, close its event in events_status.txt.

cd "$(dirname "$0")" || exit 1

TICKETS_FILE="ticket_status"
EVENTS_FILE="events_tickets.txt"
STATUS_FILE="events_status.txt"

# Print column 2 of the line whose column 1 equals $1, in file $2
lookup() {
    awk -v key="$1" '$1 == key { print $2 }' "$2"
}

# Print an error and stop
fail() {
    echo "Error: $1" >&2
    exit 1
}

# Check the input files exist; create the events DB if missing
[[ -f "$TICKETS_FILE" ]] || fail "$TICKETS_FILE not found."
[[ -f "$EVENTS_FILE" ]] || fail "$EVENTS_FILE not found."
touch "$STATUS_FILE"

# 1. Ask for the incident number
read -rp "Enter the incident number: " incident
incident="${incident^^}"    # accept lowercase too
[[ -n "$incident" ]] || fail "no incident number entered."

# 2. Look up the ticket status, its event, and the event status
ticket_status=$(lookup "$incident" "$TICKETS_FILE")
[[ -n "$ticket_status" ]] || fail "incident $incident not found."

event=$(lookup "$incident" "$EVENTS_FILE")
[[ -n "$event" ]] || fail "no event linked to $incident."

event_status=$(lookup "$event" "$STATUS_FILE")

# 3. Opened ticket: do nothing
if [[ "$ticket_status" == "opened" ]]; then
    echo "Incident $incident is opened. Nothing to do."
    echo "$event  ${event_status:-not in $STATUS_FILE}"
    exit 0
fi

[[ "$ticket_status" == "closed" ]] || fail "unknown status '$ticket_status' for $incident."

# 4. Closed ticket: make sure its event is closed
if [[ "$event_status" == "closed" ]]; then
    echo "Incident $incident is closed. Event was already closed."
elif [[ -z "$event_status" ]]; then
    echo "$event  closed" >> "$STATUS_FILE"
    echo "Incident $incident is closed. Event added as closed."
else
    # awk can't edit in place: write to a temp file, then replace the original
    awk -v key="$event" 'BEGIN { OFS = "  " } $1 == key { $2 = "closed" } { print }' \
        "$STATUS_FILE" > "$STATUS_FILE.tmp" && mv "$STATUS_FILE.tmp" "$STATUS_FILE"
    echo "Incident $incident is closed. Event closed now."
fi

echo "$event  closed"
