package com.nodename.utils
{
	import flash.utils.getDefinitionByName;
	/**
	 * @author alan
	 */
	public function getClassReference(qualifiedClassName:String):Class
{
	var classReference:Class = null;
	try
	{
		classReference = getDefinitionByName(qualifiedClassName) as Class;
	}
	catch (error:Error)
	{
		// do nothing
	}
	return classReference;
}
}
