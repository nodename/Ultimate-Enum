package examples
{
	import com.nodename.utils.Enumeration;

	public class AnUnorderedEnum
	{
		Enumeration.registerClass(AnUnorderedEnum);
		
		[Enum] public static const A:AnUnorderedEnum = _();
		[Enum] public static const B:AnUnorderedEnum = _();
		[Enum] public static const C:AnUnorderedEnum = _();
		
		protected static const LOCK:Object = {};
		private static function _():AnUnorderedEnum
		{
			return new AnUnorderedEnum(LOCK);
		}
		
		public function AnUnorderedEnum(lock:Object)
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