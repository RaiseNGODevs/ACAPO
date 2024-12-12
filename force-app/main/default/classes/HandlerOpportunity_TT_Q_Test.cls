@isTest
private class HandlerOpportunity_TT_Q_Test {
    
    @TestSetup
    static void makeData(){
        // Criar configuração personalizada
        PaymentToValidate__c paymentConfig = new PaymentToValidate__c(
            Name = 'Default',
            isActive__c = true
        );
        insert paymentConfig;
        
        // Criar conta e contato
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        Contact con = new Contact(LastName = 'Test Contact', AccountId = acc.Id,Tipo_de_S_cio__c='Efetivos');
        insert con;
        
        // Criar doação recorrente
        npe03__Recurring_Donation__c rd = new npe03__Recurring_Donation__c(
            npe03__Contact__c = con.Id,
            npe03__Amount__c = 100,
            npe03__Installment_Period__c = 'Yearly'
        );
        insert rd;
    }
    
    @isTest
    static void testCountPledgedOpportunitiesByYear() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Pledged',
            CloseDate = Date.today(),
            Amount = 100,
            npsp__Primary_Contact__c = con.Id,
            Ano_a_pagar2__c = 2024
        );
        insert opp;
        
        Test.startTest();
        Integer count = HandlerOpportunity_TT_Q.countPledgedOpportunitiesByYear(2024);
        Test.stopTest();
        
        System.assertEquals(1, count, 'Should have 1 pledged opportunity for 2024');
    }
    
    @isTest
    static void testCountOpportunities() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        
        List<Opportunity> opps = new List<Opportunity>{
            new Opportunity(Name = 'Test Opp 1', StageName = 'Pledged', CloseDate = Date.today(), Amount = 100, npsp__Primary_Contact__c = con.Id),
            new Opportunity(Name = 'Test Opp 2', StageName = 'Closed Won', CloseDate = Date.today(), Amount = 100, npsp__Primary_Contact__c = con.Id)
        };
        insert opps;
        
        Test.startTest();
        Map<String, Integer> counts = HandlerOpportunity_TT_Q.countOpportunities(con.Id, opps);
        Test.stopTest();
        
        System.assertEquals(1, counts.get('Pledged'), 'Should have 1 pledged opportunity');
        System.assertEquals(2, counts.get('Total'), 'Should have 2 total opportunities');
    }
    
    @isTest
    static void testBeforeInsertHandlerYearly() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        npe03__Recurring_Donation__c rd = [SELECT Id FROM npe03__Recurring_Donation__c LIMIT 1];
        
        Opportunity existingOpp = new Opportunity(
            Name = 'Existing Opp',
            StageName = 'Pledged',
            CloseDate = Date.today(),
            Amount = 100,
            npsp__Primary_Contact__c = con.Id,
            npe03__Recurring_Donation__c = rd.Id,
            Ano_a_pagar2__c = 2023
        );
        insert existingOpp;
        
        Opportunity newOpp = new Opportunity(
            Name = 'New Opp',
            StageName = 'Pledged',
            CloseDate = Date.today(),
            Amount = 100,
            npsp__Primary_Contact__c = con.Id,
            npe03__Recurring_Donation__c = rd.Id
        );
        
        Test.startTest();
        HandlerOpportunity_TT_Q.berforeInsertHandler(new List<Opportunity>{newOpp});
        Test.stopTest();
        
        System.assertEquals(2026, newOpp.Ano_a_pagar2__c, 'New opportunity should have Ano_a_pagar2__c set to 2024');
    }
    
    @isTest
    static void testBeforeInsertHandlerSemestral() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        npe03__Recurring_Donation__c rd = [SELECT Id FROM npe03__Recurring_Donation__c LIMIT 1];
        rd.npe03__Installment_Period__c = 'Semestral';
        update rd;
        
        Opportunity existingOpp = new Opportunity(
            Name = 'Existing Opp',
            StageName = 'Pledged',
            CloseDate = Date.today(),
            Amount = 100,
            npsp__Primary_Contact__c = con.Id,
            npe03__Recurring_Donation__c = rd.Id,
            Ano_a_pagar2__c = 2023
        );
        insert existingOpp;
        
        Opportunity newOpp = new Opportunity(
            Name = 'New Opp',
            StageName = 'Pledged',
            CloseDate = Date.today(),
            Amount = 100,
            npsp__Primary_Contact__c = con.Id,
            npe03__Recurring_Donation__c = rd.Id
        );
        
        Test.startTest();
        HandlerOpportunity_TT_Q.berforeInsertHandler(new List<Opportunity>{newOpp});
        Test.stopTest();
        
        System.assertEquals(2024, newOpp.Ano_a_pagar2__c, 'New opportunity should have Ano_a_pagar2__c set to 2023 VP');
    }
    
    /*@isTest
    static void testAfterUpdateHandler() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Pledged',
            CloseDate = Date.today(),
            Amount = 100,
            npsp__Primary_Contact__c = con.Id,
            Oportunidade_Pledged__c = 1
        );
        insert opp;
        
        opp.StageName = 'Closed Won';
        
        Test.startTest();
        update opp;
        Test.stopTest();
        
        Opportunity updatedOpp = [SELECT Id, Oportunidade_Pledged__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(0, updatedOpp.Oportunidade_Pledged__c, 'Oportunidade_Pledged__c should be decremented');
    }*/
    
    @isTest
    static void testBeforeInsertHandlerNoExistingOpps() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        
        Opportunity newOpp = new Opportunity(
            Name = 'New Opp',
            StageName = 'Pledged',
            CloseDate = Date.today(),
            Amount = 100,
            npsp__Primary_Contact__c = con.Id
        );
        
        Test.startTest();
        HandlerOpportunity_TT_Q.berforeInsertHandler(new List<Opportunity>{newOpp});
        Test.stopTest();
        
        System.assertEquals(Date.today().year()+1, newOpp.Ano_a_pagar2__c, 'New opportunity should have Ano_a_pagar2__c set to current year');
    }
    
    @isTest
    static void testBeforeInsertHandlerSemestralMultipleScenarios() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        npe03__Recurring_Donation__c rd = [SELECT Id FROM npe03__Recurring_Donation__c LIMIT 1];
        rd.npe03__Installment_Period__c = 'Semestral';
        update rd;
        
        // Scenario 1: lastYear < newYear && totalOppSemestral < 2
        Opportunity existingOpp1 = new Opportunity(
            Name = 'Existing Opp 1',
            StageName = 'Pledged',
            CloseDate = Date.today(),
            Amount = 100,
            npsp__Primary_Contact__c = con.Id,
            npe03__Recurring_Donation__c = rd.Id,
            Ano_a_pagar2__c = 2023
        );
        insert existingOpp1;
        
        Opportunity newOpp1 = new Opportunity(
            Name = 'New Opp 1',
            StageName = 'Pledged',
            CloseDate = Date.today(),
            Amount = 100,
            npsp__Primary_Contact__c = con.Id,
            npe03__Recurring_Donation__c = rd.Id
        );
        
        // Scenario 2: lastYear == newYear && totalOppSemestral < 2
        Opportunity existingOpp2 = new Opportunity(
            Name = 'Existing Opp 2',
            StageName = 'Pledged',
            CloseDate = Date.today(),
            Amount = 100,
            npsp__Primary_Contact__c = con.Id,
            npe03__Recurring_Donation__c = rd.Id,
            Ano_a_pagar2__c = 2024
        );
        insert existingOpp2;
        
        Opportunity newOpp2 = new Opportunity(
            Name = 'New Opp 2',
            StageName = 'Pledged',
            CloseDate = Date.today(),
            Amount = 100,
            npsp__Primary_Contact__c = con.Id,
            npe03__Recurring_Donation__c = rd.Id
        );
        
        // Scenario 3: lastYear < newYear && totalOppSemestral >= 2
        Opportunity existingOpp3a = new Opportunity(
            Name = 'Existing Opp 3a',
            StageName = 'Pledged',
            CloseDate = Date.today(),
            Amount = 100,
            npsp__Primary_Contact__c = con.Id,
            npe03__Recurring_Donation__c = rd.Id,
            Ano_a_pagar2__c = 2023
        );
        Opportunity existingOpp3b = new Opportunity(
            Name = 'Existing Opp 3b',
            StageName = 'Pledged',
            CloseDate = Date.today(),
            Amount = 100,
            npsp__Primary_Contact__c = con.Id,
            npe03__Recurring_Donation__c = rd.Id,
            Ano_a_pagar2__c = 2023
        );
        insert new List<Opportunity>{existingOpp3a, existingOpp3b};
        
        Opportunity newOpp3 = new Opportunity(
            Name = 'New Opp 3',
            StageName = 'Pledged',
            CloseDate = Date.today(),
            Amount = 100,
            npsp__Primary_Contact__c = con.Id,
            npe03__Recurring_Donation__c = rd.Id
        );
        
        Test.startTest();
        //HandlerOpportunity_TT_Q.berforeInsertHandler(new List<Opportunity>{newOpp1, newOpp2, newOpp3});
        HandlerOpportunity_TT_Q.berforeInsertHandler(new List<Opportunity>{newOpp1});
        Test.stopTest();
        
        System.assertEquals(2025, newOpp1.Ano_a_pagar2__c, 'Scenario 1: New opportunity should have Ano_a_pagar2__c set to 2025');
    
    
    }
}