global class Opportunity_TDTM extends npsp.TDTM_Runnable {
    
    global override npsp.TDTM_Runnable.DmlWrapper run(
        List<SObject> newlist,
        List<SObject> oldlist,
        npsp.TDTM_Runnable.Action triggerAction,
        Schema.DescribeSObjectResult objResult
    ) {
        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
        Map<Id, SObject> oldOppsMap = new Map<Id, SObject>();
        if(oldlist != null) 
            oldOppsMap = new Map<Id, SObject>(oldlist);
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
	        
        Validar_pagamentos_em_atraso__c cs = Validar_pagamentos_em_atraso__c.getInstance();
        Boolean isActive = cs.Ativo__c;
        
        Set<Id> contactIds = new Set<Id>();
        for(Opportunity opp : (List<opportunity>)newlist){
        	if(opp.npsp__Primary_Contact__c != null)
                contactIds.add(opp.npsp__Primary_Contact__c);
        }
        
        List<Opportunity> opps = [SELECT npsp__Primary_Contact__c, Ano_a_pagar2__c FROM Opportunity 
                                  WHERE Id NOT IN :newList
                                  AND Ano_a_pagar2__c != null
                                  AND npsp__Primary_Contact__c != null AND npsp__Primary_Contact__c IN :contactIds
                                  ORDER BY Ano_a_pagar2__c DESC];
        Map<Id, List<Opportunity>> mapContactOpps = new Map<Id, List<Opportunity>>();
        for(Opportunity opp : opps){
            List<Opportunity> existingOpps = mapContactOpps.get(opp.npsp__Primary_Contact__c);
            if(existingOpps != null){
                existingOpps.add(opp);
                mapContactOpps.put(opp.npsp__Primary_Contact__c, existingOpps);
            }else{
                mapContactOpps.put(opp.npsp__Primary_Contact__c, new List<Opportunity>{opp});
            }
        }
        
        if (triggerAction == npsp.TDTM_Runnable.Action.BeforeInsert) {
            for(Opportunity opp : (List<Opportunity>)newlist){
                if(opp.npsp__Primary_Contact__c != null && opp.CloseDate != null){
                    Integer newYear = opp.CloseDate.year();
                    List<Opportunity> contactOpps = mapContactOpps.get(opp.npsp__Primary_Contact__c);
                    if(isActive && contactOpps != null){
                        Decimal lastYear = contactOpps[0].Ano_a_pagar2__c;
                        if((newYear - 1) == lastYear){
                            opp.Ano_a_pagar2__c = newYear;
                        }else{
                            opp.addError('Não é possivel gerar a oportunidade por pagamentos em atraso');
                        }
                    }else{
                        opp.Ano_a_pagar2__c = newYear;
                    }
                }
            }
        }
        
        dmlWrapper.objectsToUpdate.addAll((List<Opportunity>)oppsToUpdate);
        return dmlWrapper;
    }
}