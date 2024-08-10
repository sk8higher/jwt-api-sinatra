# jwt-api-sinatra assignment

Run requests in Postman:

[<img src="https://run.pstmn.io/button.svg" alt="Run In Postman" style="width: 128px; height: 32px;">](https://god.gw.postman.com/run-collection/34454879-47cdf2ae-e410-475c-994c-ab76f34dee56?action=collection%2Ffork&source=rip_markdown&collection-url=entityId%3D34454879-47cdf2ae-e410-475c-994c-ab76f34dee56%26entityType%3Dcollection%26workspaceId%3D3aa4d990-fe59-4d29-bfac-8d664e6f37dc)

Hosted application onto a VPS (docker containers) [here](http://95.174.94.72:4567)

## POST /api/user
Only on hosted version, to create a mock user. Requires `email` param, returns `user_id` to use in other requests.

## GET /api/tokens
Requires `user_id` param, returns `access_token` and `refresh_token`.

## POST /api/refresh
Requires `user_id`, `refresh_token` params, Authorization header in `Bearer <access token>` format. Returns a new access token.

## Local dev

To seed the db: `rake db:seed`

`.env.db` file contents:

```
MONGO_INITDB_ROOT_USERNAME=<username>
MONGO_INITDB_ROOT_PASSWORD=<pass>
MONGOID_ENV=development
JWT_SECRET=<jwt-secret>
JWT_ISSUER=<jwt-issuer>
EMAIL_APP_PASSWORD=<app-pass>
EMAIL_APP_USERNAME=<app-username>
