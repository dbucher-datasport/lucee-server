<cfcomponent extends="taffy.core.resource" taffy_uri="/edition/sidebar/{editionID}">

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

				<cfset var aSidebar = []>

				<cfquery name="local.qSidebar">
					SELECT *, title_#sessionLang# AS title, text_#sessionLang# AS text
					FROM edition_sidebar
					WHERE edition_id = 1
					<!--- todo: <cfqueryparam value="#arguments.editionId#" cfsqltype="cf_sql_integer"> --->
					ORDER BY priority
				</cfquery>

				<cfloop query="qSidebar">
					<cfquery name="local.qSidebarImage">
						SELECT *
						FROM edition_sidebar_image
						WHERE sidebar_id = <cfqueryparam value="#id#" cfsqltype="cf_sql_integer">
						ORDER BY priority
					</cfquery>

					<cfset var item = [:]>
					<cfset item["type"] = type>
					<cfset item["title"] = title>
					<cfset item["text"] = text>
					<cfset item["image"] = []>
					<cfloop query="qSidebarImage">
						<cfset var image = {}>
						<cfset image["url"] = url>
						<cfset image["link"] = link>
						<cfset arrayAppend(item["image"], image)>
					</cfloop>
					<cfset arrayAppend(aSidebar, item)>
				</cfloop>

				<cfreturn rep(aSidebar)>
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