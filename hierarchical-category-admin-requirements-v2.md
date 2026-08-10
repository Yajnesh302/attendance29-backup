# Requirement Specification : Admin-Owned Categories, Configurable Tiers, Linked Upgrades & Cross-Admin Sharing

> This version supersedes the earlier draft. The key shift: **Admins now build and own their Main Category themselves** (not Super Admin), tier structures are fully configurable per category, and admins can share access to their own category with other admins.

---

## 1. Roles Overview

### 1.1 Super Admin
- Creates Admin logins/accounts.
- Can create other Super Admins.
- Has full oversight/read access across **every** Main Category, every Admin, and every cross-admin sharing grant in the system (see §5.5).
- Does **not** create Main Categories, tiers, contracts, or perform any operational data entry — purely administrative + oversight.

### 1.2 Admin
- Each Admin creates and owns **exactly one Main Category** (e.g. "HR", "Cook", "Driver" — name fully configurable, chosen by the Admin).
- Within their own Main Category, the Admin defines:
  - The **Tier structure** (see §2) — fully configurable, can be different shapes for different categories.
  - **Role Labels** under each tier (optional — see §2.2).
  - **Contracts**, vendor assignments, attendance, and all operational data under their category.
  - **Regular users (POC)** — granting them access by Sub-tier + Division (as before).
- Can grant/revoke **sharing access** to their own Main Category to other Admins (see §5).
- Cannot see or touch another Admin's Main Category **unless** that Admin has explicitly shared access with them.

### 1.3 Regular User (POC)
- Unchanged in principle: scoped by Division **and** specific tier(s) within the category, as granted by the Admin who creates them.

---

## 2. Category Structure — Main Category → Tier → (optional) Role Label

### 2.1 Main Category
- Created and owned by exactly one Admin.
- Fully configurable name (e.g. `HR`, `Cook`, `Driver`, `Security`).

### 2.2 Tier
- Each Main Category defines its own set of Tiers — the **number of tiers, their names, and their order are fully configurable** per category. There is no fixed "Skilled/Semi-Skilled/Unskilled" requirement globally.
  - Example — HR: `Skilled`, `Semi-Skilled`, `Unskilled` (3 tiers)
  - Example — Cook: `Head Cook`, `Cook`, `Helper` (3 tiers, different names) — or could be just `Cook` (1 tier)
  - Example — Driver: `Skilled`, `Unskilled` (2 tiers, one skipped)
- **Two fields per tier:**
  - `Tier Name` — required (e.g. `Skilled`, `Cook`, `Head Cook`).
  - `Role Label` — optional (e.g. `Data Entry Operator`, `Office Staff`). If left blank, the system displays just the Tier Name. If filled, it displays `Tier Name # Role Label`.
    - HR example display: `Skilled # Data Entry Operator`, `Semi-Skilled # Office Staff`, `Unskilled # Attender`.
    - Cook example display: `Cook`, `Head Cook`, `Helper` (no Role Label needed).
- The Admin explicitly marks the **relative order** of tiers (which is "top" and which is "bottom", full ranking) — this ordering is what drives upgrade (move up) vs downgrade (move down) direction (see §3).
- Tiers are identified internally by a **stable ID**, independent of their display text. Tier Name and Role Label can be renamed anytime, and new tiers can be added later, without breaking historical contracts/employee records tied to that tier ID.
- Contracts, ledgers, and document numbering continue to run **independently per Tier**, same as the previous spec (own contract period, own vendor bid, own sealed/closed cycle).

### 2.3 Display Format
Everywhere the system shows category info (grids, ledgers, documents, attendance sheets, reports), show:
`Main Category › Tier Name (# Role Label if present)`
e.g. `Cook › Head Cook`, `HR › Unskilled # Attender`.

---

## 3. Linked Upgrade / Downgrade (within a Main Category only)

- Since tiers within one Main Category have an explicit order (top→bottom), the Admin who owns that category can configure **links between adjacent (or any) tiers** to define valid upgrade/downgrade paths.
- **Linking is scoped strictly within the same Main Category** — a tier in `Cook` cannot be linked to a tier in `HR`. Cross-category movement is never a "linked" upgrade/downgrade (see §4).
- When an upgrade/downgrade action is triggered for an employee, the system uses the tier order to determine "the tier above" / "the tier below" and moves the employee accordingly.
- **No approval step required** — the acting Admin (who owns the category) performs the move directly; it takes effect immediately.
- Full employee history is retained across tier changes within the same Main Category (see §6).

---

## 4. Cross-Category Movement (no link exists)

- If an employee moves from one Main Category to a **different** Main Category (e.g. Cook → HR) — since no link is possible across categories — this is treated as:
  1. The **origin category's Admin** marks the employee as **Resigned** from that category.
  2. The **destination category's Admin** then **rejoins/onboards** the employee as a new entry under their category.
- The employee record retains a back-reference/history trail connecting the resignation and the rejoin — the employee's **complete history is tracked end-to-end across categories** (not a fully disconnected fresh record). See §6.

---

## 5. Cross-Admin Sharing of a Main Category

- The Admin who **owns** a Main Category can **grant another Admin full access** to it.
  - Example: HR Admin grants Cook Admin access to the HR category.
- **Full access, not read-only**: once granted, the receiving Admin (Cook Admin in the example) can do everything the owning admin can — create/edit contracts, mark attendance, upgrade/downgrade employees, etc. — inside the shared category.
- **One-directional**: granting Cook Admin access to HR does **not** give HR Admin any access to Cook's category. Each direction must be granted separately if needed.
- **Revocable**: the owning Admin (HR Admin) can revoke this access at any time.
- **Not re-shareable/chainable**: only the **original owning Admin** can grant or revoke access to their Main Category. An Admin who received shared access cannot re-share it with a third Admin.
- **Audit trail (assumption — please confirm/correct):** actions taken by a non-owning Admin inside a shared category should be logged/attributed to that acting Admin (e.g. "Cook Admin — via shared access to HR"), so there's a clear record of who did what inside someone else's category.
- **Super Admin oversight:** Super Admin can see a full list of all cross-admin sharing grants in the system (who granted access to whom, for which category) and can view all underlying data — though Super Admin does not grant/revoke these shares themselves (that stays with the owning Admin).

