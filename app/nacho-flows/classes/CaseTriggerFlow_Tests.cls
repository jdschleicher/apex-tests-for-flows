@IsTest
private class CaseTriggerFlow_Tests {

    // Assert helper that validates the Case.RecordTypeId against the expected RecordType DeveloperName
    private static void assertRecordType(Id caseId, String expectedRtDevName) {
        
        Case c = [SELECT Id, RecordTypeId FROM Case WHERE Id = :caseId];
        System.assertNotEquals(null, c.RecordTypeId, 'RecordTypeId should be populated by the flow');
        Id expected = CaseRecordTypeSupport.caseRtByDevName(expectedRtDevName);
        System.assertEquals(expected, c.RecordTypeId, 'RecordTypeId should match expected RecordType for branch ' + expectedRtDevName);
        
    }

    @IsTest
    static void test_Premier_Branch_Assigns_Premium_Support() {
        
        // When a Case is inserted, the Record-Triggered Autolaunched Flow runs After Save
        // Premier path is selected when SuppliedName contains 'premier'
        Case c = CaseRecordTypeSupport.newPremierCase();
        insert c;

        // Then: flow assigns RecordType = Premium_Support
        assertRecordType(c.Id, 'Premium_Support');
        
    }

    @IsTest
    static void test_SoSo_Branch_Assigns_SoSo_Support() {
        
        Case c = CaseRecordTypeSupport.newSoSoCase();
        insert c;

        assertRecordType(c.Id, 'SoSo_Support');
        
    }

    @IsTest
    static void test_Default_Branch_Assigns_Standard_Support() {
        
        Case c = CaseRecordTypeSupport.newStandardCase();
        insert c;

        assertRecordType(c.Id, 'Standard_Support');
        
    }

    // Optional: Bulk test to ensure behavior holds under bulk inserts
    @IsTest
    static void test_Bulk_Inserts_All_Branches() {
        
        List<Case> cases = new List<Case>{
            CaseRecordTypeSupport.newPremierCase(),
            CaseRecordTypeSupport.newSoSoCase(),
            CaseRecordTypeSupport.newStandardCase()
        };
        insert cases;

        Map<Id, Case> reloaded = new Map<Id, Case>([SELECT Id, RecordTypeId FROM Case WHERE Id IN :cases]);

        System.assertEquals(CaseRecordTypeSupport.caseRtByDevName('Premium_Support'), reloaded.get(cases[0].Id).RecordTypeId, 'Bulk: Premier');
        System.assertEquals(CaseRecordTypeSupport.caseRtByDevName('SoSo_Support'), reloaded.get(cases[1].Id).RecordTypeId, 'Bulk: SoSo');
        System.assertEquals(CaseRecordTypeSupport.caseRtByDevName('Standard_Support'), reloaded.get(cases[2].Id).RecordTypeId, 'Bulk: Standard');
        
    }
}
