<cfcomponent extends="taffy.core.resource" taffy_uri="/payment/online/{type}">

	<cffunction name="post">
		<cfargument name="orderId" type="string" required="true">

		<cftry>
			<cfif structKeyExists(arguments, "sessionId")>

				<cfhttp url="#application.paymentURL#/httppay_online.htm" method="post" userAgent="redjunky">
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