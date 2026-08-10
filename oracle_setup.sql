-- =============================================================================
--  ATTENDANCE MANAGEMENT SYSTEM — Complete Oracle Setup Script
--  Compatible with: Oracle Database 11g and above
--  Run as: SYSTEM user (or any DBA-privileged user)
--  NOTE: Errors on DROP statements are expected on first run — they can be ignored.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- SECTION 1: CREATE HRDATA SCHEMA (run once, ignore error if already exists)
-- -----------------------------------------------------------------------------
CREATE USER hrdata IDENTIFIED BY root DEFAULT TABLESPACE USERS QUOTA UNLIMITED ON USERS;

-- -----------------------------------------------------------------------------
-- SECTION 2: DROP EVERYTHING (clean slate — safe to ignore errors here)
-- -----------------------------------------------------------------------------

-- Drop triggers first
DROP TRIGGER TRG_EmployeeLeaveCredits;
DROP TRIGGER TRG_Notices;
DROP TRIGGER TRG_AttendanceRemarks;
DROP TRIGGER TRG_EmployeeActionLogs;
DROP TRIGGER TRG_AdminActionLog;
DROP TRIGGER TRG_ActionLog;
DROP TRIGGER TRG_Attendance;
DROP TRIGGER TRG_EmployeeEngagements;
DROP TRIGGER TRG_ContractPeriodVendors;
DROP TRIGGER TRG_ContractPeriods;
DROP TRIGGER TRG_VendorContacts;
DROP TRIGGER TRG_Vendors;
DROP TRIGGER TRG_MainCategory;
DROP TRIGGER TRG_Tiers;
DROP TRIGGER TRG_CategoryShareGrant;
DROP TRIGGER TRG_Divisions;
DROP TRIGGER TRG_ContractExtensions;
DROP TRIGGER TRG_AttendanceAuditLog;

-- Drop tables (in reverse dependency order)
DROP TABLE CertificateTemplates    CASCADE CONSTRAINTS;
DROP TABLE EmployeeLeaveCredits    CASCADE CONSTRAINTS;
DROP TABLE NoticeReads             CASCADE CONSTRAINTS;
DROP TABLE Notices                 CASCADE CONSTRAINTS;
DROP TABLE AttendanceRemarks       CASCADE CONSTRAINTS;
DROP TABLE CalculationOverrides    CASCADE CONSTRAINTS;
DROP TABLE CalculationWages        CASCADE CONSTRAINTS;
DROP TABLE Attendance_Audit_Log    CASCADE CONSTRAINTS;
DROP TABLE AdminActionLog          CASCADE CONSTRAINTS;
DROP TABLE ActionLog               CASCADE CONSTRAINTS;
DROP TABLE Attendance              CASCADE CONSTRAINTS;
DROP TABLE EmployeeActionLogs      CASCADE CONSTRAINTS;
DROP TABLE EmployeeEngagements     CASCADE CONSTRAINTS;
DROP TABLE Employees               CASCADE CONSTRAINTS;
DROP TABLE ContractExtensions      CASCADE CONSTRAINTS;
DROP TABLE ContractPeriodVendors   CASCADE CONSTRAINTS;
DROP TABLE ContractPeriods         CASCADE CONSTRAINTS;
DROP TABLE Contracts               CASCADE CONSTRAINTS;
DROP TABLE VendorContacts          CASCADE CONSTRAINTS;
DROP TABLE Vendors                 CASCADE CONSTRAINTS;
DROP TABLE UserDivisions           CASCADE CONSTRAINTS;
DROP TABLE UserTiers               CASCADE CONSTRAINTS;
DROP TABLE CategoryShareGrant      CASCADE CONSTRAINTS;
DROP TABLE Tiers                   CASCADE CONSTRAINTS;
DROP TABLE MainCategory            CASCADE CONSTRAINTS;
DROP TABLE Categories              CASCADE CONSTRAINTS;
DROP TABLE Divisions               CASCADE CONSTRAINTS;
DROP TABLE AppUsers                CASCADE CONSTRAINTS;
DROP TABLE hrdata.empdetails       CASCADE CONSTRAINTS;

-- Drop sequences
DROP SEQUENCE SEQ_EmployeeLeaveCredits;
DROP SEQUENCE SEQ_Notices;
DROP SEQUENCE SEQ_AttendanceRemarks;
DROP SEQUENCE SEQ_Divisions;
DROP SEQUENCE SEQ_MainCategory;
DROP SEQUENCE SEQ_Tiers;
DROP SEQUENCE SEQ_CategoryShareGrant;
DROP SEQUENCE SEQ_Vendors;
DROP SEQUENCE SEQ_VendorContacts;
DROP SEQUENCE SEQ_ContractPeriods;
DROP SEQUENCE SEQ_ContractPeriodVendors;
DROP SEQUENCE SEQ_EmployeeEngagements;
DROP SEQUENCE SEQ_Attendance;
DROP SEQUENCE SEQ_EmployeeActionLogs;
DROP SEQUENCE SEQ_AdminActionLog;
DROP SEQUENCE SEQ_ActionLog;
DROP SEQUENCE SEQ_ContractExtensions;
DROP SEQUENCE SEQ_AttendanceAuditLog;

-- =============================================================================
-- SECTION 3: CREATE TABLES
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 3.1  hrdata.empdetails  (Company HR table — name/designation lookup at login)
-- -----------------------------------------------------------------------------
CREATE TABLE hrdata.empdetails (
    PCNO        VARCHAR2(50)  PRIMARY KEY,
    NAME        VARCHAR2(200) NOT NULL,
    DESIGNATION VARCHAR2(100),
    DIVNAME     VARCHAR2(100)
);

-- -----------------------------------------------------------------------------
-- 3.2  AppUsers  (Authentication and role table)
--      Role: 1 = Admin, 0 = Regular User, 2 = Revoked Admin, 3 = Revoked User
-- -----------------------------------------------------------------------------
CREATE TABLE AppUsers (
    PCNO VARCHAR2(50)  PRIMARY KEY,
    Name VARCHAR2(200) NOT NULL,
    Role NUMBER(1)     DEFAULT 0 NOT NULL CHECK (Role IN (0, 1, 2, 3, 4, 5))
);

