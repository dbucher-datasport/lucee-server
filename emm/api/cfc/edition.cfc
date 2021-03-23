<cfcomponent>

	<cffunction name="populateEdition" returntype="void" output="false">
		<cfargument name="editionID" type="numeric" required="true">
		<cfargument name="jsonEdition" type="struct" required="true">

		<cfset var stEdition = jsonEdition.editionDTO>
		<cfset var stOnRegConfig = stEdition.onRegConfig>

		<cfquery name="local.qCheckEdition">
			SELECT *
			FROM edition
			WHERE edition_id = <cfqueryparam value="#arguments.editionID#" cfsqltype="cf_sql_integer">
		</cfquery>

		<!--- Update --->
		<cfif qCheckEdition.recordcount>
			<cfif parseDateTime(qCheckEdition.timestamp_utc) NEQ parseDateTime(stOnRegConfig.changedDate)>
				<cfquery>
					UPDATE edition
					SET name = <cfqueryparam value="#stEdition.name#" cfsqltype="cf_sql_varchar">,
						date_from = <cfqueryparam value="#stEdition.executionFrom#" cfsqltype="cf_sql_date">,
						date_to = <cfqueryparam value="#stEdition.executionTo#" cfsqltype="cf_sql_date">,
						image_header = <cfqueryparam value="#stOnRegConfig.mainImage.logoUrl#" cfsqltype="cf_sql_varchar" null="#not structKeyExists(stOnRegConfig.mainImage, "logoUrl")#">,
						info_title_de = <cfqueryparam value="#stOnRegConfig.aboutEventTitle.de#" cfsqltype="cf_sql_varchar">,
						info_title_fr = <cfqueryparam value="#stOnRegConfig.aboutEventTitle.fr#" cfsqltype="cf_sql_varchar">,
						info_title_it = <cfqueryparam value="#stOnRegConfig.aboutEventTitle.it#" cfsqltype="cf_sql_varchar">,
						info_title_en = <cfqueryparam value="#stOnRegConfig.aboutEventTitle.en#" cfsqltype="cf_sql_varchar">,
						info_text_de = <cfqueryparam value="#stOnRegConfig.aboutEventText.de#" cfsqltype="cf_sql_varchar">,
						info_text_fr = <cfqueryparam value="#stOnRegConfig.aboutEventText.fr#" cfsqltype="cf_sql_varchar">,
						info_text_it = <cfqueryparam value="#stOnRegConfig.aboutEventText.it#" cfsqltype="cf_sql_varchar">,
						info_text_en = <cfqueryparam value="#stOnRegConfig.aboutEventText.en#" cfsqltype="cf_sql_varchar">,
						info_link = <cfqueryparam value="#stOnRegConfig.aboutEventUrl#" cfsqltype="cf_sql_varchar">,
						info_image1 = <cfqueryparam value="#stOnRegConfig.event1Image.logoUrl#" cfsqltype="cf_sql_varchar" null="#not structKeyExists(stOnRegConfig.event1Image, "logoUrl")#">,
						info_image2 = <cfqueryparam value="#stOnRegConfig.event2Image.logoUrl#" cfsqltype="cf_sql_varchar" null="#not structKeyExists(stOnRegConfig.event2Image, "logoUrl")#">,
						timestamp_utc = <cfqueryparam value="#stOnRegConfig.changedDate#" cfsqltype="cf_sql_timestamp">,
						edit_date = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
					WHERE edition_id = <cfqueryparam value="#arguments.editionID#" cfsqltype="cf_sql_integer">
				</cfquery>
			</cfif>
		<!--- Insert --->
		<cfelse>
			<cfquery>
				INSERT INTO edition (edition_id, name, date_from, date_to, image_header, info_title_de, info_title_fr, info_title_it, info_title_en, info_text_de, info_text_fr, info_text_it, info_text_en, info_link, info_image1, info_image2, timestamp_utc, create_date)
				VALUES (
					<cfqueryparam value="#arguments.editionID#" cfsqltype="cf_sql_integer">,
					<cfqueryparam value="#stEdition.name#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#stEdition.executionFrom#" cfsqltype="cf_sql_date">,
					<cfqueryparam value="#stEdition.executionTo#" cfsqltype="cf_sql_date">,
					<cfqueryparam value="#stOnRegConfig.mainImage.logoUrl#" cfsqltype="cf_sql_varchar" null="#not structKeyExists(stOnRegConfig.mainImage, "logoUrl")#">,
					<cfqueryparam value="#stOnRegConfig.aboutEventTitle.de#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#stOnRegConfig.aboutEventTitle.fr#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#stOnRegConfig.aboutEventTitle.it#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#stOnRegConfig.aboutEventTitle.en#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#stOnRegConfig.aboutEventText.de#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#stOnRegConfig.aboutEventText.fr#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#stOnRegConfig.aboutEventText.it#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#stOnRegConfig.aboutEventText.en#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#stOnRegConfig.aboutEventUrl#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#stOnRegConfig.event1Image.logoUrl#" cfsqltype="cf_sql_varchar" null="#not structKeyExists(stOnRegConfig.event1Image, "logoUrl")#">,
					<cfqueryparam value="#stOnRegConfig.event2Image.logoUrl#" cfsqltype="cf_sql_varchar" null="#not structKeyExists(stOnRegConfig.event2Image, "logoUrl")#">,
					<cfqueryparam value="#stOnRegConfig.changedDate#" cfsqltype="cf_sql_timestamp">,
					<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
				)
			</cfquery>
		</cfif>

	</cffunction>

	<cffunction name="populateStandardAttributes" returntype="void" output="false">
		<cfargument name="editionID" type="numeric" required="true">
		<cfargument name="jsonEdition" type="struct" required="true">

		<cfset var stEdition = jsonEdition.editionDTO>
		<cfset var standardAttributes = stEdition.standardAttributes>

		<cfquery name="local.qCheckAttributes">
			SELECT *
			FROM edition_attributes
			WHERE edition_id = <cfqueryparam value="#arguments.editionID#" cfsqltype="cf_sql_integer">
		</cfquery>

		<!--- Update --->
		<cfif qCheckAttributes.recordcount>
			<cfif parseDateTime(qCheckAttributes.timestamp_utc) NEQ parseDateTime(standardAttributes.changedDate)>
				<cfquery>
					UPDATE edition_attributes
					SET firstname = <cfqueryparam value="#standardAttributes.firstname#" cfsqltype="cf_sql_varchar">,
						lastname = <cfqueryparam value="#standardAttributes.lastname#" cfsqltype="cf_sql_varchar">,
						birthday = <cfqueryparam value="#standardAttributes.birthDate#" cfsqltype="cf_sql_varchar">,
						nationality = <cfqueryparam value="#standardAttributes.nation#" cfsqltype="cf_sql_varchar">,
						gender = <cfqueryparam value="#standardAttributes.gender#" cfsqltype="cf_sql_varchar">,
						address = <cfqueryparam value="#standardAttributes.addressLines#" cfsqltype="cf_sql_varchar">,
						zip = <cfqueryparam value="#standardAttributes.index#" cfsqltype="cf_sql_varchar">,
						location = <cfqueryparam value="#standardAttributes.locality#" cfsqltype="cf_sql_varchar">,
						country = <cfqueryparam value="#standardAttributes.countryISO#" cfsqltype="cf_sql_varchar">,
						email = <cfqueryparam value="#standardAttributes.email#" cfsqltype="cf_sql_varchar">,
						phone = <cfqueryparam value="#standardAttributes.phone#" cfsqltype="cf_sql_varchar">,
						timestamp_utc = <cfqueryparam value="#standardAttributes.changedDate#" cfsqltype="cf_sql_timestamp">,
						edit_date = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
					WHERE edition_id = <cfqueryparam value="#arguments.editionID#" cfsqltype="cf_sql_integer">
				</cfquery>
			</cfif>
		<!--- Insert --->
		<cfelse>
			<cfquery>
				INSERT INTO edition_attributes (edition_id, firstname, lastname, birthday, nationality, gender, address, zip, location, country, email, phone, timestamp_utc, create_date)
				VALUES (
					<cfqueryparam value="#arguments.editionID#" cfsqltype="cf_sql_integer">,
					<cfqueryparam value="#standardAttributes.firstname#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#standardAttributes.lastname#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#standardAttributes.birthDate#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#standardAttributes.nation#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#standardAttributes.gender#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#standardAttributes.addressLines#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#standardAttributes.index#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#standardAttributes.locality#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#standardAttributes.countryISO#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#standardAttributes.email#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#standardAttributes.phone#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#standardAttributes.changedDate#" cfsqltype="cf_sql_timestamp">,
					<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
				)
			</cfquery>
		</cfif>

	</cffunction>

</cfcomponent>