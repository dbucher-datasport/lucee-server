import i18n.*;
import i18n.util.*;

component implements="i18n.IStringsFactory" {

	public IStringsFactory function init() {
		return this;
	}
	
	public ILocalizedStrings function getStrings(required string directory, required string defaultLocale) {
	
		if (!len(trim(arguments.directory))) {
			throw(type="InvalidDirectoryException", 
				message="Directory path used to initialize an instance of 
				LocalizedStrings cannot be an empty string");
		}
	
		var strings = new Strings();
		
		strings.setDefaultLocale(arguments.defaultLocale);
		
		var stringFiles = parseDirectory(path=arguments.directory);
		
		// iterate through each and add to the strings
		var i = 1;
		for (; i <= stringFiles.recordcount; i++) {
			var filePath = stringFiles.directory[i] & "\" & stringFiles.name[i];
			parseFile(path=filePath, strings=strings);	
		}
		
		if (!strings.hasStrings())
			throw(type="EmptyStringsInstance", message="LocalizedStrings instance is empty - and pretty much useless at this point.");
		
		return strings;
	}
	
	private void function parseFile(required string path, required ILocalizedStrings strings, string encoding="utf-8") {
		// grab locale based off of file name
		var fileName = listLast(arguments.path, "\");
		var fileName = createObject("java", "java.lang.String").init(fileName);
		var locale = fileName.split("\.(strings)");
		var file = fileOpen(arguments.path, "read", arguments.encoding);

		while (!fileIsEof(file)) {
			var line = fileReadLine(file);
			
			// skip empty lines
			if (!len(trim(line)))
				continue;
		
			var line = createObject("java", "java.lang.String").init(line);
			var key = line.split("\=(.+)");
			var value = line.split("(.*[^+])\=");
						
			strings.addString(locale=locale[1], key=key[1], value=value[2]);
		}

		fileClose(file);
	}
	
	private query function parseDirectory(required string path) {
	
		var reader = new DirectoryReader();
		var contents = reader.getContents(path=arguments.path, filter="*.strings");
	
		return contents;
	}

}