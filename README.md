# FountainKit Facebook Connector (Compliance-First)

Facebook Graph API connector for **user-authorized storytelling**.

## Compliance & Scope (FCIS)

- **Self-only**: fetches **only** the logged-in user’s own posts via `GET /me/posts`.
- **Text + images only**: collects post text and image URLs; **video is always excluded**.
- **Data minimization**: normalize into a small, stable IDL model and store only what’s needed for the product.
- **User controls**: `disconnect(userId)` removes stored tokens; `delete_user_data(userId)` removes stored normalized artifacts.

## Pinned Graph API Version

This connector pins Meta Graph API version in code: `FacebookGraph.API_VERSION`.

## Environment Variables (Host App)

Do not commit secrets. The host app should load credentials from env vars (or its secret manager) and pass them into `FacebookOAuthConfig`.

- `FACEBOOK_APP_ID`
- `FACEBOOK_APP_SECRET`
- `FACEBOOK_REDIRECT_URI`

## Tests

- `swift test`
- Golden fixtures live in `fixtures/graph/me_posts.json` and `fixtures/idl/posts.json`.

## Docs

- `docs/sources/meta-graph.md`
- `docs/mappings/facebook_user_posts_images.md`
