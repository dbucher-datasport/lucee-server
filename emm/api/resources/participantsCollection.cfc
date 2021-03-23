<cfcomponent extends="taffy.core.resource" taffy_uri="/participants/">

	<cffunction name="get">

		<cftry>
			<cfif structKeyExists(arguments, "sessionId")>
				<cfset var participants = []>

				<cfquery name="local.qParticipant">
					SELECT *
					FROM session_participant
					WHERE client_session_id = <cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">
				</cfquery>

				<cfloop query="qParticipant">
					<cfset var participant = [:]>
					<cfset participant["personID"] = person_id>
					<cfset participant["dsID"] = dsid>
					<cfset participant["participantID"] = participant_id>
					<cfset participant["firstname"] = firstname>
					<cfset participant["lastname"] = lastname>
					<cfset participant["nationality"] = nationality>
					<cfset participant["birthday"] = birthday>
					<cfset participant["gender"] = gender>
					<cfset participant["street1"] = street1>
					<cfset participant["country"] = country>
					<cfset participant["city"] = city>
					<cfset participant["zip"] = zip>
					<cfset participant["mobile"] = mobile>
					<cfset participant["email"] = email>
					<cfset arrayAppend(participants, participant)>
				</cfloop>

				<cfreturn rep(participants)>
			<cfelse>
				<cfreturn noData().withStatus(403)>
			</cfif>
			<cfcatch>
				<cfset application.common.informAdmin(message=cfcatch.message, data=cfcatch, subject="[Error] EMM API")>
				<cfreturn noData().withStatus(500)>
			</cfcatch>
		</cftry>
	</cffunction>

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

		<cftry>
			<cfif structKeyExists(arguments, "sessionId")>

				<cfquery>
					INSERT INTO session_participant (client_session_id, participant_id, firstname, lastname, nationality, birthday, gender, street1, country, city, zip, mobile, email, create_date)
					VALUES (
						<cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#createUUID()#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.firstname#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.lastname#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.nationality#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#lsDateFormat(arguments.birthday, "yyyy-mm-dd")#" cfsqltype="cf_sql_date">,
						<cfqueryparam value="#arguments.gender#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.street1#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.country#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.city#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.zip#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.mobile#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.email#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
					)
				</cfquery>

				<cfset var participants = []>

				<cfquery name="local.qParticipant">
					SELECT *
					FROM session_participant
					WHERE client_session_id = <cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">
				</cfquery>

				<cfloop query="qParticipant">
					<cfset var participant = [:]>
					<cfset participant["personID"] = person_id>
					<cfset participant["dsID"] = dsid>
					<cfset participant["participantID"] = participant_id>
					<cfset participant["firstname"] = firstname>
					<cfset participant["lastname"] = lastname>
					<cfset participant["nationality"] = nationality>
					<cfset participant["birthday"] = birthday>
					<cfset participant["gender"] = gender>
					<cfset participant["street1"] = street1>
					<cfset participant["country"] = country>
					<cfset participant["city"] = city>
					<cfset participant["zip"] = zip>
					<cfset participant["mobile"] = mobile>
					<cfset participant["email"] = email>
					<cfset arrayAppend(participants, participant)>
				</cfloop>

				<cfreturn rep(participants)>
			<cfelse>
				<cfreturn noData().withStatus(403)>
			</cfif>
			<cfcatch>
				<cfset application.common.informAdmin(message=cfcatch.message, data=cfcatch, subject="[Error] EMM API")>
				<cfreturn noData().withStatus(500)>
			</cfcatch>
		</cftry>
	</cffunction>

</cfcomponent>