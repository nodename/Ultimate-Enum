package examples
{
	import com.nodename.utils.Enumeration;
	public class ADerivedEnum extends AnEnum
	{
		Enumeration.registerClass(ADerivedEnum);
		
		[Enum(ordinal=1)] public static const A:ADerivedEnum = _("A");
		[Enum(ordinal=0)] public static const B:ADerivedEnum = _("B");
		
		private static function _(name:String):ADerivedEnum
		{
			return new ADerivedEnum(AnEnum.LOCK, name);
		}
		
		private var _name:String;
		
		public function ADerivedEnum(lock:Object, name:String)
		{
			super(lock);
			_name = name;
		}
	}
}