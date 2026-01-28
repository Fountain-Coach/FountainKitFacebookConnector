# Data Deletion Instructions — Fountain Coach Facebook Connector

Effective date: 2026-01-28

These instructions explain how to delete data imported from Facebook when using Fountain Coach apps that integrate this connector.

## Option A — Delete data in the app (recommended)

1) In the app’s Facebook settings, click **Disconnect** to stop further access (this removes stored tokens).
2) In the manuscript/session where you imported content, click **Clear imports** (or “Delete Facebook data”) to remove imported Facebook artifacts from the app’s storage.

This deletes the locally stored, normalized artifacts (post text + image URLs) that were imported for storytelling.

## Option B — Remove the app from Facebook

You can also remove the app’s access on Facebook:

1) Go to Facebook settings → **Apps and Websites**.
2) Find the app and **Remove** it.

Removing the app revokes access tokens at the Facebook account level. If you also want imported artifacts deleted from the host app’s local storage, use Option A as well.

## What we do NOT store

- We do not ingest or store video content via this connector.
- Host apps should store normalized artifacts (not full raw Graph payloads), except for in-repo test fixtures.

