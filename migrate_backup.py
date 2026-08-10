"""
migrate_backup.py  -  Converts old attendance backup JSON to new schema.

Usage:
    python migrate_backup.py  input.json  [output.json]

The script will ask you interactive questions about:
  - What MainCategory name to use (e.g. "Contract Wages")
  - Which admin user owns the MainCategory
  - Tier names (from old Categories or custom)
"""
import json, sys, os

# ── helpers ──────────────────────────────────────────────────────────────────

def load_json(p):
    with open(p, "r", encoding="utf-8") as f: return json.load(f)

def save_json(d, p):
    with open(p, "w", encoding="utf-8") as f: json.dump(d, f, indent=2, ensure_ascii=False)

def ci_get(d, key, default=None):
    for k, v in d.items():
        if k.lower() == key.lower(): return v
    return default

def ci_has(d, key):
    return any(k.lower() == key.lower() for k in d)

def ask(prompt, default=None):
    hint = " [{}]".format(default) if default is not None else ""
    try:    ans = raw_input("{}{}:  ".format(prompt, hint))
    except: ans = input("{}{}:  ".format(prompt, hint))
    return ans.strip() if ans.strip() else default

def ask_yn(prompt, default=True):
    hint = "Y/n" if default else "y/N"
    try:    ans = raw_input("{} [{}]:  ".format(prompt, hint))
    except: ans = input("{} [{}]:  ".format(prompt, hint))
    ans = ans.strip().lower()
    return default if not ans else ans in ("y", "yes")

# ── interactive setup ─────────────────────────────────────────────────────────

