<cfcomponent extends="taffy.core.resource" taffy_uri="/registrations/{editionID}/">

	<cffunction name="get" access="public" output="false">

		<cfset var registration = [:]>
		<cfset var apiRequest = "">
		<cfset var jsonData = "">
		<cfset var jsonEdition = "">
		<cfset var contest = "">
		<cfset var price = "">
		<cfset var category = "">
		<cfset var attribute = "">
		<cfset var fieldActive = "">
		<cfset var fieldRequired = "">
		<cfset var fetchApi = false>

		<cftry>
			<!--- todo: real editionId --->
			<cfquery name="qEditionCache">
				SELECT *
				FROM cache_edition
				WHERE editionId = 1
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
				<cfhttp url="#application.coreURL#/api/onReg/edition/1" result="apiRequest"></cfhttp>
				<cfif apiRequest.statusCode EQ 200>
					<cfif qEditionCache.recordcount>
						<cfquery>
							UPDATE cache_edition
							SET payload = <cfqueryparam value="#apiRequest.filecontent#" cfsqltype="cf_sql_varchar">,
								updated = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
							WHERE editionId = 1
						</cfquery>
					<cfelse>
						<cfquery>
							INSERT INTO cache_edition (editionId, payload, created, updated)
							VALUES (
								1,
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
				<cfset jsonEdition = jsonData.editionDTO>
				<cfset registration["editionId"] = jsonEdition.id>
				<cfset registration["editionName"] = jsonEdition.name>
				<cfset registration["eventId"] = jsonEdition.eventId>
				<cfset registration["editionDescription"] = jsonEdition.description>
				<cfset registration["rrRaceNr"] = jsonEdition.rrRaceNr>
				<cfset registration["editionYear"] = jsonEdition.year>
				<cfset registration["editionDateFrom"] = jsonEdition.executionFrom ?: "">
				<cfset registration["editionDateTo"] = jsonEdition.executionTo ?: "">
				<cfset registration["fields"] = [:]>
				<!--- Standard Fields --->
				<cfloop collection="#jsonEdition.standardAttributes#" item="local.sItem">
					<cfif structKeyExists(jsonEdition.standardAttributes, sItem) AND !isStruct(jsonEdition.standardAttributes[sItem])>
						<cfif listFind("YES_MANDATORY,YES_NOT_MANDATORY", jsonEdition.standardAttributes[sItem])>
							<cfset fieldActive = listFirst(jsonEdition.standardAttributes[sItem], "_")>
							<cfset fieldRequired = replace(jsonEdition.standardAttributes[sItem], fieldActive & "_", "")>
							<cfset registration["fields"][sItem] = [:]>
							<cfset registration["fields"][sItem]["active"] = fieldActive EQ "YES" ? true : false>
							<cfset registration["fields"][sItem]["required"] = fieldRequired EQ "MANDATORY" ? true : false>
						</cfif>
					</cfif>
				</cfloop>
				<!--- Contest --->
				<cfset registration["contest"] = []>
				<cfloop array="#jsonEdition.contests#" index="local.cItem">
					<cfset contest = [:]>
					<cfset contest["contestId"] = cItem.id>
					<cfset contest["contestName"] = cItem.name>
					<!--- Price --->
					<cfset contest["price"] = []>
					<cfloop array="#cItem.prices#" index="local.pItem">
						<cfset price = [:]>
						<cfset price["priceId"] = pItem.id>
						<cfset price["amount"] = pItem.amount>
						<cfset price["currency"] = pItem.currency>
						<cfset price["vatIncluded"] = pItem.vatIncluded>
						<cfset price["vatRate"] = pItem.vatRate>
						<cfset price["ageFrom"] = pItem.ageFrom>
						<cfset price["ageTo"] = pItem.ageTo>
						<cfset price["dateFrom"] = pItem.dateFrom>
						<cfset price["dateTo"] = pItem.dateTo>
						<cfset arrayAppend(contest["price"], price)>
					</cfloop>
					<!--- Category --->
					<cfset contest["category"] = []>
					<cfloop array="#cItem.categories#" index="local.catItem">
						<cfset category = [:]>
						<cfset category["categoryId"] = catItem.id>
						<cfset category["ageFrom"] = catItem.ageFrom>
						<cfset category["ageTo"] = catItem.ageTo>
						<cfset category["gender"] = catItem.gender>
						<cfset arrayAppend(contest["category"], category)>
					</cfloop>
					<!--- Attributes --->
					<cfset contest["attributes"] = []>
					<cfloop array="#jsonEdition.attributesDefinition#" index="local.attrItem">
						<cfif arrayFind(attrItem.contestIds, cItem.id)>
							<cfset attribute = [:]>
							<cfset attribute["attributeId"] = attrItem.id>
							<cfset attribute["type"] = attrItem.type>
							<cfset attribute["description"] = attrItem.description>
							<cfset attribute["shortDescription"] = attrItem.shortDescription>
							<cfset attribute["dropdownValue"] = attrItem.dropdownValue>
							<cfset attribute["decimals"] = attrItem.decimals>
							<cfset attribute["maxNumber"] = attrItem.maxNumber>
							<cfset attribute["minNumber"] = attrItem.minNumber>
							<cfset attribute["dependingId"] = attrItem.dependingId ?: 0>
							<cfset arrayAppend(contest["attributes"], attribute)>
						</cfif>
					</cfloop>
					<cfset arrayAppend(registration["contest"], contest)>
				</cfloop>
			</cfif>
			<cfcatch>
				<cfset application.common.informAdmin(message=cfcatch.message, data=cfcatch, subject="[Error] EMM API")>
				<cfreturn noData().withStatus(500)>
			</cfcatch>
		</cftry>

		<cfreturn rep(registration)>
	</cffunction>

</cfcomponent>