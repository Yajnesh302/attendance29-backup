# Requirement Specification (v3): Admin-Owned Categories, Configurable Tiers, Resign-&-Rejoin Movement, Cross-Admin Sharing

> This version supersedes v2. The only change from v2: **all tier/category movement — whether within the same Main Category or across different Main Categories — is now handled as Resign + Rejoin.** There is no linking, no tier ranking/order, and no direct "upgrade/downgrade" action. Everything else from v2 (admin-owned categories, configurable tiers, cross-admin sharing, Other Employees tab) remains unchanged.

---

## 1. Roles Overview

### 1.1 Super Admin
- Creates Admin logins/accounts.
- Can create other Super Admins.
- Has full oversight/read access across **every** Main Category, every Admin, and every cross-admin sharing grant in the system (see §5).
- Does **not** create Main Categories, tiers, contracts, or perform any operational data entry — purely administrative + oversight.

### 1.2 Admin
- Each Admin creates and owns **exactly one Main Category** (e.g. "HR", "Cook", "Driver" — name fully configurable, chosen by the Admin).
- Within their own Main Category, the Admin defines:
  - The **Tier structure** (see §2) — fully configurable, can be different shapes for different categories.
  - **Role Labels** under each tier (optional — see §2.2).
  - **Contracts**, vendor assignments, attendance, and all operational data under their category.
  - **Regular users (POC)** — granting them access by Tier + Division.
- Can grant/revoke **sharing access** to their own Main Category to other Admins (see §5).
- Cannot see or touch another Admin's Main Category **unless** that Admin has explicitly shared access with them.

### 1.3 Regular User (POC)
- Scoped by Division **and** specific tier(s) within the category, as granted by the Admin who creates them.

---

## 2. Category Structure — Main Category → Tier → (optional) Role Label

### 2.1 Main Category
- Created and owned by exactly one Admin.
- Fully configurable name (e.g. `HR`, `Cook`, `Driver`, `Security`).

