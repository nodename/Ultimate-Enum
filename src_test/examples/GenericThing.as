package examples
{
	import com.nodename.utils.Enumeration;
	
	public class GenericThing
	{
		Enumeration.registerClass(GenericThing);
		
		[Enum(ordinal=0)] public static const A:GenericThing = _("Small Thing");
		[Enum(ordinal=1)] public static const B:GenericThing = _("Medium Thing");
		[Enum(ordinal=2)] public static const C:GenericThing = _("Large Thing");
		[Enum] public static const D:GenericThing = _("Some Thing");
		
		public static const defaultValue:GenericThing = A;
		
		protected static const LOCK:Object = {};
		private static function _(stringValue:String):GenericThing
		{
			return new GenericThing(LOCK, stringValue);
		}
		
		private var _stringValue:String;
		
		public function GenericThing(lock:Object, stringValue:String)
		{
			if (lock != LOCK)
			{
				throw new Error("illegal contructor access");
			}
			_stringValue = stringValue;
		}
		
		public function toString():String
		{
			return _stringValue;
		}
	}
}