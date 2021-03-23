<cfcomponent extends="taffy.core.resource" taffy_uri="/language/">

	<cffunction name="get">
		<cftry>
			<cfif structKeyExists(arguments, "sessionId")>
				<cfquery name="local.qLanguage">
					SELECT *
					FROM session_language
					WHERE client_session_id = <cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">
				</cfquery>
				<cfif qLanguage.recordcount>
					<cfset var result = {"language": qLanguage.language}>
				<cfelse>
					<cfset var result = {"language": "de"}>
				</cfif>
				<cfreturn rep(result)>
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
		<cfargument name="language" type="string" required="true">

		<cftry>
			<cfif structKeyExists(arguments, "sessionId")>
				<cfquery name="local.qCheck">
					SELECT COUNT(*) AS total
					FROM session_language
					WHERE client_session_id = <cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">
				</cfquery>
				<cfif qCheck.total>
					<cfquery>
						UPDATE session_language
						SET language = <cfqueryparam value="#arguments.language#" cfsqltype="cf_sql_varchar">,
							update_date = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
						WHERE client_session_id = <cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">
					</cfquery>
				<cfelse>
					<cfquery>
						INSERT INTO session_language (client_session_id, language, create_date)
						VALUES (
							<cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#arguments.language#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
						)
					</cfquery>
				</cfif>
				<cfreturn noData().withStatus(200)>
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