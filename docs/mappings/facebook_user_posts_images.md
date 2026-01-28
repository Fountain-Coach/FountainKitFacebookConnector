# Mapping: Facebook “Logged-in User Posts (Text + Images)”

Statement of purpose: **user-authorized storytelling; self-only; no surveillance**.

## Canonical Request (Contract)

This connector uses exactly this Graph API shape as its contract:

- `GET /me/posts?fields=message,created_time,permalink_url,attachments{media_type,media,url,subattachments}`

Pagination parameters:

- `limit` (default 25; hard-capped to prevent bulk export behavior)
- `after` (cursor)

Auth:

- Uses `Authorization: Bearer <access_token>` header (never logs tokens).

## Mapping Table (Graph → IDL)

| Graph Field | IDL Field |
|---|---|
| `id` | `Post.id` |
| `created_time` | `Post.createdAt` |
| `message` | `Post.text` (optional) |
| `permalink_url` | `Post.permalink` (optional) |
| `attachments.data[].media.image.src` | `Post.images[].url` |

All emitted `ImageAsset` values include:

- `source = "facebook"`
- `postId = Post.id`

## Image Extraction Rules

- Recursively walk `attachments` and `attachments.subattachments`.
- Include an image URL only when:
  - `media.image.src` is present, **and**
  - `media_type` is **not** a video type.
- If a post contains video attachments, those media items are ignored (no video ingestion).

## Edge Cases

- Missing `message`: allowed; `Post.text` remains `nil`.
- Missing `attachments`: allowed; `Post.images` becomes `[]`.
- Unknown fields: ignored safely.
- `attachments.subattachments`: supported; images in nested attachments are collected.
- Duplicate image URLs: de-duplicated per post.

## Data Minimization & Storage

Store as little as possible:

- Store normalized `Post` objects (including image URLs), not raw Graph payloads.
- Raw Graph JSON is only kept in-repo for deterministic tests (`fixtures/graph/me_posts.json`).

Deletion & disconnect:

- `disconnect(userId)`: deletes stored tokens for that user and stops access.
- `delete_user_data(userId)`: deletes stored normalized posts/images for that user.

Retention strategy:

- This package does not enforce a retention period; the host app decides. The connector’s default recommendation is minimal retention and user-controlled deletion.