-- -----------------------------------------------------------------------------
-- 3.3  Divisions  (Organisational divisions/departments)
-- -----------------------------------------------------------------------------
CREATE TABLE Divisions (
    Id   NUMBER       PRIMARY KEY,
    Name VARCHAR2(100) NOT NULL UNIQUE
);

CREATE SEQUENCE SEQ_Divisions START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER TRG_Divisions
BEFORE INSERT ON Divisions
FOR EACH ROW
BEGIN
    IF :NEW.Id IS NULL THEN
        SELECT SEQ_Divisions.NEXTVAL INTO :NEW.Id FROM DUAL;
    END IF;
END;
/

-- -----------------------------------------------------------------------------
-- 3.4  MainCategory & Tiers (Hierarchical Category structure)
-- -----------------------------------------------------------------------------
CREATE TABLE MainCategory (
    Id              NUMBER PRIMARY KEY,
    Name            VARCHAR2(100) NOT NULL UNIQUE,
    AdminPCNO       VARCHAR2(50),
    EditDaysAllowed NUMBER DEFAULT 0 NOT NULL,
    EditMode        NUMBER(1) DEFAULT 0 NOT NULL CHECK (EditMode IN (0, 1)),
    FOREIGN KEY (AdminPCNO) REFERENCES AppUsers(PCNO) ON DELETE CASCADE
);

CREATE SEQUENCE SEQ_MainCategory START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER TRG_MainCategory
BEFORE INSERT ON MainCategory
FOR EACH ROW
BEGIN
    IF :NEW.Id IS NULL THEN
        SELECT SEQ_MainCategory.NEXTVAL INTO :NEW.Id FROM DUAL;
    END IF;
END;
/

CREATE TABLE Tiers (
    Id             NUMBER PRIMARY KEY,
    MainCategoryId NUMBER NOT NULL,
    TierName       VARCHAR2(100) NOT NULL,
    RoleLabel      VARCHAR2(100) NULL,
    SortOrder      NUMBER DEFAULT 0,
    FOREIGN KEY (MainCategoryId) REFERENCES MainCategory(Id) ON DELETE CASCADE,
    CONSTRAINT UQ_Tiers_Category UNIQUE (MainCategoryId, TierName, RoleLabel)
);

CREATE SEQUENCE SEQ_Tiers START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER TRG_Tiers
BEFORE INSERT ON Tiers
FOR EACH ROW
BEGIN
    IF :NEW.Id IS NULL THEN
        SELECT SEQ_Tiers.NEXTVAL INTO :NEW.Id FROM DUAL;
    END IF;
END;
/

-- -----------------------------------------------------------------------------
-- 3.4b UserTiers  (Allowed tiers for regular users)
-- -----------------------------------------------------------------------------
CREATE TABLE UserTiers (
    PCNO   VARCHAR2(50) NOT NULL,
    TierId NUMBER NOT NULL,
    PRIMARY KEY (PCNO, TierId),
    FOREIGN KEY (PCNO) REFERENCES AppUsers(PCNO) ON DELETE CASCADE,
    FOREIGN KEY (TierId) REFERENCES Tiers(Id) ON DELETE CASCADE
);

-- -----------------------------------------------------------------------------
-- 3.4c CategoryShareGrant  (Cross-Admin sharing mappings)
-- -----------------------------------------------------------------------------
CREATE TABLE CategoryShareGrant (
    Id             NUMBER PRIMARY KEY,
    OwnerAdminPCNO VARCHAR2(50) NOT NULL,
    SharedWithPCNO VARCHAR2(50) NOT NULL,
    MainCategoryId NUMBER NOT NULL,
    TierId         NUMBER NULL,
    IsActive       NUMBER(1) DEFAULT 1 NOT NULL CHECK (IsActive IN (0, 1)),
    GrantedAt      TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    FOREIGN KEY (OwnerAdminPCNO) REFERENCES AppUsers(PCNO) ON DELETE CASCADE,
    FOREIGN KEY (SharedWithPCNO) REFERENCES AppUsers(PCNO) ON DELETE CASCADE,
    FOREIGN KEY (MainCategoryId) REFERENCES MainCategory(Id) ON DELETE CASCADE,
    FOREIGN KEY (TierId) REFERENCES Tiers(Id) ON DELETE CASCADE,
    CONSTRAINT UQ_CategoryShareGrant UNIQUE (OwnerAdminPCNO, SharedWithPCNO, MainCategoryId, TierId)
);

CREATE SEQUENCE SEQ_CategoryShareGrant START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER TRG_CategoryShareGrant
BEFORE INSERT ON CategoryShareGrant
FOR EACH ROW
BEGIN
    IF :NEW.Id IS NULL THEN
        SELECT SEQ_CategoryShareGrant.NEXTVAL INTO :NEW.Id FROM DUAL;
    END IF;
END;
/

-- -----------------------------------------------------------------------------
-- 3.5  UserDivisions  (Maps regular users to the divisions they can manage)
-- -----------------------------------------------------------------------------
CREATE TABLE UserDivisions (
    PCNO         VARCHAR2(50)  NOT NULL,
    DivisionName VARCHAR2(100) NOT NULL,
    PRIMARY KEY (PCNO, DivisionName),
    FOREIGN KEY (PCNO) REFERENCES AppUsers(PCNO) ON DELETE CASCADE
);

-- -----------------------------------------------------------------------------
-- 3.6  Vendors  (Manpower agencies / contractors)
-- -----------------------------------------------------------------------------
CREATE TABLE Vendors (
    Id           NUMBER        PRIMARY KEY,
    MasterId     VARCHAR2(50)  NOT NULL UNIQUE,
    Name         VARCHAR2(150) NOT NULL UNIQUE,
    GemId        VARCHAR2(100),
    ContactName  VARCHAR2(100),
    ContactPhone VARCHAR2(20),
    Address      VARCHAR2(4000),
    IsActive     NUMBER(1)     DEFAULT 1 NOT NULL CHECK (IsActive IN (0, 1))
);

CREATE SEQUENCE SEQ_Vendors START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER TRG_Vendors
BEFORE INSERT ON Vendors
FOR EACH ROW
BEGIN
    IF :NEW.Id IS NULL THEN
        SELECT SEQ_Vendors.NEXTVAL INTO :NEW.Id FROM DUAL;
    END IF;
