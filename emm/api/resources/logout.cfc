<cfcomponent extends="taffy.core.resource" taffy_uri="/logout/">

	<cffunction name="post">

		<cftry>
			<cfif structKeyExists(arguments, "sessionId")>
				<!--- delete participant --->
				<cfquery>
					DELETE FROM session_participant
					WHERE client_session_id = <cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">
				</cfquery>
				<!--- delete account --->
				<cfquery>
					DELETE FROM session_account
					WHERE client_session_id = <cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">
				</cfquery>
				<!--- delete basket --->
				<cfquery>
					DELETE FROM basket
					WHERE client_session_id = <cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">
				</cfquery>
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