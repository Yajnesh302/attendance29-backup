# Build Prompt: Employee In/Out (Visitor-Style Check-In/Check-Out) Register System

Copy everything below into Antigravity as your project prompt.

---

## 1. Project Summary

Build an **offline, intranet-only ASP.NET Web Forms application** that digitizes a physical "in/out register." Staff at a reception/checkpoint PC log when an employee checks in and checks out, along with a remark/reason for the visit. All entries must be visible, searchable, and filterable, with Excel export.

This is a full production build — implement completely, don't stub out logic.

---

## 2. Environment & Hard Constraints (do not deviate)

- **IDE**: Visual Studio 2015
- **Target Framework**: .NET Framework **4.5**
- **Project type**: ASP.NET **Web Forms** (`.aspx` / `.aspx.cs`, code-behind — NOT MVC, NOT Razor, NOT Core)
- **Database**: **Oracle 11g**, accessed via `System.Data.OracleClient` or `Oracle.ManagedDataAccess.Client` (use `Oracle.ManagedDataAccess.Client` since `System.Data.OracleClient` is deprecated — reference the appropriate ODP.NET NuGet/DLL compatible with .NET 4.5 and Oracle 11g)
- **No internet access at runtime.** Do not use any CDN references (Bootstrap/jQuery/etc. must be local files bundled in the project, not CDN links). Do not use NuGet packages that require online restore at build time on the target machine — vendor the DLLs into a `/libs` folder and reference them directly.
- **Authentication**: Active Directory over LDAP against a local intranet domain controller (details in Section 5). No Windows Integrated Auth — must be a manual login form.
- All SQL must use **parameterized queries** (`OracleParameter`) — no string-concatenated SQL, anywhere.

---

## 3. Reference Materials — Read These First

Before writing any code, inspect the `example/` folder provided in the project root. It contains:
- A sample **login page design** (visual/markup reference) — match this look and feel **only for `Login.aspx`**. Keep it pixel/style faithful there.
- A sample **Web.config** — reuse its structure for connection strings, `<appSettings>` (including the `ADConnectionPath` key), and any other settings already defined there. Extend it as needed but don't discard existing conventions.

**Do not carry the login page's styling into the rest of the app.** Every other page (Section 6 onward) should follow its own clean, professional, modern UI/UX design — see Section 6a below for the design direction. The login page is the one exception; everything past it should look and feel like a proper internal business application, not match the login screen.

---

## 6a. UI/UX Direction for All Pages Except Login

This is a tool front-desk/reception staff will use dozens of times a day — optimize for speed, clarity, and low error rates, not decoration.

- **Visual style**: clean, modern, professional — think a well-built internal admin/back-office tool (generous whitespace, clear typography hierarchy, a restrained color palette with one accent color for primary actions, subtle borders/shadows instead of heavy boxes). Avoid dated Web Forms defaults (no default `GridView` gray-and-white striping, no browser-default buttons/inputs) — apply consistent custom CSS across every control.
- **Layout**: a persistent header/nav (app name, logged-in user, logout) and a consistent page shell/container across all internal pages, so navigation feels like one cohesive app, not a set of disconnected forms.
- **Forms**: clearly labeled fields, sensible tab order, inline validation messages next to the field (not just a top-of-page error summary), and obviously distinguishable primary vs. secondary buttons (e.g. a solid accent-colored "Check In" / "Check Out" button vs. a plain "Clear/Cancel" button).
- **Feedback**: every action (check-in submitted, checkout submitted, blocked duplicate, export started) should give clear, immediate visual feedback (success/error banners or toast-style messages) — never a silent postback with no confirmation.
- **Data density done well**: the log grid should be scannable at a glance — status shown as a colored badge/pill (e.g. green "Checked Out", blue "Checked In", amber "Checked In >2 days" per Section 6.2D), not just plain text.
- **Responsive-enough**: reception PCs are likely fixed desktop resolutions, so desktop-first is fine, but avoid fixed-pixel layouts that break on slightly different screen sizes.
- **Accessibility basics**: sufficient color contrast, focus states visible on interactive elements, and don't rely on color alone to convey status (pair the badge color with a text label, as above).
- Keep all CSS/JS local per Section 2 (no CDNs) — build this styling as local stylesheet(s)/local copies of any UI library, not inline styles scattered per page.