END;
/

-- -----------------------------------------------------------------------------
-- 3.6b VendorContacts  (Dynamic escalation matrix — N contact levels per vendor)
--      Priority 1 = Primary contact (Name, Phone, Email, Address required)
--      Priority 2+ = Secondary/Higher levels (Name, Phone required; Email/Address optional)
-- -----------------------------------------------------------------------------
CREATE TABLE VendorContacts (
    Id             NUMBER         PRIMARY KEY,
    VendorId       NUMBER         NOT NULL,
    Priority       NUMBER         NOT NULL,       -- 1 = Primary, 2 = Level 2, etc.
    ContactName    VARCHAR2(100)  NOT NULL,
    ContactPhone   VARCHAR2(20)   NOT NULL,
    ContactEmail   VARCHAR2(200),                 -- Required for Priority=1 only
    ContactAddress VARCHAR2(4000),                -- Required for Priority=1 only
    SortOrder      NUMBER         DEFAULT 0,
    CONSTRAINT FK_VendorContacts_Vendor FOREIGN KEY (VendorId) REFERENCES Vendors(Id) ON DELETE CASCADE,
    CONSTRAINT UQ_VendorContacts_Priority UNIQUE (VendorId, Priority)
);

CREATE SEQUENCE SEQ_VendorContacts START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER TRG_VendorContacts
BEFORE INSERT ON VendorContacts
FOR EACH ROW
BEGIN
    IF :NEW.Id IS NULL THEN
        SELECT SEQ_VendorContacts.NEXTVAL INTO :NEW.Id FROM DUAL;
    END IF;
END;
/

-- -----------------------------------------------------------------------------
-- 3.7  ContractPeriods  (One contract period per tier per vendor)
-- -----------------------------------------------------------------------------
CREATE TABLE ContractPeriods (
    Id        NUMBER        PRIMARY KEY,
    TierId    NUMBER        NOT NULL,
    VendorId  NUMBER        NOT NULL,
    GemId     VARCHAR2(100),
    StartDate DATE          NOT NULL,
    EndDate   DATE,
    DatedOn   DATE,
    Status    VARCHAR2(20)  DEFAULT 'Active' NOT NULL CHECK (Status IN ('Active', 'Closed')),
    Notes     VARCHAR2(4000),
    FOREIGN KEY (TierId) REFERENCES Tiers(Id) ON DELETE CASCADE,
    FOREIGN KEY (VendorId) REFERENCES Vendors(Id),
    CONSTRAINT UQ_ContractPeriods UNIQUE (TierId, StartDate)
);

CREATE SEQUENCE SEQ_ContractPeriods START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER TRG_ContractPeriods
BEFORE INSERT ON ContractPeriods
FOR EACH ROW
BEGIN
    IF :NEW.Id IS NULL THEN
        SELECT SEQ_ContractPeriods.NEXTVAL INTO :NEW.Id FROM DUAL;
    END IF;
END;
/

-- -----------------------------------------------------------------------------
-- 3.8  ContractPeriodVendors  (Vendors attached to a contract period)
-- -----------------------------------------------------------------------------
CREATE TABLE ContractPeriodVendors (
    Id               NUMBER        PRIMARY KEY,
    ContractPeriodId NUMBER        NOT NULL,
    VendorId         NUMBER        NOT NULL,
    TierId           NUMBER        NOT NULL,
    IsActive         NUMBER(1)     DEFAULT 1 NOT NULL CHECK (IsActive IN (0, 1)),
    FOREIGN KEY (ContractPeriodId) REFERENCES ContractPeriods(Id) ON DELETE CASCADE,
    FOREIGN KEY (VendorId)         REFERENCES Vendors(Id),
    FOREIGN KEY (TierId)           REFERENCES Tiers(Id) ON DELETE CASCADE
);

CREATE SEQUENCE SEQ_ContractPeriodVendors START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER TRG_ContractPeriodVendors
BEFORE INSERT ON ContractPeriodVendors
FOR EACH ROW
BEGIN
    IF :NEW.Id IS NULL THEN
        SELECT SEQ_ContractPeriodVendors.NEXTVAL INTO :NEW.Id FROM DUAL;
    END IF;
END;
/

-- -----------------------------------------------------------------------------
-- 3.8b ContractExtensions  (Tracks extensions to contract periods)
-- -----------------------------------------------------------------------------
CREATE TABLE ContractExtensions (
    Id               NUMBER        PRIMARY KEY,
    ContractPeriodId NUMBER        NOT NULL,
    OldEndDate       DATE,
    NewEndDate       DATE          NOT NULL,
    ExtensionDate    TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
    FOREIGN KEY (ContractPeriodId) REFERENCES ContractPeriods(Id) ON DELETE CASCADE
);

CREATE SEQUENCE SEQ_ContractExtensions START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER TRG_ContractExtensions
BEFORE INSERT ON ContractExtensions
FOR EACH ROW
BEGIN
    IF :NEW.Id IS NULL THEN
        SELECT SEQ_ContractExtensions.NEXTVAL INTO :NEW.Id FROM DUAL;
    END IF;
END;
/

-- -----------------------------------------------------------------------------
-- 3.9  Employees  (Master employee records with persistent history mapping)
-- -----------------------------------------------------------------------------
CREATE TABLE Employees (
    MasterId            VARCHAR2(50)  PRIMARY KEY,
    ID                  VARCHAR2(50)  NOT NULL,
    Name                VARCHAR2(200) NOT NULL,
    Department          VARCHAR2(100),
    TierId              NUMBER,
    EmployeeHistoryId   VARCHAR2(50)  NOT NULL,
    OriginalJoinDate    DATE,
    JoinDate            DATE,
    LeaveBalance        NUMBER        DEFAULT 0 NOT NULL,
    PrevLeaveBalance    NUMBER        DEFAULT 0 NOT NULL,
    Status              VARCHAR2(20)  DEFAULT 'Active' NOT NULL,
    ResignDate          DATE,
    ContractEndDate     DATE,
    CurrentEngagementId NUMBER,
    Phone               VARCHAR2(50),
    Email               VARCHAR2(100),
    Aadhar              VARCHAR2(50),
    Address             VARCHAR2(4000),
    Qualification       VARCHAR2(200),
    Experience          NUMBER,
    ExperienceIn        VARCHAR2(200),
    FOREIGN KEY (TierId) REFERENCES Tiers(Id) ON DELETE CASCADE
);

