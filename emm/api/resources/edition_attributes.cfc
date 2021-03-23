<cfcomponent extends="taffy.core.resource" taffy_uri="/edition/{editionID}/attributes/">

	<cffunction name="get">
		<cftry>
			<cfif structKeyExists(arguments, "sessionId")>
				<cfquery name="local.qAttributes">
					SELECT *
					FROM edition_attributes
					WHERE edition_id = <cfqueryparam value="#arguments.editionID#" cfsqltype="cf_sql_integer">
				</cfquery>

				<cfif qAttributes.recordcount>
					<cfset var stAttributes = [:]>

					<cfset var fields = "firstname,lastname,birthday,nationality,gender,address,zip,location,country,email,phone">

					<cfloop list="#fields#" index="local.iField">
						<cfset stAttributes[iField] = [:]>
						<cfif  listFirst(evaluate("qAttributes.#iField#"), "_") EQ "YES">
							<cfset stAttributes[iField]["visible"] = true>
							<cfif listLen(evaluate("qAttributes.#iField#"), "_") EQ 2>
								<cfset stAttributes[iField]["mandatory"] = true>
							<cfelse>
								<cfset stAttributes[iField]["mandatory"] = false>
							</cfif>
						<cfelse>
							<cfset stAttributes[iField]["visible"] = false>
							<cfset stAttributes[iField]["mandatory"] = false>
						</cfif>
					</cfloop>

					<cfreturn rep(stAttributes)>
				<cfelse>
					<cfreturn noData().withStatus(404)>
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