---

## 6. Employee History Tracking

- Every employee record maintains a **complete history for as long as the project/employment continues**, covering:
  - Tier-to-tier upgrade/downgrade moves within a Main Category (§3).
  - Cross-category moves via resign-then-rejoin (§4), with the two events linked together as one continuous employee history rather than appearing as two unrelated people.
- This history should be viewable end-to-end by anyone with sufficient access (the relevant Admin(s) for the categories involved, and Super Admin).

---

## 7. Employee Master — "Other Employees" Tab (unchanged from prior spec)

- Existing tabs **Active** / **Resigned** now show only employees within the Admin's own Main Category (plus any category shared with them).
- New tab **Other Employees**: shows all employees outside the Admin's access — read-only.
- Super Admin sees everything, unscoped, with filtering/drill-down by Main Category / Tier.

---

## 8. Explicitly Confirmed / Out of Scope

- No data migration needed — existing flat Skilled/Semi-Skilled/Unskilled test data can be discarded; structure will be rebuilt fresh.
- No first-run wizard needed for the first Super Admin — this will be seeded directly via database update after deployment.
- No approval workflow for upgrade/downgrade/transfer actions — direct action by the responsible Admin is sufficient.
- Same sub-category/tier being owned by **multiple Admins simultaneously** is **not** required (dropped from earlier draft) — each Main Category has exactly one owning Admin; access beyond that only happens via explicit sharing (§5).

---

## 9. Summary Example

```
Admin: HR Admin
  Owns Main Category: HR
    Tier 1 (top):    Skilled       # Data Entry Operator
    Tier 2:          Semi-Skilled  # Office Staff
    Tier 3 (bottom): Unskilled     # Attender
    Links configured: Skilled ↔ Semi-Skilled ↔ Unskilled (all linked, sequential)

Admin: Cook Admin
  Owns Main Category: Cook
    Tier 1 (top):    Head Cook
    Tier 2:          Cook
    Tier 3 (bottom): Helper
    (Role Label left blank for all — displays as just the Tier Name)

HR Admin grants Cook Admin full shared access to HR.
  → Cook Admin can now also create contracts, mark attendance,
    and upgrade/downgrade employees inside HR — in addition to their own Cook category.
  → HR Admin still cannot access Cook's category (one-directional).
  → HR Admin can revoke this grant at any time.

Employee Ramesh:
  Joins Cook › Helper → upgraded to Cook › Cook (linked, same category, no approval needed)
  → Later moves to HR:
      Cook Admin marks Ramesh as Resigned from Cook.
      HR Admin (or Cook Admin, since they have shared access) rejoins Ramesh under HR › Unskilled.
      System retains full history: Cook › Helper → Cook › Cook → (resigned) → HR › Unskilled (rejoined).

Super Admin:
  Sees all Main Categories (HR, Cook, ...), all Admins, all sharing grants,
  full employee history, with filter/drill-down — but performs no contract/attendance actions.
```

---

## 10. Build Instructions for Antigravity

1. **Entities:**
   - `MainCategory` (owning Admin ID, name).
   - `Tier` (parent Main Category ID, Tier Name, optional Role Label, order/rank number, stable internal ID).
   - `TierLink` (from Tier ID, to Tier ID) — only valid within the same Main Category; used to determine valid upgrade/downgrade paths.
   - `CategoryShareGrant` (owning Admin ID, granted-to Admin ID, Main Category ID, active/revoked flag, timestamp) — models the one-directional, non-chainable, revocable sharing in §5.
2. **Permissions layer:**
   - An Admin's effective visible categories = [Main Category they own] + [Main Categories shared **to** them via active `CategoryShareGrant`].
   - All contract/attendance/employee actions inside a shared category are permitted for the receiving Admin, logged with their identity for audit purposes.
   - Regular users continue to be scoped by Division + specific Tier(s), assigned explicitly by the Admin who creates them (not automatically inherited from the Admin's full scope).
3. **Upgrade/Downgrade logic:**
   - Use `Tier.order` plus `TierLink` to determine the valid "next tier up" / "next tier down" for a given employee's current tier, restricted to the same Main Category.
   - Execute immediately on Admin action, no approval step, with a history record appended to the employee.
4. **Cross-category transfer logic:**
   - No system-level "transfer" action across Main Categories. Instead: mark Resigned in origin category + create/rejoin in destination category, with both events linked via a shared employee history reference (e.g. a persistent `EmployeeHistoryId` that survives resignation + rejoin, distinct from the per-category employee record).
5. **Display layer:**
   - Replace all flat `Category` displays with `MainCategory › TierName (# RoleLabel if present)`.
6. **Employee Master:**
   - Add "Other Employees" tab per §7, scoped as described (visible categories = owned + shared-in).
7. **Super Admin screens:**
   - Main Category / Admin directory (read-only list, since Admins create their own categories).
   - Admin & Super Admin account creation.
   - Global view of all `CategoryShareGrant` records (read-only for Super Admin — grant/revoke stays with owning Admin).
   - Cross-category employee/contract oversight view with filter/drill-down.
8. **Contract/ledger/document numbering:** remains independent per Tier (not shared across a Main Category), as in the prior spec.
9. No data migration required — build against a clean/empty category structure; a single Super Admin account will be seeded manually via database update post-deployment.
