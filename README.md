# Nacho Flows 

## Overview
This repository demonstrates how Apex unit tests protect flow logic across feature branches with different record type scenarios.

## Scenario
A Case routing flow that behaves differently based on Case Record Type. Two feature branches will independently add new record types, and tests will catch the conflicts.

## Repository Structure

```
flow-testing-demo/
├── README.md
├── sfdx-project.json
├── .gitignore
├── force-app/
│   └── main/
│       └── default/
│           ├── flows/
│           │   └── Case_Auto_Assignment.flow-meta.xml
│           ├── classes/
│           │   ├── CaseTestDataFactory.cls
│           │   ├── CaseTestDataFactory.cls-meta.xml
│           │   ├── CaseFlowTest.cls
│           │   └── CaseFlowTest.cls-meta.xml
│           ├── objects/
│           │   └── Case/
│           │       ├── fields/
│           │       │   └── Priority_Score__c.field-meta.xml
│           │       └── recordTypes/
│           │           └── Standard_Support.recordType-meta.xml
│           └── profiles/
│               ├── Support_Agent.profile-meta.xml
│               └── Support_Manager.profile-meta.xml
```

## Branch Strategy

### Main Branch
- Contains base flow with "Standard Support" record type
- Flow assigns cases to a queue based on basic criteria
- Tests validate Standard Support behavior

### Feature Branch 1: `feature/premium-support`
- Adds "Premium Support" record type
- Flow logic: Auto-escalates to high priority, assigns to senior queue
- Tests validate Premium Support behavior
- **Conflict**: Both branches modify the same flow

### Feature Branch 2: `feature/enterprise-support`
- Adds "Enterprise Support" record type  
- Flow logic: Immediately assigns to account team, creates Slack notification
- Tests validate Enterprise Support behavior
- **Conflict**: Both branches modify the same flow

## Setup Instructions

### 1. Create Scratch Org
```bash
sfdx force:org:create -f config/project-scratch-def.json -a flow-test-demo
sfdx force:source:push
sfdx force:user:permset:assign -n Case_Management_Access
```

### 2. Run Tests
```bash
# Run all tests
sfdx force:apex:test:run -n CaseFlowTest -r human

# Run with code coverage
sfdx force:apex:test:run -n CaseFlowTest -c -r human
```

### 3. Demonstrate Conflict
```bash
# Create and work on feature branch 1
git checkout -b feature/premium-support
# Make changes, commit, run tests

# Create and work on feature branch 2
git checkout main
git checkout -b feature/enterprise-support
# Make changes, commit, run tests

# Try to merge both - tests will catch conflicts
git checkout main
git merge feature/premium-support
git merge feature/enterprise-support  # This will conflict
```

## Key Testing Patterns

### 1. Test Data Isolation
Each test creates its own data with specific record types

### 2. Running as Different Personas
Tests use `System.runAs()` to validate permission-based behavior

### 3. Flow Execution Verification
Use `Test.startTest()/stopTest()` to ensure flows execute within test context

### 4. Record Type Validation
Tests assert that correct logic executed based on record type

## Presentation Flow

1. **Show Main Branch** - Simple flow, passing tests
2. **Show Feature Branch 1** - New record type, new tests, all pass
3. **Show Feature Branch 2** - Different record type, new tests, all pass
4. **Demonstrate Merge Conflict** - Both modified same flow
5. **Show How Tests Catch Issues** - Run tests after merge, failures reveal problems
6. **Resolution** - Properly combine both record types in flow logic

## Benefits Highlighted

- ✅ Tests document expected behavior per record type
- ✅ Tests catch breaking changes during merges
- ✅ Tests enable safe parallel development
- ✅ Tests serve as living documentation
- ✅ CI/CD can automatically validate changes

## Files Included in Next Artifacts

1. Complete Flow metadata (Main + both feature variants)
2. Test Data Factory class
3. Comprehensive Test class
4. Record Type definitions
5. Custom field metadata
6. Profile configurations