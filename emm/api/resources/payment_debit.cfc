<cfcomponent extends="taffy.core.resource" taffy_uri="/payment/debit/{type}">

	<cffunction name="post">
		<cfargument name="orderId" type="string" required="true">
		<cfargument name="cardnum" type="string" default="">
		<cfargument name="cardmonth" type="string" default="">
		<cfargument name="cardyear" type="numeric" default="">
		<cfargument name="cardname" type="string" default="">
		<cfargument name="test" type="boolean" default="false">

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

				<cfif arguments.type EQ "postcard">
					<cfhttp url="#application.paymentURL#/httppay_online.htm" method="post" userAgent="redjunky">
						<cfhttpparam type="formfield" name="orderuid" value="#arguments.orderId#">
						<cfhttpparam type="formfield" name="type" value="#uCase(arguments.type)#">
					</cfhttp>

					<cfwddx action="wddx2cfml" input="#cfhttp.filecontent#" output="local.response"></cfwddx>

					<cfreturn rep(response)>
				<cfelse>
					<cfhttp url="#application.paymentURL#/httppay_card.htm" method="post" userAgent="redjunky">
						<cfhttpparam type="formfield" name="orderuid" value="#arguments.orderId#">
						<cfhttpparam type="formfield" name="type" value="#uCase(arguments.type)#">
						<cfhttpparam type="formfield" name="cardnum" value="#arguments.cardnum#">
						<cfhttpparam type="formfield" name="cardmonth" value="#arguments.cardmonth#">
						<cfhttpparam type="formfield" name="cardyear" value="#arguments.cardyear#">
						<cfhttpparam type="formfield" name="cardname" value="#arguments.cardname#">
						<cfhttpparam type="formfield" name="test" value="#arguments.test#">
						<cfhttpparam type="formfield" name="lang" value="#sessionLang#">
					</cfhttp>

					<cfif isWDDX(cfhttp.filecontent)>
						<cfwddx action="wddx2cfml" input="#cfhttp.filecontent#" output="local.response"></cfwddx>
					<cfelse>
						<cfset var response = {}>
						<cfset response["status"] = "error">
						<cfset response["message"] = REReplaceNoCase(trim(cfhttp.filecontent), "<[^><]*>", '', 'ALL')>
					</cfif>

					<cfreturn rep(response)>
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