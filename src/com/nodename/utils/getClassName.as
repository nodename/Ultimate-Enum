package com.nodename.utils
{
	import flash.utils.*;
	
	public function getClassName(o:Object):String
	{
		if (o is Class)
		{
			var s:String = o.toString();	// "[class SoAndSo]"
			return s.substring(7, s.length - 1);
		}
		else
		{
			var fullClassName:String = getQualifiedClassName(o);
			var i:int = fullClassName.lastIndexOf("::");
			if (i < 0)
			{
				return fullClassName;
			}
			return fullClassName.slice(i + 2);
		}
	}
	
}