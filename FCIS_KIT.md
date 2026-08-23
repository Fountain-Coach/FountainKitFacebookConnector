# FCIS-KIT Declaration — FountainKitFacebookConnector

Declared under FCIS-KIT v1.0, requirement FCIS-KIT-01.

```yaml
FCIS-KIT:
  owns:
    - facebook_connector: self-only, user-authorized Facebook posts-and-images connector with normalized models and host-injected custody
  consumes: []
  third-party-exceptions: []
```

The seam excludes video, accepts only the authenticated user’s own posts, and keeps OAuth credentials and token
custody outside the kit. The host owns consent, SecretStore integration, user controls, product policy, and
publication.

## Release state

Current candidate source is `d5b94a6e3f2f4af15c49d413eee04dd4004105ba`. No semver release or GitHub release is claimed
until a clean-tree test run, annotated tag, release notes, and owning release decision satisfy FCIS-KIT-07.
