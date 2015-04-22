/**
* \arg ClassName        : Trek_EntitlementsWebservice
* \arg CreatedOn      	: 21st/APR/2015
* \arg LastModifiedOn   : 22nd/APR/2015
* \arg CreatededBy    	: Mukesh
* \arg LastModifiedBy	: Mukesh
* \arg Description    	: This is webservice class will be called from another system
*/
global class Trek_EntitlementsWebservice 
{
	/*
	 @MethodName: fetchDataRelatedToCase
	 @param: String strCaseId, String strPhoneNumber, String strAccountNumber
	 @Description: This method is used to get all Contacts, Assets and Entitlements related to particular Case id   
	*/
	webservice static String fetchDataRelatedToCase(String strCaseId, String strPhoneNumber, String strAccountNumber)
	{
		Id accountIdOfCase;
		List<Contact> lstContacts = new List<Contact>();
		List<Asset> lstAssets = new List<Asset>();
		List<Entitlement> lstEntitlements = new List<Entitlement>();
		List<Account> lstAccount = new List<Account>();
		
		try
		{
			/* Get account whose account Number is matching with parameter */
			if(strAccountNumber != null && strAccountNumber != '')
			{
				for(Account objAccount : [SELECT Id,
												 AccountNumber,		 
												 Name 
											FROM Account
										   WHERE AccountNumber =: strAccountNumber])
				{
					lstAccount.add(objAccount);
				}
			}
			
			
			if(strCaseId != null && strCaseId != '')
			{
				/* Get account Id of case */
				accountIdOfCase = [SELECT Id, 
										  AccountId 
									 FROM Case 
									WHERE Id =: strCaseId].AccountId;
				
				if(accountIdOfCase != null)
				{
					/* Get account related to case if account Number is null or empty */
					if(strAccountNumber == null || strAccountNumber == '')
					{
						for(Account objAccount : [SELECT Id,
														 AccountNumber,		 
														 Name 
													FROM Account
												   WHERE Id =: accountIdOfCase])
						{
							lstAccount.add(objAccount);
						}
					}
					
					/* Iterate over the list of contact related to case account Id */
					for(Contact objContact : [SELECT Id, 
													 Phone, 
													 Name, 
													 AccountId 
											    FROM Contact 
											   WHERE AccountId =: accountIdOfCase])
					{
						if(strPhoneNumber != null && strPhoneNumber != '' && strPhoneNumber == objContact.Phone)
						{
							lstContacts.add(objContact);
						}
					}
					
					/* Iterate over the list of Asset related to case account Id */
					for(Asset objAsset : [SELECT Id, 
												 Name, 
												 AccountId 
											FROM Asset 
										   WHERE AccountId =: accountIdOfCase])
					{
						lstAssets.add(objAsset);
					}
					
					/* Iterate over the list of Entitlements related to case account Id */
					for(Entitlement objEntitlement : [SELECT Id, 
															 Name, 
															 AccountId 
														FROM Entitlement 
													   WHERE AccountId =: accountIdOfCase])
					{
						lstEntitlements.add(objEntitlement);
					}
				}
			}
			
			if(lstContacts.isEmpty() && lstAssets.isEmpty() && lstEntitlements.isEmpty() && lstAccount.isEmpty())
			{
				Log__c objLog = new Log__c(StackTrace__c = 'No contacts, assests, entitlements and account exist.');
				insert objLog;
				return objLog.StackTrace__c;
			}
			else
			{
				/* Adding all the list of Contact, Asset and Entitlement into the Wrraper class */
				ContactAssetsEntitlementWrapper objContactAssetsEntitlementWrapper = new ContactAssetsEntitlementWrapper(lstContacts, lstAssets, lstEntitlements, lstAccount);
				
				String strJSON = JSON.serialize(objContactAssetsEntitlementWrapper);
				return strJSON;
			}
		}
		catch(Exception ex)
		{
			/* Inserting error into Log object */
			Log__c objLog = new Log__c(StackTrace__c = ex.getStackTraceString());
			insert objLog;
			return objLog.StackTrace__c;
		}	
	}
		
	/*
	 @WrapperClassName: ContactAssetsEntitlementWrapper
     @param: List<Contact>, List<Asset>, List<Entitlement>
     @Description: Wrraper class to bind list of different objects
	*/
	private class ContactAssetsEntitlementWrapper
	{
		List<Contact> lstContact;
		List<Asset> lstAsset;
		List<Entitlement> lstEntitlement;
		List<Account> lstAccount;
		
		/* Start - Wrapper class Constructor */
		private ContactAssetsEntitlementWrapper(List<Contact> lstContact, List<Asset> lstAsset, List<Entitlement> lstEntitlement, List<Account> lstAccount)
		{
				this.lstContact = lstContact;
				this.lstAsset = lstAsset;
				this.lstEntitlement = lstEntitlement;
				this.lstAccount = lstAccount;
		}
		/* End - Wrapper class Constructor */
	}	
}