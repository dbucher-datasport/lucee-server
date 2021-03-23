<cfcomponent extends="taffy.core.resource" taffy_uri="/payment/phone/{type}">

	<cffunction name="get">
		<cfargument name="orderUUID" type="string" required="true">
		<cfargument name="payuid" type="string" required="true">

		<cftry>
			<cfif structKeyExists(arguments, "sessionId")>

				<cfhttp url="https://secure.datasport.com/payresult/twint_monitorOrder.htm?u=#arguments.orderUUID#" method="get" userAgent="redjunky">
				</cfhttp>

				<cfset var xmlResponse = xmlParse(cfhttp.filecontent)>
				<cfset var status = xmlResponse.msg.xmlAttributes.status>

				<cfset var response = [:]>

				<cfset response["status"] = status>

				<cfif status EQ "completed">
					<cfset response["redirect"] = "https://secure.datasport.com/payresult/success.htm?twi=&payuid=#arguments.payuid#">
				<cfelseif status EQ "unfinished">
					<cfset response["redirect"] = "https://secure.datasport.com/payresult/failure.htm?twi=&payuid=#arguments.payuid#">
				</cfif>

				<cfreturn rep(response)>
			<cfelse>
				<cfreturn noData().withStatus(403)>
			</cfif>
			<cfcatch>
				<cfset application.common.informAdmin(message=cfcatch.message, data=cfcatch, subject="[Error] EMM API")>
				<cfreturn noData().withStatus(500)>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="post">
		<cfargument name="orderId" type="string" required="true">

		<cftry>
			<cfif structKeyExists(arguments, "sessionId")>

				<cfhttp url="#application.paymentURL#/httppay_phone.htm" method="post" userAgent="redjunky">
					<cfhttpparam type="formfield" name="orderuid" value="#arguments.orderId#">
					<cfhttpparam type="formfield" name="type" value="#uCase(arguments.type)#">
				</cfhttp>

				<cfwddx action="wddx2cfml" input="#cfhttp.filecontent#" output="local.response"></cfwddx>

				<cfreturn rep(response)>
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