<cfcomponent>

	<cffunction name="getBasketStruct" returntype="struct" output="false">
		<cfargument name="sessionId" type="string" required="true">

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

		<cfquery name="local.qBasket">
			SELECT *
			FROM basket
			WHERE client_session_id = <cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<cfset var totalAmount = 0>

		<cfset var stBasket = [:]>

		<cfquery name="local.qBasketParticipant">
			SELECT bp.*, c.name_#sessionLang# AS contest_name, e.name AS edition_name, e.date_from, e.date_to,
					sp.firstname, sp.lastname, sp.birthday, sp.gender, sp.nationality, sp.street1, sp.country, sp.city, sp.zip, sp.email
			FROM basket_participant bp
			INNER JOIN contest c ON c.contest_id = bp.contest_id
			INNER JOIN edition e ON e.edition_id = c.edition_id
			INNER JOIN session_participant sp ON sp.client_session_id = bp.client_session_id AND sp.participant_id = bp.participant_id
			WHERE bp.client_session_id = <cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<cfset stBasket["participants"] = []>

		<cfloop query="qBasketParticipant">
			<cfset var participant = [:]>
			<cfset participant.setMetadata({amount: "string"})>
			<cfset participant["participantId"] = participant_id>
			<cfset participant["firstname"] = firstname>
			<cfset participant["lastname"] = lastname>
			<cfset participant["birthday"] = lsDateFormat(birthday, "yyyy-mm-dd") & "T" & lsTimeFormat(birthday, "HH:mm:ss")>
			<cfset participant["gender"] = gender>
			<cfset participant["nationality"] = nationality>
			<cfset participant["street1"] = street1>
			<cfset participant["country"] = country>
			<cfset participant["city"] = city>
			<cfset participant["zip"] = zip>
			<cfset participant["email"] = email>
			<cfset participant["contest"] = [:]>
			<cfset participant["contest"].setMetadata({amount: "string"})>
			<cfset participant["contest"]["contestId"] = contest_id>
			<cfset participant["contest"]["contestName"] = contest_name>
			<cfset participant["contest"]["currency"] = currency>
			<cfset participant["contest"]["amount"] = lsNumberFormat(amount, ".00")>
			<cfset participant["contest"]["editionName"] = edition_name>
			<cfset participant["contest"]["editionDateFrom"] = lsDateFormat(date_from, "yyyy-mm-dd") & "T" & lsTimeFormat(date_from, "HH:mm:ss")>
			<cfset participant["contest"]["editionDateTo"] = isDate(date_to) ? lsDateFormat(date_to, "yyyy-mm-dd") & "T" & lsTimeFormat(date_to, "HH:mm:ss") : "">

			<!--- Options --->
			<cfquery name="local.qOption">
				SELECT *
				FROM basket_option
				WHERE client_session_id = <cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">
				AND participant_id = <cfqueryparam value="#participant_id#" cfsqltype="cf_sql_varchar">
				AND contest_id = <cfqueryparam value="#contest_id#" cfsqltype="cf_sql_integer">
			</cfquery>

			<cfset participant["options"] = [:]>
			<cfset participant["options"].setMetadata({amount: "string"})>
			<cfset participant["options"]["currency"] = "CHF">
			<cfset participant["options"]["items"] = []>

			<cfset var totalOptionAmount = 0>

			<cfloop query="qOption">
				<cfset totalOptionAmount += amount>
				<cfset var item = [:]>
				<cfset item.setMetadata({ amount: "string" })>
				<cfset item["key"] = option_key>
				<cfset item["value"] = option_value>
				<cfset item["currency"] = "CHF">
				<cfset item["amount"] = lsNumberFormat(amount, ".00")>
				<cfset arrayAppend(participant["options"]["items"], item)>
			</cfloop>
			<cfset participant["options"]["amount"] = lsNumberFormat(totalOptionAmount, ".00")>

			<!--- Shop --->
			<cfquery name="local.qShop">
				SELECT bs.*, es.name_#sessionLang# AS name, eso.name_#sessionLang# AS optionName
				FROM basket_shop bs
				INNER JOIN edition_shop es ON es.id = bs.shop_id
				LEFT JOIN edition_shop_option eso ON eso.shop_id = bs.shop_id AND eso.value = bs.option_value
				WHERE bs.client_session_id = <cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">
				AND bs.participant_id = <cfqueryparam value="#participant_id#" cfsqltype="cf_sql_varchar">
			</cfquery>

			<cfset participant["shop"] = [:]>
			<cfset participant["shop"].setMetadata({amount: "string"})>
			<cfset participant["shop"]["amount"] = "0.00">
			<cfset participant["shop"]["currency"] = "CHF">
			<cfset participant["shop"]["items"] = []>

			<cfset var totalShopAmount = 0>

			<cfloop query="qShop">
				<cfset totalShopAmount += total_amount>
				<cfset var shopItem = [:]>
				<cfset shopItem.setMetadata({ amount: "string", totalAmount: "string" })>
				<cfset shopItem["id"] = shop_id>
				<cfset shopItem["item"] = name>
				<cfset shopItem["option"] = optionName>
				<cfset shopItem["optionValue"] = option_value>
				<cfset shopItem["currency"] = currency>
				<cfset shopItem["amount"] = amount>
				<cfset shopItem["quantity"] = quantity>
				<cfset shopItem["totalAmount"] = total_amount>
				<cfset arrayAppend(participant["shop"]["items"], shopItem)>
			</cfloop>

			<cfset participant["shop"]["amount"] = lsNumberFormat(totalShopAmount, ".00")>

			<cfset participant["amount"] = lsNumberFormat(amount + totalOptionAmount + totalShopAmount, ".00")>
			<cfset participant["currency"] = "CHF">

			<cfset arrayAppend(stBasket["participants"], participant)>

			<cfset totalAmount += amount + totalOptionAmount + totalShopAmount>
		</cfloop>

		<!--- Delivery --->
		<cfquery name="local.qDelivery">
			SELECT bd.*, ed.currency, ed.amount, ed.title_#sessionLang# AS title
			FROM basket_delivery bd
			INNER JOIN edition_delivery ed ON ed.type = bd.type AND ed.edition_id = 1<!--- todo: edition id --->
			WHERE bd.client_session_id = <cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<cfif qDelivery.recordcount>
			<cfset stBasket["delivery"] = [:]>
			<cfset stBasket["delivery"].setMetadata({amount: "string"})>
			<cfset stBasket["delivery"]["type"] = qDelivery.type>
			<cfset stBasket["delivery"]["title"] = qDelivery.title>
			<cfset stBasket["delivery"]["name"] = qDelivery.name>
			<cfset stBasket["delivery"]["street"] = qDelivery.street>
			<cfset stBasket["delivery"]["zip"] = qDelivery.zip>
			<cfset stBasket["delivery"]["city"] = qDelivery.city>
			<cfset stBasket["delivery"]["country"] = qDelivery.country>
			<cfset stBasket["delivery"]["currency"] = qDelivery.currency>
			<cfset stBasket["delivery"]["amount"] = lsNumberFormat(qDelivery.amount, ".00")>
			<cfset totalAmount += qDelivery.amount>
		</cfif>

		<cfset stBasket.setMetadata({ totalAmount: "string" })>

		<cfset stBasket["currency"] = "CHF">
		<cfset stBasket["totalAmount"] = lsNumberFormat(totalAmount, ".00")>

		<cfreturn stBasket>
	</cffunction>

	<cffunction name="saveBasket" returntype="void" output="false">
		<cfargument name="sessionId" type="string" required="true">
		<cfargument name="currency" type="string" required="true">
		<cfargument name="totalAmount" type="numeric" required="true">

		<cfquery name="local.qBasket">
			SELECT *
			FROM basket
			WHERE client_session_id = <cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<cfif qBasket.recordcount>
			<cfquery>
				UPDATE basket
				SET currency = <cfqueryparam value="#arguments.currency#" cfsqltype="cf_sql_varchar">,
					amount = <cfqueryparam value="#arguments.totalAmount#" cfsqltype="cf_sql_decimal">,
					updated = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
				WHERE client_session_id = <cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">
			</cfquery>
		<cfelse>
			<cfquery>
				INSERT INTO basket (client_session_id, currency, amount, created, updated)
				VALUES (
					<cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.currency#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.totalAmount#" cfsqltype="cf_sql_decimal">,
					<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
					<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
				)
			</cfquery>
		</cfif>

	</cffunction>

	<cffunction name="generatePayID">

		<cfset var checkZiffer = 0>
		<cfset var helpMin = Minute(now())>
		<cfset var helpSec = Second(now())>
		<cfset var payID = "">

		<cfset payID &= Num2Hex(Year(now())-2000)>
		<cfset checkZiffer += Year(now())-2000>
		<cfset payID &= Num2Hex(Month(now()))>
		<cfset checkZiffer += Month(now())>
		<cfset payID &= Num2Hex(Day(now()))>
		<cfset checkZiffer += Day(now())>
		<cfset PayID &= ".">
		<cfset PayID &= Num2Hex(Hour(now()))>
		<cfset checkZiffer += Hour(now())>

		<cfif helpMin GT 30>
			<cfset payID &= Num2Hex(30)>
			<cfset checkZiffer += 30>
			<cfset payID &= Num2Hex(helpMin-30)>
			<cfset checkZiffer += helpMin-30>
		<cfelse>
			<cfset payID &= Num2Hex(0)>
			<cfset payID &= Num2Hex(helpMin)>
			<cfset checkZiffer += helpMin>
		</cfif>

		<cfif helpSec GT 30>
			<cfset payID &= Num2Hex(30)>
			<cfset checkZiffer += 30>
			<cfset payID &= Num2Hex(helpSec-30)>
			<cfset checkZiffer += helpSec-30>
		<cfelse>
			<cfset payID &= Num2Hex(0)>
			<cfset payID &= Num2Hex(helpSec)>
			<cfset checkZiffer += helpSec>
		</cfif>

		<cfset payID &= ".">
		<cfset var randNumber = RandRange(0, 30)>
		<cfset payID &= Num2Hex(randNumber)>
		<cfset checkZiffer += randNumber>
		<cfset payID &= Num2Hex(checkZiffer MOD 31)>

		<cfreturn payID>
	</cffunction>

	<cffunction name="Num2Hex" access="private" returntype="string" output="false">
		<cfargument name="para" type="string" required="true">

		<cfset var result = "">

		<cfscript>
			if(Para LTE 0) Result = "0";
			if(Para eq 1)  Result = "1";
			if(Para eq 2)  Result = "2";
			if(Para eq 3)  Result = "3";
			if(Para eq 4)  Result = "4";
			if(Para eq 5)  Result = "5";
			if(Para eq 6)  Result = "6";
			if(Para eq 7)  Result = "7";
			if(Para eq 8)  Result = "8";
			if(Para eq 9)  Result = "9";
			if(Para eq 10) Result = "A";
			if(Para eq 11) Result = "B";
			if(Para eq 12) Result = "C";
			if(Para eq 13) Result = "D";
			if(Para eq 14) Result = "E";
			if(Para eq 15) Result = "F";
			if(Para eq 16) Result = "G";
			if(Para eq 17) Result = "H";
			if(Para eq 18) Result = "J";
			if(Para eq 19) Result = "K";
			if(Para eq 20) Result = "M";
			if(Para eq 21) Result = "N";
			if(Para eq 22) Result = "P";
			if(Para eq 23) Result = "Q";
			if(Para eq 24) Result = "R";
			if(Para eq 25) Result = "S";
			if(Para eq 26) Result = "T";
			if(Para eq 27) Result = "U";
			if(Para eq 28) Result = "V";
			if(Para eq 29) Result = "X";
			if(Para eq 30) Result = "Y";
			if(Para eq 31) Result = "Z";
			if(Para GTE 32) Result = "-";
		</cfscript>

		<cfreturn result>
	</cffunction>

</cfcomponent>