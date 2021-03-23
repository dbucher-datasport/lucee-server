<cfcomponent extends="taffy.core.resource" taffy_uri="/edition/{editionID}/upload">

	<cffunction name="get" access="public" output="false">
		<cftry>
			<cfif structKeyExists(arguments, "sessionId")>
				<cfset var aUpload = []>

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

				<cfquery name="local.qUpload">
					SELECT *, name_#sessionLang# AS name
					FROM edition_upload
				</cfquery>

				<cfloop query="qUpload">
					<cfset var item = [:]>
					<cfset item["id"] = upload_id>
					<cfset item["name"] = name>
					<cfset item["accept"] = accept>
					<cfset item["multiple"] = booleanFormat(multiple)>
					<cfset item["maxSizeMB"] = max_size_mb>
					<cfset arrayAppend(aUpload, item)>
				</cfloop>

				<cfreturn rep(aUpload)>
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