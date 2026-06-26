#!/usr/bin/env node

/**
 * Setup CRM Foundation for GHL Sub-Account
 * Creates: Custom fields, tags, and sales pipeline (idempotent)
 *
 * Requires: GHL MCP configured with valid API key in .mcp.json
 * Usage: node setup-crm-foundation.mjs
 */

const https = require('https');

// Configuration — API_KEY MUST be in environment, never hardcoded
const API_KEY = process.env.GHL_ADKINS_API_KEY;
const LOCATION_ID = process.env.GHL_ADKINS_LOCATION_ID || 'TCahcPK9X1pptNjBJxP3';

const BASE_URL = 'https://services.leadconnectorhq.com';

const config = {
  CUSTOM_FIELDS: [
    {
      fieldKey: 'instrument',
      displayName: 'Instrument',
      dataType: 'select',
      placeholder: 'Select instrument',
      picklist: ['Piano', 'Guitar', 'Voice', 'Drums', 'Violin', 'Other']
    },
    {
      fieldKey: 'student_age',
      displayName: 'Student Age',
      dataType: 'number',
      placeholder: 'Age'
    },
    {
      fieldKey: 'skill_level',
      displayName: 'Skill Level',
      dataType: 'select',
      placeholder: 'Select skill level',
      picklist: ['Beginner', 'Intermediate', 'Advanced']
    },
    {
      fieldKey: 'preferred_times',
      displayName: 'Preferred Times',
      dataType: 'textarea',
      placeholder: 'e.g., Weekday evenings, Saturday mornings'
    },
    {
      fieldKey: 'lead_source',
      displayName: 'Lead Source',
      dataType: 'text',
      placeholder: 'How did they find us?'
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
    const existingKeys = new Set(existing.customFields?.map(f => f.fieldKey) || []);

    for (const field of config.CUSTOM_FIELDS) {
      if (existingKeys.has(field.fieldKey)) {
        console.log(`  [OK] Field '${field.displayName}' already exists`);
      } else {
        await apiRequest('POST', `/locations/${LOCATION_ID}/customFields`, field);
        console.log(`  [OK] Created field '${field.displayName}'`);
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
      await apiRequest('POST', `/locations/${LOCATION_ID}/tags`, { tagName: tag });
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
  console.log('\n[PIPELINE]');

  try {
    const existing = await apiRequest('GET', '/opportunities/pipelines');
    const pipeline = existing.pipelines?.find(p => p.name === config.PIPELINE.name);

    if (pipeline) {
      console.log(`  [OK] Pipeline '${config.PIPELINE.name}' already exists`);
      console.log(`  Stages:`);
      pipeline.stages?.forEach(s => console.log(`    - ${s.name}`));
    } else {
      const created = await apiRequest('POST', '/opportunities/pipelines', config.PIPELINE);
      console.log(`  [OK] Created pipeline '${config.PIPELINE.name}'`);
      created.stages?.forEach(s => console.log(`    - ${s.name}`));
    }
  } catch (err) {
    console.log(`  [FAIL] ${err.message}`);
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
