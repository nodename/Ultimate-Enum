package examples
{
	import com.nodename.utils.Enumeration;
	
	public class SpecialThing extends GenericThing
	{
		Enumeration.registerClass(SpecialThing);
		
		[Enum(ordinal=0)] public static const A:SpecialThing = _("Small Special Thing");
		[Enum(ordinal=1)] public static const B:SpecialThing = _("Medium Special Thing");
		[Enum(ordinal=2)] public static const C:SpecialThing = _("Large Special Thing");
		
		public static const defaultValue:SpecialThing = A;
		
		private static function _(stringValue:String):SpecialThing
		{
			return new SpecialThing(GenericThing.LOCK, stringValue);
		}
		
		public function SpecialThing(lock:Object, stringValue:String)
		{
			super(lock, stringValue);
		}
		
	}
}