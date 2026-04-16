import { env } from "../config/env.js";
import { AppError } from "../utils/app-error.js";

function normaliseDate(value) {
  if (!value) {
    return null;
  }

  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? null : date;
}

function inferMode(raw) {
  const source = `${raw.mode ?? ""} ${raw.location ?? ""} ${raw.locationType ?? ""}`.toLowerCase();
  if (source.includes("remote")) {
    return "Remote";
  }

  if (source.includes("hybrid")) {
    return "Hybrid";
  }

  if (source.includes("on-site") || source.includes("onsite")) {
    return "On-site";
  }

  return raw.mode ?? "Unspecified";
}

function toArray(value) {
  if (!value) {
    return [];
  }

  if (Array.isArray(value)) {
    return value;
  }

  if (typeof value === "string") {
    return value
      .split(",")
      .map((item) => item.trim())
      .filter(Boolean);
  }

  return [];
}

function normaliseInternship(raw) {
  const title = raw.title ?? raw.position ?? raw.role;
  const company = raw.company ?? raw.companyName ?? raw.organisation;
  const sourceUrl = raw.sourceUrl ?? raw.url ?? raw.link ?? raw.applyUrl;

  if (!title || !company || !sourceUrl) {
    return null;
  }

  return {
    title,
    company,
    domain: raw.domain ?? raw.category ?? "General",
    mode: inferMode(raw),
    stipend: raw.stipend ?? raw.salary ?? raw.compensation ?? "Not specified",
    deadline: normaliseDate(raw.deadline ?? raw.applyBy ?? raw.lastDate),
    sourceUrl,
    tags: Array.from(
      new Set([
        ...toArray(raw.tags),
        ...toArray(raw.skills),
        ...toArray(raw.techStack),
      ]),
    ),
    description: raw.description ?? raw.summary ?? "",
    scrapedAt: new Date(),
  };
}

async function fetchTaskItems() {
  const url = `https://api.apify.com/v2/actor-tasks/${env.APIFY_TASK_ID}/run-sync-get-dataset-items?token=${env.APIFY_TOKEN}&format=json`;
  const response = await fetch(url, { method: "POST" });

  if (!response.ok) {
    throw new AppError("Apify task execution failed", 502);
  }

  return response.json();
}

async function fetchActorItems() {
  const runUrl = `https://api.apify.com/v2/acts/${env.APIFY_ACTOR_ID}/runs?token=${env.APIFY_TOKEN}&waitForFinish=120`;
  const runResponse = await fetch(runUrl, { method: "POST" });

  if (!runResponse.ok) {
    throw new AppError("Apify actor execution failed", 502);
  }

  const runPayload = await runResponse.json();
  const datasetId = runPayload?.data?.defaultDatasetId;

  if (!datasetId) {
    throw new AppError("Apify actor did not return a dataset", 502);
  }

  const itemsResponse = await fetch(
    `https://api.apify.com/v2/datasets/${datasetId}/items?token=${env.APIFY_TOKEN}&format=json`,
  );

  if (!itemsResponse.ok) {
    throw new AppError("Failed to fetch Apify dataset items", 502);
  }

  return itemsResponse.json();
}

export async function scrapeInternshipsFromApify() {
  if (!env.APIFY_TOKEN || (!env.APIFY_ACTOR_ID && !env.APIFY_TASK_ID)) {
    throw new AppError("Apify integration is not configured", 500);
  }

  const items = env.APIFY_TASK_ID ? await fetchTaskItems() : await fetchActorItems();
  return items.map(normaliseInternship).filter(Boolean);
}
