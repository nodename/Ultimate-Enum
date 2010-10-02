package examples
{
	import com.nodename.utils.Enumeration;

	public class AnEnum
	{
		[Enum(ordinal=1)] public static const B:AnEnum = _();
		[Enum(ordinal=2)] public static const C:AnEnum = _();
		[Enum(ordinal=0)] public static const A:AnEnum = _();
		[Enum] public static const D:AnEnum = _();
		
		public static const unenumeratedValue:AnEnum = _();
		public static const defaultValue:AnEnum = A;
		
		protected static const LOCK:Object = {};
		private static function _():AnEnum
		{
			return new AnEnum(LOCK);
		}

		public function AnEnum(lock:Object)
		{
			if (lock != LOCK)
			{
				throw new Error("illegal contructor access");
			}
		}
		
		// a default implementation of toString(), which returns "A" for A, etc.
		// of course you can choose another implementation
		public function toString():String
		{
			return Enumeration.nameOf(this);
		}
	}
}