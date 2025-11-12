public with sharing class CaseRecordTypeSupport {
    
    // Returns RecordType Id for Case by DeveloperName
    public static Id caseRtByDevName(String devName) {
        
        if (String.isBlank(devName)) {
            throw new IllegalArgumentException('DeveloperName must be provided');
        }
        
        RecordType rt = [
            SELECT Id
            FROM RecordType
            WHERE SobjectType = 'Case' AND DeveloperName = :devName
            LIMIT 1
        ];
        
        return rt.Id;
        
    }

    // Build a Case that will hit the "Premier" branch in Case_Trigger_Flow
    // Decision criteria: $Record.SuppliedName CONTAINS 'premier'
    public static Case newPremierCase() {
        
        return new Case(
            Subject = 'Premier Path',
            Origin = 'Phone',
            SuppliedName = 'Acme premier customer',
            SuppliedCompany = 'AnyCo'
        );
        
    }

    // Build a Case that will hit the "SoSo" branch in Case_Trigger_Flow
    // Decision criteria: $Record.SuppliedCompany CONTAINS 'SoSo'
    public static Case newSoSoCase() {
        
        return new Case(
            Subject = 'SoSo Path',
            Origin = 'Phone',
            SuppliedName = 'Regular Name',
            SuppliedCompany = 'SoSo Industries'
        );
        
    }

    // Build a Case that will hit the Default/Standard branch in Case_Trigger_Flow
    public static Case newStandardCase() {
        
        return new Case(
            Subject = 'Standard Path',
            Origin = 'Phone',
            SuppliedName = 'Regular Name',
            SuppliedCompany = 'RegularCo'
        );
        
    }
}
