interface {

	public string function getString(required string key, string locale);
	public void function addString(required string key, required string locale, required string value);
	public boolean function hasStrings();

}