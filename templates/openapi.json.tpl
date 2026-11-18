{
  "openapi": "3.1.0",
  "info": {
    "title": "MedCE Hub API: CME conferences and CE requirements",
    "version": "1.0.0",
    "summary": "Free JSON:API for US CME conferences, medical conferences 2026 and 2027, and CE / CME requirements by state.",
    "description": "Read-only, free and open data from [MedCE Hub](https://medcehub.com), a directory of continuing medical education (CME) conferences in the United States.\n\n* **{{conferences}} CME conferences and CE meetings** from {{first_start}} to {{last_start}}: physicians, nurse practitioners (NP), physician assistants (PA), nurses, pharmacists, dentists, psychologists, social workers, veterinarians and more. Each conference has dates, city, format (in person, online, hybrid, CME cruise), CME / CE credits, price, organizer and the official link.\n* **{{requirements}} CE / CME requirement records** for {{requirement_states}} US jurisdictions and {{requirement_professions}} professions: hours per renewal cycle, mandatory topics (opioid prescribing, implicit bias, human trafficking and others), state board and legal source.\n\nThe API follows the [JSON:API 1.1](https://jsonapi.org/format/) document structure (`data`, `type`, `id`, `attributes`, `relationships`, `links`, `meta`). It is served as static files, so there is no API key, no rate limit beyond fair use and no filtering on the server: download a collection and filter it on your side, or use the MCP server from this repository, which does the filtering for AI assistants.\n\nData is updated regularly; `meta.generated` shows the build date. Every fact is taken from the official page of the conference or the state board; `checked_at` shows the date of the last check.\n\n**License:** data CC BY 4.0. Please credit \"MedCE Hub (medcehub.com)\" and link to the `medcehub_url` of the record.",
    "contact": { "name": "MedCE Hub", "url": "https://medcehub.com/contact", "email": "info@medcehub.com" },
    "license": { "name": "CC BY 4.0 (data)", "identifier": "CC-BY-4.0" }
  },
  "externalDocs": { "description": "MedCE Hub: CME conferences directory", "url": "https://medcehub.com" },
  "servers": [ { "url": "https://medcehub.github.io/cme-conferences-api/v1", "description": "Static JSON:API (GitHub Pages)" } ],
  "tags": [
    { "name": "Conferences", "description": "CME conferences, medical conferences and CE meetings in the US." },
    { "name": "Requirements", "description": "CME and CE requirements for license renewal by state and profession." },
    { "name": "Reference", "description": "Professions, specialties, states, mandatory topics and credit types." }
  ],
  "paths": {
    "/index.json": {
      "get": {
        "tags": ["Reference"], "operationId": "getIndex", "summary": "API entry point with counts and links",
        "responses": { "200": { "description": "Entry point", "content": { "application/vnd.api+json": { "schema": { "$ref": "#/components/schemas/IndexDocument" } } } } }
      }
    },
    "/conferences.json": {
      "get": {
        "tags": ["Conferences"], "operationId": "listConferences", "summary": "All upcoming CME conferences",
        "description": "All {{conferences}} conferences the MedCE Hub site currently lists, sorted by start date. Filter by `attributes.professions`, `attributes.specialties`, `attributes.state`, `attributes.format`, `attributes.topics` or dates on your side.",
        "responses": { "200": { "description": "Collection of conferences", "content": { "application/vnd.api+json": { "schema": { "$ref": "#/components/schemas/ConferenceCollection" } } } } }
      }
    },
    "/conferences/{id}.json": {
      "get": {
        "tags": ["Conferences"], "operationId": "getConference", "summary": "One conference",
        "parameters": [ { "name": "id", "in": "path", "required": true, "description": "Conference id, for example `acc-2027`.", "schema": { "type": "string" } } ],
        "responses": {
          "200": { "description": "Conference", "content": { "application/vnd.api+json": { "schema": { "$ref": "#/components/schemas/ConferenceDocument" } } } },
          "404": { "description": "Unknown id" }
        }
      }
    },
    "/requirements.json": {
      "get": {
        "tags": ["Requirements"], "operationId": "listRequirements", "summary": "Index of CE / CME requirements by state and profession",
        "responses": { "200": { "description": "Requirement index", "content": { "application/vnd.api+json": { "schema": { "$ref": "#/components/schemas/RequirementIndex" } } } } }
      }
    },
    "/requirements/{profession}/{state}.json": {
      "get": {
        "tags": ["Requirements"], "operationId": "getRequirement", "summary": "CE / CME requirements for one profession in one state",
        "parameters": [
          { "name": "profession", "in": "path", "required": true, "description": "Profession id from `/professions.json`, for example `physicians`, `nurses`, `nurse-practitioners`.", "schema": { "type": "string" } },
          { "name": "state", "in": "path", "required": true, "description": "Two-letter state code, for example `TX`.", "schema": { "type": "string", "pattern": "^[A-Z]{2}$" } }
        ],
        "responses": {
          "200": { "description": "Requirements", "content": { "application/vnd.api+json": { "schema": { "$ref": "#/components/schemas/RequirementDocument" } } } },
          "404": { "description": "No record for this profession and state" }
        }
      }
    },
    "/professions.json": { "get": { "tags": ["Reference"], "operationId": "listProfessions", "summary": "Professions with conference counts", "responses": { "200": { "description": "Professions", "content": { "application/vnd.api+json": { "schema": { "$ref": "#/components/schemas/ReferenceCollection" } } } } } } },
    "/specialties.json": { "get": { "tags": ["Reference"], "operationId": "listSpecialties", "summary": "Medical specialties with conference counts", "responses": { "200": { "description": "Specialties", "content": { "application/vnd.api+json": { "schema": { "$ref": "#/components/schemas/ReferenceCollection" } } } } } } },
    "/states.json": { "get": { "tags": ["Reference"], "operationId": "listStates", "summary": "US states with conference counts", "responses": { "200": { "description": "States", "content": { "application/vnd.api+json": { "schema": { "$ref": "#/components/schemas/ReferenceCollection" } } } } } } },
    "/topics.json": { "get": { "tags": ["Reference"], "operationId": "listTopics", "summary": "Mandatory CE topics (opioids, implicit bias and others)", "responses": { "200": { "description": "Topics", "content": { "application/vnd.api+json": { "schema": { "$ref": "#/components/schemas/ReferenceCollection" } } } } } } },
    "/credit-types.json": { "get": { "tags": ["Reference"], "operationId": "listCreditTypes", "summary": "CME / CE credit types (AMA PRA Category 1, ANCC, ACPE ...)", "responses": { "200": { "description": "Credit types", "content": { "application/vnd.api+json": { "schema": { "$ref": "#/components/schemas/ReferenceCollection" } } } } } } }
  },
  "components": {
    "schemas": {
      "JsonApi": { "type": "object", "properties": { "version": { "type": "string", "example": "1.1" } } },
      "Meta": {
        "type": "object",
        "properties": {
          "count": { "type": "integer" }, "generated": { "type": "string", "format": "date" },
          "source": { "type": "string", "format": "uri" }, "license": { "type": "string" }, "attribution": { "type": "string" }
        }
      },
      "ResourceIdentifier": { "type": "object", "required": ["type", "id"], "properties": { "type": { "type": "string" }, "id": { "type": "string" } } },
      "Credit": {
        "type": "object",
        "properties": { "type": { "type": "string", "example": "AMA_PRA_1" }, "name": { "type": ["string", "null"] }, "amount": { "type": ["number", "null"] } }
      },
      "ConferenceAttributes": {
        "type": "object",
        "properties": {
          "title": { "type": "string", "example": "ACC.27 Scientific Session & Expo" },
          "series": { "type": "string" }, "short_name": { "type": ["string", "null"] },
          "start_date": { "type": "string", "format": "date" }, "end_date": { "type": "string", "format": "date" },
          "dates_text": { "type": "string" }, "timezone": { "type": ["string", "null"] },
          "format": { "type": "string", "enum": ["in_person", "online", "hybrid"] },
          "is_cruise": { "type": "boolean", "description": "CME cruise or CME vacation at sea" },
          "status": { "type": "string", "enum": ["scheduled", "postponed", "cancelled"] },
          "city": { "type": ["string", "null"] }, "state": { "type": ["string", "null"], "description": "Two-letter US state code" },
          "country": { "type": ["string", "null"] }, "venue": { "type": ["string", "null"] },
          "latitude": { "type": ["number", "null"] }, "longitude": { "type": ["number", "null"] },
          "professions": { "type": "array", "items": { "type": "string" }, "description": "Ids from /professions.json" },
          "specialties": { "type": "array", "items": { "type": "string" }, "description": "Ids from /specialties.json" },
          "topics": { "type": "array", "items": { "type": "string" }, "description": "Mandatory CE topics covered, ids from /topics.json" },
          "credits": { "type": "array", "items": { "$ref": "#/components/schemas/Credit" } },
          "credits_text": { "type": ["string", "null"], "example": "34 ACPE" }, "max_credits": { "type": ["number", "null"] },
          "price_from_usd": { "type": ["number", "null"] }, "price_to_usd": { "type": ["number", "null"] },
          "early_bird_until": { "type": ["string", "null"], "format": "date" },
          "credit_claim_deadline": { "type": ["string", "null"], "format": "date" },
          "cme_provider": { "type": ["string", "null"] },
          "organizer": { "type": ["string", "null"] }, "organizer_website": { "type": ["string", "null"], "format": "uri" },
          "organizer_kind": { "type": ["string", "null"] },
          "official_url": { "type": ["string", "null"], "format": "uri" }, "registration_url": { "type": ["string", "null"], "format": "uri" },
          "summary": { "type": ["string", "null"] },
          "checked_at": { "type": ["string", "null"], "format": "date", "description": "Date the facts were last checked on the official page" },
          "medcehub_url": { "type": "string", "format": "uri", "description": "Conference page on MedCE Hub (link here when you use the record)" }
        }
      },
      "Conference": {
        "type": "object", "required": ["type", "id", "attributes"],
        "properties": {
          "type": { "type": "string", "const": "conferences" }, "id": { "type": "string" },
          "attributes": { "$ref": "#/components/schemas/ConferenceAttributes" },
          "relationships": {
            "type": "object",
            "properties": {
              "professions": { "type": "object", "properties": { "data": { "type": "array", "items": { "$ref": "#/components/schemas/ResourceIdentifier" } } } },
              "specialties": { "type": "object", "properties": { "data": { "type": "array", "items": { "$ref": "#/components/schemas/ResourceIdentifier" } } } }
            }
          },
          "links": { "type": "object", "properties": { "self": { "type": "string", "format": "uri" }, "medcehub": { "type": "string", "format": "uri" } } }
        }
      },
      "ConferenceCollection": {
        "type": "object",
        "properties": { "jsonapi": { "$ref": "#/components/schemas/JsonApi" }, "meta": { "$ref": "#/components/schemas/Meta" }, "data": { "type": "array", "items": { "$ref": "#/components/schemas/Conference" } } }
      },
      "ConferenceDocument": {
        "type": "object",
        "properties": { "jsonapi": { "$ref": "#/components/schemas/JsonApi" }, "data": { "$ref": "#/components/schemas/Conference" } }
      },
      "Rule": {
        "type": "object",
        "description": "One license type, as the state board publishes it.",
        "properties": {
          "license": { "type": "string", "example": "RN" },
          "credits_required": { "type": ["number", "null"] }, "unit": { "type": ["string", "null"] },
          "period_months": { "type": ["integer", "null"] }, "no_ce_required": { "type": ["boolean", "null"] },
          "cycle_basis": { "type": ["string", "null"] }, "fixed_deadline": { "type": ["string", "null"] },
          "cat1_min": { "type": ["number", "null"] }, "online_max_pct": { "type": ["number", "null"] },
          "accepted_credit_types": { "type": ["string", "null"] }, "reporting": { "type": ["string", "null"] },
          "topics": { "type": "array", "items": { "type": "object", "properties": {
            "topic": { "type": "string" }, "hours": { "type": ["number", "null"] }, "frequency": { "type": ["string", "null"] },
            "interval_months": { "type": ["integer", "null"] }, "who": { "type": ["string", "null"] }, "source_url": { "type": ["string", "null"] } } } },
          "legal_basis": { "type": ["string", "null"] }, "legal_basis_url": { "type": ["string", "null"] },
          "renewal_url": { "type": ["string", "null"] }, "source_url": { "type": ["string", "null"] },
          "checked_at": { "type": ["string", "null"], "format": "date" }
        }
      },
      "Requirement": {
        "type": "object",
        "properties": {
          "type": { "type": "string", "const": "requirements" }, "id": { "type": "string", "example": "nurses-TX" },
          "attributes": { "type": "object", "properties": {
            "state": { "type": "string" }, "state_name": { "type": "string" }, "profession": { "type": "string" },
            "board_name": { "type": ["string", "null"] }, "board_url": { "type": ["string", "null"] },
            "rules": { "type": "array", "items": { "$ref": "#/components/schemas/Rule" } },
            "medcehub_url": { "type": "string", "format": "uri" } } },
          "links": { "type": "object" }
        }
      },
      "RequirementDocument": { "type": "object", "properties": { "jsonapi": { "$ref": "#/components/schemas/JsonApi" }, "data": { "$ref": "#/components/schemas/Requirement" } } },
      "RequirementIndex": {
        "type": "object",
        "properties": { "jsonapi": { "$ref": "#/components/schemas/JsonApi" }, "meta": { "$ref": "#/components/schemas/Meta" },
          "data": { "type": "array", "items": { "type": "object", "properties": {
            "type": { "type": "string" }, "id": { "type": "string" },
            "attributes": { "type": "object", "properties": { "state": { "type": "string" }, "state_name": { "type": "string" }, "profession": { "type": "string" },
              "board_name": { "type": ["string", "null"] }, "medcehub_url": { "type": "string" }, "licenses": { "type": "array", "items": { "type": "string" } } } },
            "links": { "type": "object" } } } } }
      },
      "ReferenceCollection": {
        "type": "object",
        "properties": { "jsonapi": { "$ref": "#/components/schemas/JsonApi" }, "meta": { "$ref": "#/components/schemas/Meta" },
          "data": { "type": "array", "items": { "type": "object", "properties": { "type": { "type": "string" }, "id": { "type": "string" }, "attributes": { "type": "object" } } } } }
      },
      "IndexDocument": {
        "type": "object",
        "properties": { "jsonapi": { "$ref": "#/components/schemas/JsonApi" }, "meta": { "type": "object" }, "links": { "type": "object", "additionalProperties": { "type": "string", "format": "uri" } } }
      }
    }
  }
}
