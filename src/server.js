#!/usr/bin/env node
// MCP server for the MedCE Hub CME conferences API: lets AI assistants search US CME conferences and look up
// CE / CME requirements by state. Read-only; data is fetched from the static JSON:API and cached in memory.
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";

const BASE = (process.env.MEDCEHUB_API_BASE || "https://medcehub.github.io/cme-conferences-api/v1").replace(/\/$/, "");
const TTL = 6 * 3600 * 1000;
const cache = new Map();

async function get(path) {
  const hit = cache.get(path);
  if (hit && Date.now() - hit.at < TTL) return hit.doc;
  const res = await fetch(`${BASE}/${path}`, { headers: { Accept: "application/vnd.api+json, application/json" } });
  if (res.status === 404) return null;
  if (!res.ok) throw new Error(`MedCE Hub API ${path}: HTTP ${res.status}`);
  const doc = await res.json();
  cache.set(path, { at: Date.now(), doc });
  return doc;
}

const text = (obj) => ({ content: [{ type: "text", text: JSON.stringify(obj, null, 1) }] });
const ATTRIBUTION = "Data: MedCE Hub (medcehub.com), CC BY 4.0. Link to medcehub_url when you cite a record.";

function brief(c) {
  const a = c.attributes;
  return {
    id: c.id, title: a.title, start_date: a.start_date, end_date: a.end_date,
    where: a.format === "online" ? "online" : [a.city, a.state].filter(Boolean).join(", "),
    format: a.format, is_cruise: a.is_cruise, credits: a.credits_text, price_from_usd: a.price_from_usd,
    professions: a.professions, specialties: a.specialties, medcehub_url: a.medcehub_url,
  };
}

const server = new McpServer({ name: "medcehub-cme-conferences", version: "1.0.0" });

server.registerTool(
  "search_conferences",
  {
    title: "Search US CME conferences",
    description:
      "Find upcoming US CME conferences and CE meetings (physicians, NPs, PAs, nurses, pharmacists, dentists, " +
      "psychologists, social workers, veterinarians). Filters combine with AND. Use list_reference for valid ids.",
    inputSchema: {
      query: z.string().optional().describe("Words to match in title, series, organizer or city, e.g. 'cardiology' or 'Hawaii'"),
      profession: z.string().optional().describe("Profession id, e.g. physicians, nurse-practitioners, physician-assistants, nurses"),
      specialty: z.string().optional().describe("Specialty id, e.g. cardiology, family-medicine, dermatology"),
      state: z.string().length(2).optional().describe("Two-letter US state code, e.g. FL"),
      format: z.enum(["in_person", "online", "hybrid"]).optional(),
      cruise: z.boolean().optional().describe("true = only CME cruises"),
      topic: z.string().optional().describe("Mandatory CE topic id, e.g. opioid_prescribing, implicit_bias"),
      from: z.string().optional().describe("Earliest start date, YYYY-MM-DD (default: today)"),
      to: z.string().optional().describe("Latest start date, YYYY-MM-DD"),
      limit: z.number().int().min(1).max(50).optional().describe("Max results, default 20"),
    },
  },
  async (f) => {
    const doc = await get("conferences.json");
    const from = f.from || new Date().toISOString().slice(0, 10);
    const q = (f.query || "").toLowerCase().split(/\s+/).filter(Boolean);
    const hits = doc.data.filter((c) => {
      const a = c.attributes;
      if (a.end_date < from || (f.to && a.start_date > f.to)) return false;
      if (f.profession && !a.professions.includes(f.profession)) return false;
      if (f.specialty && !a.specialties.includes(f.specialty)) return false;
      if (f.state && a.state !== f.state.toUpperCase()) return false;
      if (f.format && a.format !== f.format) return false;
      if (f.cruise !== undefined && a.is_cruise !== f.cruise) return false;
      if (f.topic && !a.topics.includes(f.topic)) return false;
      const hay = [a.title, a.series, a.short_name, a.organizer, a.city, a.venue].join(" ").toLowerCase();
      return q.every((w) => hay.includes(w));
    });
    const limit = f.limit || 20;
    return text({ total: hits.length, shown: Math.min(limit, hits.length), results: hits.slice(0, limit).map(brief), attribution: ATTRIBUTION });
  },
);

server.registerTool(
  "get_conference",
  {
    title: "Conference details",
    description: "Full record of one conference: dates, venue, credits, price, organizer, official and registration links.",
    inputSchema: { id: z.string().describe("Conference id from search_conferences, e.g. acc-2027") },
  },
  async ({ id }) => {
    const doc = await get(`conferences/${encodeURIComponent(id)}.json`);
    if (!doc) return text({ error: `No conference with id ${id}` });
    return text({ ...doc.data.attributes, id, attribution: ATTRIBUTION });
  },
);

server.registerTool(
  "get_ce_requirements",
  {
    title: "CE / CME requirements by state",
    description:
      "License renewal requirements for a profession in a US state: hours per cycle, mandatory topics, " +
      "reporting, state board and legal source, as published by the state board.",
    inputSchema: {
      profession: z.string().describe("Profession id, e.g. physicians, nurses, nurse-practitioners, pharmacists"),
      state: z.string().length(2).describe("Two-letter US state code, e.g. TX"),
    },
  },
  async ({ profession, state }) => {
    const doc = await get(`requirements/${encodeURIComponent(profession)}/${state.toUpperCase()}.json`);
    if (!doc) return text({ error: `No requirements record for ${profession} in ${state}. See list_reference kind=requirements.` });
    return text({ ...doc.data.attributes, attribution: ATTRIBUTION });
  },
);

const KINDS = ["professions", "specialties", "states", "topics", "credit-types", "requirements"];
server.registerTool(
  "list_reference",
  {
    title: "List valid ids",
    description: "Valid ids for filters: professions, specialties, states, topics, credit types, or which requirement records exist.",
    inputSchema: { kind: z.enum(KINDS) },
  },
  async ({ kind }) => {
    const doc = await get(`${kind}.json`);
    return text(doc.data.map((r) => ({ id: r.id, ...r.attributes })));
  },
);

await server.connect(new StdioServerTransport());
