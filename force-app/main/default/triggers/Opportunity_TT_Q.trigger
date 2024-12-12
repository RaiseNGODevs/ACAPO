trigger Opportunity_TT_Q on Opportunity (before insert, after update) {
    // Inicialização das variáveis e coleções usadas no trigger
    switch on Trigger.operationType{
        when BEFORE_INSERT{
            HandlerOpportunity_TT_Q.berforeInsertHandler(Trigger.new);
        }
        when AFTER_UPDATE {
            HandlerOpportunity_TT_Q.afterUpdateHandler(Trigger.new);
        }
    }
}