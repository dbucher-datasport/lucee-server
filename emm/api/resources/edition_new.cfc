<cfcomponent extends="taffy.core.resource" taffy_uri="/edition_new/{editionID}">

	<cffunction name="get" access="public" output="false">
		<cfargument name="lang" type="string" default="de">

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

				<!--- Data from core --->
				<cfhttp url="#application.coreURL#/api/onReg/edition/#arguments.editionID#" method="GET" result="local.getEdition">
				</cfhttp>

				<cfif getEdition.statuscode EQ 200>
					<cfset var jsonEdition = deserializeJSON(getEdition.filecontent)>
					<cfset var stEdition = jsonEdition.editionDTO>
					<cfdump var="#jsonEdition#">
					<!--- <cfabort> --->

					<!--- Edition --->
					<cfset application.oEdition.populateEdition(arguments.editionID, jsonEdition)>

					<!--- Standard Attributes --->
					<cfset application.oEdition.populateStandardAttributes(arguments.editionID, jsonEdition)>

					<!--- Contest --->
					<cfset var aContest = stEdition.contests>

					<cfquery>
						DELETE FROM contest
						WHERE edition_id = <cfqueryparam value="#arguments.editionID#" cfsqltype="cf_sql_integer">
					</cfquery>

					<cfquery>
						DELETE FROM contest_price
						WHERE edition_id = <cfqueryparam value="#arguments.editionID#" cfsqltype="cf_sql_integer">
					</cfquery>

					<cfloop array="#aContest#" index="iContest">
						<cfquery>
							INSERT INTO contest (edition_id, contest_id, name, name_short, date_from, date_to, accuracy, altitude_down, altitude_up, distance, timestamp_utc, create_date)
							VALUES (
								<cfqueryparam value="#arguments.editionID#" cfsqltype="cf_sql_integer">,
								<cfqueryparam value="#iContest.id#" cfsqltype="cf_sql_integer">,
								<cfqueryparam value="#iContest.name#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#iContest.shortName#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#iContest.from#" cfsqltype="cf_sql_date">,
								<cfqueryparam value="#iContest.to#" cfsqltype="cf_sql_date">,
								<cfif arrayIsDefined(iContest.sections, 1) AND structKeyExists(iContest.sections[1], "accuracy")>
									<cfqueryparam value="#iContest.sections[1].accuracy#" cfsqltype="cf_sql_varchar">,
								<cfelse>
									NULL,
								</cfif>
								<cfif arrayIsDefined(iContest.sections, 1) AND structKeyExists(iContest.sections[1], "altitudeDown")>
									<cfqueryparam value="#iContest.sections[1].altitudeDown#" cfsqltype="cf_sql_integer">,
								<cfelse>
									NULL,
								</cfif>
								<cfif arrayIsDefined(iContest.sections, 1) AND structKeyExists(iContest.sections[1], "altitudeUp")>
									<cfqueryparam value="#iContest.sections[1].altitudeUp#" cfsqltype="cf_sql_integer">,
								<cfelse>
									NULL,
								</cfif>
								<cfif arrayIsDefined(iContest.sections, 1) AND structKeyExists(iContest.sections[1], "distance")>
									<cfqueryparam value="#iContest.sections[1].distance#" cfsqltype="cf_sql_integer">,
								<cfelse>
									NULL,
								</cfif>
								<cfqueryparam value="#iContest.changedDate#" cfsqltype="cf_sql_timestamp">,
								<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
							)
						</cfquery>

						<!--- Prices --->
						<cfset var aPrices = iContest.prices>

						<cfloop array="#aPrices#" index="local.iPrice">

							<cfloop array="#iPrice.contestPriceDefinitions#" index="local.iPriceDef">
								<cfquery>
									INSERT INTO contest_price (edition_id, contest_id, currency, amount, date_from, age_from, age_to, timestamp_utc, create_date)
									VALUES (
										<cfqueryparam value="#arguments.editionID#" cfsqltype="cf_sql_integer">,
										<cfqueryparam value="#iPrice.id#" cfsqltype="cf_sql_integer">,
										<cfqueryparam value="#iPriceDef.currencyIso#" cfsqltype="cf_sql_varchar">,
										<cfqueryparam value="#iPriceDef.price#" cfsqltype="cf_sql_float">,
										<cfqueryparam value="#iPrice.dateFrom#" cfsqltype="cf_sql_timestamp">,
										<cfif structKeyExists(iPrice, "ageFrom")>
											<cfqueryparam value="#iPrice.ageFrom#" cfsqltype="cf_sql_integer">,
										<cfelse>
											NULL,
										</cfif>
										<cfif structKeyExists(iPrice, "ageTo")>
											<cfqueryparam value="#iPrice.ageTo#" cfsqltype="cf_sql_integer">,
										<cfelse>
											NULL,
										</cfif>
										<cfqueryparam value="#iPrice.changedDate#" cfsqltype="cf_sql_timestamp">,
										<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
									)
								</cfquery>
							</cfloop>
						</cfloop>
					</cfloop>
				</cfif>

				<cfquery name="local.qEdition">
					SELECT *,
							description_#sessionLang# AS description,
							info_title_#sessionLang# AS info_title,
							info_text_#sessionLang# AS info_text,
							info_link_label_#sessionLang# AS info_link_label
					FROM edition
					WHERE edition_id = <cfqueryparam value="#arguments.editionID#" cfsqltype="cf_sql_integer">
				</cfquery>

				<cfset var edition = [:]>

				<cfloop query="qEdition">
					<cfset edition["editionID"] = edition_id>
					<cfset edition["name"] = name>
					<!--- <cfset edition["description"] = description> --->
					<cfset edition["dateFrom"] = lsDateFormat(date_from, "yyyy-mm-dd") & "T" & lsTimeFormat(date_from, "HH:mm:ss")>
					<cfset edition["dateTo"] = isDate(date_to) ? lsDateFormat(date_to, "yyyy-mm-dd") & "T" & lsTimeFormat(date_to, "HH:mm:ss") : "">
					<cfset edition["headerImage"] = image_header>
					<!--- <cfset edition["link"] = link> --->
					<cfset edition["info"] = [:]>
					<cfset edition["info"]["title"] = info_title>
					<cfset edition["info"]["text"] = info_text>
					<cfset edition["info"]["link"] = info_link>
					<cfset edition["info"]["linkLabel"] = info_link_label>
					<cfset edition["info"]["image1"] = info_image1>
					<cfset edition["info"]["image2"] = info_image2>
				</cfloop>

				<cfreturn rep(edition)>
			<cfelse>
				<cfreturn noData().withStatus(403)>
			</cfif>
			<cfcatch>
				<cfdump var="#cfcatch#">
				<cfdump var="#isDefined("iPrice.ageFrom")#">
				<cfdump var="#structKeyExists(iPrice, "ageFrom")#">
				<cfabort>
				<cfset application.common.informAdmin(message=cfcatch.message, data=cfcatch, subject="[Error] EMM API")>
				<cfreturn noData().withStatus(500)>
			</cfcatch>
		</cftry>

	</cffunction>

</cfcomponent>