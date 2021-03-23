<cfcomponent extends="taffy.core.resource" taffy_uri="/contest/{contestId}/attributes/">

	<cffunction name="get">

		<cftry>
			<cfif structKeyExists(arguments, "sessionId")>
				<!--- mock data --->
				<cfset var aAttributes = []>

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

				<cfquery name="local.qFieldset">
					SELECT fieldset_#sessionLang# AS fieldset
					FROM attribute
					GROUP BY fieldset_#sessionLang#
				</cfquery>

				<cfloop query="qFieldset">
					<cfquery name="local.qAttribute">
						SELECT *,
								label_#sessionLang# AS label,
								placeholder_#sessionLang# AS placeholder,
								error_msg_#sessionLang# AS error_msg
						FROM attribute
						<cfif len(fieldset)>
							WHERE fieldset_#sessionLang# = <cfqueryparam value="#fieldset#" cfsqltype="cf_sql_varchar">
						<cfelse>
							WHERE fieldset_#sessionLang# IS NULL
						</cfif>
					</cfquery>
					<cfset var group = [:]>
					<cfset group["label"] = fieldset>
					<cfset group["fields"] = []>
					<cfloop query="qAttribute">
						<cfquery name="local.qAttributeOption">
							SELECT *, label_#sessionLang# AS label
							FROM attribute_option
							WHERE feldkey = '#key#'
						</cfquery>
						<cfset var item = [:]>
						<cfset item["label"] = label>
						<cfset item["type"] = type>
						<cfset item["key"] = key>
						<cfset item["required"] = required>
						<cfset item["pattern"] = pattern>
						<cfset item["default"] = default>
						<cfset item["min"] = min>
						<cfset item["max"] = max>
						<cfset item["placeholder"] = placeholder>
						<cfset item["rows"] = rows>
						<cfset item["error_msg"] = error_msg>
						<cfif qAttributeOption.recordcount>
							<cfset item["options"] = []>
							<cfloop query="qAttributeOption">
								<cfset var option = [:]>
								<cfset option.setMetadata({ label: "string", amount: "string" })>
								<cfset option["label"] = label>
								<cfset option["value"] = value>
								<cfset option["currency"] = "CHF">
								<cfset option["amount"] = "0.00">
								<cfset arrayAppend(item["options"], option)>
							</cfloop>
						</cfif>
						<cfset arrayAppend(group["fields"], item)>
					</cfloop>
					<cfset arrayAppend(aAttributes, group)>
				</cfloop>
				<cfreturn rep(aAttributes)>
			<cfelse>
				<cfreturn noData().withStatus(403)>
			</cfif>
			<cfcatch>
				<cfdump var="#cfcatch#"><cfabort>
				<cfset application.common.informAdmin(message=cfcatch.message, data=cfcatch, subject="[Error] EMM API")>
				<cfreturn noData().withStatus(500)>
			</cfcatch>
		</cftry>
	</cffunction>

</cfcomponent>