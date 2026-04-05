# ListEase Client

App Flutter único para Android, iOS e Web.

Stack base:

- `flutter_riverpod`
- `go_router`
- `dio`
- `google_sign_in`

Configuração via `--dart-define`:

```bash
flutter run \
  --dart-define=API_BASE_URL=http://localhost:3000/api/v1 \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=your-google-client-id.apps.googleusercontent.com
```

Ou usando o arquivo local:

```bash
flutter run --dart-define-from-file=env/development.json
```
