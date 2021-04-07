<cfcomponent extends="taffy.core.resource" taffy_uri="/edition/{editionID}/delivery/">

	<cffunction name="get">
		<cftry>
			<cfif structKeyExists(arguments, "sessionId")>
				<cfquery name="local.qLanguage">
					SELECT *
					FROM session_language
					WHERE client_session_id = <cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">
				</cfquery>

				<cfif qLanguage.recordcount>
					<cfset var sessionLang = qLanguage.language>
				<cfelse>
					<cfset var sessionLang = "en">
				</cfif>

				<cfquery name="local.qDelivery">
					SELECT *, title_#sessionLang# AS title, text_#sessionLang# AS text
					FROM edition_delivery
					WHERE edition_id = 1
					<!--- todo: editionId from arguments --->
					<!--- WHERE edition_id = <cfqueryparam value="#arguments.editionId#" cfsqltype="cf_sql_integer"> --->
				</cfquery>

				<cfif qDelivery.recordcount>
					<cfset var aDelivery = []>

					<cfloop query="qDelivery">
						<cfset var delivery = [:]>
						<cfset delivery.setMetadata({amount: "string"})>
						<cfset delivery["type"] = type>
						<cfset delivery["title"] = title>
						<cfset delivery["text"] = text>
						<cfset delivery["currency"] = currency>
						<cfset delivery["amount"] = lsNumberFormat(amount, ".00")>
						<cfset arrayAppend(aDelivery, delivery)>
					</cfloop>

					<cfreturn rep(aDelivery)>
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