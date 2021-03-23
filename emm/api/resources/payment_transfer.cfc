<cfcomponent extends="taffy.core.resource" taffy_uri="/payment/transfer/{type}">

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

				<cfset var stPayment = [:]>

				<cfif sessionLang EQ "de">
					<cfsavecontent variable="local.infotext"><b>Regelung für Geldüberweisungen</b><ol><li>Die Anmeldung / Bestellung wird erst nach dem Zahlungseingang ausgelöst.<br>Eine Geldüberweisung dauert von der Belastung auf Deinem Konto bis zur Gutschrift bei uns 3 Arbeitstage. <sup>1</sup><br>Die Geldüberweisung muss im Falle einer Anmeldung vor dem Meldeschluss eintreffen.</li><li>Die Geldüberweisung muss ab heute innerhalb von 4 Tagen ausgelöst werden.</li></ol><p><sup>1</sup> wir verarbeiten die Gutschriften, dank einer speziellen Anbindung an das Post/Banken-System, 1-3 Tage schneller als sonst üblich</p></cfsavecontent>
				<cfelseif sessionLang EQ "fr">
					<cfsavecontent variable="local.infotext"><b>Règlement pour les virements d'argent</b><ol><li>L'inscription / la commande est déclenchée seulement après réception du paiement.<br>Depuis le débit sur votre compte jusqu'au crédit chez nous, un virement d'argent dure 3 jours ouvrables. <sup>1</sup><br>En cas de virement pour une inscription, celui-ci doit arriver avant la clôture des inscriptions.</li><li>Le virement d'argent doit être effectué dans les 4 prochains jours à compter d'aujourd'hui.</li></ol><p><sup>1</sup> grâce à une connexion spéciale avec La Poste/système bancaire, nous pouvons traiter les avis de crédit 1 à 3 jours plus rapidement que d'habitude</p></cfsavecontent>
				<cfelseif sessionLang EQ "it">
					<cfsavecontent variable="local.infotext"><b>Regolamento per pagamenti</b><ol><li>L'iscrizione / l'ordinazione viene effettuata dopo aver ricevuto il pagamento.<br>Il trasferimento dei pagamenti dura di regola circa 3-4 giorni. <sup>1</sup><br>Concerne le iscrizioni, il pagamento deve essere in nostro possesso prima della chiusura delle stesse.</li><li>Il pagamento deve essere effettuato entro 4 giorni.</li></ol><p><sup>1</sup> trattiamo i vostri pagamenti, grazie ad un collegamento speciale al sistema della posta / banca, con 1-3 giorni di anticipo in confronto ai soliti termini</p></cfsavecontent>
				<cfelseif sessionLang EQ "en">
					<cfsavecontent variable="local.infotext"><b>Regulation for money transfers</b><ol><li>The registration/order is only released after the receipt of payment.<br>A money transfer takes 3 working days from the load on your account up to the credit note with us. <sup>1</sup><br>The money transfer must arrive in the case of a registration before the deadline.</li><li>The money transfer must be released from today on within 4 days.</li></ol><p><sup>1</sup> we process the credits, thanks to a special binding to the post / Bank-System, 1-3 days faster than usually</p></cfsavecontent>
				</cfif>

				<cfset stPayment["instruction"] = infotext>

				<cfreturn rep(stPayment)>
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
				<cfset var stPayment = [:]>
				<cfset stPayment.setMetadata({amount: "string"})>

				<cfif arguments.type EQ "transfer_ch">
					<cfset stPayment["recipient"] = "DATASPORT, CH-4563 Gerlafingen">
					<cfset stPayment["account"] = "01-51555-1">
				<cfelseif arguments.type EQ "transfer_eu" OR arguments.type EQ "transfer_de">
					<cfset stPayment["recipient"] = "DATASPORT, CH-4563 Gerlafingen">
					<cfset stPayment["iban"] = "DE 2966 0100 7500 1358 3752">
					<cfset stPayment["bic"] = "PBNK DEFF XXX">
					<cfset stPayment["bank"] = "Postbank, DE-Karlsruhe">
				</cfif>

				<cfhttp url="#application.paymentURL#/httppay_transfer.htm" method="post" userAgent="redjunky">
					<cfhttpparam type="formfield" name="orderuid" value="#arguments.orderId#">
					<cfhttpparam type="formfield" name="type" value="#uCase(arguments.type)#">
				</cfhttp>

				<cfset stPayment["currency"] = listGetAt(cfhttp.filecontent, 1)>
				<cfset stPayment["amount"] = listGetAt(cfhttp.filecontent, 2)>
				<cfif arguments.type EQ "transfer_eu">
					<cfset stPayment["referenceNumber"] = "+DRF" & listGetAt(cfhttp.filecontent, 3)>
				<cfelse>
					<cfset stPayment["referenceNumber"] = listGetAt(cfhttp.filecontent, 3)>
				</cfif>

				<cfreturn rep(stPayment)>
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