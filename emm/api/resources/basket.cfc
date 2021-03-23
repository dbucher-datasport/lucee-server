<cfcomponent extends="taffy.core.resource" taffy_uri="/basket/">

	<cffunction name="get">

		<cftry>
			<cfif structKeyExists(arguments, "sessionId")>
				<cfset var basket = application.oBasket.getBasketStruct(arguments.sessionId)>
				<cfreturn rep(basket)>
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

	<cffunction name="post">
		<cfargument name="participantId" type="string" required="true">
		<cfargument name="contestId" type="numeric" required="true">

		<cftry>
			<cfif structKeyExists(arguments, "sessionId")>

				<!--- Check if participant already takes part --->
				<cfquery name="local.qParticipant">
					SELECT *
					FROM session_participant
					WHERE client_session_id = <cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">
					AND participant_id = <cfqueryparam value="#arguments.participantId#" cfsqltype="cf_sql_varchar">
				</cfquery>

				<cfif qParticipant.recordcount>
					<!--- check if participant already takes part in contest --->
					<cfset var aBody = []>
					<cfset var participant = [:]>

					<cfset participant["id"] = qParticipant.person_id>
					<cfset participant["firstName"] = qParticipant.firstname>
					<cfset participant["lastName"] = qParticipant.lastname>
					<cfset participant["birthDate"] = lsDateFormat(qParticipant.birthday, "yyyy-mm-dd")>
					<cfset participant["nationISO"] = qParticipant.nationality>
					<cfset participant["gender"] = left(qParticipant.gender, 1)>
					<cfset participant["participantContact"] = [:]>
					<cfset participant["participantContact"]["addressLines"] = qParticipant.street1>
					<cfset participant["participantContact"]["index"] = qParticipant.zip>
					<cfset participant["participantContact"]["locality"] = qParticipant.city>
					<cfset participant["participantContact"]["countryISO"] = qParticipant.country>
					<cfset participant["participantContact"]["language"] = "">
					<cfset participant["participantContact"]["phone"] = qParticipant.mobile>
					<cfset participant["participantContact"]["email"] = qParticipant.email>
					<cfset participant["onRegPersonId"] = qParticipant.participant_id>

					<cfset arrayAppend(aBody, participant)>

					<cfhttp method="post" url="#application.coreURL#/api/onReg/contest/#arguments.contestId#/checkParticipations" result="local.checkParticipant">
						<cfhttpparam type="header" name="Content-Type" value="application/json">
						<cfhttpparam type="body" value="#serializeJSON(aBody)#">
					</cfhttp>

					<cfif checkParticipant.statuscode EQ "200">
						<cfset var aResponse = deserializeJSON(checkParticipant.filecontent)>
						<cfif arrayFind(aResponse, arguments.participantId)>
							<cfreturn rep({"error": "participant already in contest"}).withStatus(400)>
						</cfif>
					</cfif>

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
						WHERE contest_id = <cfqueryparam value="#arguments.contestId#" cfsqltype="cf_sql_integer">
					</cfquery>

					<cfif qContest.recordcount>
						<cfquery name="local.qCurrentPrice">
							SELECT *
							FROM contest_price
							WHERE contest_id = <cfqueryparam value="#arguments.contestId#" cfsqltype="cf_sql_integer">
							AND (date_from is null OR date_from <= <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">)
							AND (date_to is null OR date_to >= <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">)
							ORDER BY date_from DESC
						</cfquery>

						<cfquery name="local.qCheckParticipant">
							SELECT *
							FROM basket_participant
							WHERE client_session_id = <cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">
							AND participant_id = <cfqueryparam value="#arguments.participantId#" cfsqltype="cf_sql_varchar">
						</cfquery>

						<cfif qCheckParticipant.recordcount>
							<cfquery>
								UPDATE basket_participant
								SET contest_id = <cfqueryparam value="#arguments.contestId#" cfsqltype="cf_sql_integer">,
									<cfif qCurrentPrice.recordcount>
										currency = <cfqueryparam value="#qCurrentPrice.currency#" cfsqltype="cf_sql_varchar">,
										amount = <cfqueryparam value="#qCurrentPrice.amount#" cfsqltype="cf_sql_decimal">,
									<cfelse>
										currency = 'CHF',
										amount = 0,
									</cfif>
									updated = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
								WHERE client_session_id = <cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">
								AND participant_id = <cfqueryparam value="#arguments.participantId#" cfsqltype="cf_sql_varchar">
							</cfquery>
						<cfelse>
							<cfquery>
								INSERT INTO basket_participant (client_session_id, participant_id, contest_id, currency, amount, created, updated)
								VALUES (
									<cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#arguments.participantId#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#arguments.contestId#" cfsqltype="cf_sql_integer">,
									<cfif qCurrentPrice.recordcount>
										<cfqueryparam value="#qCurrentPrice.currency#" cfsqltype="cf_sql_varchar">,
										<cfqueryparam value="#qCurrentPrice.amount#" cfsqltype="cf_sql_decimal">,
									<cfelse>
										'CHF',
										0,
									</cfif>
									<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
									<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
								)
							</cfquery>
						</cfif>
					</cfif>

					<!--- Get Basket Struct --->
					<cfset var basket = application.oBasket.getBasketStruct(arguments.sessionId)>

					<!--- Save Basket --->
					<cfset application.oBasket.saveBasket(arguments.sessionId, basket.currency, basket.totalAmount)>

					<cfreturn rep(basket)>
				<cfelse>
					<cfreturn rep({"error": "participant not found"}).withStatus(404)>
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

	<cffunction name="put">
		<cfargument name="participantId" type="string" required="true">
		<cfargument name="contestId" type="numeric" required="true">

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

				<cfquery name="local.qContest">
					SELECT *, name_#sessionLang# AS name
					FROM contest
					WHERE contest_id = <cfqueryparam value="#arguments.contestId#" cfsqltype="cf_sql_integer">
				</cfquery>

				<cfif qContest.recordcount>
					<cfquery name="local.qCurrentPrice">
						SELECT *
						FROM contest_price
						WHERE contest_id = <cfqueryparam value="#arguments.contestId#" cfsqltype="cf_sql_integer">
						AND (date_from is null OR date_from <= <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">)
						AND (date_to is null OR date_to >= <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">)
						ORDER BY date_from DESC
					</cfquery>

					<cfquery name="local.qCheckParticipant">
						SELECT *
						FROM basket_participant
						WHERE client_session_id = <cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">
						AND participant_id = <cfqueryparam value="#arguments.participantId#" cfsqltype="cf_sql_varchar">
					</cfquery>

					<cfif qCheckParticipant.recordcount>
						<cfquery>
							UPDATE basket_participant
							SET contest_id = <cfqueryparam value="#arguments.contestId#" cfsqltype="cf_sql_integer">,
								<cfif qCurrentPrice.recordcount>
									currency = <cfqueryparam value="#qCurrentPrice.currency#" cfsqltype="cf_sql_varchar">,
									amount = <cfqueryparam value="#qCurrentPrice.amount#" cfsqltype="cf_sql_decimal">,
								<cfelse>
									currency = 'CHF',
									amount = 0,
								</cfif>
								updated = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
							WHERE client_session_id = <cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">
							AND participant_id = <cfqueryparam value="#arguments.participantId#" cfsqltype="cf_sql_varchar">
						</cfquery>
					<cfelse>
						<cfquery>
							INSERT INTO basket_participant (client_session_id, participant_id, contest_id, currency, amount, created, updated)
							VALUES (
								<cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#arguments.participantId#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#arguments.contestId#" cfsqltype="cf_sql_integer">,
								<cfif qCurrentPrice.recordcount>
									<cfqueryparam value="#qCurrentPrice.currency#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#qCurrentPrice.amount#" cfsqltype="cf_sql_decimal">,
								<cfelse>
									'CHF',
									0,
								</cfif>
								<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
								<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
							)
						</cfquery>
					</cfif>

					<cfquery>
						DELETE FROM basket_option
						WHERE client_session_id = <cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">
						AND participant_id = <cfqueryparam value="#arguments.participantId#" cfsqltype="cf_sql_varchar">
					</cfquery>
				</cfif>

				<!--- Get Basket Struct --->
				<cfset var basket = application.oBasket.getBasketStruct(arguments.sessionId)>

				<!--- Save Basket --->
				<cfset application.oBasket.saveBasket(arguments.sessionId, basket.currency, basket.totalAmount)>

				<cfreturn rep(basket)>
			<cfelse>
				<cfreturn noData().withStatus(403)>
			</cfif>
			<cfcatch>
				<cfset application.common.informAdmin(message=cfcatch.message, data=cfcatch, subject="[Error] EMM API")>
				<cfreturn noData().withStatus(500)>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="delete">
		<cfargument name="participantId" type="string" required="true">
		<cfargument name="contestId" type="numeric" required="true">

		<cftry>
			<cfif structKeyExists(arguments, "sessionId")>

				<cfquery>
					DELETE FROM basket_participant
					WHERE client_session_id = <cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">
					AND participant_id = <cfqueryparam value="#arguments.participantId#" cfsqltype="cf_sql_varchar">
					AND contest_id = <cfqueryparam value="#arguments.contestId#" cfsqltype="cf_sql_integer">
				</cfquery>

				<cfquery>
					DELETE FROM basket_option
					WHERE client_session_id = <cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">
					AND participant_id = <cfqueryparam value="#arguments.participantId#" cfsqltype="cf_sql_varchar">
				</cfquery>

				<cfquery>
					DELETE FROM basket_shop
					WHERE client_session_id = <cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">
					AND participant_id = <cfqueryparam value="#arguments.participantId#" cfsqltype="cf_sql_varchar">
				</cfquery>

				<!--- Get Basket Struct --->
				<cfset var basket = application.oBasket.getBasketStruct(arguments.sessionId)>

				<!--- Save Basket --->
				<cfset application.oBasket.saveBasket(arguments.sessionId, basket.currency, basket.totalAmount)>

				<cfreturn rep(basket)>
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