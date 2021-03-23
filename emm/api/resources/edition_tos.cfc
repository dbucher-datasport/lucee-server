<cfcomponent extends="taffy.core.resource" taffy_uri="/edition/{editionID}/tos/">

	<cffunction name="get" access="public" output="false">

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

				<cfquery name="local.qTos">
					SELECT *, text_#sessionLang# AS text
					FROM edition_tos
					WHERE edition_id = 1
					<!--- todo: editionId from arguments --->
					<!--- WHERE edition_id = <cfqueryparam value="#arguments.editionId#" cfsqltype="cf_sql_integer"> --->
				</cfquery>

				<cfset var aTos = []>

				<cfloop query="qTos">
					<cfset var tos = [:]>
					<cfset tos["key"] = key>
					<cfset tos["text"] = text>
					<cfset arrayAppend(aTos, tos)>
				</cfloop>

				<cfreturn rep(aTos)>
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