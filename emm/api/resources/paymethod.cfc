<cfcomponent extends="taffy.core.resource" taffy_uri="/paymethod/{orderId}">

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

				<cfset var tableYear = mid(arguments.orderId, 3, 1)>

				<cfif tableYear GTE 6>
					<cfset tableYear += 2010>
				<cfelse>
					<cfset tableYear += 2020>
				</cfif>

				<cfquery name="local.qOrder" datasource="pay1">
					SELECT *
					FROM order_#tableYear#
					WHERE orderuid = <cfqueryparam value="#arguments.orderId#" cfsqltype="CF_SQL_VARCHAR">
				</cfquery>

				<cfhttp method="post" url="#application.paymentURL#httppaymethodes.htm" userAgent="redjunky">
					<cfhttpparam name="notShowSue" type="FormField" value="true">
					<cfhttpparam name="isBaslerStadtlauf" type="FormField" value="false">
					<cfhttpparam name="isTortour" type="FormField" value="false">
					<cfhttpparam name="isPDG" type="FormField" value="false">
					<cfhttpparam name="onlyCreditcard" type="FormField" value="false">
					<cfhttpparam name="onlyFast" type="FormField" value="false">
					<cfhttpparam name="skinSimple" type="FormField" value="false">
					<cfhttpparam name="onlyCheap" type="FormField" value="false">
					<cfhttpparam name="noElv" type="FormField" value="false">
					<cfhttpparam name="partpay" type="FormField" value="false">
					<cfhttpparam name="lang" type="FormField" value="#sessionLang#">
				</cfhttp>

				<cfset var xml = trim(left(cfhttp.FileContent, Find("</reply>", cfhttp.FileContent)+7))>
				<cfset var paymethodes = XmlParse(xml)>

				<cfset stPaymethod = {}>

				<cfloop array="#paymethodes.reply.paymethod#" index="local.paymethod">
					<cfset var showPaymethod = true>
					<cfset var payType = paymethod.typ.xmlText>
					<cfset var shortdesc = paymethod.shortdesc.xmlText>

					<cfif (shortdesc EQ "MASTERCARD" OR shortdesc EQ "MASTERCARDD" OR shortdesc EQ "VISA" OR shortdesc EQ "VISAD") AND qOrder.order_currency EQ "EUR">
						<cfset showPaymethod = false>
					<cfelseif (shortdesc EQ "MASTERCARDG" OR shortdesc EQ "MASTERCARDDG" OR shortdesc EQ "VISAG" OR shortdesc EQ "VISADG") AND qOrder.order_currency EQ "CHF">
						<cfset showPaymethod = false>
					</cfif>

					<cfif shortdesc EQ "AMEX" AND qOrder.order_currency EQ "EUR">
						<cfset showPaymethod = false>
					<cfelseif shortdesc EQ "AMEXEUR" AND qOrder.order_currency EQ "CHF">
						<cfset showPaymethod = false>
					</cfif>

					<cfif showPaymethod>
						<cfif NOT structKeyExists(stPaymethod, payType)>
							<cfset stPaymethod[payType] = []>
						</cfif>
						<cfset var payItem = [:]>
						<cfset payItem.setMetadata({fee: "string"})>
						<cfset payItem["type"] = shortdesc>
						<cfset payItem["title"] = paymethod.longdesc.xmlText>
						<cfhttp method = "post" url = "#application.paymentURL#httpfee.htm" userAgent = "redjunky" result="local.httpfee">
							<cfhttpparam name = "paymethod" type = "FormField" value = "#shortdesc#">
							<cfhttpparam name = "currency" type = "FormField" value = "#qOrder.order_currency#">
							<cfhttpparam name = "amount" type = "FormField" value = "#qOrder.order_amount#">
						</cfhttp>
						<cfset payItem["currency"] = listGetAt(httpfee.filecontent, 2, ":")>
						<cfset payItem["fee"] = lsNumberFormat(listGetAt(httpfee.filecontent, 3, ":"), ".00")>
						<cfset arrayAppend(stPaymethod[payType], payItem)>
					</cfif>
				</cfloop>

				<cfset aPaymethod = []>
				<cfloop list="creditcard,debit,phone,online,transfer,coupon" index="local.filter">
					<cfif structKeyExists(stPaymethod, filter)>
						<cfset var newPaymethod = [:]>
						<cfset newPaymethod["type"] = filter>
						<cfset newPaymethod["name"] = application.strings.getString("pm#filter#", sessionLang)>
						<cfset newPaymethod["method"] = stPaymethod[filter]>
						<cfset arrayAppend(aPaymethod, newPaymethod)>
					</cfif>
				</cfloop>

				<cfreturn rep(aPaymethod)>
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