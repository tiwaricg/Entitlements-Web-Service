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
		
		XmlStreamWriter objXmlStreamWriter = new XmlStreamWriter();
		
		/* Start the XML document */
		objXmlStreamWriter.writeStartDocument(null, '1.0'); 
		
		/* this will start with <accounts> in XML */
		objXmlStreamWriter.writeStartElement(null, 'accounts', null); 
		
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
					
					/* This will write <account> in the XML file */
			        objXmlStreamWriter.writeStartElement(null, 'account', null);
			        
			        /* Open the tag <Name> */
			        objXmlStreamWriter.writeStartElement(null, 'Name', null);
			        
			        /* Write the value of Name to be send */
			        objXmlStreamWriter.writeCharacters(objAccount.Name);
			        
			        /* close </Name> */
			        objXmlStreamWriter.writeEndElement();
			        
			        /* close </account> */
			        objXmlStreamWriter.writeEndElement();
				}
	   			  objXmlStreamWriter.writeEndElement();
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
							
							/* This will write <account> in the XML file */
							objXmlStreamWriter.writeStartElement(null, 'account', null);
					        
					        /* Open the tag <Name> */
					        objXmlStreamWriter.writeStartElement(null, 'Name', null);
					        
					        /* Write the value of Name to be send */
					        objXmlStreamWriter.writeCharacters(objAccount.Name);
					        
					        /* close </Name> */
					        objXmlStreamWriter.writeEndElement();
					        
					        /* close </account> */
					        objXmlStreamWriter.writeEndElement();
						}
						  objXmlStreamWriter.writeEndElement();
					}
					
					objXmlStreamWriter.writeStartElement(null, 'contacts', null); //this will start with <contacts> in XML
					
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
							
							/* This will write <contact> in the XML file */
							objXmlStreamWriter.writeStartElement(null, 'contact', null);
					        
					        /* Open the tag <Name> */  
					        objXmlStreamWriter.writeStartElement(null, 'Name', null);
					        
					        /* Write the value of Name to be send */
					        objXmlStreamWriter.writeCharacters(objContact.Name);
					        
					        /* close </Name> */
					        objXmlStreamWriter.writeEndElement();
					        
					        /* close </contact> */
					        objXmlStreamWriter.writeEndElement();
						}
					}
					 objXmlStreamWriter.writeEndElement();
					
					/* this will start with <assets> in XML */
					objXmlStreamWriter.writeStartElement(null, 'assets', null); 
					
					/* Iterate over the list of Asset related to case account Id */
					for(Asset objAsset : [SELECT Id, 
												 Name, 
												 AccountId 
											FROM Asset 
										   WHERE AccountId =: accountIdOfCase])
					{
						lstAssets.add(objAsset);
						
						/* This will write <asset> in the XML file */
						objXmlStreamWriter.writeStartElement(null, 'asset', null);
				        
				        /* Open the tag <Name> */ 
				        objXmlStreamWriter.writeStartElement(null, 'Name', null);
				        
				        /* Write the value of Name to be send */
				        objXmlStreamWriter.writeCharacters(objAsset.Name);
				        
				        /* close </Name> */
				        objXmlStreamWriter.writeEndElement();
				        
				        /* close </asset> */ 
				        objXmlStreamWriter.writeEndElement();
					}
					objXmlStreamWriter.writeEndElement();
					
					/* this will start with <entitlements> in XML */
					objXmlStreamWriter.writeStartElement(null, 'entitlements', null); 
					
					/* Iterate over the list of Entitlements related to case account Id */
					for(Entitlement objEntitlement : [SELECT Id, 
															 Name, 
															 AccountId 
														FROM Entitlement 
													   WHERE AccountId =: accountIdOfCase])
					{
						lstEntitlements.add(objEntitlement);
						
						/* This will write <entitlement> in the XML file */
						objXmlStreamWriter.writeStartElement(null, 'entitlement', null);
				        
				        /* Open the tag <Name> */ 
				        objXmlStreamWriter.writeStartElement(null, 'Name', null);
				        
				        /* Write the value of Name to be send */
				        objXmlStreamWriter.writeCharacters(objEntitlement.Name);
				        
				        /* close </Name> */
				        objXmlStreamWriter.writeEndElement();
				        
				        /* close </entitlement> */
				        objXmlStreamWriter.writeEndElement();
					}
					 objXmlStreamWriter.writeEndElement();
				}
			}
			
			/* close xml document */
		    objXmlStreamWriter.writeEndDocument();
		    
		    /* Get XML document*/
		    String xmlOutput = objXmlStreamWriter.getXmlString();
   			objXmlStreamWriter.close();
			
			if(lstContacts.isEmpty() && lstAssets.isEmpty() && lstEntitlements.isEmpty() && lstAccount.isEmpty())
			{
				Log__c objLog = new Log__c(StackTrace__c = 'No contacts, assests, entitlements and account exist.');
				insert objLog;
				return objLog.StackTrace__c;
			}
			else
			{
				return xmlOutput;
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
}