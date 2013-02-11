<cfcomponent displayname="PostageApp" output="false">
	
	<!--- 
	Author: Sami Hoda
	Email: sami <at> bytestopshere.com
	Blog: http://www.bytestopshere.com
	Version: v0.1
	Note: Comments appreciated! Currently this only supports the send_message API endpoint. See: http://help.postageapp.com/kb
	
	Warning:
	This code is provided as is.  
	I make no warranty or guarantee.  
	Use of this code is at your own risk.
	
	To Do:
	- Support attachments for send_message endpoint.
	- Support additional API endpoints. See "Note" above.
		
		
	License:
	Copyright 2011 Sami Hoda
	
	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at
	
	    http://www.apache.org/licenses/LICENSE-2.0
	
	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.		
	--->
	
	<cffunction name="init" access="public" description="" output="false" returntype="PostageApp">
		<cfargument name="API_KEY" type="Any" required="true" default="" />
				
		<cfset variables.instance = structNew() />
		<cfset variables.instance.API_KEY = trim(arguments.API_KEY) />		
		<cfset variables.instance.send_message_api_url = "https://api.postageapp.com/v.1.0/send_message.json" />
		
		<cfreturn this />
	</cffunction>
	

	<cffunction name="send_message" access="public" description="" output="false" returntype="Any">
		<!--- This function will implement the send_message endpoint --->		
		<!--- TO DO: IMPLEMENT ATTACHMENTS --->
		
		<cfargument name="recipients" type="struct" required="true" default="#StructNew()#" 
			hint="Pass in a struct where the keys are email address and values are structs of variables (which is optional) for user specific merging." />
			 
		<cfargument name="headers" type="struct" required="false" default="#StructNew()#" 
			hint="Pass in a struct of headers to send to the API, like subject, from, etc." />
			
		<cfargument name="content" type="struct" required="false" default="#StructNew()#" 
			hint="Pass in a struct of with keys text/html and text/plain. This is optional is using template, and either key can be used in that case." />
				
		<cfargument name="template" type="string" required="false" default="" 
			hint="Pass in a optional string value of a template slug. Use child if there is a parent/child defined in the app." />
			
		<cfargument name="_variables" type="struct" required="false" default="#StructNew()#" 
			hint="Pass in a struct of global variables to send to the API for merging." />
			
		<cfargument name="recipient_override" type="string" required="false" default="" 
			hint="Override the 'to' during development and testing. Single email address only." />	
			
		<cfargument name="uid" type="string" required="false" default="" 
			hint="Use a UID. See API. Useful tool." />	
		
		<cfset var sLocal = StructNew() />		
		
		<cfset sLocal.cfhttp = "" />		
		<cfset sLocal.jsonPacket = assembleJSONPacket(arguments) />		
		
		<cfif isJSON(sLocal.jsonPacket)>
			<cfhttp url="#variables.instance.send_message_api_url#" method="post" result="slocal.cfhttp" throwOnError="false">
				<cfhttpparam type="header" name="Accept" value="application/json" />
				<cfhttpparam type="header" name="Content-type" value="application/json" />
				<cfhttpparam type="header" name="User-Agent" value="POSTAGEAPP-COLDFUSION 1.0.0 (CF #SERVER.ColdFusion.ProductVersion#)" />
				<cfhttpparam type="body" encoded="no" value="#trim(sLocal.jsonPacket)#" />
			</cfhttp>		
		</cfif>		
		
		<cfreturn slocal />	
	</cffunction>
	
	<cffunction name="assembleJSONPacket" access="private" description="Assembles the JSON packet for the API" output="false" returntype="Any">
		<cfargument name="args" type="Struct" required="true" />
		
		<cfset var sLocal = arguments.args />
		
		<cfset sLocal.jsonPacket = StructNew() />		
		
		<!--- uid --->
		<cfif len(trim(sLocal.uid))>
			<cfset sLocal.jsonPacket.uid = trim(sLocal.uid) />
		</cfif>
		
		<!--- API_KEY --->
		<cfif len(trim(variables.instance.API_KEY))>
			<cfset sLocal.jsonPacket.api_key = trim(variables.instance.API_KEY) />
		</cfif>
		
		<!--- recipients --->
		<!--- While the API allows all sorts of configurations, the easiest and most 
			flexible to do this is to follow the example that pairs emails with variables. 
			A struct of structs is needed. --->				
		<cfset sLocal.jsonPacket.arguments.recipients = sLocal.recipients />
		
		<!--- headers --->
		<cfif structCount(sLocal.headers)>
			<cfset sLocal.jsonPacket.arguments.headers = sLocal.headers />
		</cfif>
		
		<!--- template or content --->
		<cfif len(trim(sLocal.template))>
			<cfset sLocal.jsonPacket.arguments.template = trim(sLocal.template) />
		<cfelse>
			<cfset sLocal.jsonPacket.arguments.content = sLocal.content />	
		</cfif>
		
		<!--- variables --->
		<cfif structCount(sLocal._variables)>
			<cfset sLocal.jsonPacket.arguments.variables = sLocal._variables />
		</cfif>
		
		<!--- recipient_override --->
		<cfif len(trim(sLocal.recipient_override))>
			<cfset sLocal.jsonPacket.arguments.recipient_override = trim(sLocal.recipient_override) />
		</cfif>
		
		<cfreturn serializeJSON(sLocal.jsonPacket) />
	</cffunction>	
	
</cfcomponent>