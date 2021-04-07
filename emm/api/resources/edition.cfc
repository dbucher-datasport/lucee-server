<cfcomponent extends="taffy.core.resource" taffy_uri="/edition/{editionID}">

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

				<!--- todo: remove hardcoded edtionID --->
				<cfset arguments.editionID = 3>

				<!--- Data from core --->
				<cfhttp url="#application.coreURL#/api/onReg/edition/#arguments.editionID#" method="GET" result="local.getEdition">
				</cfhttp>

				<cfif getEdition.statuscode EQ 200>
					<cfset var jsonEdition = deserializeJSON(getEdition.filecontent)>

					<!--- Edition --->
					<cfset application.oEdition.populateEdition(arguments.editionID, jsonEdition)>

					<!--- OnReg --->
					<cfset application.oEdition.populateOnReg(arguments.editionID, jsonEdition)>

					<!--- Infotext --->
					<cfset application.oEdition.populateInfotext(arguments.editionID, jsonEdition)>

					<!--- Standard Attributes --->
					<cfset application.oEdition.populateStandardAttributes(arguments.editionID, jsonEdition)>

					<!--- Contest --->
					<cfset application.oEdition.populateContest(arguments.editionID, jsonEdition)>

					<!--- Attribute --->
					<cfset application.oEdition.populateAttribute(arguments.editionID, jsonEdition)>
				</cfif>

				<cfquery name="local.qEdition">
					SELECT *,
							o.about_title_#sessionLang# AS about_title,
							o.about_text_#sessionLang# AS about_text
					FROM edition e
					LEFT JOIN edition_onreg o ON e.edition_id = e.edition_id
					WHERE e.edition_id = <cfqueryparam value="#arguments.editionID#" cfsqltype="cf_sql_integer">
				</cfquery>

				<cfif qEdition.recordcount>
					<cfset var edition = [:]>

					<cfloop query="qEdition">
						<cfset edition["editionID"] = edition_id>
						<cfset edition["name"] = name>
						<cfset edition["dateFrom"] = lsDateFormat(date_from, "yyyy-mm-dd") & "T" & lsTimeFormat(date_from, "HH:mm:ss")>
						<cfset edition["dateTo"] = isDate(date_to) ? lsDateFormat(date_to, "yyyy-mm-dd") & "T" & lsTimeFormat(date_to, "HH:mm:ss") : "">
						<cfset edition["openFrom"] = lsDateFormat(open_from, "yyyy-mm-dd") & "T" & lsTimeFormat(open_from, "HH:mm:ss")>
						<cfset edition["openTo"] = isDate(open_to) ? lsDateFormat(open_to, "yyyy-mm-dd") & "T" & lsTimeFormat(open_to, "HH:mm:ss") : "">
						<cfif len(trim(main_image))>
							<cfset edition["headerImage"] = application.coreURL & main_image>
						<cfelse>
							<cfset edition["headerImage"] = "https://via.placeholder.com/1400x400.png/000000/000000/">
						</cfif>
						<cfset edition["info"] = [:]>
						<cfset edition["info"]["title"] = about_title>
						<cfset edition["info"]["text"] = about_text>
						<cfset edition["info"]["link"] = about_url>
						<cfset edition["info"]["image1"] = application.coreURL & event_image1>
						<cfset edition["info"]["image2"] = application.coreURL & event_image2>
						<cfset edition["isActive"] = active ? true : false>
						<cfset edition["isOpen"] = (active AND now() GTE open_from AND now() LTE open_to) ? true : false>
						<cfset edition["needsMyds"] = myds ? true : false>
					</cfloop>

					<cfreturn rep(edition)>
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