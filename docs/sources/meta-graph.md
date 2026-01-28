# Meta Graph API — Source of Truth

Purpose: **user-authorized storytelling; self-only; no surveillance**.

## Base URL + Pinned Version

- Base URL: `https://graph.facebook.com/`
- Pinned API version: `v24.0` (see `FacebookGraph.API_VERSION`)

## Relevant Meta Docs (Reference Links)

These are the source-of-truth pages used when implementing this connector:

- Graph API overview & versioning:
  - `https://developers.facebook.com/docs/graph-api/overview/`
  - `https://developers.facebook.com/docs/graph-api/overview/versioning/`
- Facebook Login — authorization code flow (manual/server-side flow):
  - `https://developers.facebook.com/docs/facebook-login/manually-build-a-login-flow/`
- Permissions:
  - `user_posts` (required to read the logged-in user’s posts): `https://developers.facebook.com/docs/permissions/reference/user_posts/`
- User posts edge (`/me/posts`):
  - `https://developers.facebook.com/docs/graph-api/reference/user/posts/`

## Connector Constraints

- Endpoint is **fixed** to `/me/posts` (no “fetch other users” support).
- Media ingestion is **images only**. Video is explicitly excluded at normalization time.