def gather_options(raw):
    """Ask the user migration questions and return an opts dict."""
    opts = {}

    raw_u = ci_get(raw, "AppUsers") or []
    admin_users = []
    for u in raw_u:
        try: r = int(ci_get(u, "Role") or ci_get(u, "ROLE") or 0)
        except: r = 0
        if r == 1:
            admin_users.append({"pcno": ci_get(u,"PCNO") or "",
                                 "name": ci_get(u,"Name") or ci_get(u,"NAME") or ""})

    has_old_cats  = bool(ci_get(raw, "Categories") or [])
    has_new_mc    = bool(ci_get(raw, "MainCategory") or [])
    has_new_tiers = bool(ci_get(raw, "Tiers") or [])

    sep = "=" * 62

    print("\n" + sep)
    print("  MIGRATION SETUP")
    print(sep)

    # ── If already new schema, no questions needed ──
    if has_new_mc and has_new_tiers:
        print("\nBackup already has MainCategory & Tiers - no setup needed.\n")
        opts["skip"] = True
        return opts

    opts["skip"] = False

    # ── MainCategory name ──
    print("\n[1/3]  MAIN CATEGORY NAME")
    print("All employees/contracts are grouped under one MainCategory.")
    print("Example: 'Contract Wages'")
    mc_name = ask("MainCategory name", "Contract Wages")
    opts["mc_name"] = mc_name

    # ── Admin PCNO ──
    print("\n[2/3]  ADMIN USER (owner of the MainCategory)")
    if admin_users:
        print("Admin users found in backup:")
        for i, u in enumerate(admin_users, 1):
            print("  [{}]  PCNO={}  |  {}".format(i, u["pcno"], u["name"]))
        default_pcno = admin_users[0]["pcno"]
        raw_choice = ask("Enter number from list OR type a PCNO directly", default_pcno)
        try:
            idx = int(raw_choice) - 1
            opts["admin_pcno"] = admin_users[idx]["pcno"] if 0 <= idx < len(admin_users) else raw_choice
        except (ValueError, TypeError):
            opts["admin_pcno"] = raw_choice if raw_choice else default_pcno
    else:
        print("No admin users (Role=1) found in backup.")
        opts["admin_pcno"] = ask("Enter admin PCNO to own this MainCategory", "1001")

    # ── Tiers ──
    print("\n[3/3]  TIERS  (categories/skill levels)")
    raw_cats = ci_get(raw, "Categories") or []

    if has_old_cats:
        print("Old Categories found in backup:")
        for c in raw_cats:
            cid   = ci_get(c, "Id") or ci_get(c, "ID") or "?"
            cname = ci_get(c, "Name") or ci_get(c, "NAME") or "?"
            print("  ID={}  |  {}".format(cid, cname))
        use_old = ask_yn("Map these as Tiers under '{}'?".format(mc_name), True)
    else:
        print("No old Categories in backup.")
        print("Default tiers will be: Skilled, Semi-Skilled, Unskilled")
        use_old = False
        ask_yn("Use default tiers (Skilled / Semi-Skilled / Unskilled)?", True)

    custom_tiers = []
    if use_old and has_old_cats:
        print("\nYou may rename each tier or press Enter to keep the original name:")
        idx = 1
        for c in raw_cats:
            cid   = ci_get(c, "Id") or ci_get(c, "ID")
            try: cid = int(cid)
            except: cid = idx
            orig = (ci_get(c,"Name") or ci_get(c,"NAME") or "Category_{}".format(cid)).strip()
            new_name = ask("  Tier {} '{}' -> rename to".format(cid, orig), orig)
            custom_tiers.append({"id": cid, "name": new_name, "sort": idx})
            idx += 1
    elif not has_old_cats:
        use_defaults = ask_yn("Use default tiers?", True)
        if use_defaults:
            custom_tiers = [{"id":1,"name":"Skilled","sort":1},
                            {"id":2,"name":"Semi-Skilled","sort":2},
                            {"id":3,"name":"Unskilled","sort":3}]
        else:
            print("Enter tier names one by one (blank line to finish, min 1):")
            tidx = 1
            while True:
                nm = ask("  Tier {}".format(tidx), "Skilled" if tidx==1 else None)
                if not nm:
                    if not custom_tiers: print("  Need at least one tier."); continue
                    break
                custom_tiers.append({"id": tidx, "name": nm, "sort": tidx})
                tidx += 1
    else:
        # use_old=False but has_old_cats - user chose not to use old cats
        print("Enter tier names one by one (blank line to finish, min 1):")
        tidx = 1
        while True:
            nm = ask("  Tier {}".format(tidx), "Skilled" if tidx==1 else None)
            if not nm:
                if not custom_tiers: print("  Need at least one tier."); continue
                break
            custom_tiers.append({"id": tidx, "name": nm, "sort": tidx})
            tidx += 1

    opts["tiers"] = custom_tiers

    # ── Division / Directorate Mapping ──
    print("\n[4/4]  DIVISIONS / DIRECTORATES MAPPING")
    raw_div_names = set()
    for d in (ci_get(raw, "Divisions") or []):
        nm = (ci_get(d, "Name") or ci_get(d, "NAME") or "").strip()
        if nm: raw_div_names.add(nm)
    for ud in (ci_get(raw, "UserDivisions") or []):
        nm = (ci_get(ud, "DivisionName") or ci_get(ud, "DIVISIONNAME") or "").strip()
        if nm: raw_div_names.add(nm)
    for emp in (ci_get(raw, "Employees") or []):
        nm = (ci_get(emp, "Department") or ci_get(emp, "DEPARTMENT") or "").strip()
        if nm: raw_div_names.add(nm)
    for ee in (ci_get(raw, "EmployeeEngagements") or []):
        nm = (ci_get(ee, "Department") or ci_get(ee, "DEPARTMENT") or "").strip()
        if nm: raw_div_names.add(nm)
    for ed in (ci_get(raw, "empdetails") or []):
        nm = (ci_get(ed, "DIVNAME") or ci_get(ed, "divname") or "").strip()
        if nm: raw_div_names.add(nm)

    sorted_div_names = sorted(list(raw_div_names))
    div_map = {}
    if sorted_div_names:
        print("Found {} distinct division(s)/directorate(s) in backup:".format(len(sorted_div_names)))
        for dname in sorted_div_names:
            print("  • {}".format(dname))
        remap_divs = ask_yn("\nWould you like to review / rename any of these divisions?", True)
        if remap_divs:
            print("\nEnter new division/directorate name for each (or press Enter to keep original):")
            for old_div in sorted_div_names:
                new_div = ask("  Division '{}' -> rename to".format(old_div), old_div)
                div_map[old_div] = new_div
        else:
            for old_div in sorted_div_names:
                div_map[old_div] = old_div
    else:
        print("No division/directorate records found in backup.")

    opts["div_map"] = div_map

    # ── Summary + confirm ──
    print("\n" + sep)
    print("  SUMMARY")
    print(sep)
    print("  MainCategory  :  {}".format(opts["mc_name"]))
    print("  Admin PCNO    :  {}".format(opts["admin_pcno"]))
    for t in opts["tiers"]:
        print("  Tier {:>2}       :  {}".format(t["id"], t["name"]))
    renamed_count = sum(1 for k, v in opts["div_map"].items() if k != v)
    if renamed_count > 0:
        print("  Divisions     :  {} division(s) will be renamed:".format(renamed_count))
        for k, v in opts["div_map"].items():
            if k != v:
                print("                     '{}' -> '{}'".format(k, v))
    else:
        print("  Divisions     :  {} division(s) (no name changes)".format(len(opts["div_map"])))
    print(sep)
    if not ask_yn("Proceed with migration?", True):
        print("Cancelled.")
        sys.exit(0)

    return opts

# ── core migration ────────────────────────────────────────────────────────────

DEFAULT_CAT_MAP = {"skilled":1, "semi-skilled":2, "semiskilled":2, "unskilled":3}

def resolve_tier(cat_val, cmap):
    if cat_val is None: return None
    s = str(cat_val).strip()
    try:
        n = int(float(s))
        if n in cmap.values(): return n
        return n
    except: pass
    return cmap.get(s.lower(), 1)

