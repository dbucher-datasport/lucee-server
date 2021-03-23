<cfcomponent extends="taffy.core.resource" taffy_uri="/account/">

	<cffunction name="get">

		<cftry>
			<cfif structKeyExists(arguments, "sessionId")>
				<cfquery name="local.qAccount">
					SELECT *
					FROM session_account
					WHERE client_session_id = <cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">
				</cfquery>
				<cfif qAccount.recordcount>
					<cfset var account = [:]>
					<cfset account["account_id"] = qAccount.account_id>
					<cfset account["account_name"] = qAccount.account_name>
					<cfset account["account_currency"] = qAccount.account_currency>
					<cfset account["account_language"] = qAccount.account_language>
					<cfset account["person_id"] = qAccount.person_id>
					<cfset account["dsid"] = qAccount.dsid>
					<cfset account["firstname"] = qAccount.firstname>
					<cfset account["lastname"] = qAccount.lastname>
					<cfset account["gender"] = qAccount.gender>
					<cfset account["yob"] = qAccount.yob>
					<cfset account["country"] = qAccount.country>
					<cfset account["city"] = qAccount.city>
					<cfreturn rep(account)>
				<cfelse>
					<cfreturn noData().withStatus(401)>
				</cfif>
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