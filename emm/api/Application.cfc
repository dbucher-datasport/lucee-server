component extends="taffy.core.api" {
	abrot;
	this.name = "emmAPI";
	this.mappings['/taffy'] = expandPath('./taffy');
	this.sessionManagement = true;
	this.datasource = "reg3";

	variables.framework = {
		disableDashboard = false,
		reloadOnEveryRequest = true,
		allowCrossDomain = true,
		environments = {
			production = {
				disableDashboard = true,
				reloadOnEveryRequest = false
			}
		},
		exceptionLogAdapter = "taffy.bonus.LogToEmail",
		exceptionLogAdapterConfig = {
			emailFrom = "webapps@datasport.com",
			emailTo = "amarras@datasport.com",
			emailSubj = "[Error] EMM API",
			emailType = "html"
		}
	};

	function getEnvironment() {
		if (getHostname() == "vesuvioA-dev1") {
			return "development";
		} else {
			return "production";
		}
	}

	function onApplicationStart() {
		application.common = createObject('component', 'ds.common');

		import i18n.impl.*;
		import i18n.util.*;
		factory = new StringsFactory();
		application.strings = factory.getStrings(directory=expandPath("\emm\api\i18n\strings"), defaultLocale="de");

		application.oBasket = createObject("component", "cfc.basket");
		application.oEdition = createObject("component", "cfc.edition");

		include "config.cfm";

		return super.onApplicationStart();
	}

	function onRequestStart() {
		request.remoteIP = application.common.getRemoteIP();
		return super.onRequestStart();
    }

	function onTaffyRequest(verb, cfc, requestArguments, mimeExt, headers) {
		var serverRequest = '#createObject("java", "java.net.InetAddress").localhost.getCanonicalHostName()#:#iif(right(server.coldfusion.rootdir,1) eq "n", DE("1"), DE("#right(server.coldfusion.rootdir,1)#"))#';
		/* Log to Mail */
		cfmail( from="taffy@datasport.com", subject="[LOG] EMM API", to="vesuvio_log@datasport.com", type="html" ) {
			writeOutput('Server: #serverRequest#');
			writeOutput('<p>Timestamp: #now()#</p>');
			writeOutput('<p>Remote IP: <a href="http://www.iptools.ch/?ip=#request.remoteIP#">#request.remoteIP#</a></p>');
			writeOutput('<p>Client-Session-Id: #structKeyExists(arguments.headers, "X-Client-Session-Id") ? arguments.headers["X-Client-Session-Id"] : ""#</p>');
			writeOutput('<p>#arguments.verb# #arguments.requestArguments.endpoint#</p>');
			writeDump(var=requestArguments, label="requestArguments");
			writeOutput('<br><br>');
			writeDump(var=headers, label="Headers");
		}
		/* Log to DB */
		queryExecute("INSERT INTO log_emm_api (insertDate, verb, endpoint, arguments, requestIP, useragent, server, clientSessionId) VALUES (:insertDate, :verb, :endpoint, :arguments, :requestIP, :useragent, :server, :clientSessionId)",
			{
				insertDate = { value=now(), cfsqltype="timestamp"},
				verb = { value=arguments.verb, cfsqltype="varchar"},
				endpoint = { value=arguments.requestArguments.endpoint, cfsqltype="varchar"},
				arguments = { value=serializeJSON(arguments.requestArguments), cfsqltype="varchar"},
				requestIP = { value=request.remoteIP, cfsqltype="varchar"},
				useragent = { value=arguments.headers["user-agent"], cfsqltype="varchar"},
				server = { value=serverRequest, cfsqltype="varchar"},
				clientSessionId = { value=structKeyExists(arguments.headers, "X-Client-Session-Id") ? arguments.headers["X-Client-Session-Id"] : "" , cfsqltype="varchar"}
			},
			{datasource="reg3"}
		);

		if (structKeyExists(arguments.headers, "X-Client-Session-Id")) {
			requestArguments["sessionId"] = arguments.headers["X-Client-Session-Id"];
		}

		return true;
	}
}