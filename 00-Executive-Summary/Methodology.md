# Methodology

## Phase 1 — Discovery

I started by taking inventory of everything in the 52 Logistics tenant. That meant reviewing the existing users and groups, checking how licensing was assigned, looking at what authentication settings were already in place, and identifying who held privileged roles. The goal here wasn't to fix anything yet, just to get an honest, complete picture of what I actually inherited before I started forming opinions about it.

---

## Phase 2 — Analysis

With the inventory done, I moved into assessing what it actually meant from a risk standpoint. I reviewed how administrative roles were assigned across the tenant, evaluated the Conditional Access posture, which at this point meant confirming just how little was configured, and assessed what Identity Protection capabilities were available and whether they were being used. From there I identified the concrete gaps between where the tenant stood and where it needed to be.

---

## Phase 3 — Recommendations

Once I knew what the gaps actually were, I worked through what it would take to close them. I developed remediation plans for each finding, prioritized them based on risk rather than tackling them in whatever order I found them, and made sure every recommendation tied back to Zero Trust principles rather than being a one-off fix.

---

## Phase 4 — Validation

Recommendations don't mean much until they're actually implemented and proven to work. In this phase I tested the controls I put in place to confirm they behaved as intended, verified that legitimate users and workflows weren't unintentionally blocked in the process, and re-checked the tenant against the same gaps I identified in Phase 2 to confirm they'd actually closed.

---

## Phase 5 — Documentation

The last phase was making sure none of this work disappears the moment my access to the tenant does. I documented each phase as I went, captured screenshots and exported configuration as evidence rather than relying on memory after the fact, and wrote up the reasoning behind every major decision so the project reads as a record of how I actually thought through securing this tenant, not just a list of settings I changed.