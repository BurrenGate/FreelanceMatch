# API Generation (Axios)

This project uses OpenAPI Generator (`typescript-axios`) to produce a typed axios client.

## Commands

- Default (uses local backend):

```bash
npm run generate:api:local
```

- Custom OpenAPI URL:

```bash
OPENAPI_URL=http://localhost:8080/v3/api-docs npm run generate:api
```

## Output

Generated files are written to:

- `src/shared/api/generated`

Do not edit generated files manually. Put handwritten wrappers in:

- `src/shared/api/services`
