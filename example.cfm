<cfset sLocal = StructNew() />

<cfset sLocal.api_key = "" /> <!--- Each project has its own API Key. Enter yours here. --->
<cfset sLocal.api_url = "https://api.postageapp.com/v.1.0/send_message.json" />

<cfset sLocal.headerStruct = StructNew() /> <!--- Optional Headers Go Here --->
<cfset sLocal.headerStruct['replyto'] = "support@xyz.com" /> 
<cfset sLocal.headerStruct['failto'] = "foo@bar.com" />
<cfset sLocal.headerStruct['subject'] = "This is the subject." />

<cfset sLocal.to = StructNew() /> <!--- Details on who you are sending to. --->

<cfset sLocal.to['test@test.com'] = "" />
<!--- Optional TO specific variables, like first name, last name go Here --->
<!---
<cfset sLocal.to['customer1@xyz.com']['var1'] = "foo" />
<cfset sLocal.to['customer1@xyz.com']['var2'] = "bar" />
--->

<!---
<cfset sLocal.to['customer2@bar.com'] = "" />
<cfset sLocal.to['customer2@bar.com']['var1'] = "foo" />
<cfset sLocal.to['customer2@bar.com']['var2'] = "bar" />
--->

<cfset sLocal.content = StructNew() />
<cfset sLocal.content['text/plain'] = 'This is a test from ColdFusion!' />

<cfset sLocal.template = "" /> <!--- Optional if using templates --->

<!--- Optional Global vars go here --->
<cfset sLocal.vars = StructNew() />
<cfset sLocal.vars['homepage_url'] = "www.xyz.com" />

<!--- Time to Assemble the JSON packet --->
<cfset sLocal.packet = StructNew() />
<cfset sLocal.packet.api_key = sLocal.api_key />
<cfset sLocal.packet.uid = hash(sLocal.headerStruct['subject'] & dateFormat(Now(), 'MM/DD/YYYY' & timeFormat(now())), 'SHA-1') /> <!--- See documentation on how take advantage of UID. --->
<cfset sLocal.packet.arguments = StructNew() />

<cfset sLocal.packet.arguments.headers = sLocal.headerStruct />
<cfset sLocal.packet.arguments.template = sLocal.template />
<cfset sLocal.packet.arguments.variables = sLocal.vars />
<cfset sLocal.packet.arguments.content = sLocal.content />

<cfset slocal.api = createObject("component","PostageApp").init( sLocal.api_key ) /> 
<cfset sLocal.return = sLocal.api.send_message(
												recipients = sLocal.to, 
												headers = sLocal.packet.arguments.headers, 
												template = sLocal.packet.arguments.template, 
												_variables = sLocal.packet.arguments.variables,
												content = sLocal.packet.arguments.content, 
												uid = sLocal.packet.uid  ) 
/>

<cfdump var="#sLocal.return#" />

<cfif structKeyExists(sLocal.return, 'cfhttp')>
	<cfdump var="#DeserializeJSON(sLocal.return.cfhttp.filecontent)#" />
</cfif>