### 2.2 Tier
- Each Main Category defines its own set of Tiers — the **number of tiers and their names are fully configurable** per category. There is no fixed "Skilled/Semi-Skilled/Unskilled" requirement globally, and **no ranking/order between tiers is required** (see §3 — since movement is always resign + rejoin, there's no "up" or "down" direction to define).
  - Example — HR: `Skilled`, `Semi-Skilled`, `Unskilled` (3 tiers)
  - Example — Cook: `Head Cook`, `Cook`, `Helper` (3 tiers, different names) — or could be just `Cook` (1 tier)
  - Example — Driver: `Skilled`, `Unskilled` (2 tiers)
- **Two fields per tier:**
  - `Tier Name` — required (e.g. `Skilled`, `Cook`, `Head Cook`).
  - `Role Label` — optional (e.g. `Data Entry Operator`, `Office Staff`). If left blank, the system displays just the Tier Name. If filled, it displays `Tier Name # Role Label`.
    - HR example display: `Skilled # Data Entry Operator`, `Semi-Skilled # Office Staff`, `Unskilled # Attender`.
    - Cook example display: `Cook`, `Head Cook`, `Helper` (no Role Label needed).
- Tiers are identified internally by a **stable ID**, independent of their display text. Tier Name and Role Label can be renamed anytime, and new tiers can be added later, without breaking historical contracts/employee records tied to that tier ID.
- Contracts, ledgers, and document numbering continue to run **independently per Tier** — own contract period, own vendor bid, own sealed/closed cycle.

### 2.3 Display Format
Everywhere the system shows category info (grids, ledgers, documents, attendance sheets, reports), show:
`Main Category › Tier Name (# Role Label if present)`
e.g. `Cook › Head Cook`, `HR › Unskilled # Attender`.

---

## 3. Employee Movement — Always Resign & Rejoin

- There is **no linking, no ranking, and no direct upgrade/downgrade action** between tiers — this applies **whether the move is within the same Main Category or across two different Main Categories.**
- Any change in an employee's tier — for any reason (promotion, demotion, lateral move, department change) — is handled as two explicit steps:
  1. The Admin who currently has access to that employee (in their current Tier) marks them as **Resigned** from that Tier.
  2. The Admin who owns the destination Tier (could be the same Admin, if moving within their own Main Category, or a different Admin, if moving across Main Categories) **rejoins/onboards** the employee as a new entry under the destination Tier.
- This is a uniform rule with **no special case** for same-category moves — e.g. `HR › Unskilled` → `HR › Skilled` follows the exact same resign-then-rejoin flow as `Cook › Helper` → `HR › Unskilled`.
- **No approval step required** — whichever Admin has access to a given side of the move performs their step directly (resign or rejoin) with no dependency on the other Admin's confirmation.
- Full employee history is retained across all such moves (see §4) — the resignation and the subsequent rejoin are linked together as one continuous employee history, not two disconnected people.

---

## 4. Employee History Tracking

- Every employee record maintains a **complete history for as long as the project/employment continues**, covering every resign-and-rejoin move across tiers and Main Categories.
- Each rejoin event links back to the prior resignation via a persistent internal reference (e.g. a stable `EmployeeHistoryId` that survives across resign/rejoin cycles, distinct from the per-tier employee record), so the full chain (e.g. `Cook › Helper` → resigned → `Cook › Cook` → resigned → `HR › Unskilled` → rejoined) is viewable end-to-end.
- This history should be viewable by anyone with sufficient access (the relevant Admin(s) for the tiers/categories involved, and Super Admin).

---

## 5. Cross-Admin Sharing of a Main Category

- The Admin who **owns** a Main Category can **grant another Admin full access** to it.
  - Example: HR Admin grants Cook Admin access to the HR category.
- **Full access, not read-only**: once granted, the receiving Admin (Cook Admin in the example) can do everything the owning Admin can — create/edit contracts, mark attendance, resign/rejoin employees, etc. — inside the shared category.
- **One-directional**: granting Cook Admin access to HR does **not** give HR Admin any access to Cook's category. Each direction must be granted separately if needed.
- **Revocable**: the owning Admin (HR Admin) can revoke this access at any time.
- **Not re-shareable/chainable**: only the **original owning Admin** can grant or revoke access to their Main Category. An Admin who received shared access cannot re-share it with a third Admin.
- **Audit trail (assumption — please confirm/correct):** actions taken by a non-owning Admin inside a shared category should be logged/attributed to that acting Admin (e.g. "Cook Admin — via shared access to HR"), so there's a clear record of who did what inside someone else's category.
- **Super Admin oversight:** Super Admin can see a full list of all cross-admin sharing grants in the system (who granted access to whom, for which category) and can view all underlying data — though Super Admin does not grant/revoke these shares themselves (that stays with the owning Admin).

---

## 6. Employee Master — "Other Employees" Tab

- Existing tabs **Active** / **Resigned** now show only employees within the Admin's own Main Category (plus any category shared with them).
- New tab **Other Employees**: shows all employees outside the Admin's access — read-only.
- Super Admin sees everything, unscoped, with filtering/drill-down by Main Category / Tier.

---

## 7. Explicitly Confirmed / Out of Scope

- No data migration needed — existing flat Skilled/Semi-Skilled/Unskilled test data can be discarded; structure will be rebuilt fresh.
- No first-run wizard needed for the first Super Admin — this will be seeded directly via database update after deployment.
- No approval workflow for resign/rejoin actions — each Admin acts independently on their own side of the move.
- Same Main Category being owned by **multiple Admins simultaneously** is **not** required — each Main Category has exactly one owning Admin; access beyond that only happens via explicit sharing (§5).
- No tier ranking/order and no linking between tiers is needed anywhere in the system.

---

## 8. Summary Example

```
Admin: HR Admin
  Owns Main Category: HR
    Tier: Skilled       # Data Entry Operator
    Tier: Semi-Skilled  # Office Staff
    Tier: Unskilled     # Attender
    (No order/ranking between these — not needed)

Admin: Cook Admin
  Owns Main Category: Cook
    Tier: Head Cook
    Tier: Cook
    Tier: Helper
    (Role Label left blank for all — displays as just the Tier Name)

HR Admin grants Cook Admin full shared access to HR.
  → Cook Admin can now also create contracts, mark attendance,
    and resign/rejoin employees inside HR — in addition to their own Cook category.
  → HR Admin still cannot access Cook's category (one-directional).
  → HR Admin can revoke this grant at any time.

Employee Ramesh:
  Joins Cook › Helper.
  Later moves to Cook › Cook:
      Cook Admin marks Ramesh Resigned from Cook › Helper.
      Cook Admin rejoins Ramesh under Cook › Cook.
  Later moves to HR › Unskilled:
      Cook Admin (or whoever has access) marks Ramesh Resigned from Cook › Cook.
      HR Admin (or Cook Admin, since they have shared access) rejoins Ramesh under HR › Unskilled.
  → System retains full linked history across all three stops via internal EmployeeHistoryId.

Super Admin:
  Sees all Main Categories (HR, Cook, ...), all Admins, all sharing grants,
  full employee history, with filter/drill-down — but performs no contract/attendance actions.
```

---

## 9. Build Instructions for Antigravity

1. **Entities:**
   - `MainCategory` (owning Admin ID, name).
   - `Tier` (parent Main Category ID, Tier Name, optional Role Label, stable internal ID — **no order/rank field needed**).
   - `CategoryShareGrant` (owning Admin ID, granted-to Admin ID, Main Category ID, active/revoked flag, timestamp) — models the one-directional, non-chainable, revocable sharing in §5.
   - `EmployeeHistoryId` (or equivalent persistent identifier) on the employee record, preserved across resign/rejoin cycles so history can be reconstructed end-to-end regardless of how many tiers/categories the employee has passed through.
2. **Permissions layer:**
   - An Admin's effective visible categories = [Main Category they own] + [Main Categories shared **to** them via active `CategoryShareGrant`].
   - All contract/attendance/employee actions inside a shared category are permitted for the receiving Admin, logged with their identity for audit purposes.
   - Regular users are scoped by Division + specific Tier(s), assigned explicitly by the Admin who creates them (not automatically inherited from the Admin's full scope).
3. **Movement logic (replaces upgrade/downgrade from v2):**
   - Remove any concept of tier ranking, "next tier up/down," or linking.
   - Implement a single uniform **Resign** action (on the source Tier) and **Rejoin** action (on the destination Tier), usable for any move — same Main Category or different — with no approval dependency between the two steps.
   - On Rejoin, prompt to link the new record to a prior resigned record (search by name/ID) so the persistent `EmployeeHistoryId` carries forward; if the Admin doesn't find/select a prior record, treat as a brand-new employee with a fresh `EmployeeHistoryId`.
4. **Display layer:**
   - Replace all flat `Category` displays with `MainCategory › TierName (# RoleLabel if present)`.
5. **Employee Master:**
   - Add "Other Employees" tab per §6, scoped as described (visible categories = owned + shared-in).
6. **Super Admin screens:**
   - Main Category / Admin directory (read-only list, since Admins create their own categories).
   - Admin & Super Admin account creation.
   - Global view of all `CategoryShareGrant` records (read-only for Super Admin — grant/revoke stays with owning Admin).
   - Cross-category employee/contract oversight view with filter/drill-down, including full employee history view via `EmployeeHistoryId`.
7. **Contract/ledger/document numbering:** remains independent per Tier (not shared across a Main Category).
8. No data migration required — build against a clean/empty category structure; a single Super Admin account will be seeded manually via database update post-deployment.