-- -----------------------------------------------------------------------------
-- 3.10 EmployeeEngagements  (Employment stints within a contract period)
-- -----------------------------------------------------------------------------
CREATE TABLE EmployeeEngagements (
    Id               NUMBER        PRIMARY KEY,
    EmpID            VARCHAR2(50)  NOT NULL,
    ContractPeriodId NUMBER,
    TierId           NUMBER        NOT NULL,
    VendorId         NUMBER        NOT NULL,
    Department       VARCHAR2(100),
    StartDate        DATE          NOT NULL,
    EndDate          DATE,
    EndReason        VARCHAR2(50),
    IsCarriedOver    NUMBER(1)     DEFAULT 0 NOT NULL CHECK (IsCarriedOver IN (0, 1)),
    PrevEngagementId NUMBER,
    EmployeeId       VARCHAR2(50),
    FOREIGN KEY (EmpID)            REFERENCES Employees(MasterId) ON DELETE CASCADE,
    FOREIGN KEY (ContractPeriodId) REFERENCES ContractPeriods(Id) ON DELETE SET NULL,
    FOREIGN KEY (VendorId)         REFERENCES Vendors(Id),
    FOREIGN KEY (PrevEngagementId) REFERENCES EmployeeEngagements(Id),
    FOREIGN KEY (TierId)           REFERENCES Tiers(Id) ON DELETE CASCADE
);

CREATE SEQUENCE SEQ_EmployeeEngagements START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER TRG_EmployeeEngagements
BEFORE INSERT ON EmployeeEngagements
FOR EACH ROW
BEGIN
    IF :NEW.Id IS NULL THEN
        SELECT SEQ_EmployeeEngagements.NEXTVAL INTO :NEW.Id FROM DUAL;
    END IF;
END;
/

-- -----------------------------------------------------------------------------
-- 3.10b EmployeeLeaveCredits  (Date-specific employee leave credits)
-- -----------------------------------------------------------------------------
CREATE TABLE EmployeeLeaveCredits (
    Id               NUMBER        PRIMARY KEY,
    EmpID            VARCHAR2(50)  NOT NULL,
    ContractPeriodId NUMBER        NOT NULL,
    Amount           NUMBER        NOT NULL,
    EffectiveDate    DATE          NOT NULL,
    Remarks          VARCHAR2(200),
    FOREIGN KEY (EmpID)            REFERENCES Employees(MasterId) ON DELETE CASCADE,
    FOREIGN KEY (ContractPeriodId) REFERENCES ContractPeriods(Id) ON DELETE CASCADE
);

CREATE SEQUENCE SEQ_EmployeeLeaveCredits START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER TRG_EmployeeLeaveCredits
BEFORE INSERT ON EmployeeLeaveCredits
FOR EACH ROW
BEGIN
    IF :NEW.Id IS NULL THEN
        SELECT SEQ_EmployeeLeaveCredits.NEXTVAL INTO :NEW.Id FROM DUAL;
    END IF;
END;
/


-- Add deferred FK for CurrentEngagementId (circular ref: Employees <-> Engagements)
ALTER TABLE Employees
    ADD CONSTRAINT FK_Emp_CurrentEngagement
    FOREIGN KEY (CurrentEngagementId) REFERENCES EmployeeEngagements(Id);

-- -----------------------------------------------------------------------------
-- 3.11 Attendance  (Daily attendance records)
--      StatusValue: 0 = Absent, 1 = Present, 2 = Paid Leave, 3 = Unpaid Leave
--      Remarks: populated on manual Saturday override (admin right-click edit)
--      AutoSat: 1 = counted as absent automatically (Saturday rule)
-- -----------------------------------------------------------------------------
CREATE TABLE Attendance (
    Id               NUMBER        PRIMARY KEY,
    EmpID            VARCHAR2(50)  NOT NULL,
    EngagementId     NUMBER,
    ContractPeriodId NUMBER,
    Year             NUMBER(4)     NOT NULL,
    Month            NUMBER(2)     NOT NULL,
    Day              NUMBER(2)     NOT NULL,
    StatusValue      NUMBER(1),
    LeaveType        VARCHAR2(50),
    IsHoliday        NUMBER(1)     DEFAULT 0 CHECK (IsHoliday IN (0, 1)),
    AutoSat          NUMBER(1)     DEFAULT 0 CHECK (AutoSat IN (0, 1)),
    Remarks          VARCHAR2(500),
    FOREIGN KEY (EmpID)            REFERENCES Employees(MasterId),
    FOREIGN KEY (EngagementId)     REFERENCES EmployeeEngagements(Id),
    FOREIGN KEY (ContractPeriodId) REFERENCES ContractPeriods(Id),
    CONSTRAINT UQ_Attendance_Date  UNIQUE (EmpID, Year, Month, Day)
);

CREATE SEQUENCE SEQ_Attendance START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER TRG_Attendance
BEFORE INSERT ON Attendance
FOR EACH ROW
BEGIN
    IF :NEW.Id IS NULL THEN
        SELECT SEQ_Attendance.NEXTVAL INTO :NEW.Id FROM DUAL;
    END IF;
END;
/

-- -----------------------------------------------------------------------------
-- 3.12 CalculationWages  (Wage rate per month per tier for salary calc)
-- -----------------------------------------------------------------------------
CREATE TABLE CalculationWages (
    Year     NUMBER(4)     NOT NULL,
    Month    NUMBER(2)     NOT NULL,
    TierId   NUMBER        NOT NULL,
    WageRate NUMBER(10, 2) NOT NULL,
    PRIMARY KEY (Year, Month, TierId),
    FOREIGN KEY (TierId) REFERENCES Tiers(Id) ON DELETE CASCADE
);

