<cfcomponent extends="taffy.core.resource" taffy_uri="/basket/shop/">

	<cffunction name="post">
		<cfargument name="participantId" type="string" required="true">
		<cfargument name="shopId" type="numeric" required="true">
		<cfargument name="quantity" type="numeric" required="true">
		<cfargument name="option" type="string" required="true">

		<cftry>
			<cfif structKeyExists(arguments, "sessionId")>

				<cfif arguments.quantity EQ 0>
					<cfquery>
						DELETE FROM basket_shop
						WHERE client_session_id = <cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">
						AND participant_id = <cfqueryparam value="#arguments.participantId#" cfsqltype="cf_sql_varchar">
						AND shop_id = <cfqueryparam value="#arguments.shopId#" cfsqltype="cf_sql_integer">
						<cfif len(trim(arguments.option))>
							AND option_value = <cfqueryparam value="#arguments.option#" cfsqltype="cf_sql_varchar">
						</cfif>
					</cfquery>
				<cfelse>
					<cfquery name="local.qShop">
						SELECT *
						FROM edition_shop
						WHERE id = <cfqueryparam value="#arguments.shopId#" cfsqltype="cf_sql_integer">
					</cfquery>
					<cfif qShop.recordcount>
						<cfquery name="local.qBasketShop">
							SELECT *
							FROM basket_shop
							WHERE client_session_id = <cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">
							AND participant_id = <cfqueryparam value="#arguments.participantId#" cfsqltype="cf_sql_varchar">
							AND shop_id = <cfqueryparam value="#arguments.shopId#" cfsqltype="cf_sql_integer">
							<cfif len(trim(arguments.option))>
								AND option_value = <cfqueryparam value="#arguments.option#" cfsqltype="cf_sql_varchar">
							</cfif>
						</cfquery>
						<cfif qBasketShop.recordcount>
							<cfset var newQuantity = qBasketShop.quantity + arguments.quantity>
							<cfquery>
								UPDATE basket_shop
								SET currency = <cfqueryparam value="#qShop.currency#" cfsqltype="cf_sql_varchar">,
									amount = <cfqueryparam value="#qShop.amount#" cfsqltype="cf_sql_float">,
									quantity = <cfqueryparam value="#newQuantity#" cfsqltype="cf_sql_integer">,
									total_amount = <cfqueryparam value="#newQuantity * qShop.amount#" cfsqltype="cf_sql_float">,
									update_date = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
								WHERE client_session_id = <cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">
								AND participant_id = <cfqueryparam value="#arguments.participantId#" cfsqltype="cf_sql_varchar">
								AND shop_id = <cfqueryparam value="#arguments.shopId#" cfsqltype="cf_sql_integer">
								<cfif len(trim(arguments.option))>
									AND option_value = <cfqueryparam value="#arguments.option#" cfsqltype="cf_sql_varchar">
								</cfif>
							</cfquery>
						<cfelse>
							<cfquery>
								INSERT INTO basket_shop (client_session_id, participant_id, shop_id, option_value, currency, amount, quantity, total_amount, create_date)
								VALUES (
									<cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#arguments.participantId#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#arguments.shopId#" cfsqltype="cf_sql_integer">,
									<cfqueryparam value="#arguments.option#" cfsqltype="cf_sql_varchar" null="#not len(trim(arguments.option))#">,
									<cfqueryparam value="#qShop.currency#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#qShop.amount#" cfsqltype="cf_sql_float">,
									<cfqueryparam value="#arguments.quantity#" cfsqltype="cf_sql_integer">,
									<cfqueryparam value="#arguments.quantity * qShop.amount#" cfsqltype="cf_sql_float">,
									<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
								)
							</cfquery>
						</cfif>
					</cfif>
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

	<cffunction name="put">
		<cfargument name="participantId" type="string" required="true">
		<cfargument name="shopId" type="numeric" required="true">
		<cfargument name="quantity" type="numeric" required="true">
		<cfargument name="option" type="string" required="true">

		<cftry>
			<cfif structKeyExists(arguments, "sessionId")>

				<cfif arguments.quantity EQ 0>
					<cfquery>
						DELETE FROM basket_shop
						WHERE client_session_id = <cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">
						AND participant_id = <cfqueryparam value="#arguments.participantId#" cfsqltype="cf_sql_varchar">
						AND shop_id = <cfqueryparam value="#arguments.shopId#" cfsqltype="cf_sql_integer">
						<cfif len(trim(arguments.option))>
							AND option_value = <cfqueryparam value="#arguments.option#" cfsqltype="cf_sql_varchar">
						</cfif>
					</cfquery>
				<cfelse>
					<cfquery name="local.qShop">
						SELECT *
						FROM edition_shop
						WHERE id = <cfqueryparam value="#arguments.shopId#" cfsqltype="cf_sql_integer">
					</cfquery>
					<cfif qShop.recordcount>
						<cfquery name="local.qBasketShop">
							SELECT *
							FROM basket_shop
							WHERE client_session_id = <cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">
							AND participant_id = <cfqueryparam value="#arguments.participantId#" cfsqltype="cf_sql_varchar">
							AND shop_id = <cfqueryparam value="#arguments.shopId#" cfsqltype="cf_sql_integer">
							<cfif len(trim(arguments.option))>
								AND option_value = <cfqueryparam value="#arguments.option#" cfsqltype="cf_sql_varchar">
							</cfif>
						</cfquery>
						<cfif qBasketShop.recordcount>
							<cfquery>
								UPDATE basket_shop
								SET currency = <cfqueryparam value="#qShop.currency#" cfsqltype="cf_sql_varchar">,
									amount = <cfqueryparam value="#qShop.amount#" cfsqltype="cf_sql_float">,
									quantity = <cfqueryparam value="#arguments.quantity#" cfsqltype="cf_sql_integer">,
									total_amount = <cfqueryparam value="#arguments.quantity * qShop.amount#" cfsqltype="cf_sql_float">,
									update_date = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
								WHERE client_session_id = <cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">
								AND participant_id = <cfqueryparam value="#arguments.participantId#" cfsqltype="cf_sql_varchar">
								AND shop_id = <cfqueryparam value="#arguments.shopId#" cfsqltype="cf_sql_integer">
								<cfif len(trim(arguments.option))>
									AND option_value = <cfqueryparam value="#arguments.option#" cfsqltype="cf_sql_varchar">
								</cfif>
							</cfquery>
						<cfelse>
							<cfquery>
								INSERT INTO basket_shop (client_session_id, participant_id, shop_id, option_value, currency, amount, quantity, total_amount, create_date)
								VALUES (
									<cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#arguments.participantId#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#arguments.shopId#" cfsqltype="cf_sql_integer">,
									<cfqueryparam value="#arguments.option#" cfsqltype="cf_sql_varchar" null="#not len(trim(arguments.option))#">,
									<cfqueryparam value="#qShop.currency#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#qShop.amount#" cfsqltype="cf_sql_float">,
									<cfqueryparam value="#arguments.quantity#" cfsqltype="cf_sql_integer">,
									<cfqueryparam value="#arguments.quantity * qShop.amount#" cfsqltype="cf_sql_float">,
									<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
								)
							</cfquery>
						</cfif>
					</cfif>
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
		<cfargument name="shopId" type="numeric" required="true">
		<cfargument name="option" type="string" required="true">

		<cftry>
			<cfif structKeyExists(arguments, "sessionId")>
				<cfquery>
					DELETE FROM basket_shop
					WHERE client_session_id = <cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">
					AND participant_id = <cfqueryparam value="#arguments.participantId#" cfsqltype="cf_sql_varchar">
					AND shop_id = <cfqueryparam value="#arguments.shopId#" cfsqltype="cf_sql_integer">
					<cfif len(trim(arguments.option))>
						AND option_value = <cfqueryparam value="#arguments.option#" cfsqltype="cf_sql_varchar">
					</cfif>
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