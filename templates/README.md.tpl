# CME Conferences API and MCP server

Free, open data on **{{conferences}} US CME conferences** (medical conferences {{first_start}} to {{last_start}}) and **CE / CME requirements by state**, from [MedCE Hub](https://medcehub.com), the directory of continuing medical education conferences in the United States.

* **API docs (Swagger / OpenAPI):** https://medce-hub.github.io/cme-conferences-api/
* **Format:** [JSON:API 1.1](https://jsonapi.org/), static files, no API key
* **MCP server:** lets Claude, ChatGPT and other AI assistants search CME conferences and look up state CE requirements
* **Updated:** regularly. Last build {{generated}}
* **License:** data CC BY 4.0 (credit "MedCE Hub" with a link, see [LICENSE-DATA.md](LICENSE-DATA.md)), code MIT ([LICENSE](LICENSE))

## What is inside

| Data | Count | Endpoint |
|---|---|---|
| CME conferences and CE meetings | {{conferences}} | [`/v1/conferences.json`](https://medce-hub.github.io/cme-conferences-api/v1/conferences.json) |
| One conference | | `/v1/conferences/{id}.json` |
| CE / CME requirements (state × profession) | {{requirements}} records ({{requirement_rules}} rules by license type), {{requirement_states}} US jurisdictions, {{requirement_professions}} professions | [`/v1/requirements.json`](https://medce-hub.github.io/cme-conferences-api/v1/requirements.json), `/v1/requirements/{profession}/{state}.json` |
| Professions | {{professions}} | [`/v1/professions.json`](https://medce-hub.github.io/cme-conferences-api/v1/professions.json) |
| Specialties | {{specialties}} | [`/v1/specialties.json`](https://medce-hub.github.io/cme-conferences-api/v1/specialties.json) |
| States, mandatory topics, credit types | | `/v1/states.json`, `/v1/topics.json`, `/v1/credit-types.json` |

Conferences cover physicians (CME), nurse practitioners and physician assistants, nurses, pharmacists, dentists, psychologists, social workers, therapists and veterinarians. Every record has dates, city and state, format (in person, online, hybrid), CME cruises, CME / CE credits (AMA PRA Category 1, ANCC, AANP, ACPE, ADA CERP, RACE ...), price, organizer, official link and the date the facts were checked on the official page.

Requirement records give the hours per renewal cycle, mandatory topics such as opioid prescribing, implicit bias, human trafficking or domestic violence, how hours are reported (CE Broker, attestation), the state board and the legal source.

## Quick start

```bash
curl -s https://medce-hub.github.io/cme-conferences-api/v1/conferences.json \
  | jq '.data[] | select(.attributes.specialties | index("cardiology")) | .attributes | {title, start_date, city, state, credits_text}'

curl -s https://medce-hub.github.io/cme-conferences-api/v1/requirements/nurses/TX.json | jq '.data.attributes.rules'
```

A conference record (shortened):

```json
{{example}}
```

The files are static, so the API has no server side filters: download a collection and filter it in your code. GitHub Pages sends `application/json`; the body is a JSON:API document.

## MCP server for AI assistants

Tools:

| Tool | What it does |
|---|---|
| `search_conferences` | Find CME conferences by words, profession, specialty, state, format, CME cruise, mandatory topic and dates |
| `get_conference` | Full record of one conference |
| `get_ce_requirements` | CE / CME requirements for one profession in one state |
| `list_reference` | Valid ids for professions, specialties, states, topics, credit types |

Claude Desktop, Claude Code or any MCP client (Node 18+):

```json
{
  "mcpServers": {
    "medcehub": {
      "command": "npx",
      "args": ["-y", "github:MedCE-hub/cme-conferences-api"]
    }
  }
}
```

Claude Code: `claude mcp add medcehub -- npx -y github:MedCE-hub/cme-conferences-api`

Docker: `docker run -i --rm ghcr.io/medce-hub/cme-conferences-api` (the same server as an image; listed in the official MCP Registry as `io.github.MedCE-hub/cme-conferences-api`)

Example questions: "Which cardiology CME conferences are in Florida in spring 2027?", "Nurse practitioner conferences 2027 with pharmacology hours", "CME cruises next year", "How many CE hours does a Texas RN need and which topics are mandatory?"

## Sources and accuracy

Facts come only from the official page of the conference, its organizer or the state licensing board; each record has `official_url` or `source_url` and `checked_at`. Rules change: always confirm a renewal requirement with the state board before you rely on it. Found a mistake or want your conference listed? Write to info@medcehub.com or use [Add your conference](https://medcehub.com/add-your-conference). Listing and corrections are free.

## Attribution

Please credit **MedCE Hub (medcehub.com)** and link to the `medcehub_url` of the record you use.

## More on MedCE Hub

* [CME conferences 2026 and 2027](https://medcehub.com/cme-conferences)
* [Nurse practitioner conferences](https://medcehub.com/nurse-practitioner-conferences)
* [CME requirements by state](https://medcehub.com/cme-requirements)
* [Nursing CE requirements by state](https://medcehub.com/nursing-ce-requirements)
