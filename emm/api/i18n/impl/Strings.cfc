import i18n.*;

component implements="i18n.ILocalizedStrings" {
	
	public ILocalizedStrings function init() {
		variables.strings = {};
		variables.unsupportedLocale = "A Supported locale is required when requesting an internationalized string.";	
		return this;
	}
	
	public string function getString(required string key, string locale) {
				
		if (!isNull(arguments.locale))
			var useLocale = arguments.locale;
		else if (!isNull(variables.defaultLocale))
			var useLocale = variables.defaultLocale;
		else
			throw(type="UnsupportedLocaleException", message=variables.unsupportedLocale);
			
		if (!structKeyExists(variables.strings, useLocale))
			throw(type="UnsupportedLocaleException", message=variables.unsupportedLocale);
			
		if (!structKeyExists(variables.strings[useLocale], arguments.key))
			throw(type="NoSuchStringException", message="String with key '#arguments.key#' does not exist.");
			
		var string = variables.strings[useLocale][arguments.key];
		
		// time to parameterize this string
		if (!refind("\{.+}", string, 1))
			return string;
			
		var params = rematch("(\{.*?\}\}?)", string);
		var i = 1;
		for (; i <= arrayLen(params); i++) {
			var param = params[i];
			var arg = rereplace(param, "\{|}", "", "all");
			string = replace(string, param, arguments[arg]);
		}
	
		return string;
	}
	
	public void function addString(required string key, required string locale, required string value) {
		variables.strings[trim(arguments.locale)][trim(arguments.key)] = trim(arguments.value);
	}
	
	public void function setDefaultLocale(required string locale) {
		variables.defaultLocale = arguments.locale;
	}
	
	public boolean function hasStrings() {
		return structCount(variables.strings);
	}

}