#!/usr/bin/env node

/**
 * Setup CRM Foundation for GHL Sub-Account
 * Creates: Custom fields, tags, and sales pipeline (idempotent)
 *
 * Requires: GHL_ADKINS_API_KEY in .env
 * Usage: node setup-crm-foundation.mjs
 */

import https from 'https';
import { URL } from 'url';
import fs from 'fs';
import path from 'path';

// Load .env file
const envPath = path.join(path.dirname(import.meta.url).replace('file:///', ''), '..', '.env');
if (fs.existsSync(envPath)) {
  const envContent = fs.readFileSync(envPath, 'utf8');
  envContent.split('\n').forEach(line => {
    const [key, value] = line.split('=');
    if (key && !process.env[key]) {
      process.env[key] = value;
    }
  });
}

// Configuration — API_KEY MUST be in environment, never hardcoded
const API_KEY = process.env.GHL_ADKINS_API_KEY;
const LOCATION_ID = process.env.GHL_ADKINS_LOCATION_ID || 'TCahcPK9X1pptNjBJxP3';

const BASE_URL = 'https://services.leadconnectorhq.com';

const config = {
  CUSTOM_FIELDS: [
    {
      name: 'Instrument',
      dataType: 'SINGLE_OPTIONS',
      options: ['Piano', 'Guitar', 'Voice', 'Drums', 'Violin', 'Other']
    },
    {
      name: 'Student Age',
      dataType: 'NUMERICAL'
    },
    {
      name: 'Skill Level',
      dataType: 'SINGLE_OPTIONS',
      options: ['Beginner', 'Intermediate', 'Advanced']
    },
    {
      name: 'Preferred Times',
      dataType: 'LARGE_TEXT'
    },
    {
      name: 'Lead Source',
      dataType: 'TEXT'
    }
  ],

  TAGS: [
    'trial-requested',
    'trial-booked',
    'trial-completed',
    'enrolled',
    'lost',
    'nurture'
  ],

  PIPELINE: {
    name: 'Trial to Enrollment',
    stages: [
      { name: 'New Lead' },
      { name: 'Contacted' },
      { name: 'Trial Booked' },
      { name: 'Trial Completed' },
      { name: 'Enrolled' }
    ]
  }
};

// Helper: Make API request
function apiRequest(method, path, body = null) {
  return new Promise((resolve, reject) => {
    const url = new URL(BASE_URL + path);

    const options = {
      method,
      headers: {
        'Authorization': `Bearer ${API_KEY}`,
        'Content-Type': 'application/json',
        'Version': '2021-07-28'
      }
    };

    const req = https.request(url, options, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        if (res.statusCode >= 400) {
          reject(new Error(`${res.statusCode}: ${data || res.statusMessage}`));
        } else {
          try {
            resolve(JSON.parse(data || '{}'));
          } catch {
            resolve(data);
          }
        }
      });
    });

    req.on('error', reject);
    if (body) req.write(JSON.stringify(body));
    req.end();
  });
}

// ===== SETUP FUNCTIONS =====

async function setupCustomFields() {
  console.log('\n[CUSTOM FIELDS]');

  try {
    const existing = await apiRequest('GET', `/locations/${LOCATION_ID}/customFields`);
    const existingNames = new Set(existing.customFields?.map(f => f.name) || []);

    for (const field of config.CUSTOM_FIELDS) {
      if (existingNames.has(field.name)) {
        console.log(`  [OK] Field '${field.name}' already exists`);
      } else {
        try {
          await apiRequest('POST', `/locations/${LOCATION_ID}/customFields`, field);
          console.log(`  [OK] Created field '${field.name}'`);
        } catch (err) {
          if (err.message.includes('already exists')) {
            console.log(`  [OK] Field '${field.name}' already exists`);
          } else {
            throw err;
          }
        }
      }
    }
  } catch (err) {
    console.log(`  [WARN] Could not manage custom fields: ${err.message}`);
  }
}

async function setupTags() {
  console.log('\n[TAGS]');

  for (const tag of config.TAGS) {
    try {
      await apiRequest('POST', `/locations/${LOCATION_ID}/tags`, { name: tag });
      console.log(`  [OK] Tag '${tag}' created/exists`);
    } catch (err) {
      if (err.message.includes('409') || err.message.includes('400')) {
        console.log(`  [OK] Tag '${tag}' already exists`);
      } else {
        console.log(`  [WARN] Tag '${tag}': ${err.message}`);
      }
    }
  }
}

async function setupPipeline() {
  console.log('\n[PIPELINE] (UI-only — GET existing or create in UI)');

  try {
    const existing = await apiRequest('GET', `/opportunities/pipelines?locationId=${LOCATION_ID}`);
    const pipeline = existing.pipelines?.find(p => p.name === config.PIPELINE.name);

    if (pipeline) {
      console.log(`  [OK] Pipeline '${config.PIPELINE.name}' exists`);
      console.log(`  Stages:`);
      pipeline.stages?.forEach(s => console.log(`    - ${s.name} (id: ${s.id})`));
      console.log(`\n  → Use stage IDs above when creating opportunities via API`);
    } else {
      console.log(`  [INFO] Pipeline '${config.PIPELINE.name}' not found`);
      console.log(`  → Create it in Adkins UI: Opportunities → Pipelines → Create New Pipeline`);
      console.log(`  → Once created, re-run this script to capture stage IDs`);
    }
  } catch (err) {
    console.log(`  [WARN] Could not read pipelines: ${err.message}`);
  }
}

async function verify() {
  console.log('\n[VERIFICATION]');

  try {
    const fields = await apiRequest('GET', `/locations/${LOCATION_ID}/customFields`);
    console.log(`  [OK] Custom Fields: ${fields.customFields?.length || 0} total`);
    fields.customFields?.forEach(f => console.log(`    - ${f.displayName}`));
  } catch {
    console.log(`  [WARN] Could not verify custom fields`);
  }

  try {
    const pipelines = await apiRequest('GET', '/opportunities/pipelines');
    const pipeline = pipelines.pipelines?.find(p => p.name === config.PIPELINE.name);
    if (pipeline) {
      console.log(`  [OK] Pipeline '${config.PIPELINE.name}':`);
      pipeline.stages?.forEach(s => console.log(`    - ${s.name}`));
    }
  } catch {
    console.log(`  [WARN] Could not verify pipelines`);
  }
}

// ===== MAIN =====

async function main() {
  if (!API_KEY) {
    console.error('[FATAL] GHL_ADKINS_API_KEY not set in .env');
    console.error('Required: GHL_ADKINS_API_KEY=<rotated-pit>');
    process.exit(1);
  }

  console.log('=== GHL CRM Foundation Setup ===');
  console.log(`Location ID: ${LOCATION_ID}`);
  console.log(`API Key: ${API_KEY.substring(0, 20)}...`);

  await setupCustomFields();
  await setupTags();
  await setupPipeline();
  await verify();

  console.log('\n=== Setup Complete ===');
}

main().catch(err => {
  console.error('\n[FATAL]', err.message);
  process.exit(1);
});
