<cfcomponent extends="taffy.core.resource" taffy_uri="/edition/{editionID}/step/">

	<cffunction name="get">
		<cftry>
			<cfif structKeyExists(arguments, "sessionId")>
				<cfquery name="local.qStep">
					SELECT *
					FROM edition_step
					WHERE edition_id = 1 <!--- todo: <cfqueryparam value="#arguments.editionID#" cfsqltype="cf_sql_integer"> --->
				</cfquery>

				<cfif qStep.recordcount>
					<cfset var steps = [:]>
					<cfloop query="qStep">
						<cfset steps["editionId"] = edition_id>
						<cfset steps["participant"] = participant ? true : false>
						<cfset steps["registration"] = registration ? true : false>
						<cfset steps["extra"] = extra ? true : false>
						<cfset steps["shop"] = shop ? true : false>
						<cfset steps["summary"] = summary ? true : false>
						<cfset steps["checkout"] = checkout ? true : false>
					</cfloop>
					<cfreturn rep(steps)>
				<cfelse>
					<cfreturn noData()>
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