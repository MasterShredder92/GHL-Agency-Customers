# The 15 Core Capabilities

**All 15 are usable today in any client sub-account.** Each is either Native (works in GHL as-is) or Build (needs Claude Code/API or a connector).

---

## The 15

| # | Capability | Native or Build | How It Works |
|---|---|---|---|
| **1** | **Instant lead response (AI SMS)** | Native | Contact created → workflow sends SMS via LC Phone within 2 min |
| **2** | **Cold lead follow-up** | Native | Tag-based workflow: 3-day, 7-day, 14-day sequences via SMS/email |
| **3** | **Warm lead re-engagement** | Native | Find dormant leads → targeted re-activation campaign via SMS |
| **4** | **No-show recovery** | Native* | Booking webhook → workflow sends reminder + reschedule link; *if booking is in GHL. Build if external scheduler |
| **5** | **Reactivation / win-back** | Native | Past customers tagged → custom re-engagement journey (SMS → email → upsell offer) |
| **6** | **Retention / loyalty touchpoints** | Native | Current customers → check-in SMS, birthday messages, referral requests |
| **7** | **Social auto-posting** | Native | Advanced CSV upload → GHL posts to Facebook/Instagram on schedule |
| **8** | **FAQ / routine message auto-handling** | Native | Keyword trigger in SMS → auto-reply from template (no human needed) |
| **9** | **Unified inbox** | Native | All SMS, email, chat, calls in one GHL conversation (no context switching) |
| **10** | **Pipeline / lead tracking** | Native | Contacts move through stages (Prospect → Qualified → Booked → Customer); reports on conversion rates |
| **11** | **Calendar & booking** | Native* | GHL calendar or external scheduler bridge; *limited for open-ended recurring (see north-star.md) |
| **12** | **Payments & invoicing** | Native* | One-time charges on any processor + recurring on Stripe; *recurring on Square/others = custom build or stays in client's tool |
| **13** | **Voice AI** | Native | Inbound call → AI agent answers, qualifies, books appointment (pay-per-minute) |
| **14** | **Reporting dashboards** | Native | Conversion funnels, SMS open rates, pipeline velocity, ROI (if you feed the data in) |
| **15** | **Snapshots (scaling)** | Native | Clone entire sub-account config to new client (workflows, tags, custom fields, automations) |

---

## The Zero-Limit Core

**These 9 work for ANY service business on ANY stack with NO connector needed:**

1. Instant lead response (AI SMS)
2. Cold lead follow-up
3. Warm lead re-engagement
4. Reactivation / win-back
5. Retention / loyalty touchpoints
6. Social auto-posting
7. FAQ / routine message auto-handling
8. Unified inbox
9. Pipeline / lead tracking

**Lead every sales pitch with these.** They're the no-compromise offer.

---

## Native vs. Build: How to Decide

- **Native:** Fully built into GHL. Activate in settings, build workflow, run. No custom code.
- **Build:** Needs Claude Code (MCP + API) to connect GHL to external tools or custom logic.

### When a Capability is "Build"

**Example: No-Show Recovery**
- *Native* if booking is in GHL Calendar → workflow sees it, sends reminder automatically
- *Build* if booking is in external scheduler (e.g., Square Appointments) → you need a webhook + API call to fetch Square appointments, then trigger GHL workflow

**Example: Recurring Payments**
- *Native* if using Stripe → GHL handles auto-billing natively
- *Build* or stays-in-client's-tool if using Square → GHL can create an invoice, but actual charging stays in Square

---

## How to Use This List

1. **On discovery calls:** Lead with the zero-limit 9. Those work today with zero dependencies.
2. **When client asks for X:** Look it up in the table. If Native, quote timeline as 1-2 weeks. If Build, spec the integration first.
3. **When building a workflow:** Pick the capabilities you need, list them, confirm client understands the native/build split.
4. **When scaling to new client:** Reference this list to scope the engagement (which 15 are we offering? Which 5 are custom?).

---

## Current Adkins Implementation

**Live/In-Progress:**
- ✅ Instant lead response (workflow built, A2P approval pending)
- 🔄 Cold lead follow-up (workflow template ready, awaiting SMS approval)
- 🔄 Social auto-posting (CSV template ready)
- 📋 Retention touchpoints (template built, not yet deployed)

**Not Yet Needed:**
- Voice AI (low priority until SMS is live)
- Advanced booking (Square Appointments used; GHL calendar is advisory only)

**Scoped for Later:**
- No-show recovery (webhook from Square → GHL → SMS reminder)
- Advanced reporting (post-first-month, once we have data)