def migrate(raw, opts):
    out = {}; warns = []

    skip = opts.get("skip", False)
    mc_name    = opts.get("mc_name", "Contract Wages")
    admin_pcno = opts.get("admin_pcno", None)
    tiers_cfg  = opts.get("tiers", [])
    div_map    = opts.get("div_map", {})

    def map_div(name):
        if not name: return name
        s = str(name).strip()
        if not s: return name
        if s in div_map: return div_map[s]
        for k, v in div_map.items():
            if k.lower() == s.lower():
                return v
        return s

    # ── AppUsers ──
    raw_u = ci_get(raw, "AppUsers") or []
    users = []
    for u in raw_u:
        users.append({"PCNO": ci_get(u,"PCNO") or "",
                      "Name": ci_get(u,"Name") or ci_get(u,"NAME") or "",
                      "Role": ci_get(u,"Role") if ci_has(u,"Role") else (ci_get(u,"ROLE") or 0)})
    out["AppUsers"] = users

    if admin_pcno is None:
        for u in users:
            try: r = int(u.get("Role",0) or 0)
            except: r = 0
            if r == 1: admin_pcno = u["PCNO"]; break
        if admin_pcno is None and users: admin_pcno = users[0]["PCNO"]
        if admin_pcno is None:
            admin_pcno = "SYSTEM"
            warns.append("No AppUsers - using SYSTEM as AdminPCNO.")

    # ── Divisions ──
    raw_d = ci_get(raw, "Divisions") or []
    divs = []
    seen_div_names = set()
    idx = 1
    for d in raw_d:
        orig_id = ci_get(d, "Id") or ci_get(d, "ID")
        try: orig_id = int(orig_id)
        except: orig_id = idx
        nm = (ci_get(d, "Name") or ci_get(d, "NAME") or "").strip()
        if nm:
            mapped_nm = map_div(nm)
            if mapped_nm and mapped_nm not in seen_div_names:
                seen_div_names.add(mapped_nm)
                divs.append({"Id": orig_id, "Name": mapped_nm})
        idx += 1

    # Ensure all mapped division names from div_map are in Divisions table
    for old_nm, new_nm in div_map.items():
        if new_nm and new_nm not in seen_div_names:
            seen_div_names.add(new_nm)
            divs.append({"Id": len(divs) + 1, "Name": new_nm})

    out["Divisions"] = divs
    valid_divs = {d["Name"] for d in divs}

    # ── Build category map ──
    raw_cats = ci_get(raw, "Categories") or []
    cmap = {}; cats_by_id = {}
    if raw_cats:
        idx = 1
        for c in raw_cats:
            cid = ci_get(c,"Id") or ci_get(c,"ID")
            try: cid = int(cid)
            except: cid = idx
            nm = (ci_get(c,"Name") or ci_get(c,"NAME") or "Cat_{}".format(cid)).strip()
            cmap[nm.lower()] = cid; cmap[str(cid)] = cid
            cats_by_id[cid] = nm; idx += 1
    else:
        cmap = dict(DEFAULT_CAT_MAP)
        cats_by_id = {1:"Skilled",2:"Semi-Skilled",3:"Unskilled"}

    # ── MainCategory ──
    raw_mc = ci_get(raw, "MainCategory") or []
    if raw_mc:
        mcs = [{"Id": ci_get(m,"Id") or ci_get(m,"ID"),
                "Name": ci_get(m,"Name") or ci_get(m,"NAME") or "",
                "AdminPCNO": ci_get(m,"AdminPCNO") or ci_get(m,"ADMINPCNO") or admin_pcno,
                "EditDaysAllowed": ci_get(m,"EditDaysAllowed") or 0} for m in raw_mc]
    else:
        mcs = [{"Id":1, "Name": mc_name, "AdminPCNO": admin_pcno, "EditDaysAllowed": 0}]
    out["MainCategory"] = mcs

    # ── Tiers ──
    raw_t = ci_get(raw, "Tiers") or []
    if raw_t:
        tiers = [{"Id": ci_get(t,"Id") or ci_get(t,"ID"),
                  "MainCategoryId": ci_get(t,"MainCategoryId") or ci_get(t,"MAINCATEGORYID") or 1,
                  "TierName": ci_get(t,"TierName") or ci_get(t,"TIERNAME") or "",
                  "RoleLabel": ci_get(t,"RoleLabel") or ci_get(t,"ROLELABEL"),
                  "SortOrder": ci_get(t,"SortOrder") or ci_get(t,"SORTORDER") or 0,
                  "IsActive": ci_get(t,"IsActive") if ci_has(t,"IsActive") else 1} for t in raw_t]
    elif tiers_cfg:
        tiers = [{"Id": t["id"], "MainCategoryId": 1, "TierName": t["name"],
                  "RoleLabel": None, "SortOrder": t["sort"], "IsActive": 1} for t in tiers_cfg]
    elif cats_by_id:
        tiers = [{"Id":k,"MainCategoryId":1,"TierName":v,"RoleLabel":None,"SortOrder":i,"IsActive":1}
                 for i,(k,v) in enumerate(sorted(cats_by_id.items()),1)]
    else:
        tiers = [{"Id":1,"MainCategoryId":1,"TierName":"Skilled","RoleLabel":None,"SortOrder":1,"IsActive":1},
                 {"Id":2,"MainCategoryId":1,"TierName":"Semi-Skilled","RoleLabel":None,"SortOrder":2,"IsActive":1},
                 {"Id":3,"MainCategoryId":1,"TierName":"Unskilled","RoleLabel":None,"SortOrder":3,"IsActive":1}]
    out["Tiers"] = tiers
    valid_tids = {t["Id"] for t in tiers}

    # Update cmap with final tier data
    for t in tiers:
        cmap[(t.get("TierName") or "").strip().lower()] = t["Id"]
        cmap[str(t["Id"])] = t["Id"]
    if tiers_cfg:
        for t in tiers_cfg:
            cmap[t["name"].lower()] = t["id"]
            cmap[str(t["id"])] = t["id"]

    def safe_tid(val, ctx):
        tid = resolve_tier(val, cmap)
        if tid not in valid_tids:
            warns.append("{}: TierId={} not found - defaulting to first tier.".format(ctx, tid))
            return min(valid_tids) if valid_tids else 1
        return tid

    # ── UserTiers ──
    out["UserTiers"] = [{"PCNO": ci_get(u,"PCNO") or "",
                         "TierId": ci_get(u,"TierId") or ci_get(u,"TIERID") or
                                   resolve_tier(ci_get(u,"Category") or ci_get(u,"CATEGORY"), cmap)}
                        for u in (ci_get(raw,"UserTiers") or [])]

    # ── CategoryShareGrant ──
    out["CategoryShareGrant"] = [{"Id": ci_get(c,"Id") or ci_get(c,"ID"),
        "OwnerAdminPCNO": ci_get(c,"OwnerAdminPCNO") or ci_get(c,"OWNERADMINPCNO") or admin_pcno,
        "SharedWithPCNO": ci_get(c,"SharedWithPCNO") or ci_get(c,"SHAREDWITHPCNO") or "",
        "MainCategoryId": ci_get(c,"MainCategoryId") or ci_get(c,"MAINCATEGORYID") or 1,
        "TierId": ci_get(c,"TierId") or ci_get(c,"TIERID"),
        "IsActive": ci_get(c,"IsActive") if ci_has(c,"IsActive") else 1,
        "GrantedAt": ci_get(c,"GrantedAt") or ci_get(c,"GRANTEDAT")}
        for c in (ci_get(raw,"CategoryShareGrant") or [])]

    # ── UserDivisions ──
    uds = []
    seen_uds = set()
    for ud in (ci_get(raw,"UserDivisions") or []):
        dn = (ci_get(ud,"DivisionName") or ci_get(ud,"DIVISIONNAME") or "").strip()
        mapped_dn = map_div(dn)
        pcno = ci_get(ud,"PCNO") or ""
        if mapped_dn:
            if mapped_dn not in valid_divs:
                valid_divs.add(mapped_dn)
                divs.append({"Id": len(divs) + 1, "Name": mapped_dn})
            key = (pcno, mapped_dn)
            if key not in seen_uds:
                seen_uds.add(key)
                uds.append({"PCNO": pcno, "DivisionName": mapped_dn})
    out["UserDivisions"] = uds

    # ── Vendors ──
    vlist = []
    for v in (ci_get(raw,"Vendors") or []):
        vlist.append({"Id": ci_get(v,"Id") or ci_get(v,"ID"),
            "MasterId": ci_get(v,"MasterId") or ci_get(v,"MASTERID") or "",
            "Name": ci_get(v,"Name") or ci_get(v,"NAME") or "",
            "GemId": ci_get(v,"GemId") or ci_get(v,"GEMID"),
            "ContactName": ci_get(v,"ContactName") or ci_get(v,"CONTACTNAME"),
            "ContactPhone": ci_get(v,"ContactPhone") or ci_get(v,"CONTACTPHONE"),
            "Address": ci_get(v,"Address") or ci_get(v,"ADDRESS"),
            "IsActive": ci_get(v,"IsActive") if ci_has(v,"IsActive") else (ci_get(v,"ISACTIVE") if ci_has(v,"ISACTIVE") else 1)})
    out["Vendors"] = vlist
    valid_vids = {v["Id"] for v in vlist}

    # ── VendorContacts ──
    vcs = []
    for vc in (ci_get(raw,"VendorContacts") or []):
        vid = ci_get(vc,"VendorId") or ci_get(vc,"VENDORID")
        if vid not in valid_vids:
            warns.append("VendorContacts Id={}: bad VendorId={} - skipped.".format(ci_get(vc,"Id"),vid)); continue
        vcs.append({"Id": ci_get(vc,"Id") or ci_get(vc,"ID"), "VendorId": vid,
            "Priority": ci_get(vc,"Priority") or ci_get(vc,"PRIORITY") or 1,
            "ContactName": ci_get(vc,"ContactName") or ci_get(vc,"CONTACTNAME") or "",
            "ContactPhone": ci_get(vc,"ContactPhone") or ci_get(vc,"CONTACTPHONE") or "",
            "ContactEmail": ci_get(vc,"ContactEmail") or ci_get(vc,"CONTACTEMAIL"),
            "ContactAddress": ci_get(vc,"ContactAddress") or ci_get(vc,"CONTACTADDRESS"),
            "SortOrder": ci_get(vc,"SortOrder") or ci_get(vc,"SORTORDER") or 0})
    out["VendorContacts"] = vcs
    out["GemContracts"] = ci_get(raw,"GemContracts") or []

    # ── ContractPeriods ── (old: CATEGORY text; new: TierId number, no GEMID)
    cp_list = []; cp_id_to_tier = {}
    for cp in (ci_get(raw,"ContractPeriods") or []):
        cpid = ci_get(cp,"Id") or ci_get(cp,"ID")
        tid = ci_get(cp,"TierId") or ci_get(cp,"TIERID") or \
              resolve_tier(ci_get(cp,"Category") or ci_get(cp,"CATEGORY"), cmap)
        if tid not in valid_tids:
            warns.append("ContractPeriods Id={}: TierId={} bad - defaulting.".format(cpid,tid))
            tid = min(valid_tids) if valid_tids else 1
        vid = ci_get(cp,"VendorId") or ci_get(cp,"VENDORID")
        if vid not in valid_vids:
            warns.append("ContractPeriods Id={}: VendorId={} not found - skipped.".format(cpid,vid)); continue
        cp_id_to_tier[cpid] = tid
        cp_list.append({"Id":cpid,"TierId":tid,"VendorId":vid,
            "StartDate": ci_get(cp,"StartDate") or ci_get(cp,"STARTDATE"),
            "EndDate":   ci_get(cp,"EndDate")   or ci_get(cp,"ENDDATE"),
            "DatedOn":   ci_get(cp,"DatedOn")   or ci_get(cp,"DATEDON"),
            "Status":    ci_get(cp,"Status")    or ci_get(cp,"STATUS") or "Active",
            "Notes":     ci_get(cp,"Notes")     or ci_get(cp,"NOTES")})
    out["ContractPeriods"] = cp_list
    valid_cpids = {cp["Id"] for cp in cp_list}

    # ── ContractExtensions ──
    ce_list = []
    for ce in (ci_get(raw,"ContractExtensions") or []):
        cpr = ci_get(ce,"ContractPeriodId") or ci_get(ce,"CONTRACTPERIODID")
        if cpr not in valid_cpids:
            warns.append("ContractExtensions Id={}: bad ContractPeriodId={} - skipped.".format(ci_get(ce,"Id"),cpr)); continue
        ce_list.append({"Id": ci_get(ce,"Id") or ci_get(ce,"ID"), "ContractPeriodId": cpr,
            "OldEndDate": ci_get(ce,"OldEndDate") or ci_get(ce,"OLDENDDATE"),
            "NewEndDate": ci_get(ce,"NewEndDate") or ci_get(ce,"NEWENDDATE"),
            "ExtensionDate": ci_get(ce,"ExtensionDate") or ci_get(ce,"EXTENSIONDATE")})
    out["ContractExtensions"] = ce_list

    # ── ContractPeriodVendors ──
    cpv_list = []
    for cpv in (ci_get(raw,"ContractPeriodVendors") or []):
        cpvid = ci_get(cpv,"Id") or ci_get(cpv,"ID")
        cpr = ci_get(cpv,"ContractPeriodId") or ci_get(cpv,"CONTRACTPERIODID")
        if cpr not in valid_cpids:
            warns.append("ContractPeriodVendors Id={}: bad CP={} - skipped.".format(cpvid,cpr)); continue
        vid = ci_get(cpv,"VendorId") or ci_get(cpv,"VENDORID")
        if vid not in valid_vids:
            warns.append("ContractPeriodVendors Id={}: bad Vendor={} - skipped.".format(cpvid,vid)); continue
        tid = ci_get(cpv,"TierId") or ci_get(cpv,"TIERID")
        if tid is None:
            cv = ci_get(cpv,"Category") or ci_get(cpv,"CATEGORY")
            tid = resolve_tier(cv,cmap) if cv else cp_id_to_tier.get(cpr,1)
        if tid not in valid_tids:
            warns.append("ContractPeriodVendors Id={}: bad TierId={} - defaulting.".format(cpvid,tid))
            tid = min(valid_tids) if valid_tids else 1
        cpv_list.append({"Id":cpvid,"ContractPeriodId":cpr,"VendorId":vid,"TierId":tid,
            "IsActive": ci_get(cpv,"IsActive") if ci_has(cpv,"IsActive") else (ci_get(cpv,"ISACTIVE") if ci_has(cpv,"ISACTIVE") else 1)})
    out["ContractPeriodVendors"] = cpv_list

    # ── Employees ── (old: CATEGORY text, no TierId, no EmployeeHistoryId)
    emp_list = []; valid_mids = set(); emp_cur = {}
    for emp in (ci_get(raw,"Employees") or []):
        mid = ci_get(emp,"MasterId") or ci_get(emp,"MASTERID") or ""
        tid = ci_get(emp,"TierId") or ci_get(emp,"TIERID")
        if tid is None:
            cv = ci_get(emp,"Category") or ci_get(emp,"CATEGORY")
            if cv: tid = resolve_tier(cv, cmap)
        if tid is not None and tid not in valid_tids:
            warns.append("Employees {}: TierId={} bad - defaulting.".format(mid,tid))
            tid = min(valid_tids) if valid_tids else 1
        dept = ci_get(emp,"Department") or ci_get(emp,"DEPARTMENT")
        dept = map_div(dept)
        ehid = ci_get(emp,"EmployeeHistoryId") or ci_get(emp,"EMPLOYEEHISTORYID") or mid
        cid = ci_get(emp,"CurrentEngagementId") or ci_get(emp,"CURRENTENGAGEMENTID")
        if cid is not None: emp_cur[mid] = cid
        valid_mids.add(mid)
        emp_list.append({"MasterId":mid,"ID":ci_get(emp,"ID") or ci_get(emp,"Id") or mid,
            "Name":ci_get(emp,"Name") or ci_get(emp,"NAME") or "",
            "Department":dept,"TierId":tid,"EmployeeHistoryId":ehid,
            "OriginalJoinDate":ci_get(emp,"OriginalJoinDate") or ci_get(emp,"ORIGINALJOINDATE"),
            "JoinDate":ci_get(emp,"JoinDate") or ci_get(emp,"JOINDATE"),
            "LeaveBalance":ci_get(emp,"LeaveBalance") if ci_has(emp,"LeaveBalance") else (ci_get(emp,"LEAVEBALANCE") or 0),
            "PrevLeaveBalance":ci_get(emp,"PrevLeaveBalance") if ci_has(emp,"PrevLeaveBalance") else (ci_get(emp,"PREVLEAVEBALANCE") or 0),
            "Status":ci_get(emp,"Status") or ci_get(emp,"STATUS") or "Active",
            "ResignDate":ci_get(emp,"ResignDate") or ci_get(emp,"RESIGNDATE"),
            "ContractEndDate":ci_get(emp,"ContractEndDate") or ci_get(emp,"CONTRACTENDDATE"),
            "CurrentEngagementId":None,
            "Phone":ci_get(emp,"Phone") or ci_get(emp,"PHONE"),
            "Email":ci_get(emp,"Email") or ci_get(emp,"EMAIL"),
            "Aadhar":ci_get(emp,"Aadhar") or ci_get(emp,"AADHAR"),
            "Address":ci_get(emp,"Address") or ci_get(emp,"ADDRESS"),
            "Qualification":ci_get(emp,"Qualification") or ci_get(emp,"QUALIFICATION"),
            "Experience":ci_get(emp,"Experience") or ci_get(emp,"EXPERIENCE"),
            "ExperienceIn":ci_get(emp,"ExperienceIn") or ci_get(emp,"EXPERIENCEIN")})
    out["Employees"] = emp_list

    # ── EmployeeEngagements ──
    raw_ee = ci_get(raw,"EmployeeEngagements") or []
    all_ee_ids = {ci_get(e,"Id") or ci_get(e,"ID") for e in raw_ee}
    ee_list = []
    for ee in raw_ee:
        eid   = ci_get(ee,"Id") or ci_get(ee,"ID")
        empid = ci_get(ee,"EmpID") or ci_get(ee,"EMPID") or ""
        if empid not in valid_mids:
            warns.append("EmployeeEngagements Id={}: EmpID='{}' not found - skipped.".format(eid,empid)); continue
        vid = ci_get(ee,"VendorId") or ci_get(ee,"VENDORID")
        if vid not in valid_vids:
            warns.append("EmployeeEngagements Id={}: VendorId={} not found - skipped.".format(eid,vid)); continue
        cpid = ci_get(ee,"ContractPeriodId") or ci_get(ee,"CONTRACTPERIODID")
        if cpid is not None and cpid not in valid_cpids:
            warns.append("EmployeeEngagements Id={}: ContractPeriodId={} not found - NULL.".format(eid,cpid)); cpid=None
        tid = ci_get(ee,"TierId") or ci_get(ee,"TIERID")
        if tid is None:
            cv = ci_get(ee,"Category") or ci_get(ee,"CATEGORY")
            tid = resolve_tier(cv,cmap) if cv else 1
        if tid not in valid_tids:
            warns.append("EmployeeEngagements Id={}: TierId={} bad - defaulting.".format(eid,tid))
            tid = min(valid_tids) if valid_tids else 1
        prev = ci_get(ee,"PrevEngagementId") or ci_get(ee,"PREVENGAGEMENTID")
        if prev is not None and prev not in all_ee_ids:
            warns.append("EmployeeEngagements Id={}: PrevEngagementId={} not found - NULL.".format(eid,prev)); prev=None
        dept = ci_get(ee,"Department") or ci_get(ee,"DEPARTMENT")
        dept = map_div(dept)
        ee_list.append({"Id":eid,"EmpID":empid,"ContractPeriodId":cpid,"TierId":tid,"VendorId":vid,
            "Department":dept,
            "StartDate":ci_get(ee,"StartDate") or ci_get(ee,"STARTDATE"),
            "EndDate":ci_get(ee,"EndDate") or ci_get(ee,"ENDDATE"),
            "EndReason":ci_get(ee,"EndReason") or ci_get(ee,"ENDREASON"),
            "IsCarriedOver":ci_get(ee,"IsCarriedOver") if ci_has(ee,"IsCarriedOver") else (ci_get(ee,"ISCARRIEDOVER") or 0),
            "PrevEngagementId":prev,
            "EmployeeId":ci_get(ee,"EmployeeId") or ci_get(ee,"EMPLOYEEID")})
    out["EmployeeEngagements"] = ee_list

    valid_eids = {e["Id"] for e in ee_list}
    for emp in out["Employees"]:
        cid = emp_cur.get(emp["MasterId"])
        if cid is not None and cid in valid_eids: emp["CurrentEngagementId"] = cid

    # ── EmployeeLeaveCredits ──
    # New schema: ContractPeriodId NOT NULL, Amount NOT NULL, EffectiveDate NOT NULL
    # Old schema: Month, Year, Credits, BalanceAfter  (incompatible - drop old rows)
    raw_elc = ci_get(raw,"EmployeeLeaveCredits") or []
    elc_list = []
    if raw_elc:
        first = raw_elc[0]
        is_new = ci_has(first,"ContractPeriodId") or ci_has(first,"CONTRACTPERIODID")
        if is_new:
            for elc in raw_elc:
                empid = ci_get(elc,"EmpID") or ci_get(elc,"EMPID") or ""
                cpid  = ci_get(elc,"ContractPeriodId") or ci_get(elc,"CONTRACTPERIODID")
                if empid not in valid_mids:
                    warns.append("EmployeeLeaveCredits: EmpID='{}' not found - skipped.".format(empid)); continue
                if cpid is None or cpid not in valid_cpids:
                    warns.append("EmployeeLeaveCredits: ContractPeriodId={} not valid - skipped.".format(cpid)); continue
                elc_list.append({"Id":ci_get(elc,"Id") or ci_get(elc,"ID"),"EmpID":empid,
                    "ContractPeriodId":cpid,
                    "Amount":ci_get(elc,"Amount") or ci_get(elc,"AMOUNT") or 0,
                    "EffectiveDate":ci_get(elc,"EffectiveDate") or ci_get(elc,"EFFECTIVEDATE"),
                    "Remarks":ci_get(elc,"Remarks") or ci_get(elc,"REMARKS")})
        else:
            warns.append("EmployeeLeaveCredits: Old schema (Month/Year/Credits) detected - "
                         "{} records dropped. New schema is incompatible.".format(len(raw_elc)))
    out["EmployeeLeaveCredits"] = elc_list

    # ── Attendance ──
    att_list = []
    for att in (ci_get(raw,"Attendance") or []):
        empid = ci_get(att,"EmpID") or ci_get(att,"EMPID") or ""
        if empid not in valid_mids:
            warns.append("Attendance: EmpID='{}' not found - skipped.".format(empid)); continue
        att_list.append(dict(att))
    out["Attendance"] = att_list

    # ── CalculationWages ──
    raw_cw = ci_get(raw, "CalculationWages") or []
    cw_list = []
    for row in raw_cw:
        cw_id = ci_get(row, "Id") or ci_get(row, "ID")
        yr    = ci_get(row, "Year") or ci_get(row, "YEAR")
        mn    = ci_get(row, "Month") or ci_get(row, "MONTH")
        rate  = ci_get(row, "WageRate") or ci_get(row, "WAGERATE")
        tid   = ci_get(row, "TierId") or ci_get(row, "TIERID")
        if tid is None or tid not in valid_tids:
            cat_name = ci_get(row, "Category") or ci_get(row, "CATEGORY")
            if cat_name:
                tid = resolve_tier(cat_name, cmap)
        if tid is None or tid not in valid_tids:
            warns.append("CalculationWages Id={}: TierId is missing or invalid (Category='{}') - skipped.".format(cw_id, ci_get(row, "Category") or ci_get(row, "CATEGORY")))
            continue
        if yr is None or mn is None or rate is None:
            warns.append("CalculationWages Id={}: Missing Year/Month/WageRate - skipped.".format(cw_id))
            continue
        item = {"Year": int(yr), "Month": int(mn), "TierId": int(tid), "WageRate": float(rate)}
        if cw_id is not None:
            item["Id"] = int(cw_id)
        cw_list.append(item)
    out["CalculationWages"] = cw_list

    # ── CalculationOverrides ──
    raw_co = ci_get(raw, "CalculationOverrides") or []
    co_list = []
    for row in raw_co:
        co_id = ci_get(row, "Id") or ci_get(row, "ID")
        yr    = ci_get(row, "Year") or ci_get(row, "YEAR")
        mn    = ci_get(row, "Month") or ci_get(row, "MONTH")
        empid = ci_get(row, "EmpID") or ci_get(row, "EMPID") or ""
        days  = ci_get(row, "FinalDays") or ci_get(row, "FINALDAYS")
        if empid not in valid_mids:
            warns.append("CalculationOverrides Id={}: EmpID='{}' not found - skipped.".format(co_id, empid))
            continue
        if yr is None or mn is None or days is None:
            warns.append("CalculationOverrides Id={}: Missing Year/Month/FinalDays - skipped.".format(co_id))
            continue
        tid = ci_get(row, "TierId") or ci_get(row, "TIERID")
        if tid is None or tid not in valid_tids:
            cat_name = ci_get(row, "Category") or ci_get(row, "CATEGORY")
            if cat_name:
                tid = resolve_tier(cat_name, cmap)
        if tid is not None and tid not in valid_tids:
            tid = None
        cpid = ci_get(row, "ContractPeriodId") or ci_get(row, "CONTRACTPERIODID")
        if cpid is not None and cpid not in valid_cpids:
            cpid = None
        item = {
            "Year": int(yr),
            "Month": int(mn),
            "EmpID": empid,
            "TierId": tid,
            "ContractPeriodId": cpid,
            "FinalDays": float(days),
            "Remarks": ci_get(row, "Remarks") or ci_get(row, "REMARKS") or ""
        }
        if co_id is not None:
            item["Id"] = int(co_id)
        co_list.append(item)
    out["CalculationOverrides"] = co_list

    # ── CategoryWages ──
    raw_catw = ci_get(raw, "CategoryWages") or []
    catw_list = []
    raw_wo = ci_get(raw, "WageOrders") or []
    valid_woids = {ci_get(w, "Id") or ci_get(w, "ID") for w in raw_wo if (ci_get(w, "Id") or ci_get(w, "ID")) is not None}
    for row in raw_catw:
        cw_id = ci_get(row, "Id") or ci_get(row, "ID")
        woid  = ci_get(row, "WageOrderId") or ci_get(row, "WAGEORDERID")
        rate  = ci_get(row, "WageRate") or ci_get(row, "WAGERATE")
        tid   = ci_get(row, "TierId") or ci_get(row, "TIERID")
        if tid is None or tid not in valid_tids:
            cat_name = ci_get(row, "Category") or ci_get(row, "CATEGORY")
            if cat_name:
                tid = resolve_tier(cat_name, cmap)
        if tid is None or tid not in valid_tids:
            warns.append("CategoryWages Id={}: TierId is missing or invalid - skipped.".format(cw_id))
            continue
        if valid_woids and (woid is None or woid not in valid_woids):
            warns.append("CategoryWages Id={}: WageOrderId={} invalid - skipped.".format(cw_id, woid))
            continue
        item = {
            "WageOrderId": int(woid) if woid is not None else None,
            "TierId": int(tid),
            "WageRate": float(rate) if rate is not None else 0.0,
            "CreatedBy": ci_get(row, "CreatedBy") or ci_get(row, "CREATEDBY") or "ADMIN",
            "CreatedAt": ci_get(row, "CreatedAt") or ci_get(row, "CREATEDAT")
        }
        if cw_id is not None:
            item["Id"] = int(cw_id)
        catw_list.append(item)
    out["CategoryWages"] = catw_list

    for tbl in ("WageOrders", "StatutoryOrders", "CertificateTemplates",
                "EmployeeActionLogs", "ActionLog", "AdminActionLog",
                "AttendanceRemarks", "Notices"):
        out[tbl] = ci_get(raw, tbl) or []

    return out, warns

# ── entry point ───────────────────────────────────────────────────────────────

def main():
    if len(sys.argv) < 2:
        print("Usage: python migrate_backup.py input.json [output.json]"); sys.exit(1)
    inp  = sys.argv[1]
    outp = sys.argv[2] if len(sys.argv) >= 3 else os.path.splitext(inp)[0]+"_migrated"+os.path.splitext(inp)[1]
    if not os.path.exists(inp): print("ERROR: File not found: {}".format(inp)); sys.exit(1)

    print("Loading: " + inp)
    raw = load_json(inp)

    opts = gather_options(raw)

    print("\nMigrating...")
    result, warns = migrate(raw, opts)

    if warns:
        print("\n" + "="*62 + "\n  WARNINGS  ({})".format(len(warns)) + "\n" + "="*62)
        for w in warns: print("  [!] " + w)
        print("="*62)
    else:
        print("No warnings - clean migration!")

    save_json(result, outp)

    print("\nTable rows in migrated file:")
    for t, r in result.items():
        if isinstance(r, list): print("  {:<30} {:>5}".format(t, len(r)))

    print("\nSaved: " + outp)
    print("Done!  Restore via  Settings -> Restore Database Backup.")

if __name__ == "__main__":
    main()