-- -----------------------------------------------------------------------------
-- 3.13 CalculationOverrides  (Manual override of final days for salary calc)
-- -----------------------------------------------------------------------------
CREATE TABLE CalculationOverrides (
    Year             NUMBER(4)    NOT NULL,
    Month            NUMBER(2)    NOT NULL,
    TierId           NUMBER       NOT NULL,
    EmpID            VARCHAR2(50) NOT NULL,
    EngagementId     NUMBER,
    ContractPeriodId NUMBER,
    FinalDays        NUMBER(5, 2),
    Remarks          VARCHAR2(500),
    PRIMARY KEY (Year, Month, TierId, EmpID),
    FOREIGN KEY (EmpID)            REFERENCES Employees(MasterId),
    FOREIGN KEY (EngagementId)     REFERENCES EmployeeEngagements(Id),
    FOREIGN KEY (ContractPeriodId) REFERENCES ContractPeriods(Id),
    FOREIGN KEY (TierId)           REFERENCES Tiers(Id) ON DELETE CASCADE
);

-- -----------------------------------------------------------------------------
-- 3.14 EmployeeActionLogs  (Audit trail of employee record changes)
-- -----------------------------------------------------------------------------
CREATE TABLE EmployeeActionLogs (
    Id          NUMBER         PRIMARY KEY,
    ActionTime  TIMESTAMP      DEFAULT SYSTIMESTAMP NOT NULL,
    ActionType  VARCHAR2(50)   NOT NULL,
    EmpMasterId VARCHAR2(50)   NOT NULL,
    Description VARCHAR2(500)  NOT NULL,
    PreState    CLOB,
    PostState   CLOB,
    IsUndone    NUMBER(1)      DEFAULT 0 NOT NULL CHECK (IsUndone IN (0, 1))
);

CREATE SEQUENCE SEQ_EmployeeActionLogs START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER TRG_EmployeeActionLogs
BEFORE INSERT ON EmployeeActionLogs
FOR EACH ROW
BEGIN
    IF :NEW.Id IS NULL THEN
        SELECT SEQ_EmployeeActionLogs.NEXTVAL INTO :NEW.Id FROM DUAL;
    END IF;
END;
/

-- -----------------------------------------------------------------------------
-- 3.15 ActionLog  (General system action log)
-- -----------------------------------------------------------------------------
CREATE TABLE ActionLog (
    Id          NUMBER        PRIMARY KEY,
    ActionTime  TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
    ActionType  VARCHAR2(100) NOT NULL,
    PerformedBy VARCHAR2(100),
    TargetId    VARCHAR2(100),
    Description VARCHAR2(1000),
    PreState    CLOB,
    PostState   CLOB
);

CREATE SEQUENCE SEQ_ActionLog START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER TRG_ActionLog
BEFORE INSERT ON ActionLog
FOR EACH ROW
BEGIN
    IF :NEW.Id IS NULL THEN
        SELECT SEQ_ActionLog.NEXTVAL INTO :NEW.Id FROM DUAL;
    END IF;
END;
/

-- -----------------------------------------------------------------------------
-- 3.16 AdminActionLog  (Admin-specific action log, e.g. bulk saves)
-- -----------------------------------------------------------------------------
CREATE TABLE AdminActionLog (
    Id          NUMBER        PRIMARY KEY,
    ActionTime  TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
    ActionType  VARCHAR2(100) NOT NULL,
    PerformedBy VARCHAR2(100),
    TargetId    VARCHAR2(100),
    Description VARCHAR2(1000),
    PreState    CLOB,
    PostState   CLOB
);

CREATE SEQUENCE SEQ_AdminActionLog START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER TRG_AdminActionLog
BEFORE INSERT ON AdminActionLog
FOR EACH ROW
BEGIN
    IF :NEW.Id IS NULL THEN
        SELECT SEQ_AdminActionLog.NEXTVAL INTO :NEW.Id FROM DUAL;
    END IF;
END;
/

-- -----------------------------------------------------------------------------
-- 3.17 Attendance_Audit_Log  (Tracks every change to an attendance record)
-- -----------------------------------------------------------------------------
CREATE TABLE Attendance_Audit_Log (
    Id          NUMBER        PRIMARY KEY,
    LogTime     TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
    EmpID       VARCHAR2(50),
    Year        NUMBER(4),
    Month       NUMBER(2),
    Day         NUMBER(2),
    OldValue    NUMBER(1),
    NewValue    NUMBER(1),
    ChangedBy   VARCHAR2(100),
    Reason      VARCHAR2(500)
);

CREATE SEQUENCE SEQ_AttendanceAuditLog START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER TRG_AttendanceAuditLog
BEFORE INSERT ON Attendance_Audit_Log
FOR EACH ROW
BEGIN
    IF :NEW.Id IS NULL THEN
        SELECT SEQ_AttendanceAuditLog.NEXTVAL INTO :NEW.Id FROM DUAL;
    END IF;
END;
/

-- -----------------------------------------------------------------------------
-- 3.18 AttendanceRemarks  (User-submitted remarks/correction requests to admin)
--      SubmittedBy : PCNO of the user who sent the remark
--      SenderName  : Display name of the sender
--      EmpID       : MasterId of the employee the remark is about
--      RemarkDate  : The attendance date the remark refers to
--      IsRead      : 0 = Unread (new), 1 = Read by admin
--      CreatedAt   : Timestamp when the remark was submitted
-- -----------------------------------------------------------------------------
CREATE TABLE AttendanceRemarks (
    Id             NUMBER          PRIMARY KEY,
    SubmittedBy    VARCHAR2(100)   NOT NULL,
    SenderName     VARCHAR2(200)   NOT NULL,
    EmpID          VARCHAR2(50)    NOT NULL,
    RemarkDate     DATE            NOT NULL,
    Message        VARCHAR2(1000)  NOT NULL,
    IsRead         NUMBER(1)       DEFAULT 0 NOT NULL CHECK (IsRead IN (0, 1)),
    CreatedAt      TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
    MainCategoryId NUMBER          NULL REFERENCES MainCategory(Id)
);

CREATE SEQUENCE SEQ_AttendanceRemarks START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER TRG_AttendanceRemarks
BEFORE INSERT ON AttendanceRemarks
FOR EACH ROW
BEGIN
    IF :NEW.Id IS NULL THEN
        SELECT SEQ_AttendanceRemarks.NEXTVAL INTO :NEW.Id FROM DUAL;
    END IF;
