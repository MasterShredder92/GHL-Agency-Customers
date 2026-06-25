# North Star — What ZiroWork Is

---

## The Frame (Never Lose This)

**ZiroWork is a done-for-you customer-acquisition and client-management service for service-based businesses.** It sits *on top of* whatever tools a client already uses and adds the engine most small businesses can't staff: instant lead response, relentless follow-up, reactivation, and retention.

**The vertical does not matter.** ZiroWork is processor- and vertical-agnostic. It serves any service business (music schools, coaching, consulting, trades, salons, etc.). The first client is Adkins Music Lessons — that's a case study, not the product category.

**The core promise to a client:** "We get you more customers and keep the ones you have. We don't touch the systems you already love."

---

## Why This Model Works

Most service businesses are terrible at follow-up. Owners are busy teaching, coaching, or delivering service. Leads fall through cracks. Students churn because nobody stays in touch.

ZiroWork automates that entire layer with AI + consistent messaging. Clients see:
- More booked appointments (leads don't get lost)
- Fewer no-shows (reminders + confirmations)
- Better customer retention (check-ins, re-engagement)
- More referrals (automated ask-for-referrals sequences)

Clients pay because they don't have to think about any of this.

---

## The Hub Model

- **You (Claude) = the hub.** You own the automation layer. All lead capture, qualification, follow-up, and re-engagement flows through your system.
- **Client = the business owner.** They own the customer relationship. They deliver the service and manage their calendar/billing in their existing tool.
- **Contact data = lives in your system (GHL).** For operational automation. But client always owns their customer forever.

ZiroWork sits **in front of** a client's booking/billing system, not inside it. So when a client uses Square, Stripe, Wix, a spreadsheet — ZiroWork feeds leads and runs comms; the client's tool keeps doing scheduling and billing.

---

## The Two Honest GHL Limits

**Know them. State them honestly. They rarely bite ZiroWork.**

1. **Recurring auto-billing is Stripe-only.** GHL can't auto-charge a card on file every cycle through Square or most non-Stripe processors. **Irrelevant to ZiroWork** because billing stays in the client's tool.

2. **Calendar is weak for open-ended recurring appointments.** GHL has a 24-occurrence cap, no indefinite recurrence, and reminders fire only on the first of a custom series. **Irrelevant to ZiroWork** because scheduling stays in the client's tool. Only matters if someone tries to run a recurring-appointment business *inside* GHL — which ZiroWork never does.

**If a future client wants an all-in-one that includes recurring scheduling/billing** (e.g., a music-school-software competitor), that's a **separate, later build** — GHL engine + thin custom scheduling/billing layer via the API. Not part of core ZiroWork.

---

## The Stack (Top-Down)

- **GHL = the engine.** Everything client-facing runs through GHL sub-accounts: lead capture, AI SMS, follow-up, pipelines, reporting.
- **Claude Code = the control layer.** Primary tool via GHL MCP + API for building, automating, and operating GHL in plain English. This is the day-to-day.
- **n8n = allowed but reluctant.** Only if Claude Code + API genuinely can't do something.
- **Make.com = avoid.** Integrations are often too limited; n8n is the smarter fallback.

---

## Current State

- GHL agency account live. **ZiroWork = agency level.**
- **Adkins Music Lessons = first sub-account** (Omaha, Bellevue, Gretna, Elkhorn locations).
- GHL MCP connected via Private Integration Token (PIT).
- Square is connected as a payment processor (one-time charges only; recurring stays in Square).
- A2P 10DLC SMS registration in progress (gates all SMS).

---

## The Adkins Engagement (First Real Delivery)

Andrea is Adkins director and knows she's the ZiroWork test client. The play:

- **ZiroWork delivers:** Instant lead response, fast follow-up, reactivation, retention touchpoints.
- **Adkins keeps Square:** Scheduling, recurring billing, processing. Nothing changes there.
- **The handoff seam:** ZiroWork puts a ready-to-enroll student in front of Andrea; she enrolls them in Square.
- **Success = two visible numbers in 30 days:** Students you didn't chase + social posts going out hands-free.

---

## Hard Preferences

- Plain language, no jargon. Lead with the answer, push back when something's a bad idea.
- Claude = architect/builder. Human commits/decides when it works.
- Trust behavior not self-reports. ("It runs / gate passes" counts; "looks done" doesn't.)
- Don't over-build. If something can be a script, say so before reaching for an agent.
