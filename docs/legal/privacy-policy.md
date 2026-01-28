# Privacy Policy — Fountain Coach Facebook Connector

Effective date: 2026-01-28

This policy describes the Facebook integration used by Fountain Coach products (e.g., Modernization Studio) via this repository’s connector library.

## Purpose (non‑surveillance)

This integration is for **user‑authorized storytelling**:

- You explicitly connect your own Facebook account.
- The app only reads **your own posts** (self‑access) to help you bring **your own text and images** into a writing/storytelling workflow.
- This is **not** intended for surveillance or monitoring other people.

## Data we access (data minimization)

When you connect Facebook, the app uses Meta’s Graph API to fetch only the fields needed for the product purpose:

- Post id
- Post created time
- Post text (message), if present
- Post permalink, if present
- Image media URLs from post attachments

We do **not** ingest video. If a post contains video attachments, those media items are ignored.

The canonical request used by this connector is documented in `docs/mappings/facebook_user_posts_images.md`.

## Where data is stored

Storage is determined by the host application integrating this library. In Fountain Coach apps:

- Facebook access tokens are stored securely (e.g., macOS Keychain).
- Imported Facebook content is stored as **normalized artifacts** (post text + image URLs), not full raw Graph payloads.
- This repository includes a sample Graph payload only as a **test fixture** in `fixtures/` (not user data).

## Sharing

We do not sell Facebook data. The app uses your imported content only within the product experience.

## Retention

Retention depends on the host app. The recommended default is **minimal retention** and user‑controlled deletion.

## Your controls

Within the host app you can:

- **Disconnect** Facebook: removes stored tokens and stops any further access.
- **Delete imported Facebook data**: deletes locally stored imported artifacts (posts/images) from the app’s storage.

You can also remove the app from your Facebook account via Facebook’s “Apps and Websites” settings.

## Contact

For questions or requests, open an issue in this repository.