END;
/

-- -----------------------------------------------------------------------------
-- 3.18b AttPocEditRemarks  (Stores POC edit-reason remarks per attendance cell)
-- -----------------------------------------------------------------------------
CREATE TABLE AttPocEditRemarks (
    Id          NUMBER          PRIMARY KEY,
    EmpID       VARCHAR2(50)    NOT NULL,
    Year        NUMBER          NOT NULL,
    Month       NUMBER          NOT NULL,
    Day         NUMBER          NOT NULL,
    RemarkType  VARCHAR2(50)    DEFAULT 'POCEdit' NOT NULL,
    Remark      VARCHAR2(1000)  NOT NULL,
    CreatedBy   VARCHAR2(100)   NOT NULL,
    CreatedAt   TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL
);

CREATE SEQUENCE SEQ_AttPocEditRemarks START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER TRG_AttPocEditRemarks
BEFORE INSERT ON AttPocEditRemarks
FOR EACH ROW
BEGIN
    IF :NEW.Id IS NULL THEN
        SELECT SEQ_AttPocEditRemarks.NEXTVAL INTO :NEW.Id FROM DUAL;
    END IF;
END;
/

-- -----------------------------------------------------------------------------
-- 3.19 Notices  (Official notices and documents uploaded by admin)
-- -----------------------------------------------------------------------------
CREATE TABLE Notices (
    Id             NUMBER        PRIMARY KEY,
    Name           VARCHAR2(255) NOT NULL,
    FilePath       VARCHAR2(500) NULL,
    NoticeText     NCLOB,
    Category       VARCHAR2(100) DEFAULT 'General',
    IsHidden       NUMBER(1)     DEFAULT 0 NOT NULL CHECK (IsHidden IN (0, 1)),
    UploadDate     TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
    MainCategoryId NUMBER        NULL REFERENCES MainCategory(Id)
);

CREATE SEQUENCE SEQ_Notices START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER TRG_Notices
BEFORE INSERT ON Notices
FOR EACH ROW
BEGIN
    IF :NEW.Id IS NULL THEN
        SELECT SEQ_Notices.NEXTVAL INTO :NEW.Id FROM DUAL;
    END IF;
END;
/

-- -----------------------------------------------------------------------------
-- 3.19b NoticeReads (Tracks notice read timestamps by user PCNO)
-- -----------------------------------------------------------------------------
CREATE TABLE NoticeReads (
    NoticeId NUMBER        NOT NULL REFERENCES Notices(Id) ON DELETE CASCADE,
    PCNO     VARCHAR2(100) NOT NULL,
    ReadAt   TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT PK_NoticeReads PRIMARY KEY (NoticeId, PCNO)
);

-- -----------------------------------------------------------------------------
-- 3.20 CertificateTemplates (Templates for generated document sentences)
-- -----------------------------------------------------------------------------
CREATE TABLE CertificateTemplates (
    TemplateKey   VARCHAR2(50)   PRIMARY KEY,
    TemplateValue VARCHAR2(1000) NOT NULL
);

-- -----------------------------------------------------------------------------
-- 3.21 WageOrders (Government/Labour Wage Order Master Records)
-- -----------------------------------------------------------------------------
CREATE TABLE WageOrders (
    Id             NUMBER         PRIMARY KEY,
    OrderId        VARCHAR2(100)  NOT NULL,
    MainCategoryId NUMBER         NOT NULL,
    EffectiveDate  DATE           NOT NULL,
    OrderDetails   VARCHAR2(4000),
    CreatedBy      VARCHAR2(50)   NOT NULL,
    CreatedAt      TIMESTAMP      DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (MainCategoryId) REFERENCES MainCategory(Id) ON DELETE CASCADE
);

CREATE SEQUENCE SEQ_WageOrders START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER TRG_WageOrders
BEFORE INSERT ON WageOrders
FOR EACH ROW
BEGIN
    IF :NEW.Id IS NULL THEN
        SELECT SEQ_WageOrders.NEXTVAL INTO :NEW.Id FROM DUAL;
    END IF;
END;
/

-- -----------------------------------------------------------------------------
-- 3.22 CategoryWages (Per-category daily/monthly wage rates linked to a Wage Order)
-- -----------------------------------------------------------------------------
CREATE TABLE CategoryWages (
    Id          NUMBER         PRIMARY KEY,
    WageOrderId NUMBER         NOT NULL,
    TierId      NUMBER         NOT NULL,
    WageRate    NUMBER(10,2)   NOT NULL,
    CreatedBy   VARCHAR2(50),
    CreatedAt   TIMESTAMP      DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (WageOrderId) REFERENCES WageOrders(Id) ON DELETE CASCADE,
    FOREIGN KEY (TierId)      REFERENCES Tiers(Id) ON DELETE CASCADE
);

CREATE SEQUENCE SEQ_CategoryWages START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER TRG_CategoryWages
BEFORE INSERT ON CategoryWages
FOR EACH ROW
BEGIN
    IF :NEW.Id IS NULL THEN
        SELECT SEQ_CategoryWages.NEXTVAL INTO :NEW.Id FROM DUAL;
    END IF;
END;
/

-- -----------------------------------------------------------------------------
-- 3.23 StatutoryOrders (EPF & GST Statutory Revision History)
-- -----------------------------------------------------------------------------
CREATE TABLE StatutoryOrders (
    Id               NUMBER         PRIMARY KEY,
    OrderId          VARCHAR2(100)  NOT NULL,
    EffectiveDate    DATE           NOT NULL,
    EpfRate          NUMBER(5,2)    NOT NULL,
    EpfLimit         NUMBER(10,2)   NOT NULL,
    EpfCappedAmount  NUMBER(10,2)   NOT NULL,
    GstRate          NUMBER(5,2)    DEFAULT 18.00 NOT NULL,
    OrderDetails     VARCHAR2(4000),
    CreatedBy        VARCHAR2(50)   NOT NULL,
    CreatedAt        TIMESTAMP      DEFAULT CURRENT_TIMESTAMP
);

