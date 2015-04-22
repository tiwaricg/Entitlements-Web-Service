/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class Trek_Test_EntitlementsWebservice 
{
	static testMethod void myUnitTest() 
    {
    	/* Insert Account */
    	Account objAccount = new Account(Name = 'Test Account', AccountNumber= '787878');
    	insert objAccount;
    	
    	/* Insert Contacts */
    	Contact objContact1 = new Contact(LastName = 'Test Contact1', AccountId = objAccount.Id, Phone = '02245454');
    	insert objContact1;
    	
    	Contact objContact2 = new Contact(LastName = 'Test Contact2', AccountId = objAccount.Id);
    	insert objContact2;
    	
 		Case objCase = new Case(Status = 'New', Origin = 'Web', AccountId = objAccount.Id);
 		insert objCase;
 		
 		/* Insert Assets */
 		Asset objAsset1 = new Asset(Name = 'Test Asset1', AccountId = objAccount.Id);
 		insert objAsset1;
 		
 		Asset objAsset2 = new Asset(Name = 'Test Asset1', AccountId = objAccount.Id);
 		insert objAsset2;
 		
 		/* Insert Entitlements */
 		Entitlement objEntitlement1 = new Entitlement(Name = 'Test Entitlement1', AccountId = objAccount.Id);
 		insert objEntitlement1;
 		
 		Entitlement objEntitlement2 = new Entitlement(Name = 'Test Entitlement2', AccountId = objAccount.Id);
 		insert objEntitlement2;
 		
 		/* Calling webservice method */   	 
    	Trek_EntitlementsWebservice.fetchDataRelatedToCase(objCase.Id, '02245454', '787878');
    	
    	/* Asserting the proper out put */
    	System.assertEquals(1, [SELECT Id FROM Account WHERE AccountNumber = '787878'].size());
    	System.assertEquals(1, [SELECT Id FROM Contact WHERE Phone = '02245454'].size());
    	System.assertEquals(2, [SELECT Id FROM Asset].size());
    	System.assertEquals(2, [SELECT Id FROM Entitlement].size());
    	
    	Trek_EntitlementsWebservice.fetchDataRelatedToCase(objCase.Id, '02245454', '');
    	
    	Trek_EntitlementsWebservice.fetchDataRelatedToCase('', '', '');
    }    
}