<cfcomponent extends="taffy.core.resource" taffy_uri="/basket/checkout/">

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

				<cfset var payID = application.oBasket.generatePayID()>

				<cfquery name="local.payidCheck" datasource="reg2">
					SELECT *
					FROM waitPayment
					WHERE payid = <cfqueryparam value="#payID#" cfsqltype="cf_sql_varchar">
				</cfquery>

				<cfif payidCheck.RecordCount neq 0>
					<cfset payID = application.oBasket.generatePayID()>

					<cfquery name="local.payidCheck2" datasource=#dbSource#>
						SELECT *
						FROM waitPayment
						WHERE payid = <cfqueryparam value="#payID#" cfsqltype="cf_sql_varchar">
					</cfquery>

					<cfif payidCheck2.RecordCount neq 0>
						<cfset payID = application.oBasket.generatePayID()>
					</cfif>
				</cfif>

				<cfset var basket = application.oBasket.getBasketStruct(arguments.sessionId)>

				<cfwddx action="cfml2wddx" input="#basket#" output="local.basketWddx"></cfwddx>

				<cfquery datasource="reg2">
					INSERT INTO WaitPayment (PayID, PayTyp, userlang, DataDS, PayStatus, PayHist)
					VALUES (
						<cfqueryparam value="#payID#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="order_emm" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="DE" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#basketWddx#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="init" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#DateFormat(now(),"dd.mm.yyyy")#/#TimeFormat(now(),"HH:mm:ss")# init#chr(10)#" cfsqltype="cf_sql_varchar">
					)
				</cfquery>

				<!--- send data to payment gateway --->
				<cfhttp method="post" url="#application.paymentURL#/httporder.htm" userAgent="redjunky">
					<cfhttpparam name = "test" type = "FormField" value = "1">
					<cfhttpparam name="orderuser" type="FormField" value="u23qKk5VS">
					<cfhttpparam name="password" type="FormField" value="54jsBmLa">
					<cfhttpparam name="app" type="FormField" value="reg3">
					<cfhttpparam name="payid" type="FormField" value="#PayID#">
					<cfhttpparam name="currency" type="FormField" value="#basket.currency#">
					<cfhttpparam name="amount" type="FormField" value="#basket.totalAmount#">
					<cfhttpparam name="fee" type="FormField" value = "excl">
					<cfhttpparam name="lang" type="FormField" value="de">
					<cfhttpparam name="country" type="FormField" value="ch">
					<cfhttpparam name="usermail" type="FormField" value="amarras@datasport.com">

					<cfset var itemCounter = 0>
					<cfloop array="#basket.participants#" index="local.participant">
						<cfset itemCounter++>
						<cfset var itemDescription = '<b>#application.strings.getString("registration", sessionLang)# #participant.contest.editionName# - #lsDateFormat(participant.contest.editionDateFrom, "dd.mm.yyy")##isDate(participant.contest.editionDateTo) ? lsDateFormat(participant.contest.editionDateTo, "dd.mm.yyy") : ""#</b><br>'>
						<cfset itemDescription &= 'Person: #participant.firstname# #participant.lastname#, #lsDateFormat(participant.birthday, "dd.mm.yyyy")#, #left(participant.gender, 1)#, #participant.nationality#<br>'>
						<cfset itemDescription &= '#participant.street1#, #participant.country#-#participant.zip# #participant.city#<br>'>
						<cfset itemDescription &= '#participant.email#<br>'>
						<cfset itemDescription &= 'Wettbewerb: #participant.contest.contestName#<br>'>
						<cfhttpparam name="item#itemCounter#desctxt" type="FormField" value="#itemDescription#">
						<cfhttpparam name="item#itemCounter#currency" type="FormField" value="#participant.contest.currency#">
						<cfhttpparam name="item#itemCounter#amount" type="FormField" value="#participant.contest.amount#">
						<cfhttpparam name="item#itemCounter#backpipe" type="FormField" value="">
						<cfhttpparam name="item#itemCounter#deleteoption" type="FormField" value="0">
						<cfloop array="#participant.shop.items#" item="local.shopItem">
							<cfset itemCounter++>
							<cfset var shopItemDescription = '<b>Shop - #shopItem.item#</b><br>'>
							<cfif len(trim(shopItem.option))>
								<cfset shopItemDescription &= '#shopItem.option#<br>'>
							</cfif>
							<cfset shopItemDescription &= '#shopItem.quantity# x #shopItem.currency# #shopItem.amount#'>
							<cfhttpparam name="item#itemCounter#desctxt" type="FormField" value="#shopItemDescription#">
							<cfhttpparam name="item#itemCounter#currency" type="FormField" value="#shopItem.currency#">
							<cfhttpparam name="item#itemCounter#amount" type="FormField" value="#shopItem.totalAmount#">
							<cfhttpparam name="item#itemCounter#backpipe" type="FormField" value="">
							<cfhttpparam name="item#itemCounter#deleteoption" type="FormField" value="0">
						</cfloop>
					</cfloop>

					<cfif structKeyExists(basket, "delivery") AND basket.delivery.amount GT 0>
						<cfset itemCounter++>
						<cfset var deliveryDescription = '<b>#application.strings.getString("shippingCosts", sessionLang)#</b><br>'>
						<cfset deliveryDescription &= '#basket.delivery.title#:<br>'>
						<cfset deliveryDescription &= '#basket.delivery.name#<br>#basket.delivery.street#<br>#basket.delivery.country#-#basket.delivery.zip# #basket.delivery.city#'>
						<cfhttpparam name="item#itemCounter#desctxt" type="FormField" value="#deliveryDescription#">
						<cfhttpparam name="item#itemCounter#currency" type="FormField" value="#basket.delivery.currency#">
						<cfhttpparam name="item#itemCounter#amount" type="FormField" value="#basket.delivery.amount#">
						<cfhttpparam name="item#itemCounter#backpipe" type="FormField" value="">
						<cfhttpparam name="item#itemCounter#deleteoption" type="FormField" value="0">
					</cfif>
				</cfhttp>

				<cfset var xml = cfhttp.FileContent>
				<cfset xml = right(xml, len(xml)-Find("<reply>", xml)+1)>
				<cfset xml = left(xml, Find("</reply>", xml)+7)>

				<cfset var order1 = XmlParse(xml)>

				<cfif order1.reply.typ.xmltext eq "initerror" OR order1.reply.typ.xmltext eq "procerror">
					<cfreturn noData().withStatus(400)>
				<cfelseif order1.reply.typ.xmltext eq "redirect">
					<cfset var redirect["orderId"] = URLDecode(listGetAt(URLDecode(order1.reply.para1.xmltext), 4, "/"))>
					<cfreturn rep(redirect)>
				<cfelse>
					<cfreturn noData().withStatus(400)>
				</cfif>
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