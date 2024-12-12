@isTest
public class updateNumSocioTest {
    
    
    @testSetup
    public static void setup(){
        
        N_S_cio_Seria_o__c serieTestA = new N_S_cio_Seria_o__c (Tipo_de_S_cio__c = 'Efetivos', Letra__c = 'A', ultimo_n_mero__c = 1);
        insert serieTestA;
         N_S_cio_Seria_o__c serieTestB = new N_S_cio_Seria_o__c (Tipo_de_S_cio__c = 'Cooperante', Letra__c = 'B', ultimo_n_mero__c = 1);
        insert serieTestB;
         N_S_cio_Seria_o__c serieTestC = new N_S_cio_Seria_o__c (Tipo_de_S_cio__c = 'Cooperante pessoa coletiva', Letra__c = 'C', ultimo_n_mero__c = 1);
        insert serieTestC;
        
        
    }

    @isTest
    public static void test(){
        insert new Contact(
        	LastName = 'teste',
            Data_de_admiss_o__c = date.today(),
            Tipo_de_S_cio__c = 'Efetivos'
        );
        
        insert new Contact(
        	lastname = 'teste 2',
            Data_de_admiss_o__c = date.today(),
            Tipo_de_S_cio__c = 'Cooperante'
        );
        
        insert new Contact(
            lastname = 'teste 3',
             Data_de_admiss_o__c = date.today(),
             Tipo_de_S_cio__c = 'Cooperante pessoa coletiva',
              BI_CC__c  = '232312332'
        );
        
        
    }
    
    @isTest 
    public static void updateTest(){
        

        Contact t = new Contact(
            lastname = 'teste 3',
             Data_de_admiss_o__c = date.today(),
             Tipo_de_S_cio__c = 'Cooperante pessoa coletiva',
              BI_CC__c  = '232312332'
        );
        insert t;

        t.Tipo_de_S_cio__c = 'Cooperante';
        
        update t;

        
    }
   
}