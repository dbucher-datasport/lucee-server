<cfcomponent extends="taffy.core.resource" taffy_uri="/edition/{editionID}/shop/">

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

				<cfquery name="local.qShop">
					SELECT *, name_#sessionLang# AS name, description_#sessionLang# AS description, discount_#sessionLang# AS discount
					FROM edition_shop
					WHERE edition_id = 1
					<!--- todo: editionId from arguments --->
					<!--- WHERE edition_id = <cfqueryparam value="#arguments.editionId#" cfsqltype="cf_sql_integer"> --->
					AND stock_available > 0
				</cfquery>

				<cfset var aShop = []>

				<cfloop query="qShop">
					<cfquery name="local.qShopImage">
						SELECT *
						FROM edition_shop_image
						WHERE shop_id = <cfqueryparam value="#id#" cfsqltype="cf_sql_integer">
					</cfquery>
					<cfset var item = [:]>
					<cfset item.setMetadata({
						amount: {type: "string"},
						originalAmount: {type: "string"}
					})>
					<cfset item["id"] = id>
					<cfset item["name"] = name>
					<cfset item["description"] = description>
					<cfset item["image"] = []>
					<cfloop query="qShopImage">
						<cfset arrayAppend(item["image"], image)>
					</cfloop>
					<cfset item["currency"] = currency>
					<cfset item["amount"] = lsNumberFormat(amount, ".00")>
					<cfset item["originalAmount"] = isNumeric(amount_original) ? lsNumberFormat(amount_original, ".00") : "">
					<cfset item["discount"] = discount>
					<cfset item["stock"] = stock>
					<cfset item["stock_available"] = stock_available>
					<cfset var stockQuota = (100 * stock_available) / stock>
					<cfset item["stock_text"] = stockQuota LTE 10 ? application.strings.getString("lowStock", sessionLang) : application.strings.getString("inStock", sessionLang)>
					<cfset item["stock_flag"] = stockQuota LTE 10 ? "red" : "green">
					<cfset item["option"] = []>

					<cfquery name="local.qOption">
						SELECT *, name_#sessionLang# AS name
						FROM edition_shop_option
						WHERE shop_id = <cfqueryparam value="#id#" cfsqltype="cf_sql_integer">
					</cfquery>

					<cfloop query="qOption">
						<cfset var option = [:]>
						<cfset var option["value"] = value>
						<cfset var option["name"] = name>
						<cfset arrayAppend(item["option"], option)>
					</cfloop>

					<cfset arrayAppend(aShop, item)>
				</cfloop>

				<cfreturn rep(aShop)>
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