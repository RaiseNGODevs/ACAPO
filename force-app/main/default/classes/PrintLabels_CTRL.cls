public class PrintLabels_CTRL {
	ApexPages.StandardSetController sc;
    
    public PrintLabels_CTRL(ApexPages.StandardSetController sc){ 
        this.sc = sc;
    }
 
	public PageReference urlRedirection() {
        PageReference page = new PageReference(URL.getSalesforceBaseUrl().toExternalForm() + '/apex/aiell__aiPLvfp_pdfLabel?&SObjectType=Contact&ListViewId='+sc.getFilterId()+'&LabelTemplateId=a1F1v000003wXZVEA2&option=1&records=');
        page.setRedirect(true);
        return page;
    }

}