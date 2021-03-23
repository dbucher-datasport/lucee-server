<cfcomponent extends="taffy.core.resource" taffy_uri="/participants/basket/">

	<cffunction name="post">
		<cfargument name="firstname" type="string" required="true">
		<cfargument name="lastname" type="string" required="true">
		<cfargument name="nationality" type="string" required="true">
		<cfargument name="birthday" type="date" required="true">
		<cfargument name="gender" type="string" required="true">
		<cfargument name="street1" type="string" required="true">
		<cfargument name="country" type="string" required="true">
		<cfargument name="city" type="string" required="true">
		<cfargument name="zip" type="string" required="true">
		<cfargument name="mobile" type="string" required="true">
		<cfargument name="email" type="string" required="true">
		<cfargument name="contestId" type="numeric" required="true">

		<cftry>
			<cfif structKeyExists(arguments, "sessionId")>

				<cfhttp url="https://secure.datasport.com/emm/api/participants/" method="post" result="local.apiParticipants">
					<cfhttpparam type="header" name="X-Client-Session-Id" value="#arguments.sessionId#">
					<cfhttpparam type="formfield" name="firstname" value="#arguments.firstname#">
					<cfhttpparam type="formfield" name="lastname" value="#arguments.lastname#">
					<cfhttpparam type="formfield" name="nationality" value="#arguments.nationality#">
					<cfhttpparam type="formfield" name="birthday" value="#arguments.birthday#">
					<cfhttpparam type="formfield" name="gender" value="#arguments.gender#">
					<cfhttpparam type="formfield" name="street1" value="#arguments.street1#">
					<cfhttpparam type="formfield" name="country" value="#arguments.country#">
					<cfhttpparam type="formfield" name="city" value="#arguments.city#">
					<cfhttpparam type="formfield" name="zip" value="#arguments.zip#">
					<cfhttpparam type="formfield" name="mobile" value="#arguments.mobile#">
					<cfhttpparam type="formfield" name="email" value="#arguments.email#">
				</cfhttp>

				<cfset aParticipants = deserializeJSON(apiParticipants.filecontent)>

				<cfset var participantId = aParticipants[arrayLen(aParticipants)].participantID>

				<cfhttp url="https://secure.datasport.com/emm/api/basket/" method="post" result="local.apiBasket">
					<cfhttpparam type="header" name="X-Client-Session-Id" value="#arguments.sessionId#">
					<cfhttpparam type="formfield" name="participantId" value="#participantId#">
					<cfhttpparam type="formfield" name="contestId" value="#arguments.contestId#">
				</cfhttp>

				<cfset var basket = deserializeJSON(apiBasket.filecontent)>

				<cfreturn rep(basket)>
			<cfelse>
				<cfreturn noData().withStatus(403)>
			</cfif>
			<cfcatch>
				<cfdump var="#cfcatch#">
				<cfabort>
				<cfset application.common.informAdmin(message=cfcatch.message, data=cfcatch, subject="[Error] EMM API")>
				<cfreturn noData().withStatus(500)>
			</cfcatch>
		</cftry>
	</cffunction>

</cfcomponent>