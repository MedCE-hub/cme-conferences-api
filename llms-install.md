# Installing the MedCE Hub CME conferences MCP server (for AI coding agents)

This server needs no API key, no environment variables and no build step. It runs with Node.js 18 or newer straight from GitHub.

## Steps

1. Check that Node.js 18+ is available: `node --version`.
2. Add this entry to the MCP settings file of the client (for Cline: `cline_mcp_settings.json`), inside `"mcpServers"`:

```json
"medcehub": {
  "command": "npx",
  "args": ["-y", "github:MedCE-hub/cme-conferences-api"]
}
```

3. Do not clone the repository and do not run `npm install`; `npx` downloads and starts the server by itself. The first start can take up to a minute.
4. Verify: the server should list 4 tools: `search_conferences`, `get_conference`, `get_ce_requirements`, `list_reference`. A quick test call: `get_ce_requirements` with `profession: "nurses"` and `state: "TX"`.

## Notes

- Transport: stdio. Read-only: the server only sends HTTPS GET requests to https://api.medcehub.com/v1/.
- Optional environment variable `MEDCEHUB_API_BASE` overrides the data URL; leave it unset.
- Docker alternative: `docker run -i --rm ghcr.io/medce-hub/cme-conferences-api`.
