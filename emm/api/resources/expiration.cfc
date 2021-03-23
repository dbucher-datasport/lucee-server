<cfcomponent extends="taffy.core.resource" taffy_uri="/expiration/">

	<cffunction name="get">
		<cftry>
			<cfif structKeyExists(arguments, "sessionId")>
				<cfquery name="local.qExpiration">
					SELECT *
					FROM session_expiration
					WHERE client_session_id = <cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">
				</cfquery>
				<cfif qExpiration.recordcount>
					<cfset var secondsLeft = dateDiff("s", now(), qExpiration.expiration_date)>
					<cfset var expiration = {}>
					<cfif secondsLeft GT 0>
						<cfset expiration["seconds"] = secondsLeft>
					<cfelse>
						<cfset expiration["seconds"] = 0>
					</cfif>
					<cfreturn rep(expiration)>
				<cfelse>
					<cfreturn rep({"seconds": 0})>
				</cfif>
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

	<cffunction name="post">
		<cftry>
			<cfif structKeyExists(arguments, "sessionId")>
				<!--- todo: expiration time definition from core?  --->
				<!--- Add 20 Minutes --->
				<cfset var expirationDate = dateAdd("s", 1200, now())>

				<cfquery name="local.qExpiration">
					SELECT *
					FROM session_expiration
					WHERE client_session_id = <cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">
				</cfquery>

				<cfif qExpiration.recordcount>
					<cfif dateDiff("s", qExpiration.expiration_date, now()) GT 0>
						<cfquery>
							UPDATE session_expiration
							SET expiration_date = <cfqueryparam value="#expirationDate#" cfsqltype="cf_sql_timestamp">
							WHERE client_session_id = <cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">
						</cfquery>
						<cfreturn rep({"seconds": 1200})>
					<cfelse>
						<cfreturn rep({"seconds": dateDiff("s", now(), qExpiration.expiration_date)})>
					</cfif>
				<cfelse>
					<cfquery>
						INSERT INTO session_expiration (client_session_id, expiration_date)
						VALUES (
							<cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#expirationDate#" cfsqltype="cf_sql_timestamp">
						)
					</cfquery>
					<cfreturn rep({"seconds": 1200})>
				</cfif>
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