CREATE SEQUENCE SEQ_StatutoryOrders START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER TRG_StatutoryOrders
BEFORE INSERT ON StatutoryOrders
FOR EACH ROW
BEGIN
    IF :NEW.Id IS NULL THEN
        SELECT SEQ_StatutoryOrders.NEXTVAL INTO :NEW.Id FROM DUAL;
    END IF;
END;
/

-- =============================================================================
-- SECTION 4: SEED DATA (Minimal required test data)
-- =============================================================================

-- 4.1  HR data (company employees — used for login name/designation lookup)
INSERT INTO hrdata.empdetails (PCNO, NAME, DESIGNATION, DIVNAME) VALUES ('1001', 'Admin User',  'Manager',    'DKRM/ITISG');
INSERT INTO hrdata.empdetails (PCNO, NAME, DESIGNATION, DIVNAME) VALUES ('1002', 'Test User',   'Engineer',   'D-ADMIN/STORE');
INSERT INTO hrdata.empdetails (PCNO, NAME, DESIGNATION, DIVNAME) VALUES ('1003', 'John Doe',    'Technician', 'DKRM/MAINT');

-- 4.2  App users (login accounts)
--      PCNO 1001 = Admin (Role 1)
--      PCNO 1002 / 1003 = Regular Users (Role 0)
INSERT INTO AppUsers (PCNO, Name, Role) VALUES ('1001', 'Admin User', 1);
INSERT INTO AppUsers (PCNO, Name, Role) VALUES ('1002', 'Test User',  0);
INSERT INTO AppUsers (PCNO, Name, Role) VALUES ('1003', 'John Doe',   0);

-- 4.3  Divisions
INSERT INTO Divisions (Name) VALUES ('AD-Admin');
INSERT INTO Divisions (Name) VALUES ('AD-Planning');
INSERT INTO Divisions (Name) VALUES ('AD-Quality');
INSERT INTO Divisions (Name) VALUES ('AD-RM');
INSERT INTO Divisions (Name) VALUES ('AD-System I');
INSERT INTO Divisions (Name) VALUES ('CWG');
INSERT INTO Divisions (Name) VALUES ('D-ADMIN');
INSERT INTO Divisions (Name) VALUES ('D-Admin');
INSERT INTO Divisions (Name) VALUES ('D-AE');
INSERT INTO Divisions (Name) VALUES ('D-ASR');
INSERT INTO Divisions (Name) VALUES ('D-FCR');
INSERT INTO Divisions (Name) VALUES ('D-FMM');
INSERT INTO Divisions (Name) VALUES ('D-HQA');
INSERT INTO Divisions (Name) VALUES ('D-KRM');
INSERT INTO Divisions (Name) VALUES ('D-LRR');
INSERT INTO Divisions (Name) VALUES ('D-ME');
INSERT INTO Divisions (Name) VALUES ('D-MS');
INSERT INTO Divisions (Name) VALUES ('D-MS/CREECHE');
INSERT INTO Divisions (Name) VALUES ('D-PC');
INSERT INTO Divisions (Name) VALUES ('D-PS');
INSERT INTO Divisions (Name) VALUES ('D-PSRR');
INSERT INTO Divisions (Name) VALUES ('D-RAM');
INSERT INTO Divisions (Name) VALUES ('D-RSW');
INSERT INTO Divisions (Name) VALUES ('D-SALES');
INSERT INTO Divisions (Name) VALUES ('D-SQA');
INSERT INTO Divisions (Name) VALUES ('D-SR');
INSERT INTO Divisions (Name) VALUES ('DS');
INSERT INTO Divisions (Name) VALUES ('LCSO');
INSERT INTO Divisions (Name) VALUES ('SECURITY');
INSERT INTO Divisions (Name) VALUES ('Security');

-- 4.4  MainCategory and Tiers (Seeded for Admin User '1001')
INSERT INTO MainCategory (Id, Name, AdminPCNO) VALUES (1, 'HR', '1001');

INSERT INTO Tiers (Id, MainCategoryId, TierName, RoleLabel, SortOrder) VALUES (1, 1, 'Skilled', NULL, 1);
INSERT INTO Tiers (Id, MainCategoryId, TierName, RoleLabel, SortOrder) VALUES (2, 1, 'Semi-Skilled', NULL, 2);
INSERT INTO Tiers (Id, MainCategoryId, TierName, RoleLabel, SortOrder) VALUES (3, 1, 'Unskilled', NULL, 3);

-- Update SEQ starting values so new additions don't conflict
DROP SEQUENCE SEQ_MainCategory;
CREATE SEQUENCE SEQ_MainCategory START WITH 2 INCREMENT BY 1 NOCACHE NOCYCLE;
DROP SEQUENCE SEQ_Tiers;
CREATE SEQUENCE SEQ_Tiers START WITH 4 INCREMENT BY 1 NOCACHE NOCYCLE;

-- 4.5  User-Division mappings (which divisions each regular user can access)
INSERT INTO UserDivisions (PCNO, DivisionName) VALUES ('1002', 'D-Admin');
INSERT INTO UserDivisions (PCNO, DivisionName) VALUES ('1002', 'D-ASR');
INSERT INTO UserDivisions (PCNO, DivisionName) VALUES ('1003', 'D-Admin');
INSERT INTO UserDivisions (PCNO, DivisionName) VALUES ('1003', 'D-KRM');

-- 4.6  System Seed Records
INSERT INTO Employees (MasterId, ID, Name, Department, TierId, EmployeeHistoryId, Status, LeaveBalance) VALUES ('GLOBAL', 'GLOBAL', 'GLOBAL Adjustment', NULL, NULL, 'GLOBAL', 'System', 0);

