<cfcomponent extends="taffy.core.resource" taffy_uri="/contests/{editionId}">

	<cffunction name="get" access="public" output="false">

		<!---
		<cfset var result = [:]>
		<cfset var jsonData = "">
		<cfset var fetchApi = false>
		<cfset var editionId = 6><!--- todo: arguments.editionId (real editionId) --->
		 --->

		<cftry>
			<cfif structKeyExists(arguments, "sessionId")>
				<!--- mock data --->
				<cfset var aContest = []>

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

				<cfquery name="local.qContest">
					SELECT *, name_#sessionLang# AS name
					FROM contest
				</cfquery>

				<cfloop query="qContest">
					<cfset var contest = [:]>
					<cfset contest["id"] = contest_id>
					<cfset contest["name"] = name>
					<cfset contest["dateFrom"] = isDate(date_from) ? lsDateFormat(date_from, "yyyy-mm-dd") & "T" & lsTimeFormat(date_from, "HH:mm:ss") : "">
					<cfset contest["dateTo"] = isDate(date_to) ? lsDateFormat(date_to, "yyyy-mm-dd") & "T" & lsTimeFormat(date_to, "HH:mm:ss") : "">

					<cfquery name="local.qCurrentPrice">
						SELECT *
						FROM contest_price
						WHERE contest_id = <cfqueryparam value="#contest_id#" cfsqltype="cf_sql_integer">
						AND (date_from is null OR date_from <= <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">)
						AND (date_to is null OR date_to >= <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">)
						ORDER BY date_from DESC
					</cfquery>

					<cfif qCurrentPrice.recordcount>
						<cfset contest["currentPrice"] = [:]>
						<cfset contest["currentPrice"]["amount"] = lsNumberFormat(qCurrentPrice.amount, ".00")>
						<cfset var amountType = {amount: "string"}>
						<cfset contest["currentPrice"].setMetadata(amountType)>
						<cfset contest["currentPrice"]["currency"] = qCurrentPrice.currency>
						<cfset contest["currentPrice"]["dateFrom"] = isDate(qCurrentPrice.date_from) ? lsDateFormat(qCurrentPrice.date_from, "yyyy-mm-dd") & "T" & lsTimeFormat(qCurrentPrice.date_from, "HH:mm:ss") : "">
						<cfset contest["currentPrice"]["dateTo"] = isDate(qCurrentPrice.date_to) ? lsDateFormat(qCurrentPrice.date_to, "yyyy-mm-dd") & "T" & lsTimeFormat(qCurrentPrice.date_to, "HH:mm:ss") : "">
						<cfset contest["currentPrice"]["ageFrom"] = qCurrentPrice.age_from>
						<cfset contest["currentPrice"]["ageTo"] = qCurrentPrice.age_to>
						<cfif currentrow EQ 1>
							<cfset contest["currentPrice"]["alternativeAmount"] = lsNumberFormat(qCurrentPrice.amount-10, ".00")>
							<cfset var alternativeAmountType = {alternativeAmount: "string"}>
							<cfset contest["currentPrice"].setMetadata(alternativeAmountType)>
							<cfset contest["currentPrice"]["alternativeAgeFrom"] = 7>
						<cfset contest["currentPrice"]["alternativeAgeTo"] = 9>
						</cfif>
					</cfif>

					<cfquery name="local.qFuturePrice">
						SELECT *
						FROM contest_price
						WHERE contest_id = <cfqueryparam value="#contest_id#" cfsqltype="cf_sql_integer">
						AND date_from >= <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
						ORDER BY date_from
					</cfquery>

					<cfif qFuturePrice.recordcount>
						<cfset contest["futurePrice"] = [:]>
						<cfset contest["futurePrice"]["amount"] = lsNumberFormat(qFuturePrice.amount, ".00")>
						<cfset var amountType = {amount: "string"}>
						<cfset contest["futurePrice"].setMetadata(amountType)>
						<cfset contest["futurePrice"]["currency"] = qFuturePrice.currency>
						<cfset contest["futurePrice"]["dateFrom"] = isDate(qFuturePrice.date_from) ? lsDateFormat(qFuturePrice.date_from, "yyyy-mm-dd") & "T" & lsTimeFormat(qFuturePrice.date_from, "HH:mm:ss") : "">
						<cfset contest["futurePrice"]["dateTo"] = isDate(qFuturePrice.date_to) ? lsDateFormat(qFuturePrice.date_to, "yyyy-mm-dd") & "T" & lsTimeFormat(qFuturePrice.date_to, "HH:mm:ss") : "">
						<cfset contest["futurePrice"]["ageFrom"] = qFuturePrice.age_from>
						<cfset contest["futurePrice"]["ageTo"] = qFuturePrice.age_to>
					</cfif>

					<cfquery name="local.qAttribute">
						SELECT *, label_#sessionLang# AS label
						FROM contest_attribute
						WHERE contest_id = <cfqueryparam value="#contest_id#" cfsqltype="cf_sql_integer">
					</cfquery>

					<cfset contest["attributes"] = []>

					<cfloop query="qAttribute">
						<cfset var attribute = [:]>
						<cfset attribute["key"] = key>
						<cfset attribute["label"] = label>
						<cfset attribute["value"] = value>
						<cfset arrayAppend(contest["attributes"], attribute)>
					</cfloop>

					<cfset arrayAppend(aContest, contest)>
				</cfloop>

				<cfreturn rep(aContest)>
			<cfelse>
				<cfreturn noData().withStatus(403)>
			</cfif>
			<!---
			<cfquery name="qEditionCache">
				SELECT *
				FROM cache_edition
				WHERE editionId = <cfqueryparam value="#editionId#" cfsqltype="cf_sql_integer">
			</cfquery>

			<cfif qEditionCache.recordcount>
				<!--- Caching 5 Minutes --->
				<cfif dateDiff("n", qEditionCache.updated, now()) GT 5>
					<cfset fetchApi = true>
				<cfelse>
					<cfset jsonData = deserializeJSON(qEditionCache.payload)>
				</cfif>
			<cfelse>
				<cfset fetchApi = true>
			</cfif>

			<cfif fetchApi>
				<!--- Get Data from Core --->
				<!--- todo: real editionId --->
				<cfhttp url="#application.coreURL#/api/onReg/edition/#editionId#" result="local.apiRequest"></cfhttp>
				<cfif apiRequest.statusCode EQ 200>
					<cfif qEditionCache.recordcount>
						<cfquery>
							UPDATE cache_edition
							SET payload = <cfqueryparam value="#apiRequest.filecontent#" cfsqltype="cf_sql_varchar">,
								updated = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
							WHERE editionId = <cfqueryparam value="#editionId#" cfsqltype="cf_sql_integer">
						</cfquery>
					<cfelse>
						<cfquery>
							INSERT INTO cache_edition (editionId, payload, created, updated)
							VALUES (
								<cfqueryparam value="#editionId#" cfsqltype="cf_sql_integer">,
								<cfqueryparam value="#apiRequest.filecontent#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
								<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
							)
						</cfquery>
					</cfif>
					<cfset jsonData = deserializeJSON(apiRequest.filecontent)>
				</cfif>
			</cfif>

			<cfif isStruct(jsonData)>
				<cfset var jsonEdition = jsonData.editionDTO>
				<cfset result["editionId"] = editionId>
				<cfset result["editionName"] = jsonEdition.name>
				<cfset result["editionDescription"] = jsonEdition.description>
				<cfset result["editionDateFrom"] = jsonEdition.executionFrom ?: "2020-10-14">
				<cfset result["editionDateTo"] = jsonEdition.executionTo ?: "2020-10-15">
				<cfset result["editionHeaderImage"] = "https://dummyimage.com/1089x937/000/fff">
				<cfset result["contests"] = []>
				<cfloop array="#jsonEdition.contests#" index="local.cItem">
					<cfset contest = [:]>
					<cfset contest["id"] = cItem.id>
					<cfset contest["name"] = cItem.name>
					<cfset contest["dateFrom"] = "2020-10-14">
					<cfset contest["dateTo"] = "2020-10-14">
					<!--- todo: real logic --->
					<cfset contest["currentPrice"] = [:]>
					<cfset contest["currentPrice"]["amount"] = cItem.prices[1].amount>
					<cfset contest["currentPrice"]["currency"] = cItem.prices[1].currency>
					<cfset contest["currentPrice"]["dateFrom"] = left(cItem.prices[1].dateFrom, 10)>
					<cfset contest["currentPrice"]["dateTo"] = left(cItem.prices[1].dateTo, 10)>
					<cfset contest["currentPrice"]["ageFrom"] = cItem.prices[1].ageFrom>
					<cfset contest["currentPrice"]["ageTo"] = cItem.prices[1].ageTo>
					<!--- todo: real logic --->
					<cfset contest["futurePrice"] = [:]>
					<cfset contest["futurePrice"]["amount"] = cItem.prices[2].amount>
					<cfset contest["futurePrice"]["currency"] = cItem.prices[2].currency>
					<cfset contest["futurePrice"]["dateFrom"] = left(cItem.prices[2].dateFrom, 10)>
					<cfset contest["futurePrice"]["dateTo"] = left(cItem.prices[2].dateTo, 10)>
					<cfset contest["futurePrice"]["ageFrom"] = cItem.prices[2].ageFrom>
					<cfset contest["futurePrice"]["ageTo"] = cItem.prices[2].ageTo>
					<cfset arrayAppend(result["contests"], contest)>
				</cfloop>
			</cfif>
			 --->
			<cfcatch>
				<cfdump var="#cfcatch#">
				<cfabort>
				<cfset application.common.informAdmin(message=cfcatch.message, data=cfcatch, subject="[Error] EMM API")>
				<cfreturn noData().withStatus(500)>
			</cfcatch>
		</cftry>

		<cfreturn rep(result)>
	</cffunction>

</cfcomponent>