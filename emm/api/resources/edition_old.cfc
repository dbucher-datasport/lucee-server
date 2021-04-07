<cfcomponent extends="taffy.core.resource" taffy_uri="/edition_old/{editionID}">

	<cffunction name="get" access="public" output="false">
		<cfargument name="lang" type="string" default="de">

		<cftry>
			<cfif structKeyExists(arguments, "sessionId")>
				<!--- TODO: data from core --->
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

				<cfquery name="local.qEdition">
					SELECT *,
							description_#sessionLang# AS description,
							info_title_#sessionLang# AS info_title,
							info_text_#sessionLang# AS info_text,
							info_link_label_#sessionLang# AS info_link_label
					FROM edition
					WHERE edition_id = 1
				</cfquery>

				<cfset var edition = [:]>

				<cfloop query="qEdition">
					<cfset edition["editionID"] = edition_id>
					<cfset edition["name"] = name>
					<cfset edition["description"] = description>
					<cfset edition["dateFrom"] = lsDateFormat(date_from, "yyyy-mm-dd") & "T" & lsTimeFormat(date_from, "HH:mm:ss")>
					<cfset edition["dateTo"] = isDate(date_to) ? lsDateFormat(date_to, "yyyy-mm-dd") & "T" & lsTimeFormat(date_to, "HH:mm:ss") : "">
					<cfset edition["headerImage"] = image_header>
					<cfset edition["link"] = link>
					<cfset edition["info"] = [:]>
					<cfset edition["info"]["title"] = info_title>
					<cfset edition["info"]["text"] = info_text>
					<cfset edition["info"]["link"] = info_link>
					<cfset edition["info"]["linkLabel"] = info_link_label>
					<cfset edition["info"]["image"] = info_image1>
				</cfloop>

				<cfreturn rep(edition)>
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