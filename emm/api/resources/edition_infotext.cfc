<cfcomponent extends="taffy.core.resource" taffy_uri="/edition/{editionID}/infotext/">

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

				<cfquery name="local.qInfotext">
					SELECT *, title_#sessionLang# AS title, text_#sessionLang# AS text
					FROM edition_infotext
					WHERE edition_id = 1
					<!--- todo: editionId from arguments --->
					<!--- WHERE edition_id = <cfqueryparam value="#arguments.editionId#" cfsqltype="cf_sql_integer"> --->
				</cfquery>

				<cfif qInfotext.recordcount>
					<cfset var infotext = [:]>
					<cfset infotext["title"] = qInfotext.title>
					<cfset infotext["text"] = qInfotext.text>
					<cfset infotext["isOpen"] = qInfotext.isOpen ? "true" : "false">
					<cfreturn rep(infotext)>
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