---

## 4. Database Schema (Oracle 11g)

Design and generate the DDL scripts (as a `.sql` file) for the following tables. Use sensible Oracle 11g-compatible types (`VARCHAR2`, `NUMBER`, `DATE`/`TIMESTAMP`, sequences + triggers for auto-increment PKs since 11g has no `IDENTITY`).

### 4.1 `EMPLOYEE_MASTER` (assume this may already exist — write defensive `CREATE TABLE IF NOT EXISTS`-equivalent logic, i.e. check `USER_TABLES` before creating)
- `EMP_ID` (PK)
- `EMPLOYEE_NAME`
- `PC_NO`
- `DIV_NAME` (division/department)
- `DESIGNATION` — required. Must be displayed everywhere employee details are shown (search results, selected-employee panel, log grid).
- Add any other columns you think a reception lookup would reasonably need (active/inactive flag, etc.) — flag these as assumptions in your response so I can confirm/remove them.

### 4.2 `PC_ACCESS_CONTROL`
Purpose: after AD login succeeds, the app resolves the logged-in user's `EmployeeID` from AD, and this table decides whether that PC/user is **authorized to use this application**.
- `PC_NO` (matches the PC/EmployeeID resolved from AD)
- `IS_AUTHORIZED` (Y/N)
- `REMARKS` (optional, why access was granted/revoked)

### 4.3 `CHECKIN_CHECKOUT_LOG`
- `LOG_ID` (PK, sequence-based)
- `EMP_ID` (FK → `EMPLOYEE_MASTER`) — keep this for referential integrity / joins.
- `EMPLOYEE_NAME`, `PC_NO` — **denormalized snapshot columns, stored directly on the log row at the time of check-in**, in addition to the FK. Reasoning: if `EMPLOYEE_MASTER` data changes later (name correction, PC reassignment, employee removed), historical log rows must still show what was true at the time of the visit, and the log grid can display these snapshot columns directly without a join on every page load — which also helps with the performance requirement below.
- `CHECKIN_DATETIME`
- `CHECKIN_REMARK` (reason/cause for visit)
- `CHECKOUT_DATETIME` (nullable until checked out)
- `LOGGED_BY_PCNO` (which reception PC / logged-in AD user made the entry — for audit)
- `CREATED_ON`, `MODIFIED_ON` (audit timestamps)

Add appropriate indexes on `EMP_ID`, `CHECKIN_DATETIME` (descending, since most queries want recent-first), and `CHECKOUT_DATETIME` since filtering/searching will run against these constantly. Add a composite index on `(CHECKIN_DATETIME DESC, EMP_ID)` to keep the default "most recent first, filterable by employee" view fast as the table grows.

---

## 5. Authentication Module

Implement a manual login form (per the sample login page design) that authenticates against AD using this exact pattern — adapt/harden it but preserve the logic:

```csharp
DirectoryEntry entry = new DirectoryEntry(
    ConfigurationManager.AppSettings["ADConnectionPath"], // e.g. LDAP://192.168.0.106/DC=ad01,DC=yajnesh,DC=com
    username,
    password
);
DirectorySearcher search = new DirectorySearcher(entry);
search.Filter = "(SAMAccountName=" + username + ")";
search.PropertiesToLoad.Add("EmployeeID");
SearchResult result = search.FindOne();
```