-- 4.7  Certificate Templates Seed Records
INSERT INTO CertificateTemplates (TemplateKey, TemplateValue) VALUES ('AttDesc1', 'This is certify that DEO ({Category}) under GeM Contract No: {ContractNo}, dated: {ContractDate}, Dated On: {DatedOn}');
INSERT INTO CertificateTemplates (TemplateKey, TemplateValue) VALUES ('AttDesc2', 'M/s. {VendorName}, {VendorAddress} worked as following, for the period from {StartDate} to {EndDate}');
INSERT INTO CertificateTemplates (TemplateKey, TemplateValue) VALUES ('SatDesc1', 'This is to certify that M/s. <b>{VendorName}</b>, {VendorAddress} is engaged as an Industry Partner in our Establishment to provide Services towards <b>{Services}</b> for a period of {Duration} w.e.f. {WefDate} against GeM Contract No. <b>{ContractNo}</b> dated {ContractDate}, Dated On: {DatedOn}.');
INSERT INTO CertificateTemplates (TemplateKey, TemplateValue) VALUES ('SatDesc2', 'The Industry Partner provided <b>{EmpCount}</b> Contract Employees and found working satisfactorily.');
INSERT INTO CertificateTemplates (TemplateKey, TemplateValue) VALUES ('SatDesc3', 'The service provided by the Industry Partner from {StartDate} to {EndDate} is found satisfactory.');
INSERT INTO CertificateTemplates (TemplateKey, TemplateValue) VALUES ('SatSignatory', '(Raajita B Reddy)');
INSERT INTO CertificateTemplates (TemplateKey, TemplateValue) VALUES ('SatDesignation', 'Scientist ''F''');
INSERT INTO CertificateTemplates (TemplateKey, TemplateValue) VALUES ('SatServices', 'Human Resource Outsourcing Services');
INSERT INTO CertificateTemplates (TemplateKey, TemplateValue) VALUES ('CovPhone', '2312');
INSERT INTO CertificateTemplates (TemplateKey, TemplateValue) VALUES ('CovRefNo', '49805/HRD/HM/{Year}');
INSERT INTO CertificateTemplates (TemplateKey, TemplateValue) VALUES ('CovSubject', 'HIRING OF MANPOWER SERVICES');
INSERT INTO CertificateTemplates (TemplateKey, TemplateValue) VALUES ('CovBody', 'The copies of the Attendance report along with the wage calculation for {Category} category Contract Employees from M/s. {VendorName}, {VendorAddress} for the period of {StartDate} to {EndDate} is enclosed. This is for purpose of their payment processing please.');
INSERT INTO CertificateTemplates (TemplateKey, TemplateValue) VALUES ('CovSignatory', 'Usha Nandini AA');
INSERT INTO CertificateTemplates (TemplateKey, TemplateValue) VALUES ('CovDesignation', 'TO C');
INSERT INTO CertificateTemplates (TemplateKey, TemplateValue) VALUES ('CovAuthority', 'For GD, {Division}');
INSERT INTO CertificateTemplates (TemplateKey, TemplateValue) VALUES ('CovRecipient', 'To, ' || CHR(13) || CHR(10) || 'D-FMM/Purchase');
INSERT INTO CertificateTemplates (TemplateKey, TemplateValue) VALUES ('WagesHdrContract', 'Contract No. <b>{ContractNo}</b> Dt. <b>{ContractDate}</b> {ExtraCode}, Dated On: {DatedOn}');
INSERT INTO CertificateTemplates (TemplateKey, TemplateValue) VALUES ('WagesHdrCategory', 'Manpower Outstanding Services - Data Entry Operators({CategoryDesc}) - {PeopleCount} No.s');
INSERT INTO CertificateTemplates (TemplateKey, TemplateValue) VALUES ('WagesHdrPeriod', 'Contract Period <b>{Period}</b>');
INSERT INTO CertificateTemplates (TemplateKey, TemplateValue) VALUES ('WagesHdrVendor', 'M/s {VendorName}, {VendorAddress}');
INSERT INTO CertificateTemplates (TemplateKey, TemplateValue) VALUES ('WagesHdrPayment', 'Payment for the period <b>{PaymentStart}</b> to <b>{PaymentEnd}</b> - <b>{WorkingDays} days</b>');
INSERT INTO CertificateTemplates (TemplateKey, TemplateValue) VALUES ('WagesDesc_Skilled', 'Data Entry Operators(Skilled)');
INSERT INTO CertificateTemplates (TemplateKey, TemplateValue) VALUES ('WagesDesc_Semi_Skilled', 'Staff');
INSERT INTO CertificateTemplates (TemplateKey, TemplateValue) VALUES ('WagesDesc_Unskilled', 'attender');
INSERT INTO CertificateTemplates (TemplateKey, TemplateValue) VALUES ('WagesEpfLimit', '15000');
INSERT INTO CertificateTemplates (TemplateKey, TemplateValue) VALUES ('WagesEpfRate', '13');
INSERT INTO CertificateTemplates (TemplateKey, TemplateValue) VALUES ('WagesEpfCappedAmount', '1950');


-- =============================================================================
-- SECTION 5: GRANTS (allow SYSTEM schema to query hrdata tables — SELECT ONLY)
-- =============================================================================
GRANT SELECT ON hrdata.empdetails TO SYSTEM;

-- =============================================================================
-- SECTION 6: COMMIT
-- =============================================================================
COMMIT;


-- =============================================================================
-- END OF SCRIPT
--
-- NOTES FOR PRODUCTION DEPLOYMENT AT YOUR COMPANY:
--
-- 1. PASSWORDS: Change all default passwords before running in production.
--    Search for 'root' in this file and replace with secure passwords.
--
-- 2. ACTIVE DIRECTORY: Update Web.config  ADConnectionPath  to point to your
--    company's LDAP server:
--    LDAP://your-ad-server/DC=yourdomain,DC=com
--
-- 3. CONNECTION STRING: Update Web.config to use your production DB host:
--    Data Source=//YOUR-DB-HOST:1521/YOUR-SERVICE-NAME
--
-- 4. HRDATA SCHEMA: If your company already has an HRDATA schema with an
--    EMPDETAILS table, skip the hrdata.empdetails CREATE and GRANT statements
--    and verify that the PCNO, NAME, DESIGNATION, DIVNAME columns match.
--    If column names differ, update the query in Login.aspx.cs line ~114.
--
-- 5. ADMIN SETUP: After running this script, log in with PCNO 1001 (Admin).
--    Go to Admin Management to create your real admin and user accounts.
--    Then delete the test seed accounts (1001, 1002, 1003) from AppUsers.
--
-- 6. ORACLE 11g NOTE: This script uses SEQUENCE + BEFORE INSERT TRIGGER for
--    auto-increment IDs. Do NOT use GENERATED ALWAYS AS IDENTITY — that
--    feature requires Oracle 12c or above.
-- =============================================================================
