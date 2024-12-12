public class HandlerOpportunity_TT_Q {
    //@InvocableMethod
    private static Boolean hasAlreadyRun = false;

    public static Integer countPledgedOpportunitiesByYear(Integer year) {
        return [SELECT COUNT() 
                FROM Opportunity 
                WHERE StageName = 'Pledged' 
                AND Ano_a_pagar2__c = :year];
    }

    public static Map < String, Integer > countOpportunities(Id contactId, List < Opportunity > relatedOpps) {
        Map < String, Integer > counts = new Map < String, Integer > {
            'Pledged' => 0,
            'Total' => 0
        };

        for (Opportunity opp: relatedOpps) {
            if (opp.npsp__Primary_Contact__c == contactId) {
                counts.put('Total', counts.get('Total') + 1);

                if (opp.StageName == 'Pledged') {
                    counts.put('Pledged', counts.get('Pledged') + 1);
                }
            }
        }

        return counts;
    }

    public static void berforeInsertHandler(List < Opportunity > newRecord) {

        Map < Id, SObject > oldOppsMap = new Map < Id, SObject > ();
        List < Opportunity > oppsToUpdate = new List < Opportunity > ();

        List < PaymentToValidate__c > paymentConfigs = PaymentToValidate__c.getall().values();
        Boolean isActive = false;
        if (!paymentConfigs.isEmpty()) {
            isActive = paymentConfigs[0].isActive__c;
        }

        Set < Id > contactIds = new Set < Id > ();
        for (Opportunity opp: newRecord) {
            if (opp.npsp__Primary_Contact__c != null) {
                contactIds.add(opp.npsp__Primary_Contact__c);
            }
        }


        List < Opportunity > relatedOpps = [
            SELECT Id, npsp__Primary_Contact__c, Ano_a_pagar2__c, StageName, Oportunidade_Pledged__c, npe03__Recurring_Donation__r.Id,
            npe03__Recurring_Donation__r.npe03__Installment_Period__c
            FROM Opportunity
            WHERE Id NOT IN: contactIds
            AND npe03__Recurring_Donation__r.npe03__Contact__c IN: contactIds
            AND Ano_a_pagar2__c != null
            AND npsp__Primary_Contact__c != null
            AND npsp__Primary_Contact__c IN: contactIds
            ORDER BY npsp__Primary_Contact__c, Ano_a_pagar2__c DESC
        ];

        List < Opportunity > relatedOppsWithBlankPaidYear = [
            SELECT Id, npsp__Primary_Contact__c, Ano_a_pagar2__c, StageName, Oportunidade_Pledged__c
            FROM Opportunity
            WHERE Id NOT IN: contactIds
            AND npsp__Primary_Contact__c != null
            AND npsp__Primary_Contact__c IN: contactIds
            ORDER BY npsp__Primary_Contact__c, Ano_a_pagar2__c DESC
        ];

        Map < Id, Opportunity > mapContactOpps = new Map < Id, Opportunity > ();
        for (Opportunity opp: relatedOpps) {

            if (!mapContactOpps.containsKey(opp.npsp__Primary_Contact__c) ||
                opp.Ano_a_pagar2__c > mapContactOpps.get(opp.npsp__Primary_Contact__c).Ano_a_pagar2__c) {
                mapContactOpps.put(opp.npsp__Primary_Contact__c, opp);
            }
        }

        if (mapContactOpps.size() > 0) {

            for (Opportunity opp: newRecord) {
                if (opp.npsp__Primary_Contact__c != null && opp.CloseDate != null) {
                    Opportunity contactOpp = mapContactOpps.get(opp.npsp__Primary_Contact__c);
                    Map < String, Integer > opportunityCounts = HandlerOpportunity_TT_Q.countOpportunities(opp.npsp__Primary_Contact__c, relatedOppsWithBlankPaidYear);
                    Integer totalOppPledged = opportunityCounts.get('Pledged');

                    Integer newYear = (Integer) opp.Ano_a_pagar2__c != null ? (Integer) opp.Ano_a_pagar2__c : Date.today().year();
                    String periodoParcela = contactOpp.npe03__Recurring_Donation__r.npe03__Installment_Period__c;
                    switch on periodoParcela {
                        when 'Semestral' {
                            
                            if (isActive && contactOpp != null) {
                                Integer lastYear = (Integer) contactOpp.Ano_a_pagar2__c;
                                System.debug('Year: '+lastYear);
                                Integer totalOppSemestral = HandlerOpportunity_TT_Q.countPledgedOpportunitiesByYear(lastYear);
                                System.debug('totalOppSemestral: '+totalOppSemestral);
                                if (lastYear < newYear && totalOppSemestral < 2) {
                                    opp.Ano_a_pagar2__c = lastYear;
                                } else if (lastYear == newYear && totalOppSemestral < 2) {
                                    opp.Ano_a_pagar2__c = lastYear;
                                } else if (lastYear < newYear && totalOppSemestral >= 2){
                                    opp.Ano_a_pagar2__c = lastYear + 1;
                                }else if (lastYear == newYear && totalOppSemestral >= 2){
                                    opp.Ano_a_pagar2__c = lastYear + 1;
                                }
                            }
                        }
                        when 'Yearly' {
                            if (isActive && contactOpp != null) {
                                Integer lastYear = (Integer) contactOpp.Ano_a_pagar2__c; 
                                if (lastYear == newYear) {
                                    opp.Ano_a_pagar2__c = lastYear + 1;
                                    opp.Oportunidade_Pledged__c = totalOppPledged;
                                } else {

                                    opp.Ano_a_pagar2__c = lastYear + 1;
                                    opp.Oportunidade_Pledged__c = totalOppPledged;
                                }
                            } else {
                                opp.Ano_a_pagar2__c = newYear;
                                opp.Oportunidade_Pledged__c = totalOppPledged;
                            }

                        }

                    }




                }
            }


        } else {

            for (Opportunity opp: newRecord) {
                if (isActive && opp.npsp__Primary_Contact__c != null && opp.CloseDate != null && opp.Ano_a_pagar2__c == null) {
                    Integer newYear = opp.CloseDate.Year();
                    Map < String, Integer > opportunityCounts = HandlerOpportunity_TT_Q.countOpportunities(opp.npsp__Primary_Contact__c, relatedOppsWithBlankPaidYear);
                    Integer pledgedOpps = opportunityCounts.get('Pledged');
                    opp.Ano_a_pagar2__c = newYear;
                    opp.Oportunidade_Pledged__c = pledgedOpps;

                }

            }
        }


    }


    public static void afterUpdateHandler(List < Opportunity > newRecord) {
        if (hasAlreadyRun) {
            return;
        }
        hasAlreadyRun = true;

        List < Opportunity > opportunitiesToUpdate = new List < Opportunity > ();

        for (Opportunity opp: newRecord) {
            if ((opp.StageName == 'Closed Won' || opp.StageName == 'Closed Lost') &&
                opp.Oportunidade_Pledged__c > 0) {
                Opportunity oppToUpdate = new Opportunity(
                    Id = opp.Id,
                    Oportunidade_Pledged__c = opp.Oportunidade_Pledged__c - 1
                );
                opportunitiesToUpdate.add(oppToUpdate);
            }
        }
        if (!opportunitiesToUpdate.isEmpty()) {
            update opportunitiesToUpdate;
        }
    }

}