Flow to implement:
1. User enters username + password on the login form.
2. Bind to AD with those credentials via `DirectoryEntry` — if the bind throws (invalid credentials), show a generic "Invalid username or password" error (don't leak whether the username exists).
3. On successful bind, run the `SAMAccountName` search and retrieve `EmployeeID`.
4. **Escape/sanitize `username` before inserting into the LDAP filter string** (LDAP injection risk — encode special characters like `(`, `)`, `\`, `*`, NUL) even though this is offline; do it correctly.
5. Look up the resolved `EmployeeID` (treated as `PC_NO`) in `PC_ACCESS_CONTROL`. If not found or `IS_AUTHORIZED = 'N'`, deny access with a clear "This PC/user is not authorized to use this application" message and do not create a session.
6. If authorized, create an authenticated session (FormsAuthentication or a session variable holding username + resolved PC_NO), and redirect to the main Check-In/Check-Out page.
7. Add a logout function that clears the session.
8. Protect all internal pages so unauthenticated users are redirected to Login.aspx (use `web.config` `<authorization>` rules or a base page class that checks session on `Page_Load`).

Read `ADConnectionPath` and any other AD-related settings from `Web.config` `<appSettings>`, matching the key names in the sample Web.config provided.

---

## 6. Application Pages/Modules

### 6.1 `Login.aspx`
As described above, styled per the sample.

### 6.2 `CheckInOut.aspx` — single combined page: entry form + full log

Do **not** split entry and log/history into separate pages — one page, entry controls at top, full filterable log grid below, so the receptionist never navigates away to see what's already logged.

**A. Employee search/select (used for both check-in and check-out):**
- A search box that lets the receptionist search `EMPLOYEE_MASTER` by **either PC No or Employee Name** (partial match, case-insensitive — use `UPPER(...) LIKE UPPER('%...%')`).
- Show matching results (autocomplete dropdown or small results panel) showing Name, PC No, Division, **Designation** — user clicks/selects one.
- Once selected, display the chosen employee's details (name, pc no, division, designation) clearly on screen before submission.
- Implement this via an `UpdatePanel`/partial postback (or a lightweight AJAX call) so searching doesn't trigger a full page reload — see performance notes below.

**B. Check-in section:**
- Date field — defaults to current date, editable.
- Time field — defaults to current time, editable.
- Remark/Reason field (free text — "cause for visit" e.g. "checkup", etc.) — required.
- **Before allowing check-in**, verify the selected employee doesn't already have an open entry (a row in `CHECKIN_CHECKOUT_LOG` where `CHECKOUT_DATETIME IS NULL`). If one exists, block the new check-in and show a warning with the existing open entry's details (so the receptionist can check them out instead, if that was the intent).
- On submit, insert a new row into `CHECKIN_CHECKOUT_LOG`, storing `EMP_ID`, and also writing `EMPLOYEE_NAME` and `PC_NO` directly onto the row (denormalized snapshot — see schema section).

**C. Check-out section:**
- For an employee with an open entry: search/select that employee (same search control as 6.2A), or pick directly from the "currently checked-in" panel.
- Date/time fields default to current date/time, editable.
- Submit updates `CHECKOUT_DATETIME` on the matching open log row.

**D. Live "Currently Checked In" panel:** a small live list on this same page of everyone currently checked in (no checkout yet), so staff can check someone out with one click instead of searching. Visually flag (e.g. highlight/badge in a warning color) any entry that has been open for **more than 2 days** — this indicates a checkout was likely forgotten rather than a genuinely long visit, and needs manual attention/correction.

**E. Full log grid (same page, below the entry controls):**
- Shows **every** check-in/check-out entry: Employee Name, PC No, Division, Designation, Check-in Date/Time, Remark, Check-out Date/Time, Logged-by PC, status (Checked In / Checked Out).
- Filters (combinable):
  - Date range (from/to) — applies to check-in date by default; let the user choose whether to filter on check-in or check-out date.
  - Employee (search by name or PC No, same search pattern as 6.2A).
  - Status (All / Currently Checked In / Checked Out).
- Sortable columns.
- After a successful check-in or check-out submission, refresh just the log grid (partial postback), not the whole page.
- **Excel export button** — exports the currently filtered result set (respecting all applied filters, not just the current visible page) to `.xlsx`. Use a library that works offline in .NET 4.5 (e.g. an older EPPlus version compatible with .NET 4.5/without the newer commercial licensing restrictions, or ClosedXML; vendor the DLL locally, don't restore from NuGet at runtime). Name the exported file with the filter context and export timestamp, e.g. `CheckInOutLog_2026-08-11.xlsx`.

**Performance requirement — do not re-query the whole table on every interaction:**
- Implement **true server-side pagination** for the log grid: fetch only the rows needed for the current page from Oracle, not the entire result set. Oracle 11g has no `OFFSET/FETCH`, so use a `ROWNUM`-bounded windowed subquery (the standard `SELECT * FROM (SELECT a.*, ROWNUM rnum FROM (SELECT ... ORDER BY CHECKIN_DATETIME DESC) a WHERE ROWNUM <= :maxRow) WHERE rnum > :minRow` pattern), driven by the indexes defined in Section 4.3.
- Get the total row count for the filtered set with a separate lightweight `COUNT(*)` query (for the pager UI), not by pulling all rows into memory.
- Do **not** reload/re-query on every postback if the filters haven't changed — only re-query when a filter, sort, or page number actually changes. Keep the current filter/page state in `ViewState`/session, not the full dataset.
- Cache `EMPLOYEE_MASTER` (name/pcno/division/designation) in ASP.NET in-memory `Cache`/`Application` state with a sensible expiry (e.g. 15–30 min) or manual "refresh" trigger, since it's small, mostly-static reference data — this makes the employee search instant instead of hitting Oracle on every keystroke. Denormalizing name/pcno onto the log table (Section 4.3) also means the log grid itself never needs to join against `EMPLOYEE_MASTER` at all.

### 6.3 Optional `Admin` area (implement if reasonable, flag as assumption)
- Manage `PC_ACCESS_CONTROL` (grant/revoke access per PC).
- Manage/view `EMPLOYEE_MASTER` (if this app should also own that table rather than just reading it — ask if unclear, otherwise assume read-only reference here and flag it).

---

## 7. Business Rules Recap
- One open (not-checked-out) entry per employee at a time — enforced at check-in.
- Check-in and check-out date/time always default to "now" but are editable by the user.
- Remark is mandatory on check-in.
- Any log entry still open (no checkout) **more than 2 days** after check-in is flagged as a likely-forgotten checkout — surfaced visually on the "Currently Checked In" panel (Section 6.2D). No auto-checkout; a human must resolve it.
- Every log entry is permanently visible in the register (no soft-delete/hide by default) — flag if you think a "void/correct entry" audit feature is needed instead of hard delete.
- All timestamps stored and displayed in server-local time (no timezone complexity needed for a single-site offline deployment).

---

## 8. Non-Functional Requirements
- No external/CDN dependencies — everything (CSS/JS/DLLs) must be local to the project so it runs on an air-gapped machine.
- All Oracle access via parameterized queries; centralize connection handling in a single data-access class (`using` blocks / proper connection disposal — connections must not leak).
- Basic input validation both client-side (for usability) and server-side (mandatory, since this is the real security boundary).
- Meaningful error handling: DB unreachable, AD unreachable, LDAP bind failure, no search results, duplicate check-in — each should show a clear, non-technical message to the receptionist, while logging technical details server-side (e.g. to a local text log file, since there's no internet for centralized logging).
- Keep the codebase organized: `/App_Code` or a class library for data access + AD auth logic, separate from the `.aspx` code-behind, so logic is testable and not duplicated across pages.

---

## 9. Deliverables Expected From Antigravity
1. Full VS2015-compatible Web Forms project (.sln/.csproj targeting net45).
2. `.sql` script for schema creation (tables, sequences, triggers, indexes) — idempotent where reasonable.
3. All `.aspx`/`.aspx.cs` pages listed above, styled consistently with the sample login page.
4. A data-access layer and an AD-authentication class as reusable components.
5. `Web.config` extended from the provided sample with all needed `<appSettings>` and `<connectionStrings>`.
6. A short `README.md` describing how to point it at a different Oracle instance/AD path, and how to deploy to IIS on the target offline machine.

---

## 10. Questions Antigravity Should Ask If Anything Is Unclear
- Whether `EMPLOYEE_MASTER` already exists with a fixed schema I must match exactly (vs. being free to create it).
- Whether `Admin` management of `PC_ACCESS_CONTROL`/`EMPLOYEE_MASTER` is in scope for this first version.
- Whether check-out should also require/allow a remark (e.g. "outcome" note), or only check-in does.
